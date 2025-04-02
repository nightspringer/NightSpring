# ---------------------------
# STAGE 1: Builder
# ---------------------------
FROM ruby:3.2.3-slim AS builder

ARG BUNDLER_VERSION=2.5.5
ARG NODE_VERSION=16

ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV SITE_NAME=NightSpring
ENV APP_NAME=NightSpring
ENV APP_TITLE=NightSpring
ENV HOSTNAME=nightspring.net

# System dependencies (added libidn11-dev to fix idn-ruby build)
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  build-essential libpq-dev curl git libvips libcurl4-openssl-dev \
  libffi-dev nodejs yarn imagemagick tzdata libidn11-dev \
  && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Add Gemfiles and install bundler
COPY Gemfile* ./
RUN gem install bundler:$BUNDLER_VERSION \
 && bundle config set without 'development test' \
 && bundle install --jobs=$(nproc)

# Copy source code and install JS deps
COPY . .
RUN yarn install --frozen-lockfile

# Patch DB config (DO NOT overwrite app branding files)
RUN cp config/database.yml.postgres config/database.yml

# Asset & i18n precompile
ARG SECRET_KEY_BASE=temporary_for_assets
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE
RUN bundle exec rails locale:generate \
 && bundle exec i18n export \
 && bundle exec rails assets:precompile

# ---------------------------
# STAGE 2: Final Runtime Image
# ---------------------------
FROM ruby:3.2.3-slim

ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV SITE_NAME=NightSpring
ENV APP_NAME=NightSpring
ENV APP_TITLE=NightSpring
ENV HOSTNAME=nightspring.net

# # System packages
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  libpq5 libvips imagemagick curl git libidn12 \
  && rm -rf /var/lib/apt/lists/*

# Create app user and working dir
RUN useradd -m -d /app nightspring
WORKDIR /app

# Copy precompiled app and gems
COPY --from=builder /app /app
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Fix permissions
RUN chown -R nightspring:nightspring /app
USER nightspring

# Healthcheck for Render
HEALTHCHECK CMD curl -f http://localhost:$PORT || exit 1

EXPOSE 3000

# Final start command
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "$PORT"]
