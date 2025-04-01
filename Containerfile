# Base image
# Base image
FROM registry.opensuse.org/opensuse/leap:15.5

LABEL org.opencontainers.image.title="NightSpring (production)"
LABEL org.opencontainers.image.description="Image to run NightSpring in production."
LABEL org.opencontainers.image.vendor="NightSpring"
LABEL org.opencontainers.image.url="https://nightspring.net"

ARG RUBY_VERSION=3.2.3
ARG RUBY_INSTALL_VERSION=0.9.3
ARG BUNDLER_VERSION=2.5.5

ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true

# Dependencies
RUN zypper addrepo https://download.opensuse.org/repositories/devel:languages:nodejs/15.5/devel:languages:nodejs.repo \
 && zypper --gpg-auto-import-keys refresh \
 && zypper install -y \
    automake gcc gdbm-devel gzip libffi-devel libopenssl-devel libyaml-devel \
    jemalloc-devel make ncurses-devel readline-devel tar xz zlib-devel curl \
    gcc-c++ git libidn-devel nodejs16 npm16 postgresql-devel ImageMagick \
 && zypper clean -a \
 && npm install -g yarn

# Ruby
RUN curl -Lo ruby-install-${RUBY_INSTALL_VERSION}.tar.gz https://github.com/postmodern/ruby-install/archive/v${RUBY_INSTALL_VERSION}.tar.gz \
 && tar xvf ruby-install-${RUBY_INSTALL_VERSION}.tar.gz \
 && (cd ruby-install-${RUBY_INSTALL_VERSION} && make install) \
 && ruby-install --no-install-deps --cleanup --system ruby ${RUBY_VERSION} -- --disable-install-rdoc --with-jemalloc \
 && gem install bundler:${BUNDLER_VERSION}

# App setup
RUN useradd -m nightspring \
 && install -o nightspring -g users -d /opt/nightspring/app \
 && install -o nightspring -g users -d /opt/nightspring/bundle

WORKDIR /opt/nightspring/app
USER nightspring:users

COPY . .

# Create writable dirs (Render-safe)
RUN mkdir -p tmp log

# Install
RUN bundle config set without 'development test' \
 && bundle config set path '/opt/nightspring/bundle' \
 && bundle install --jobs=$(nproc) \
 && yarn install --frozen-lockfile

# TEMP key for assets
ARG SECRET_KEY_BASE=temporary_for_assets

RUN bundle exec rails locale:generate \
 && bundle exec i18n export \
 && bundle exec rails assets:precompile

EXPOSE 3000

CMD bundle exec rails server -b 0.0.0.0 -p $PORT
