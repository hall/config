self: super:
super.vscodium.overrideAttrs (prev: {
  postFixup = ''
    # append content from stdin to end of element tag
    append() {
      ${super.pkgs.gnused}/bin/sed -i "/<\/$1>/e ${super.pkgs.coreutils}/bin/cat -" $out/lib/vscode/resources/app/out/vs/code/electron-browser/workbench/workbench.html 
    }

    # TODO: don't disable all CSP
    sed -i '/Content-Security-Policy/d' $out/lib/vscode/resources/app/out/vs/code/electron-browser/workbench/workbench.html 

    find ${./custom} -type f | while read file; do 
      case $file in
        *.js)
          # echo -e "<meta http-equiv=\"Content-Security-Policy\" content=\"script-src 'sha256-$(echo -e "\n$(cat $file)\n" | sha256sum | cut -d' ' -f1)'\">" | append head
          echo -e "<script>\n$(cat $file)\n</script>" | append html
        ;;
        *.css)
          echo -e "<style>\n$(cat $file)\n</style>" | append head
        ;;
        *.scss|*.sass)
          echo -e "<style>\n$(${super.pkgs.sass}/bin/sass $file)\n</style>" | append head
        ;;
      esac
    done
  '';
})
