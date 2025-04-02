FROM ruby:3.2.3

USER root

ARG UID=1000
ARG GID=1000
ARG NODE_MAJOR=20

# Set consistent timezone
ENV TZ=UTC

# Add Node.js and Yarn securely
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    curl gnupg2 ca-certificates lsb-release

RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list

# Install system dependencies
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential libpq-dev postgresql-client libxml2-dev libxslt1-dev \
    libmagickwand-dev imagemagick libidn11-dev tzdata \
    nodejs yarn git \
    && rm -rf /var/lib/apt/lists/*

# App directory
RUN mkdir -p /app /cache
WORKDIR /app

# Add app user
RUN addgroup --gid ${GID} app \
 && adduser --gecos "" --disabled-password --shell /bin/bash --uid ${UID} --gid ${GID} app \
 && chown -R app:app /app /cache

# Add entrypoint
COPY .docker/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

# Switch to non-root
USER app:app

# Install Ruby gems
COPY Gemfile* ./
RUN gem install bundler:2.5.5 \
 && bundle config set without 'development test' \
 && bundle install --jobs=$(nproc)

# Install JS packages
COPY package.json yarn.lock ./
RUN yarn install --immutable

# Copy the full app
COPY . .

# Port & boot
EXPOSE 3000
ENTRYPOINT ["entrypoint.sh"]
CMD ["rails", "server", "-b", "0.0.0.0"]
