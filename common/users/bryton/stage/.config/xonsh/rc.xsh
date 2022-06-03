#from xonsh.xontribs import xontribs_load
# xontribs_load([
#    "mpl",
#    "sh"
# ])

# $THREAD_SUBPROCS = False

# $BASH_COMPLETIONS = f"{$(nix eval --raw 'nixpkgs#bash-completion')}/share/bash-completion/bash_completion"
# $BASH_COMPLETIONS.append(f"{$(nix show-derivation 'nixpkgs#bash-completion' | jq -j '.[].outputs.out.path')}/share/bash-completion/bash_completion")

# $LS_COLORS='rs=0:di=01;36:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:'

$PATH = [
    "$HOME/bin",
    "$HOME/.cargo/bin",
    # "$HOME/.krew/bin",
] + $PATH

$GOPATH = $HOME

aliases |= {
    "k": ["kubectl"],
    "t": ["talosctl"],
    "cd": ["z"],
    "lens": ["bash", "-c", "sudo rm -rf ~/.config/Lens/extensions && openlens"]
}


execx($(zoxide init xonsh), 'exec', __xonsh__.ctx, filename='zoxide')
execx($(starship init xonsh))

# $ANS = f'{$HOME}/src/github.com/haslersn/any-nix-shell/bin'
# $PATH.append($ANS)
# execx($(any-nix-shell xonsh), 'exec', __xonsh__.ctx, filename='any-nix-shell')
