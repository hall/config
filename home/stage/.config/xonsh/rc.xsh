from xonsh.xontribs import xontribs_load

#$PROMPT = '[{localtime}] {YELLOW}{env_name} {BOLD_BLUE}{user}@{hostname} {BOLD_GREEN}{cwd} {gitstatus}{RESET}\n> '

$THREAD_SUBPROCS = False

$BASH_COMPLETIONS = f"{$HOME}/.nix-profile/share/bash-completion/bash_completion"

$LS_COLORS='rs=0:di=01;36:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:'

$PATH = [
  "$HOME/bin",
  "$HOME/.cargo/bin",
  "$HOME/.krew/bin",
  ] + $PATH

$GOPATH = $HOME

aliases |= {
    "k": ["kubectl"],
    "t": ["talosctl"],
    "cd": ["z"]
}

xontribs_load([
  "mpl",
  # "sh"
])

execx($(zoxide init xonsh), 'exec', __xonsh__.ctx, filename='zoxide')
execx($(starship init xonsh))

