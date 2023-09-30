{ kubenix, flake, lib, vars, ... }:
let
  creds = "digitalocean-token";
  ns = "kube-system";
  resolver = "letsencrypt";
in
{
  kubernetes = {
    resources = {
      secrets.${creds} = {
        metadata.namespace = ns;
        stringData.DO_AUTH_TOKEN = vars.secret "/cloud/token";
      };

      ingressroute.default = {
        metadata.namespace = ns;
        spec = {
          entryPoints = [ "web" "websecure" ];
          routes = [
            {
              match = "Host(`*`)";
              kind = "Rule";
            }
            {
              match = "Host(`home.${flake.lib.hostname}`)";
              kind = "Rule";
              middlewares = [{ name = "home"; }];
            }
          ];
          tls = {
            certResolver = resolver;
            domains = [{
              main = "*.${flake.lib.hostname}";
            }];
          };
        };
      };
      middlewares = {
        home = {
          metadata.namespace = ns;
          spec.headers = {
            contentSecurityPolicy = "frame-src home.${flake.lib.hostname}";
            customResponseHeaders.x-frame-options = "";
          };
        };
        cloud = {
          metadata.namespace = ns;
          spec = {
            # headers = {
            #   stsSeconds = 15552000;
            #   # stsIncludeSubdomains = "";
            #   # stsPreload = true;
            # };
            redirectRegex = {
              permanent = true;
              regex = "https://(.*)/.well-known/(?:card|cal)dav";
              replacement = "https://\${1}/remote.php/dav";
            };
          };
        };
      };

      # TODO: remove with todo item below
      services.traefik = {
        metadata = {
          namespace = ns;
          # labels = {
          #   "app.kubernetes.io/name" = "traefik";
          #   "helm.sh/chart" = "traefik-10.24.1";
          #   "app.kubernetes.io/managed-by" = "Helm";
          #   "app.kubernetes.io/instance" = "traefik";
          # };
        };
        spec = {
          type = "LoadBalancer";
          selector = {
            "app.kubernetes.io/name" = "traefik";
            "app.kubernetes.io/instance" = "traefik";
          };
          ports = [
            {
              port = 80;
              name = "web";
              targetPort = "web";
              protocol = "TCP";
            }
            {
              port = 443;
              name = "websecure";
              targetPort = "websecure";
              protocol = "TCP";
            }
            {
              port = 1883;
              name = "mqtt";
              targetPort = "mqtt";
              protocol = "TCP";
            }
            {
              port = 465;
              name = "smtps";
              targetPort = "smtp";
              protocol = "TCP";
            }
            {
              port = 993;
              name = "imaps";
              targetPort = "imap";
              protocol = "TCP";
            }
          ];
        };
      };
    };

    helm.releases.traefik = {
      chart = kubenix.lib.helm.fetch {
        repo = "https://helm.traefik.io/traefik";
        chart = "traefik";
        version = "10.24.1";
        sha256 = "sha256-JcPjxnvIaJ/X4V5GG4th/B8eZhjS6AqTvgtDCLVok5Y=";
      };
      includeCRDs = true;
      noHooks = true;
      namespace = ns;
      values = {
        # TODO: error: The option `kubernetes.api.resources.core.v1.List' does not exist. Definition values:
        service.enabled = false;

        logs.general.level = "DEBUG";

        certResolvers.${resolver} = {
          email = flake.lib.email;
          storage = "/data/acme.json";
          dnsChallenge = {
            provider = "digitalocean";
            resolvers = [ "1.1.1.1:53" "8.8.8.8:53" ];
          };
        };
        persistence = {
          enabled = true;
          storageClass = "longhorn-static";
        };
        envFrom = [{ secretRef.name = creds; }];
        # ssl = {
        #   enabled = true;
        #   permanentRedirect = true;
        # };
        rbac.enabled = true;
        ports = {
          web.redirectTo = "websecure";
          websecure.tls.enabled = true;
          mqtt = {
            port = 1883;
            expose = true;
            # exposedPort = 1883;
            # protocol = "TCP";
          };
          imap = {
            port = 1143;
            expose = true;
            # exposedPort = 143;
            # protocol = "TCP";
          };
          smtp = {
            port = 1025;
            expose = true;
            # exposedPort = 25;
            # protocol = "TCP";
          };
        };
        providers.kubernetesIngress.publishedService.enabled = true;
        # The "volume-permissions" init container is required if you run into permission issues.
        # Related issue: https://github.com/traefik/traefik/issues/6972
        deployment.initContainers = [
          {
            name = "volume-permissions";
            image = "busybox:1.31.1";
            command = [ "sh" "-c" "chmod -Rv 600 /data/*" ];
            volumeMounts = [{
              name = "data";
              mountPath = "/data";
            }];
          }
        ];
      };
    };

    customTypes = {
      ingressroute = {
        attrName = "ingressroute";
        group = "traefik.containo.us";
        version = "v1alpha1";
        kind = "IngressRoute";
      };
      ingressroutetcp = {
        attrName = "ingressroutetcp";
        group = "traefik.containo.us";
        version = "v1alpha1";
        kind = "IngressRouteTCP";
      };
      middlewares = {
        attrName = "middlewares";
        group = "traefik.containo.us";
        version = "v1alpha1";
        kind = "Middleware";
      };
    };
  };

}
