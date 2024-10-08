{ config, lib, flake, ... }:
let
  cfg = config.stylix.targets.logseq;
in
{
  options.stylix.targets.logseq = {
    enable = config.lib.stylix.mkEnableTarget "logseq" true;
    path = lib.mkOption {
      description = "Path to the graph, relative to $HOME";
      type = lib.types.str;
    };
  };

  config = lib.mkIf (config.stylix.enable && config.stylix.targets.logseq.enable) {
    # https://github.com/logseq/logseq-plugin-samples/blob/461d559b03e28119994126a13fc0e910bbd21197/logseq-base16-themes/css/base16-ocean.css
    home-manager.users.${flake.lib.username}.home.file."${cfg.path}/logseq/custom.css.link" = {
      # TODO: https://github.com/logseq/logseq/issues/11267
      onChange = "cp ${cfg.path}/logseq/custom.css.link ${cfg.path}/logseq/custom.css";
      text = with config.lib.stylix.colors; ''
        :root {
          --base00: #${base00};
          --base01: #${base01};
          --base02: #${base02};
          --base03: #${base03};
          --base04: #${base04};
          --base05: #${base05};
          --base06: #${base06};
          --base07: #${base07};
          --base08: #${base08};
          --base09: #${base09};
          --base0A: #${base0A};
          --base0B: #${base0B};
          --base0C: #${base0C};
          --base0D: #${base0D};
          --base0E: #${base0E};
          --base0F: #${base0F};
          --button-blue: var(--base0C);
          --button-gray-1: var(--base05);
          --button-gray-2: var(--base06);
          --button-gray-3: var(--base07);
        }

        .dark-theme {
            --ls-primary-background-color: var(--base00);
            --ls-secondary-background-color: var(--base01);
            --ls-tertiary-background-color: var(--ls-secondary-background-color);
            --ls-search-background-color: var(--ls-primary-background-color);
            --ls-border-color: var(--base03);
            --ls-menu-hover-color: var(--ls-secondary-background-color);
            --ls-primary-text-color: var(--base05);
            --ls-secondary-text-color: var(--base06);
            --ls-title-text-color: var(--base0D);
            --ls-link-text-color: var(--base09);
            --ls-link-text-hover-color: var(--base0A);
            --ls-link-ref-text-color: var(--ls-link-text-color);
            --ls-block-bullet-border-color: var(--base02);
            --ls-block-bullet-color: var(--base0A);
            --ls-block-highlight-color: var(--base02);
            --ls-page-checkbox-color: var(--base01);
            --ls-page-checkbox-border-color: var(--ls-primary-background-color);
            --ls-page-blockquote-color: var(--ls-secondary-text-color);
            --ls-page-blockquote-border-color: var(--ls-secondary-text-color);
            --ls-page-inline-code-color: var(--ls-primary-text-color);
            --ls-page-inline-code-bg-color: var(--base01);
            --ls-scrollbar-color: var(--base00);
            --ls-scrollbar-thumb-hover-color: #b4b4b466;
            --ls-head-text-color: var(--ls-link-text-color);
            --ls-icon-color: var(--base05);
            --ls-search-icon-color: var(--ls-link-text-color);
            --ls-a-chosen-bg: var(--ls-secondary-background-color);
        }


        .dark-theme .form-checkbox {
            background-color: var(--base02);
            border-color: var(--base04);
        }

        mark {
            background: var(--base0A);
            color: var(--base00);
        }

        .dark-theme .focus\:shadow-outline:focus {
            box-shadow: 0 0 0 3px var(--base0A);
        }

        .dark-theme tr:nth-child(odd) {
            background-color: var(--base01);
        }

        .dark-theme tr:nth-child(even) {
            background-color: var(--base02);
        }

        .dark-theme th {
            color: var(--base05);
            border-bottom: 2px solid var(--base03);
        }

        .dark-theme .non-block-editor textarea,
        .dark-theme pre,
        .dark-theme pre.code {
            background: var(--base01);
        }

        .dark-theme .block-children {
            border-left: 1px solid var(--base02);
        }

        .dark-theme .non-block-editor textarea,
        .dark-theme pre,
        .dark-theme pre.code .dark-theme #right-sidebar .non-block-editor textarea,
        .dark-theme #right-sidebar pre,
        .dark-theme #right-sidebar pre.code {
            background: var(--base01);
        }

        .dark-theme .block-children {
            border-left: 1px solid var(--base01);
        }

        .text-gray-500 {
            color: var(--base01);
        }

        #right-sidebar .bg-base-2 {
            background-color: var(--base01);
        }
        #right-sidebar .bg-base-4 {
            background-color: var(--base00);
        }

        /** CodeMirror **/
        .cm-s-default .CodeMirror {
            background: var(--base00);
            color: var(--base05);
        }
        .cm-s-default div.CodeMirror-selected {
            background: var(--base02);
        }
        .cm-s-default .CodeMirror-line::selection,
        .cm-s-default .CodeMirror-line > span::selection,
        .cm-s-default .CodeMirror-line > span > span::selection {
            background: rgba(73, 72, 62, .99);
        }
        .cm-s-default .CodeMirror-line::-moz-selection,
        .cm-s-default .CodeMirror-line > span::-moz-selection,
        .cm-s-default .CodeMirror-line > span > span::-moz-selection {
            background: rgba(73, 72, 62, .99);
        }
        .cm-s-default .CodeMirror-gutters {
            background: var(--base00);
            border-right: 0px;
        }
        .cm-s-default .CodeMirror-guttermarker {
            color: white;
        }
        .cm-s-default .CodeMirror-guttermarker-subtle {
            color: #d0d0d0;
        }
        .cm-s-default .CodeMirror-linenumber {
            color: #d0d0d0;
        }
        .cm-s-default .CodeMirror-cursor {
            border-left: 1px solid #f8f8f0;
        }

        .cm-s-default span.cm-comment {
            color: var(--base03);
        }
        .cm-s-default span.cm-atom {
            color: var(--base0E);
        }
        .cm-s-default span.cm-number {
            color: var(--base0E);
        }

        .cm-s-default span.cm-comment.cm-attribute {
            color: #97b757;
        }
        .cm-s-default span.cm-comment.cm-def {
            color: #bc9262;
        }
        .cm-s-default span.cm-comment.cm-tag {
            color: #bc6283;
        }
        .cm-s-default span.cm-comment.cm-type {
            color: #5998a6;
        }

        .cm-s-default span.cm-property,
        .cm-s-default span.cm-attribute {
            color: var(--base0B);
        }
        .cm-s-default span.cm-keyword {
            color: var(--base08);
        }
        .cm-s-default span.cm-builtin {
            color: var(--base0D);
        }
        .cm-s-default span.cm-string {
            color: #e6db74;
        }

        .cm-s-default span.cm-variable {
            color: var(--base05);
        }
        .cm-s-default span.cm-variable-2 {
            color: #9effff;
        }
        .cm-s-default span.cm-variable-3,
        .cm-s-default span.cm-type {
            color: var(--base0D);
        }
        .cm-s-default span.cm-def {
            color: var(--base09);
        }
        .cm-s-default span.cm-bracket {
            color: var(--base05);
        }
        .cm-s-default span.cm-tag {
            color: var(--base08);
        }
        .cm-s-default span.cm-header {
            color: var(--base0E);
        }
        .cm-s-default span.cm-link {
            color: var(--base0E);
        }
        .cm-s-default span.cm-error {
            background: var(--base08);
            color: #f8f8f0;
        }

        .cm-s-default .CodeMirror-activeline-background {
            background: #373831;
        }
        .cm-s-default .CodeMirror-matchingbracket {
            text-decoration: underline;
            color: white !important;
        }
      '';
    };
  };
}
