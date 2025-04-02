# ---------------------------
# STAGE 1: Builder
# ---------------------------
FROM ruby:3.2.3-slim AS builder

ARG BUNDLER_VERSION=2.5.5
ARG NODE_VERSION=20

ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV TZ=UTC
ENV SITE_NAME=NightSpring
ENV APP_NAME=NightSpring
ENV APP_TITLE=NightSpring
ENV HOSTNAME=nightspring.net

# Securely add Node.js 20 and Yarn repos
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  curl gnupg2 ca-certificates lsb-release

RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list

# Install full system build dependencies
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  build-essential libpq-dev libvips libcurl4-openssl-dev \
  libffi-dev nodejs yarn imagemagick tzdata libidn11-dev git \
  && rm -rf /var/lib/apt/lists/*

# App directory
WORKDIR /app

# Install bundler and gems
COPY Gemfile* ./
RUN gem install bundler:$BUNDLER_VERSION \
 && bundle config set without 'development test' \
 && bundle install --jobs=$(nproc)

# Copy app and install JS deps
COPY . .
RUN yarn install --immutable

# Patch database config safely
RUN cp config/database.yml.postgres config/database.yml || true

# Precompile assets only (skip locales)
ARG SECRET_KEY_BASE=temporary_for_assets
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE
RUN bundle exec rails assets:precompile

# ---------------------------
# STAGE 2: Runtime Image
# ---------------------------
FROM ruby:3.2.3-slim

ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV TZ=UTC
ENV SITE_NAME=NightSpring
ENV APP_NAME=NightSpring
ENV APP_TITLE=NightSpring
ENV HOSTNAME=nightspring.net

# Runtime dependencies only
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  libpq5 libvips imagemagick curl git libidn12 tzdata \
  && rm -rf /var/lib/apt/lists/*

# Create app user
RUN useradd -m -d /app nightspring
WORKDIR /app

# Copy built app and gems from builder
COPY --from=builder /app /app
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Ownership
RUN chown -R nightspring:nightspring /app
USER nightspring

# Healthcheck for Render
HEALTHCHECK CMD curl -f http://localhost:$PORT || exit 1

EXPOSE 3000

# Run the Rails app
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "$PORT"]
