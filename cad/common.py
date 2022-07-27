import cadquery as cq
from jupyter_cadquery.cadquery import show
from jupyter_cadquery import set_defaults
from pathlib import Path
import re
import ipyplot

set_defaults(
        axes=True, 
        axes0=True, 
        grid=False, 
        tools=False, 
        theme="dark", 
        default_edgecolor=(0,0,0)
        )

def render(name: str, render):
        """
        display and save object
        """
        show(render)
        p = Path(name)
        cq.exporters.export(render, f'{p}.stl')
        cq.exporters.export(render, f'{p}.svg')
        # ipyplot.plot_images([f'clip/hook.svg'], img_width=250, force_b64=True)

        # update_readme(p.parent, p.name)


def add_figure(match):
     """
     add figure if missing
     """
     if match.group("figure"):
             return "yes"
     else:
             return "no"


def update_readme(directory, name):
    """
    update figures in README.md under directory
    """
    filename = Path(directory) / "README.md"
    with open(filename, "r") as file:
        readme = file.read()

    regex = re.compile(f"(?P<figure><!-- START FIGURE {name} -->).*(<!-- END FIGURE -->)", re.DOTALL)
    readme = regex.sub(add_figure, fr"\g<1>\n!\[{name}\]\({name}.svg\).\n\g<2>", readme)

    with open(filename, "w") as file:
        file.write(readme)
