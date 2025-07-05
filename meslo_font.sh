#!/bin/bash

DEST_DIR="/usr/local/share/fonts"

cp MesloLGSNerdFontMono-Regular.ttf $DESTDIR
fc-cache -fv

