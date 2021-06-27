#!@BASH@
# shellcheck shell=bash

set -e
shopt -s nullglob

FIRST_RUN="${XDG_CONFIG_HOME}/@FLAGFILE_PREFIX@-first-run"
SDK_UPDATE="${XDG_CONFIG_HOME}/@FLAGFILE_PREFIX@-sdk-update-@SDK_VERSION@"

function msg() {
  echo "@PROGRAM_NAME@-wrapper: $*" >&2
}

function exec_vscode() {
  exec "@EDITOR_BINARY@" @EDITOR_ARGS@ "$@"
}

if [ -n "${FLATPAK_IDE_ENV}" ]; then
  msg "Environment is already set up"
  exec_vscode "$@"
fi

declare -A PATH_SUBDIRS
PATH_SUBDIRS[PATH]="bin"
PATH_SUBDIRS[PYTHONPATH]="lib/python@PYTHON_VERSION@/site-packages"
PATH_SUBDIRS[PKG_CONFIG_PATH]="lib/pkgconfig"
PATH_SUBDIRS[GI_TYPELIB_PATH]="lib/girepository-1.0"

function export_path_vars() {
  base_dir="$1"
  for var_name in "${!PATH_SUBDIRS[@]}"; do
    abs_dir="$base_dir/${PATH_SUBDIRS[$var_name]}"
    if [ -d "$abs_dir" ]; then
      msg "Adding $abs_dir to $var_name"
      if [ -z "${!var_name}" ]; then
        export $var_name="$abs_dir"
      else
        export $var_name="${!var_name}:$abs_dir"
      fi
    fi
  done
}

for tool_dir in /app/tools/*; do
  export_path_vars "$tool_dir"
done

if [ "$FLATPAK_ENABLE_SDK_EXT" = "*" ]; then
  SDK=()
  for d in /usr/lib/sdk/*; do
    SDK+=("${d##*/}")
  done
else
  IFS=',' read -ra SDK <<< "$FLATPAK_ENABLE_SDK_EXT"
fi

for i in "${SDK[@]}"; do
  sdk_ext_dir="/usr/lib/sdk/$i"
  if [[ -d "$sdk_ext_dir" ]]; then
    if [[ -z "$FLATPAK_SDK_EXT_NO_SCRIPTS" && \
          -f "$sdk_ext_dir/enable.sh" ]]; then
      msg "Evaluating $sdk_ext_dir/enable.sh"
      # shellcheck source=/dev/null
      . "$sdk_ext_dir/enable.sh"
    else
      export_path_vars "$sdk_ext_dir"
    fi
  else
    msg "Requested SDK extension \"$i\" is not installed"
  fi
done

FLATPAK_PREFER_USER_PACKAGES="${FLATPAK_PREFER_USER_PACKAGES:-0}"
FLATPAK_ISOLATE_PACKAGES="${FLATPAK_ISOLATE_PACKAGES:-1}"
FLATPAK_ISOLATE_NPM="${FLATPAK_ISOLATE_NPM:-${FLATPAK_ISOLATE_PACKAGES}}"
FLATPAK_PREFER_USER_NPM="${FLATPAK_PREFER_USER_NPM:-${FLATPAK_PREFER_USER_PACKAGES}}"
FLATPAK_ISOLATE_CARGO="${FLATPAK_ISOLATE_CARGO:-${FLATPAK_ISOLATE_PACKAGES}}"
FLATPAK_PREFER_USER_CARGO="${FLATPAK_PREFER_USER_CARGO:-${FLATPAK_PREFER_USER_PACKAGES}}"
FLATPAK_ISOLATE_PIP="${FLATPAK_ISOLATE_PIP:-${FLATPAK_ISOLATE_PACKAGES}}"
FLATPAK_PREFER_USER_PIP="${FLATPAK_PREFER_USER_PIP:-${FLATPAK_PREFER_USER_PACKAGES}}"

if [ "${FLATPAK_ISOLATE_NPM}" -ne 0 ]; then
  msg "Setting up NPM packages"
  export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npmrc"
  if [ ! -f "$NPM_CONFIG_USERCONFIG" ]; then
  cat <<EOF_NPM_CONFIG > "$NPM_CONFIG_USERCONFIG"
prefix=\${XDG_DATA_HOME}/node
init-module=\${XDG_CONFIG_HOME}/npm-init.js
tmp=\${XDG_CACHE_HOME}/tmp
EOF_NPM_CONFIG
  fi
  if [ "$FLATPAK_PREFER_USER_NPM" -ne 0 ]; then
    export PATH="$XDG_DATA_HOME/node/bin:$PATH"
  else
    export PATH="$PATH:$XDG_DATA_HOME/node/bin"
  fi
fi

if [ "${FLATPAK_ISOLATE_CARGO}" -ne 0 ] ; then
  msg "Setting up Cargo packages"
  export CARGO_INSTALL_ROOT="$XDG_DATA_HOME/cargo"
  export CARGO_HOME="$CARGO_INSTALL_ROOT"
  if [ "$FLATPAK_PREFER_USER_CARGO" -ne 0 ]; then
    export PATH="$CARGO_INSTALL_ROOT/bin:$PATH"
  else
    export PATH="$PATH:$CARGO_INSTALL_ROOT/bin"
  fi
fi

if [ "${FLATPAK_ISOLATE_PIP}" -ne 0 ]; then
  msg "Setting up Python packages"
  export PYTHONUSERBASE="$XDG_DATA_HOME/python"
  if [ "$FLATPAK_PREFER_USER_PIP" -ne 0 ]; then
    export PATH="$PYTHONUSERBASE/bin:$PATH"
  else
    export PATH="$PATH:$PYTHONUSERBASE/bin"
  fi
fi

export FLATPAK_IDE_ENV=1

if [ ! -f "${FIRST_RUN}" ]; then
  touch "${FIRST_RUN}"
  touch "${SDK_UPDATE}"
  exec_vscode "$@" "@FIRST_RUN_README@"
elif [ ! -f "${SDK_UPDATE}" ]; then
  touch "${SDK_UPDATE}"
  exec_vscode "$@" "@SDK_UPDATE_README@"
else
  exec_vscode "$@"
fi
