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
        cq.exporters.export(render, f'{p}.svg')
        # ipyplot.plot_images([f'clip/hook.svg'], img_width=250, force_b64=True)

        # with open(p.parent / "README.md", "w") as file:
        #     file.write(f"{doc}\n![]({p.name}.svg)")
