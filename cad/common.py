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

def render(name: str, doc: str, render):
        """
        display and save object
        """
        show(render)
        p = Path(name)
        cq.exporters.export(render, f'{p}.stl')

        # with open(p.parent / "README.md", "w") as file:
        #     file.write(f"{doc}\n![]({p.name}.svg)")
