import cadquery as cq
import cqkit
from cq_server.ui import ui, show_object
from pathlib import Path

dir = Path(__file__).resolve().parent

obj = (cqkit.Ribbon("XY", [
    ("start", {"position": (0, 0), "direction": 30, "width": 5}),
    # hook over mount
    ("arc", {"radius": 20, "angle": 180}),
    # height
    ("line", {"length": 200}),
    # hook for rings
    ("arc", {"radius": 40, "angle": 180}),
]).render().extrude(20))

show_object(obj)
cq.exporters.export(obj, str(dir / 'main.stl'))
