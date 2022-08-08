{ pkgs, flake, ... }:
let
  xontribs = [
    # "argcomplete" # tab completion of python and xonsh scripts
    "sh" # prefix (ba)sh commands with "!"
    # "autojump" or "z"   # autojump support(or zoxide?)
    # "autoxsh" or "direnv"     # execute .autoxsh when entering directory
    "onepath" # act on file/dir by only using its name
    # "prompt_starship"
    # "pipeliner" # use "pl" to pipe a python expression
    # xxh-xxh
  ];
  pyenv = flake.inputs.mach.lib.x86_64-linux.mkPython {
    requirements = ''
      # black
      # numpy
      # pandas

      # setuptools
      # wheel
      # pip
    '' + builtins.toString (map (x: "xontrib-" + x + "\n") xontribs);
  };
  xonsh = pkgs.xonsh.overrideAttrs (super: {
    # propagatedBuildInputs = super.propagatedBuildInputs ++ (pyenv.selectPkgs pyenv.python.pkgs);
    # pythonPath = pyenv.selectPkgs pyenv.python.pkgs;
  });
in
{
  users.users.${flake.username} = {
    isNormalUser = true;
    shell = xonsh;
    extraGroups = [
      "audio"
      "dialout"
      "docker"
      "i2c"
      "input"
      "wheel"
      #"wireshark"

      "feedbackd"
      "video"
      "networkmanager"
    ];
  };
  environment.etc.xonshrc = {
    text = "xontrib load abbrevs " + builtins.toString xontribs;
    target = "xonsh/xonshrc";
  };
}
