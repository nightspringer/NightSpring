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

# Securely install Node.js and Yarn
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

# Create application directories
RUN mkdir -p /app /cache
WORKDIR /app

# Create non-root user
RUN addgroup --gid ${GID} app \
 && adduser --gecos "" --disabled-password --shell /bin/bash --uid ${UID} --gid ${GID} app \
 && chown -R app:app /app /cache

# Add entrypoint
COPY .docker/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

# Install Ruby dependencies
COPY Gemfile* ./
RUN gem install bundler:$BUNDLER_VERSION \
 && bundle config set without 'development test' \
 && bundle install --jobs=$(nproc)

# Install JS dependencies
COPY package.json yarn.lock ./
RUN yarn install --immutable

# Copy application code
COPY . .

# Clean up non-English locales (optional)
RUN find config/locales -type f ! -name '*.en.yml' -delete

# Ensure permissions
RUN chown -R app:app /app

# Switch to non-root for safety
USER app:app

# Set exposed port and boot command
EXPOSE 3000
ENTRYPOINT ["entrypoint.sh"]
CMD ["rails", "server", "-b", "0.0.0.0"]
