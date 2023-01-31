import cadquery as cq
import cqkit
from cq_server.ui import ui, show_object
from pathlib import Path

dir = Path(__file__).resolve().parent

obj = (
    cqkit.Ribbon("XY", [
        ("start", {"position": (0, 0), "direction": 0, "width": 5}),
        # length of surface mount
        ("line", {"length": 60}),
        ("arc", {"radius": 10, "angle": 90}),
        # height
        ("line", {"length": 80}),
        # tenting angle
        ("arc", {"radius": 20, "angle": 90-30}),
        # length under keyboard
        ("line", {"length": 110}),
    ]).render().extrude(20)
)

show_object(obj)
cq.exporters.export(obj, str(dir / 'main.stl'))
