#!/bin/bash

case $TS_VERSION in
  LATEST)
    export TS_VERSION=`/get-version.sh`
    ;;
esac

cd /data

TARFILE=teamspeak3-server_linux_amd64-${TS_VERSION}.tar.bz2

download=0
if [ ! -e version ]; then
  download=1
else
  read version <version
  if [ "$version" != "$TS_VERSION" ]; then
    download=1
  fi
fi

if [ "$download" -eq 1 ]; then
  echo "Downloading ${TARFILE} ..."
  wget -q http://dl.4players.de/ts/releases/${TS_VERSION}/${TARFILE} \
  && tar -j -x -f ${TARFILE} --strip-components=1 \
  && rm -f ${TARFILE} \
  && echo $TS_VERSION >version
fi

export LD_LIBRARY_PATH=".:/data:/data/redist"

TS3ARGS=""
if [ -e /data/ts3server.ini ]; then
  TS3ARGS="inifile=/data/ts3server.ini"
else
  TS3ARGS="createinifile=1"
fi

if [ -n "$SERVERADMIN_PASSWORD" ]; then
  TS3ARGS="$TS3ARGS serveradmin_password=$SERVERADMIN_PASSWORD"
fi

if [ "accept" = "$TS3SERVER_LICENSE" ]; then
  TS3ARGS="$TS3ARGS license_accepted=1"
  touch /data/.ts3server_license_accepted
fi

exec ./ts3server $TS3ARGS

