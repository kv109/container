FROM aidanlister/postgres-hstore

ENV BUILD_PACKAGES python3-pip wget

RUN apt-get update -qq && \
    apt-get install -y $BUILD_PACKAGES --force-yes && \
    rm -rf /var/lib/apt/lists/* && \
    pip3 install awscli --upgrade --user && \
    chmod +x ~/.local/bin/aws && \
    ln -nfs ~/.local/bin/aws /usr/bin/

ADD scripts /scripts
RUN chmod -R +x /scripts
ADD init.sh /docker-entrypoint-initdb.d/init.sh
