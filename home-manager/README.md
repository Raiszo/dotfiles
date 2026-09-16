# Le Home Manager

## Install Nix

Just follow your heart https://nixos.org/download/

## Clone config

```bash
nix --extra-experimental-features 'nix-command flakes' run nixpkgs#git -- clone https://github.com/Raiszo/dotfiles.git
```

Maybe use ssh url

## Install flake

```bash
cd dotfiles/home-manager
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager -- switch --flake .
```

## Swift

Using swiftly https://www.swift.org/install/linux/

```zsh
./swiftly init --quiet-shell-followup --no-modify-profile
```

It stores its stuff in `~/.local/share/swiftly`. For more info `swiftly init -h`.

## STM32 ST-LINK debugging from Emacs

The Home Manager configuration packages the STM32Cube Core and ST-LINK GDB
server VS Code extensions and installs two stable commands:

- `stm32-cube`: ST's Cube CLI wrapper.
- `stm32-stlink-dap`: the standalone ST-LINK Debug Adapter Protocol server.

The extension package contains the Cube wrapper, but the licensed GDB,
STM32CubeProgrammer, and ST-LINK server bundles are installed separately into
the writable per-user STM32Cube bundle store. Install them once:

```bash
stm32-cube bundle install \
  stlink-gdbserver \
  programmer \
  gnu-gdb-for-stm32
```

Accept ST's licenses when prompted. By default the downloaded bundles and
CMSIS packs live outside the Nix store under:

```text
~/.local/share/stm32cube/bundles
~/.local/share/stm32cube/packs
```

Verify that the required commands resolve:

```bash
stm32-cube --resolve stlink-gdbserver-pure
stm32-cube --resolve arm-none-eabi-gdb
```

Project-specific target, image, and build settings remain in
`.vscode/launch.json`. The adapter wrapper changes `PATH` only for its own
process so that the adapter can invoke the packaged `cube` executable.

### CMSIS device packs

Home Manager also installs `cpackget` from a pinned upstream Linux x86-64
release. The `programs.zsh.sessionVariables` declaration in [home.nix](home.nix)
sets `CMSIS_PACK_ROOT` to `$HOME/.local/share/stm32cube/packs`, matching Cube's
default pack repository. If you customize Cube's pack location, update this
declaration too. After activating Home Manager, start a new login Zsh session
before running these commands:
