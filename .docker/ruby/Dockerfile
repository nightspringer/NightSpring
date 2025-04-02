FROM ruby:3.2.3

USER root

ARG UID=1000
ARG GID=1000
ARG NODE_MAJOR=20

# Add Node.js and Yarn secure repos
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    curl gnupg2 ca-certificates lsb-release

# Add Node.js and Yarn secure repos
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list

# Install system dependencies
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential libpq-dev postgresql-client libxml2-dev libxslt1-dev \
    libmagickwand-dev imagemagick libidn11-dev tzdata \
    nodejs yarn git \
    && rm -rf /var/lib/apt/lists/*

# Set consistent timezone
ENV TZ=UTC

# App setup
RUN mkdir -p /app /cache
WORKDIR /app

# Create app user
RUN addgroup --gid ${GID} app \
 && adduser --gecos "" --disabled-password --shell /bin/bash --uid ${UID} --gid ${GID} app \
 && chown -R app:app /app /cache

# Entrypoint
COPY .docker/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

# Switch to app user
USER app:app

# Install Ruby gems
COPY Gemfile* ./
RUN gem install bundler:2.5.5 \
 && bundle config set without 'development test' \
 && bundle install --jobs=$(nproc)

# Install Node packages
COPY package.json yarn.lock ./
RUN yarn install --immutable

# Copy all source code
COPY . .

# Default command
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
