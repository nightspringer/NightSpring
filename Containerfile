FROM ruby:3.2.3

USER root

ARG UID=1000
ARG GID=1000
ARG NODE_MAJOR=20
ARG BUNDLER_VERSION=2.5.5

ENV TZ=UTC
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV SITE_NAME=NightSpring
ENV APP_NAME=NightSpring
ENV APP_TITLE=NightSpring
ENV HOSTNAME=nightspring.net

# Install secure dependencies for Node and Yarn
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  curl gnupg2 ca-certificates lsb-release

RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list

# Install system dependencies
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  build-essential libpq-dev postgresql-client \
  libxml2-dev libxslt1-dev libmagickwand-dev imagemagick \
  libidn11-dev tzdata nodejs yarn git \
  && rm -rf /var/lib/apt/lists/*

# Create app directory
RUN mkdir -p /app /cache
WORKDIR /app

# Create and assign non-root user
RUN addgroup --gid ${GID} app \
 && adduser --gecos "" --disabled-password --shell /bin/bash --uid ${UID} --gid ${GID} app \
 && chown -R app:app /app /cache

# Add entrypoint
COPY .docker/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

# Install Ruby dependencies before copying full app (cache optimization)
COPY Gemfile Gemfile.lock ./
RUN gem install bundler:$BUNDLER_VERSION \
 && bundle config set without 'development test' \
 && bundle install --jobs=$(nproc)

# Install JavaScript packages
COPY package.json yarn.lock ./
RUN yarn install --immutable

# Copy full application source
COPY . .

# Remove non-English locales to reduce final image size
RUN find config/locales -type f ! -name '*.en.yml' -delete

# Set ownership again post-copy
RUN chown -R app:app /app

# Switch to app user for security
USER app:app

# Expose port and launch Rails
EXPOSE 3000
ENTRYPOINT ["entrypoint.sh"]
CMD ["rails", "server", "-b", "0.0.0.0"]
