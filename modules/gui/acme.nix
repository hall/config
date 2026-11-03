{
  flake,
  config,
  lib,
  pkgs,
  ...
}:
let
  # self-reference: this home-manager user's own stylix palette,
  # so acme's hardcoded C colors track whatever base16Scheme is active
  stylixColors = config.home-manager.users.${flake.lib.username}.lib.stylix.colors;
  acme-custom = pkgs.plan9port.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace src/cmd/acme/acme.c \
        --replace-fail 'tagcols[BACK] = allocimagemix(display, DPalebluegreen, DWhite);' \
                        'tagcols[BACK] = allocimage(display, Rect(0,0,1,1), screen->chan, 1, 0x${stylixColors.base01}FF);' \
        --replace-fail 'tagcols[HIGH] = allocimage(display, Rect(0,0,1,1), screen->chan, 1, DPalegreygreen);' \
                        'tagcols[HIGH] = allocimage(display, Rect(0,0,1,1), screen->chan, 1, 0x${stylixColors.base02}FF);' \
        --replace-fail 'tagcols[BORD] = allocimage(display, Rect(0,0,1,1), screen->chan, 1, DPurpleblue);' \
                        'tagcols[BORD] = allocimage(display, Rect(0,0,1,1), screen->chan, 1, 0x${stylixColors.base03}FF);' \
        --replace-fail 'tagcols[TEXT] = display->black;' \
                        'tagcols[TEXT] = allocimage(display, Rect(0,0,1,1), screen->chan, 1, 0x${stylixColors.base05}FF);' \
        --replace-fail 'tagcols[HTEXT] = display->black;' \
                        'tagcols[HTEXT] = allocimage(display, Rect(0,0,1,1), screen->chan, 1, 0x${stylixColors.base05}FF);' \
        --replace-fail 'textcols[BACK] = allocimagemix(display, DPaleyellow, DWhite);' \
                        'textcols[BACK] = allocimage(display, Rect(0,0,1,1), screen->chan, 1, 0x${stylixColors.base00}FF);' \
        --replace-fail 'textcols[HIGH] = allocimage(display, Rect(0,0,1,1), screen->chan, 1, DDarkyellow);' \
                        'textcols[HIGH] = allocimage(display, Rect(0,0,1,1), screen->chan, 1, 0x${stylixColors.base02}FF);' \
        --replace-fail 'textcols[BORD] = allocimage(display, Rect(0,0,1,1), screen->chan, 1, DYellowgreen);' \
                        'textcols[BORD] = allocimage(display, Rect(0,0,1,1), screen->chan, 1, 0x${stylixColors.base03}FF);' \
        --replace-fail 'textcols[TEXT] = display->black;' \
                        'textcols[TEXT] = allocimage(display, Rect(0,0,1,1), screen->chan, 1, 0x${stylixColors.base05}FF);' \
        --replace-fail 'textcols[HTEXT] = display->black;' \
                        'textcols[HTEXT] = allocimage(display, Rect(0,0,1,1), screen->chan, 1, 0x${stylixColors.base05}FF);' \
        --replace-fail '"/lib/font/bit/lucsans/euro.8.font",' \
                        '"/mnt/font/Hack-Regular/13a/font",' \
        --replace-fail '"/lib/font/bit/lucm/unicode.9.font"' \
                        '"/mnt/font/Hack-Regular/13a/font"' \
        --replace-fail $'\t\t\tdraw(screen, screen->r, display->white, nil, ZP);\n\t\t\ticoninit();' \
                        $'\t\t\ticoninit();\n\t\t\tdraw(screen, screen->r, textcols[BACK], nil, ZP);'

      # Delete (forward-delete) is otherwise translated by devdraw to
      # a literal ASCII DEL (0x7F) rune, which stock acme has no
      # special case for -- it just inserts the uninterpreted rune,
      # which renders as a missing-glyph box. Give it the obvious
      # mirror-image of the existing ^H/backspace handler.
      substituteInPlace src/cmd/acme/text.c \
        --replace-fail $'\tcase 0x08:\t/* ^H: erase character */\n\tcase 0x15:\t/* ^U: erase line */\n\tcase 0x17:\t/* ^W: erase word */' \
                        $'\tcase 0x7F:\t/* DEL: erase next character */\n\t\tif(t->q0 == t->file->b.nc)\t/* nothing to erase */\n\t\t\treturn;\n\t\tq0 = t->q0;\n\t\tq1 = q0+1;\n\t\tfor(i=0; i<t->file->ntext; i++){\n\t\t\tu = t->file->text[i];\n\t\t\tu->nofill = TRUE;\n\t\t\tif(u->eq0==q0 || u->eq0==~0)\n\t\t\t\tu->eq0 = q0;\n\t\t\ttextdelete(u, q0, q1, TRUE);\n\t\t\tif(u != t)\n\t\t\t\ttextsetselect(u, u->q0, u->q1);\n\t\t\telse\n\t\t\t\ttextsetselect(t, q0, q0);\n\t\t\tu->nofill = FALSE;\n\t\t}\n\t\tfor(i=0; i<t->file->ntext; i++)\n\t\t\ttextfill(t->file->text[i]);\n\t\tt->iq1 = t->q0;\n\t\treturn;\n\tcase 0x08:\t/* ^H: erase character */\n\tcase 0x15:\t/* ^U: erase line */\n\tcase 0x17:\t/* ^W: erase word */'

      # colinit/colclose/rowinit/rowadd/rowclose clear newly-empty or
      # not-yet-populated column/row space to a literal display->white
      # rather than textcols[BACK] -- invisible on stock acme's
      # near-white default, glaring once textcols[BACK] is dark.
      substituteInPlace src/cmd/acme/cols.c \
        --replace-fail 'draw(screen, r, display->white, nil, ZP);' \
                        'draw(screen, r, textcols[BACK], nil, ZP);'
      substituteInPlace src/cmd/acme/rows.c \
        --replace-fail 'draw(screen, r, display->white, nil, ZP);' \
                        'draw(screen, r, textcols[BACK], nil, ZP);'
    '';
  });
  # acme only plumbs B3 clicks if a plumber is already listening in
  # the same namespace (derived from $DISPLAY); otherwise it falls back
  # to opening everything as text, so start one alongside acme
  acme-wrapped = pkgs.writeShellScriptBin "acme" ''
    ${acme-custom}/bin/9 9p ls plumb >/dev/null 2>&1 || ${acme-custom}/bin/9 plumber
    exec ${acme-custom}/bin/9 acme "$@"
  '';
in
{
  config = lib.mkIf config.gui.enable {
    home-manager.users.${flake.lib.username}.home = {
      packages = [
        acme-custom
        acme-wrapped
      ];

      file."lib/plumbing".text = ''
        # video/audio go to mpv
        type is text
        data matches '([a-zA-Z¡-￿0-9_\-./@]+)\.(mp4|mkv|webm|mov|avi|m4v|mp3|flac|ogg|opus)'
        arg isfile $0
        plumb start ${pkgs.mpv}/bin/mpv $file

        include basic
      '';
    };
  };
}
