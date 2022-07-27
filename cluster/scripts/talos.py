#!/usr/bin/env python
import subprocess
import jinja2 as jinja
import json
from pathlib import Path

env = jinja.Environment(loader=jinja.FileSystemLoader(Path(__file__).parents[1]))
template = env.get_template("talos.yaml.jinja")

# retrieve talosconfig fields from bitwarden vault
fields = json.loads(subprocess.run(["bw", "get", "item", "talosconfig"],
    check=True, capture_output=True).stdout).get("fields")
# convert list of dicts, into a single dict
secrets = {x['name']: x["value"] for x in fields}

dist = Path(__file__).parents[1] / "dist"
dist.mkdir(exist_ok=True)

for i in range(5):
    hostname = f'k{i}'
    variables = {
        "type": "controlplane" if i < 3 else "worker",
        "hostname": hostname,
    }

    with open(dist / f"{hostname}.yaml", "w") as f:
        f.write(template.render(variables | secrets))
