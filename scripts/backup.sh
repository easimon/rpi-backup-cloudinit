#!/bin/bash

set -euo pipefail

RSYNC_USER=ubuntu
RSYNC_HOST=backup.domain.com # or
RSYNC_HOST=123.123.123.123
RSYNC_SKIP_COMPRESS=3g2/3gp/3gpp/7z/aac/ace/amr/apk/appx/appxbundle/arc/arj/asf/avi/bz2/cab/crypt5/crypt7/crypt8/deb/dmg/drc/ear/gz/flac/flv/gpg/iso/jar/jp2/jpg/jpeg/lz/lzma/lzo/m4a/m4p/m4v/mkv/msi/mov/mp3/mp4/mpeg/mpg/mpv/oga/ogg/ogv/opus/png/qt/rar/rpm/rzip/s7z/sfx/svgz/tbz/tgz/tlz/txz/vob/wim/wma/wmv/xz/z/zip
RSYNC_INCLUDE_FILE=/etc/rsync-backup.include
RSYNC_EXCLUDE_FILE=/etc/rsync-backup.exclude

time rsync \
  -e 'ssh'
  --rsync-path='sudo rsync'
  --archive \
  --numeric-ids \
  --acls \
  --xattrs \
  --partial \
  --hard-links \
  --delete \
  --delete-excluded \
  --compress \
  --skip-compress="${RSYNC_SKIP_COMPRESS}" \
  --include-from="${RSYNC_INCLUDE_FILE}" \
  --exclude-from="${RSYNC_EXCLUDE_FILE}" \
  --stats \
  /mnt/snapshot/ \
  "${RSYNC_USER}@${RSYNC_HOST}:/mnt/backup-home/"

#  --sparse \
