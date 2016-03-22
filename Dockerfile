FROM debian:8
MAINTAINER Paul Roche 
# cloned from https://github.com/domibarton/docker-sickbeard

#
# Add CouchPotato startup script.
#

COPY assets/scripts/couchpotato.sh /opt/couchpotato.sh

#
# Install SickBeard and all required dependencies.
#

RUN apt-get -qq update \
    && apt-get install -yf curl            \
                           ca-certificates \
                           python-cheetah  \
                           python-openssl  \
                           git             \
    && apt-get -y autoremove               \
    && apt-get -y clean                    \
    && rm -rf /var/lib/apt/lists/*

RUN git clone git://github.com/CouchPotato/CouchPotatoServer.git /couchpotato

#
# Start CP.
#

ENTRYPOINT ["/opt/couchpotato.sh"]
