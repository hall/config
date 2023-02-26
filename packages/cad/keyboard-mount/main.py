import cadquery as cq
import cqkit
from cq_server.ui import ui, show_object
from pathlib import Path

dir = Path(__file__).resolve().parent

tent = 30
height = 60

obj = (
    cqkit.Ribbon("XY", [
        ("start", {"position": (0, 0), "direction": 0, "width": 5}),
        # length of surface mount
        ("line", {"length": 113.9}),
        ("arc", {"radius": 10, "angle": 90}),
        # height on short end
        ("line", {"length": height}),
        # tenting angle
        ("arc", {"radius": 20, "angle": 90-tent}),
        # length under keyboard
        ("line", {"length": 120}),
        # angle back up
        ("arc", {"radius": 20, "angle": 90+tent}),
        # height on long end
        ("line", {"length": 110}),
        # angle to close the loop
        ("arc", {"radius": 20, "angle": 90}),
    ]).render().extrude(20)
)

show_object(obj)
cq.exporters.export(obj, str(dir / 'main.stl'))
