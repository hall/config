{ pkgs, flake, ... }:
let
  xontribs = [
    # "argcomplete" # tab completion of python and xonsh scripts
    "sh" # prefix (ba)sh commands with "!"
    # "onepath" # act on file/dir by only using its name # TODO: build failed
    "pipeliner" # use "pl" to pipe a python expression
    "zoxide"
    "prompt-starship"
    # "readable-traceback"
  ];
  pyenv = flake.inputs.mach.lib.${pkgs.system}.mkPython {
    python = "python310";
    requirements = ''
      # black
      # numpy
      # pandas

      xxh-xxh
      # xxh-shell-xonsh
      xonsh-direnv
    '' + builtins.toString (map (x: "xontrib-" + x + "\n") xontribs);
  };
  xonsh = pkgs.xonsh.overrideAttrs (super: {
    pythonPath = pyenv.selectPkgs pyenv.python.pkgs;
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
    text = "xontrib load direnv prompt_starship " + builtins.toString xontribs;
    target = "xonsh/xonshrc";
  };
}
