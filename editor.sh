#!@BASH@
# shellcheck shell=bash

set -e
shopt -s nullglob

source "@WRAPPER_SCRIPT@"

function exec_editor() {
  exec "@EDITOR_BINARY@" @EDITOR_ARGS@ "$@"
}

FIRST_RUN="${XDG_CONFIG_HOME}/@FLAGFILE_PREFIX@-first-run"
SDK_UPDATE="${XDG_CONFIG_HOME}/@FLAGFILE_PREFIX@-sdk-update-@SDK_VERSION@"

if [ ! -f "${FIRST_RUN}" ]; then
  touch "${FIRST_RUN}"
  touch "${SDK_UPDATE}"
  exec_editor "$@" "@FIRST_RUN_README@"
elif [ ! -f "${SDK_UPDATE}" ]; then
  touch "${SDK_UPDATE}"
  exec_editor "$@" "@SDK_UPDATE_README@"
else
  exec_editor "$@"
fi

