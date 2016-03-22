#!/bin/bash

# Display settings on standard out.

USER="couchpotato"

echo "CouchPotato settings"
echo "=================="
echo
echo "  User:       ${USER}"
echo "  UID:        ${COUCHPOTATO_UID:=666}"
echo "  GID:        ${COUCHPOTATO_GID:=666}"
echo
echo "  DATADIR:    ${DATADIR:=/data/couchpotato}"
echo

# Change UID / GID of CouchPotato user.
printf "Updating couchpotato user... "
SBEARD=$(id -u couchpotato 2> /dev/null)
if [ $? -eq 0 ]; then
  if [ ${SBEARD} != ${COUCHPOTATO_UID} ]; then
    groupmod -u ${COUCHPOTATO_GID} ${USER}
    usermod -u ${COUCHPOTATO_UID} ${USER}
  fi
else
  groupadd -r -g ${COUCHPOTATO_GID} ${USER}
  useradd -r -u ${COUCHPOTATO_UID} -g ${COUCHPOTATO_GID} -d /couchpotato ${USER}
fi
echo "[DONE]"

if [ ! -d ${DATADIR} ]; then
  echo "[ERROR] Unable to find ${DATADIR}"
fi

# Update CouchPotato
# git runs as root,  fix permissions after
git -C /couchpotato pull

# Set directory permissions.
printf "Set permissions for /couchpotato... "
if [[ $(stat -c "%u" /couchpotato/) -ne ${COUCHPOTATO_UID} && \
      $(stat -c "%g" /couchpotato/) -ne ${COUCHPOTATO_GID} ]]; then
  chmod 2755 /couchpotato
  chown -R ${USER}: /couchpotato
fi
echo "[DONE]"

printf "Set permissions for ${DATADIR}... "
if [[ $(stat -c "%u" ${DATADIR}/) -ne ${COUCHPOTATO_UID} && \
      $(stat -c "%g" ${DATADIR}/) -ne ${COUCHPOTATO_GID} ]]; then
  chmod 2755 /couchpotato
  chown -R ${USER}: /couchpotato
  chown ${USER}: ${DATADIR}
fi
echo "[DONE]"


# Finally, start CouchPotato.
echo "Starting CouchPotato..."
exec su -pc "/couchpotato/CouchPotato.py --data_dir ${DATADIR}" ${USER}
