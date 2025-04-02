# ---------------------------
# BASE RUBY IMAGE
# ---------------------------
FROM ruby:3.2.3-slim

# ---------------------------
# SETUP ENV & METADATA
# ---------------------------
ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    SITE_NAME=NightSpring \
    APP_NAME=NightSpring \
    APP_TITLE=NightSpring \
    HOSTNAME=nightspring.net \
    TZ=Etc/UTC

ARG UID=1000
ARG GID=1000
ARG NODE_MAJOR=16
ARG BUNDLER_VERSION=2.5.5

# ---------------------------
# INSTALL SYSTEM DEPENDENCIES
# ---------------------------
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  ca-certificates curl gnupg tzdata build-essential git \
  libpq-dev postgresql-client libxml2-dev libxslt1-dev \
  libmagickwand-dev imagemagick libidn11-dev libvips \
  && rm -rf /var/lib/apt/lists/*

# ---------------------------
# INSTALL NODE + YARN
# ---------------------------
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian stable main" > /etc/apt/sources.list.d/yarn.list \
 && mkdir -p /etc/apt/keyrings \
 && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
 && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
 && apt-get update -qq \
 && apt-get install -y --no-install-recommends nodejs yarn \
 && rm -rf /var/lib/apt/lists/*

# ---------------------------
# CREATE APP USER & FOLDERS
# ---------------------------
RUN addgroup --gid ${GID} app \
 && adduser --gecos "" --disabled-password --shell /bin/bash --uid ${UID} --gid ${GID} app \
 && mkdir -p /app /cache && chown -R app:app /app /cache

USER app:app
WORKDIR /app

# ---------------------------
# INSTALL BUNDLER & DEPENDENCIES
# ---------------------------
COPY Gemfile* ./
RUN gem install bundler:$BUNDLER_VERSION \
 && bundle config set without 'development test' \
 && bundle install --jobs=$(nproc)

# ---------------------------
# INSTALL YARN PACKAGES
# ---------------------------
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --production

# ---------------------------
# COPY APP SOURCE
# ---------------------------
COPY --chown=app:app . .

# Patch DB config if needed
RUN cp config/database.yml.postgres config/database.yml || true

# ---------------------------
# PRECOMPILE ASSETS
# ---------------------------
ARG SECRET_KEY_BASE=temporary_for_assets
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE

RUN bundle exec rails locale:generate \
 && bundle exec i18n export \
 && bundle exec rails assets:precompile

# ---------------------------
# FINAL SETTINGS
# ---------------------------
EXPOSE 3000
ENTRYPOINT ["entrypoint.sh"]
CMD ["rails", "server", "-b", "0.0.0.0"]
