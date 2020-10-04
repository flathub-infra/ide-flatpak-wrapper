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

Add as a module to your flatpak-builder manifest and configure it to match the editor properties, e.g.

```yaml
  - name: vscode-flatpak-wrapper
    buildsystem: meson
    config-opts:
      # Path to the editor executable
      - -Deditor_binary=/app/main/bin/code-oss
      # Install wrapper under this name
      - -Dprogram_name=code-oss
      # Human-readable editor name
      - -Deditor_title=Code - OSS
```
