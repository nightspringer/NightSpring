# Base image
FROM registry.opensuse.org/opensuse/leap:15.5

LABEL org.opencontainers.image.title="Retrospring (production)"
LABEL org.opencontainers.image.description="Image containing everything to run Retrospring in production mode."
LABEL org.opencontainers.image.vendor="The Retrospring team"
LABEL org.opencontainers.image.url="https://github.com/Retrospring/retrospring"

ARG RETROSPRING_VERSION=2023.0131.1
ARG RUBY_VERSION=3.2.3
ARG RUBY_INSTALL_VERSION=0.9.3
ARG BUNDLER_VERSION=2.5.5

ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true

# Install dependencies
RUN zypper addrepo https://download.opensuse.org/repositories/devel:languages:nodejs/15.5/devel:languages:nodejs.repo \
 && zypper --gpg-auto-import-keys up -y \
 && zypper in -y \
      automake gcc gdbm-devel gzip libffi-devel libopenssl-devel libyaml-devel \
      jemalloc-devel make ncurses-devel readline-devel tar xz zlib-devel curl \
      gcc-c++ git libidn-devel nodejs16 npm16 postgresql-devel ImageMagick \
 && zypper clean -a \
 && npm install -g yarn

# Install Ruby
RUN curl -Lo ruby-install-${RUBY_INSTALL_VERSION}.tar.gz https://github.com/postmodern/ruby-install/archive/v${RUBY_INSTALL_VERSION}.tar.gz \
 && tar xvf ruby-install-${RUBY_INSTALL_VERSION}.tar.gz \
 && (cd ruby-install-${RUBY_INSTALL_VERSION} && make install) \
 && rm -rf ruby-install-${RUBY_INSTALL_VERSION} ruby-install-${RUBY_INSTALL_VERSION}.tar.gz \
 && ruby-install --no-install-deps --cleanup --system --jobs=$(nproc) ruby ${RUBY_VERSION} -- --disable-install-rdoc --with-jemalloc \
 && gem install bundler:${BUNDLER_VERSION}

# Create user and app dirs
RUN useradd -m justask \
 && install -o justask -g users -m 0755 -d /opt/retrospring/app \
 && install -o justask -g users -m 0755 -d /opt/retrospring/bundle

WORKDIR /opt/retrospring/app
USER justask:users

# Download app source
RUN curl -L https://github.com/Retrospring/retrospring/archive/${RETROSPRING_VERSION}.tar.gz | tar xz --strip-components=1

# Install Ruby & Node packages
RUN bundle config set without 'development test' \
 && bundle config set path '/opt/retrospring/bundle' \
 && bundle install --jobs=$(nproc) \
 && yarn install --frozen-lockfile

# TEMP secret for build assets
ARG SECRET_KEY_BASE=secret_for_build

# Copy config files and precompile assets
RUN cp config/justask.yml.example config/justask.yml \
 && cp config/database.yml.postgres config/database.yml \
 && bundle exec rails locale:generate \
 && bundle exec i18n export \
 && bundle exec rails assets:precompile \
 && rm config/database.yml

EXPOSE 3000

# Final command: run app with correct PORT
CMD bundle exec rails server -b 0.0.0.0 -p $PORT
