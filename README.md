# Dotfiles

This is a [chezmoi](https://www.chezmoi.io/) source repository. `.chezmoiroot` points chezmoi at `home/`, which contains the managed files. The shell, Git, and tmux configurations are intended for Linux. They are excluded on macOS and other systems.

## Use this checkout

Install chezmoi, then review the changes before applying them:

```sh
chezmoi --source "$HOME/dotfiles" managed
chezmoi --source "$HOME/dotfiles" diff
chezmoi --source "$HOME/dotfiles" apply --dry-run --verbose
```

On Linux, `./install.sh` runs the preview, asks before applying, creates `~/.gitconfig.local` if needed, and offers to install the optional tools. You can instead run `chezmoi --source "$HOME/dotfiles" apply --verbose` after reviewing the diff.

On a new machine, `chezmoi init git@github.com:sirejdua/dotfiles.git` clones this repository into chezmoi's default source directory. Run `chezmoi diff` before `chezmoi apply`.

The shared `.bashrc` sources `~/.bashrc.local`, and the shared `.gitconfig` includes `~/.gitconfig.local`. Keep machine-specific settings and credentials in those local files, outside Git.

On `b200-06`, chezmoi excludes the existing `.bashrc`, `.profile`, `.zshrc`, and `.gitconfig` so applying this repo cannot replace the host's current shell settings or credentials. Its current `.tmux.conf` is included in the managed source. Move the host's local settings into local files before removing those exclusions.
