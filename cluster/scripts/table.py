#!/usr/bin/env python
import re
from functools import reduce
import pandas as pd
from kubernetes import client, config

# define table columns
template = {
    "hostname": "metadata.name",
    "arch":     "status.node_info.architecture",
    "os":       "status.node_info.os_image",
    "cpu":      "status.capacity.cpu",
    "memory":   "status.capacity.memory",
    "storage":  "status.capacity.ephemeral-storage",
}


def rgetattr(obj, attr, *args):
    """recursive getattr"""

    def _getattr(obj, attr):
        try:
            return getattr(obj, attr, *args)
        except:
            # assume obj is a dict
            o = obj.get(attr)
            if "Ki" in o:
                return str(round(int(o[:-2]) / (1024 ** 2), 2)) + "Gi"
            return o

    return reduce(_getattr, [obj] + attr.split("."))


def update_readme(table):
    """update table in README.md"""
    filename = "../README.md"
    with open(filename, "r") as file:
        readme = file.read()

    regex = re.compile("(<!-- START TABLE -->).*(<!-- END TABLE -->)", re.DOTALL)
    readme = re.sub(regex, fr"\g<1>\n{table}\n\g<2>", readme)

    with open(filename, "w") as file:
        file.write(readme)


config.load_kube_config()
df = pd.DataFrame(columns=template.keys())

for i in client.CoreV1Api().list_node().items:
    df = df.append(pd.Series(
            [rgetattr(i, f) for f in template.values()], index=template.keys()
        ), ignore_index=True)

update_readme(df.sort_values(["hostname"]).to_markdown(index=False))
