#!@BASH@
# shellcheck shell=bash

set -e
shopt -s nullglob

FIRST_RUN="${XDG_CONFIG_HOME}/@FLAGFILE_PREFIX@-first-run"
SDK_UPDATE="${XDG_CONFIG_HOME}/@FLAGFILE_PREFIX@-sdk-update-@SDK_VERSION@"

function display_server_args (){
  # See https://github.com/flathub/im.riot.Riot/blob/3fdd41c84f40fa1e8e186bade5d832d79045600c/element.sh
  if [ "wayland" == "${XDG_SESSION_TYPE}" ] && [ -e "${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}" ]
  then
      DISPLAY_SERVER_ARGS="--ozone-platform-hint=auto --enable-wayland-ime --enable-features=WaylandWindowDecorations"
      if  [ -c /dev/nvidia0 ]
      then
          DISPLAY_SERVER_ARGS="${DISPLAY_SERVER_ARGS} --disable-gpu-sandbox" 
      fi
  else
      DISPLAY_SERVER_ARGS="--ozone-platform=x11"
  fi
  echo "${DISPLAY_SERVER_ARGS}"
}

function exec_editor() {
  @EXPORT_ENVS@
  # shellcheck disable=SC2046
  exec "@WRAPPER_PATH@" @EDITOR_ARGS@ $(display_server_args) "$@"
}

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
