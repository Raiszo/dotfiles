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
