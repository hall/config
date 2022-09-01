# $BASH_COMPLETIONS = f"{$(nix eval --raw 'nixpkgs#bash-completion')}/share/bash-completion/bash_completion"
# $BASH_COMPLETIONS.append(f"{$(nix show-derivation 'nixpkgs#bash-completion' | jq -j '.[].outputs.out.path')}/share/bash-completion/bash_completion")

# PATH = [
#     "$HOME/bin",
#     "$HOME/.cargo/bin",
# ] + $PATH

$GOPATH = $HOME

aliases |= {
    "k": ["kubectl"],
    "cd": ["z"],
    "lens": ["bash", "-c", "sudo rm -rf ~/.config/OpenLens/extensions && openlens"]
}

# $ANS = f'{$HOME}/src/github.com/haslersn/any-nix-shell/bin'
# $PATH.append($ANS)
# execx($(any-nix-shell xonsh), 'exec', __xonsh__.ctx, filename='any-nix-shell')
