{ kubenix, flake, vars, pkgs, ... }:
let
  name = "go-neb";
in
{
  helm.releases.${name} = {
    chart = vars.template { inherit kubenix; };
    namespace = "default";
    values = {
      image = {
        repository = "brytonhall/${name}";
        tag = "master";
      };
      env = {
        CONFIG_FILE = "/config/config.yaml";
        BASE_URL = "http://${name}:4050";
      };
      service.main.ports.http.port = 4050;
      persistence = {
        config = {
          enabled = true;
          type = "configMap";
          name = "${name}-config";
          readOnly = true;
        };
      };
      configmap.config = {
        enabled = true;
        data."config.yaml" = builtins.readFile ((pkgs.formats.yaml { }).generate "." {
          clients = [{
            UserID = vars.secret "/matrix/user";
            AccessToken = vars.secret "/matrix/token";
            DeviceID = name;
            HomeserverURL = "https://matrix.org";
            Sync = true;
            AutoJoinRooms = true;
            DisplayName = "Home";
          }];
          services = [{
            ID = name;
            Type = "alertmanager";
            UserID = vars.secret "/matrix/user";
            Config = {
              webhook_url = "http://${name}/services/hooks/Z28tbmVi";
              rooms = {
                "${vars.secret "/matrix/room"}" = {
                  msg_type = "m.text";
                  text_template = ''{{`{{ range .Alerts -}} [{{ .Status }}] {{index .Labels "alertname" }}: {{index .Annotations "description"}} {{ end -}}`}}'';
                  html_template = ''{{`
                    {{- range .Alerts -}}
                      {{ $severity := index .Labels "severity" }}
                      {{ $color := "purple" }}

                      {{ if eq .Status "firing" }}
                        {{ if eq $severity "critical"}}
                          {{ $color = "red" }}
                        {{ else if eq $severity "warning"}}
                          {{ $color = "orange" }}
                        {{ else if eq $severity "info"}}
                          {{ $color = "yellow" }}
                        {{ end }}
                      {{ else }}
                        {{ $color = "green" }}
                        {{ $severity = "resolved" }}
                      {{ end }}

                        [<font color='{{ $color }}'><b>{{ $severity }}</b></font>]

                        <a href="{{ .GeneratorURL }}">{{ index .Labels "alertname"}}</a>: {{ index .Annotations "description"}}
                        <br/>
                      {{- end -}}
                  `}}'';
                };
              };
            };
          }];
        });
      };
    };
  };
}
