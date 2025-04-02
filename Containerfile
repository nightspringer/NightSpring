# ---------------------------
# STAGE 1: Builder
# ---------------------------
FROM ruby:3.2.3-slim AS builder

ARG BUNDLER_VERSION=2.5.5
ARG NODE_VERSION=16

ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    TZ=UTC \
    SITE_NAME=NightSpring \
    APP_NAME=NightSpring \
    APP_TITLE=NightSpring \
    HOSTNAME=nightspring.net

# Add secure Node.js & Yarn repos
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  curl gnupg2 ca-certificates lsb-release

RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian stable main" > /etc/apt/sources.list.d/yarn.list

# System deps
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  build-essential libpq-dev libvips libcurl4-openssl-dev \
  libffi-dev nodejs yarn imagemagick tzdata libidn11-dev \
  && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install gems
COPY Gemfile* ./
RUN gem install bundler:$BUNDLER_VERSION \
 && bundle config set without 'development test' \
 && bundle install --jobs=$(nproc)

# Copy full source + install JS
COPY . .
RUN yarn install --frozen-lockfile

# Copy default DB config if missing
RUN cp config/database.yml.postgres config/database.yml || true

# Precompile assets and export locales
ARG SECRET_KEY_BASE=temporary_for_assets
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE
RUN bundle exec rails locale:generate \
 && bundle exec i18n export \
 && bundle exec rails assets:precompile

# ---------------------------
# STAGE 2: Final Runtime Image
# ---------------------------
FROM ruby:3.2.3-slim

ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    TZ=UTC \
    SITE_NAME=NightSpring \
    APP_NAME=NightSpring \
    APP_TITLE=NightSpring \
    HOSTNAME=nightspring.net

# Runtime dependencies
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  libpq5 libvips imagemagick curl git libidn12 tzdata \
  && rm -rf /var/lib/apt/lists/*

# Create app user and working dir
RUN useradd -m -d /app nightspring
WORKDIR /app

# Copy app and gems
COPY --from=builder /app /app
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Permissions
RUN chown -R nightspring:nightspring /app
USER nightspring

# Healthcheck for Render
HEALTHCHECK CMD curl -f http://localhost:$PORT || exit 1

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "$PORT"]
