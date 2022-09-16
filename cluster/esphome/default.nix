{ kubenix, flake, vars, ... }:
vars.simple {
  inherit kubenix;
  image = "esphome/esphome:2022.8.0";
  port = 6052;
}
# helm.releases.esphome = {
#     persistence = {
#       config = {
#         # enabled = true;
#         type = "configMap";
#         subPath = "config";
#         mountPath = "/config/config";
#         name = "esphome-config";
#         readOnly = true;
#       };
#     };
#     configmap.config = {
#       enabled = true;
#       data = {
#         config = ''
#       '';
#       };
#     };
#   };
# };
# }
