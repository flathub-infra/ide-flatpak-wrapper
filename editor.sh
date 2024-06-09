#!@BASH@
# shellcheck shell=bash

set -e
shopt -s nullglob

FIRST_RUN="${XDG_CONFIG_HOME}/@FLAGFILE_PREFIX@-first-run"
SDK_UPDATE="${XDG_CONFIG_HOME}/@FLAGFILE_PREFIX@-sdk-update-@SDK_VERSION@"

declare -a DISPLAY_SERVER_ARGS=()

function update_display_server_args () {
  # See https://github.com/flathub/im.riot.Riot/blob/3fdd41c84f40fa1e8e186bade5d832d79045600c/element.sh
  # See also https://gaultier.github.io/blog/wayland_from_scratch.html 
  # and https://github.com/flathub/com.vscodium.codium/issues/321
  if [ "wayland" == "${XDG_SESSION_TYPE}" ] && [ -n "${WAYLAND_DISPLAY}" ]; then
    if [[ "${WAYLAND_DISPLAY}" =~ ^/ ]]; then
      wayland_socket="${WAYLAND_DISPLAY}"
    else
      wayland_socket="${XDG_RUNTIME_DIR:-/run/user/${UID}}/${WAYLAND_DISPLAY}"
    fi
  fi

  # shellcheck disable=SC2050
  if [ "@ELECTRON_ENABLED@" -eq 0 ]; then
    return 0
  fi

  if [ -e "$wayland_socket" ]; then
    DISPLAY_SERVER_ARGS=(
      "--ozone-platform=wayland"
      "--enable-wayland-ime"
      "--enable-features=WaylandWindowDecorations"
    )
    if [ -c /dev/nvidia0 ]; then
      DISPLAY_SERVER_ARGS+=("--disable-gpu-sandbox")
    fi
  else
    DISPLAY_SERVER_ARGS=("--ozone-platform=x11")
  fi
}

function exec_editor() {
  @EXPORT_ENVS@
  update_display_server_args
  # shellcheck disable=SC2086
  exec "@WRAPPER_PATH@" @EDITOR_ARGS@ "${DISPLAY_SERVER_ARGS[@]}" ${EDITOR_RUNTIME_ARGS} "$@"
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
