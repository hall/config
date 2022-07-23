self: super:
super.vscodium.overrideAttrs (prev: {
  postFixup = ''
    # insert custom html before closing tag
    ${super.pkgs.gnused}/bin/sed -i \
      '/<\/html>/e ${super.pkgs.coreutils}/bin/cat ${./custom.html}' \
      $out/lib/vscode/resources/app/out/vs/code/electron-browser/workbench/workbench.html
  '';
})
