# Flatpak editor wrapper

This wrapper sets up development environment before launching the editor inside flatpak sandbox.

Current functions:

* Show up a readme on first launch
* Show up a notice after SDK update
* Enable installed SDK extensions (from `/usr/lib/sdk`)
  * `FLATPAK_ENABLE_SDK_EXT` must be set to a comma-separated list or `*`
* Enable installed development tools (from `/app/tools`)
* Isolate npm/pip/cargo/etc packages from host environment

## Usage

Usage of this module consists of:

  1. Sourcing this repository as a git submodule or using flatpak-builder's built-in git source.
  1. Creating a module in your flatpak's build file that specifies the options you want to use.
  1. Overwriting your flatpak's entry points to run the wrapper instead of the actual program's
  executable. This must be done on the "command" key of your build file as well as on the
  ".desktop" file of your upstream.

Some aspects of this module's behaviour may be changed using environment variables, see the full listing in the "Environment Variables" section below.

### Sourcing this Repository

To use this repository as a git submodule, you may clone it inside of your flatpak's build directory
with the command:

```
git submodule add https://github.com/flathub/ide-flatpak-wrapper.git
```

Then, you will bring it into your build file using flatpak-builder's "dir" source. Example:

```yaml
  - name: ide-flatpak-wrapper
    buildsystem: meson
    config-opts:
      # your config opts (more on this later)
    sources:
      - type: dir
        path: ide-flatpak-wrapper
```

If you prefer, you may use the git source instead. Exemple:

```yaml
  - name: ide-flatpak-wrapper
    buildsystem: meson
    config-opts:
      # your config opts (more on this later)
    sources:
      - type: git
        url: https://github.com/flathub/ide-flatpak-wrapper.git
        branch: master
```

### Specifying Config Options

For this module to work properly, we must specify a minimum of 2 options - the path to your editor's
binary and a name to install the wrapper under:

```yaml
  - name: ide-flatpak-wrapper
    buildsystem: meson
    config-opts:
      # Path to the editor executable
      - -Deditor_binary=/app/main/bin/code-oss
      # Install wrapper under this name (must be different from the above)
      - -Dprogram_name=code-oss-wrapper
    sources:
      # your source choice
```

Additionally, you may specify the following options:

* `-Dshell_wrapper_name` Name of an executable that launches bash with the environment set up (defaults to `shell-wrapper`).
* `-Deditor_args` Command line args to append to the editor executable.
* `-Deditor_title` Human readable title of the editor. This will be interpolated into the "first run template"
      file (more on this file later).
* `-Dfirst_run_template` Name of the file that will be opened on your editor's first run.
* `-Dsdk_update_template` Name of the file that will be opened when your flatpak updates its SDK. This can be
      used to inform the user that the SDK extensions they were using before must be updated as well.
* `-Dflagfile_prefix` An arbitrary string prepended to `-first-run` and `-sdk-update-` files names that indicate
      that we already did show the corresponding readme.
* `-Ddefault_loglevel` The default loglevel. May be overwritten by user with FLATPAK_IDE_LOGLEVEL environment variable.

### Overwriting the Flatpak's Entry Points

Now that you have your wrapper configured, you must ensure **it** is executed instead of your actual editor's
binary. Typically your flatpak will have two entry points: the `command` key of your build file which is used
when the flatpak is executed using the `flatpak run` command and the desktop file which is used when the user
clicks on your editor's icon from their desktop environment. If the desktop file comes from upstream you will
need to patch the `Exec` line to call the wrapper.

### First Run and SDK Update Templates

To inform your user of the particulars of flatpaks, you can include a first run template and an SDK update template
which will be run once after each of those events. You must include those files in the `sources` section of the
module:

```yaml
  - name: ide-flatpak-wrapper
    buildsystem: meson
    config-opts:
      # your options
    sources:
      # your source choice
      - type: file
        path: ide-first-run.txt
      - type: file
        path: sdk-update.txt
```

Those template files have string interpolation for the `EDITOR_TITLE` and `FLATPAK_ID` using the `@` symbol.
For example, using an editor title of "VS Code" and a flatpak ID of "com.visualstudio.code" the template file
would go from this:

```
------------------------------------------------------------------------------------
| Warning: You are running an unofficial Flatpak version of @EDITOR_TITLE@ !!! |
------------------------------------------------------------------------------------

Please open issues under: https://github.com/flathub/@FLATPAK_ID@/issues
```

To this:

```
------------------------------------------------------------------------------------
| Warning: You are running an unofficial Flatpak version of VS Code !!! |
------------------------------------------------------------------------------------

Please open issues under: https://github.com/flathub/com.visualstudio.code/issues
```

## Environment Variables

You may use the following environment variables to change the behaviour of the ide-flatpak-wrapper:

* `FLATPAK_IDE_LOGLEVEL` (= `1`)

  Controls verbosity of the module, `0` supresses all module-originated outputs to stdout.

  * Type: Number (`0` | `1`)

* `FLATPAK_PREFER_USER_PACKAGES` (= `0`)

* `FLATPAK_ISOLATE_PACKAGES` (= `1`)

* `FLATPAK_ISOLATE_NPM` (= `FLATPAK_ISOLATE_PACKAGES`)

* `FLATPAK_PREFER_USER_NPM` (= `FLATPAK_PREFER_USER_PACKAGES`)

* `FLATPAK_ISOLATE_CARGO` (= `FLATPAK_ISOLATE_PACKAGES`)

* `FLATPAK_PREFER_USER_CARGO` (= `FLATPAK_PREFER_USER_PACKAGES`)

* `FLATPAK_ISOLATE_PIP` (= `FLATPAK_ISOLATE_PACKAGES`)

* `FLATPAK_PREFER_USER_PIP` (= `FLATPAK_PREFER_USER_PACKAGES`)
