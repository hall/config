{ pkgs, flake, lib, ... }:
{
  home = {
    packages = with pkgs; [
      # azure-cli
      awscli2
      google-cloud-sdk
      tfswitch
      nomad
      slack
      jwt-cli
      toml2json
      _1password-gui
      dasel
    ];
  };

  programs = {

    ssh = {
      extraOptionOverrides = {
        CanonicalizeHostname = "yes";
        CanonicalDomains = "lab.rigetti.com";
      };

      matchBlocks = {
        gitlab.identityFile = lib.mkForce "/run/secrets/id_work";
        lab = {
          host = "*.lab.rigetti.com";
          user = "ansible";
          identityFile = "~/.ssh/infra-shared.pem";
          extraOptions = {
            PubkeyAcceptedKeyTypes = "+ssh-rsa";
          };
        };
        bhall = {
          host = "bhall";
          hostname = "bhall.pg.rigetti.com";
          user = "bhall";
          identityFile = "/run/secrets/id_work";
        };
        bhall-uk = {
          host = "bhall-uk";
          hostname = "bhall-uk.pg.rigetti.com";
          user = "bhall-uk";
          identityFile = "/run/secrets/id_work";
        };
      };
    };

    git = {
      includes = [
        {
          condition = "gitdir:~/src/gitlab.com/rigetti/";
          contents = {
            user = {
              email = "bhall@rigetti.com";
            };
          };
        }
      ];

    };

    vscode = {
      userSettings = {
        "atlascode.bitbucket.enabled" = false;
        "atlascode.jira.statusbar.enabled" = false;
        "atlascode.jira.startWorkBranchTemplate.customTemplate" = "{{{issueKey}}}";
        "atlascode.jira.jqlList" =
          let
            query = q: "project = Infrastructure AND resolution = Unresolved ${q} ORDER BY priority";
          in
          [
            {
              id = "b0972d31-32eb-4204-bcfc-aada2039305d";
              siteId = "3d2cc213-b5ca-4763-8895-5914364c694e";
              name = "sprint";
              query = query "AND assignee = currentUser() AND sprint in openSprints()";
              enabled = true;
              monitor = true;
            }
            {
              id = "80fadf03-cb61-47e7-8f75-af20fed5abb3";
              siteId = "3d2cc213-b5ca-4763-8995-5914364c694e";
              name = "assigned";
              query = query "AND assignee = currentUser()";
              enabled = true;
              monitor = true;
            }
            {
              id = "daf314a4-0611-49cb-945f-955ffec55fb9";
              siteId = "46ab5043-b423-4a25-a555-7754dd572b41";
              name = "backlog";
              query = query "";
              enabled = true;
              monitor = true;
            }
          ];
        "gitlab.customQueries" = [{ name = ""; type = "merge_requests"; }];
      };
      extensions = (with pkgs.vscode-extensions; [
        hashicorp.terraform
        # TODO: too old
        # ms-kubernetes-tools.vscode-kubernetes-tools # TODO: too old
      ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "vscode-kubernetes-tools";
          publisher = "ms-kubernetes-tools";
          version = "1.3.11";
          sha256 = "sha256-I2ud9d4VtgiiIT0MeoaMThgjLYtSuftFVZHVJTMlJ8s=";
        }
        {
          name = "hcl";
          publisher = "hashicorp";
          version = "0.2.1";
          sha256 = "sha256-5dBLDJ7Wgv7p3DY0klqxtgo2/ckAHoMOm8G1mDOlzZc=";
        }
        {
          name = "atlascode";
          publisher = "atlassian";
          version = "2.10.12";
          sha256 = "sha256-6YAutknTJzCUwnZ6O4A8gAfCVJk3kpW05jacxA9j9/M=";
        }
        {
          name = "vscode-open-in-github";
          publisher = "sysoev";
          version = "1.17.0";
          sha256 = "sha256-D0CQeoXsy1xhYCa7Voo+uYGMpDs9SkH1MEWTSIaVbhM=";
        }
      ];
    };
  };
}
