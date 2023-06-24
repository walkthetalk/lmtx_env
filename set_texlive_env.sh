#!/usr/bin/env bash

# Author: Yi Qingliang
# this file is used for setting environment of the texlive.

if [ "$0" == "${BASH_SOURCE}" ]; then
        echo "ERROR: you need source this file, but not execute it directly!!!"
        exit 1
fi

# $1 is this script

# $2 is texlive main dir
if [ "$1" == "" ]; then
TL_MAIN_DIR="`readlink -fe "${BASH_SOURCE}" | xargs dirname`"
TL_MAIN_DIR="${TL_MAIN_DIR}/2023"
else
TL_MAIN_DIR="$1"
fi

if [ "$2" == "" ]; then
TL_FONT_DIR="/mnt/datum/iso/tex/fonts"
else
TL_FONT_DIR="$2"
fi

PATH=${TL_MAIN_DIR}/bin/x86_64-linux:$PATH; export PATH
MANPATH=${TL_MAIN_DIR}/texmf/doc/man:$MANPATH; export MANPATH
INFOPATH=${TL_MAIN_DIR}/texmf/doc/info:$INFOPATH; export INFOPATH
# on ArchLinux, the adobe font pkgs in aur will generate two dirs under
# /usr/share/fonts:
# adobe | Adobe
# but the context can only use the 'adobe', can't access 'Adobe'
# maybe the capital problem, context may ignored the 'Adobe',
# so we should put all Adobe fonts in another directory, and
# add it in the env var 'OSFONTDIR'.
MYFONTDIR="`find "${TL_FONT_DIR}" -type d|tr '\n' ';'`"
OSFONTDIR="${MYFONTDIR}:$OSFONTDIR"; export OSFONTDIR
