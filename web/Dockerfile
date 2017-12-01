FROM ruby:2.3.4

ENV APP_HOME /usr/app
ENV BUILD_PACKAGES bash build-essential cmake curl libxml2-dev libxslt1-dev libicu-dev nginx nodejs unzip vim

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get update -qq && \
    apt-get install -y $BUILD_PACKAGES --force-yes && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir $APP_HOME && \
    mkdir $APP_HOME/tmp && \
    mkdir $APP_HOME/log && \
    gem install bundler && \
    npm install -g yarn && \
    curl -L https://raw.githubusercontent.com/dockito/vault/master/ONVAULT > /usr/local/bin/ONVAULT && \
    chmod +x /usr/local/bin/ONVAULT

WORKDIR $APP_HOME

COPY src/Gemfile Gemfile
COPY src/Gemfile.lock Gemfile.lock

ADD src/vendor/gems/ vendor/gems/

# Use ONVAULT for save ssh keys usage
ARG VAULT_HOST
RUN ONVAULT bash -c "bundle check || bundle install --jobs 20 --retry 5 --without development test"

# Copy app
ADD src $APP_HOME/

# Copy configs
ADD configs/*.yml $APP_HOME/config/
ADD configs/nginx.conf /etc/nginx/sites-available/default

# Create space for unicorn socket
RUN mkdir /var/sockets

# Generate self-signed certificate
RUN mkdir /etc/nginx/ssl && \
    openssl genrsa -des3 -passout pass:x -out /etc/nginx/ssl/platform-os.pass.key 2048 && \
    openssl rsa -passin pass:x -in /etc/nginx/ssl/platform-os.pass.key -out /etc/nginx/ssl/platform-os.key && \
    rm /etc/nginx/ssl/platform-os.pass.key && \
    openssl req -new -key /etc/nginx/ssl/platform-os.key -out /etc/nginx/ssl/platform-os.csr -subj "/C=US/ST=California/L=Leamington/O=PlatformOS/OU=IT Department/CN=near-me.com" && \
    openssl x509 -req -days 365 -in /etc/nginx/ssl/platform-os.csr -signkey /etc/nginx/ssl/platform-os.key -out /etc/nginx/ssl/platform-os.crt

ADD docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
