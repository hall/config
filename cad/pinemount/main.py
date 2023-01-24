import cadquery as cq
from cq_server.ui import ui, show_object
from pathlib import Path
dir = Path(__file__).resolve().parent

# from cq_vscode import show_object, reset_show, set_defaults
# reset_show() # use for reapeated shift-enter execution to clean object buffer
# set_defaults(axes=True, transparent=False, collapse=1, grid=(True, True, True))

thickness = 2
angle = 80

phone = {
    "width": 80,
    "height": 160,
    "depth": 14
}
earbuds = {
    "width": 50,
    "depth": 70,
    "offset": 40 # distance from the bottom of phone back plate
}
watch = {
    "width": 37,
    "height": 40,
    "offset": 120
}

attachment = {
    "spread": 10,
    "width": 50,
    "depth": thickness/2,
    "thickness": 6,
    "taper": 20
}

bracket = {
    "length": 200,
    "width": 10,
    "size": 20 # length of one edge on the attachment
}

earbuds = (
    cq.Workplane()
    # draw the main body
    .box(earbuds['depth'], earbuds['width'], thickness)
    .tag("body")
    # round corners
    .edges("|Z").fillet(5)
    # create lip
    .faces("+Z").shell(thickness)

    # add wire bracket
    .workplaneFromTagged('body')
    # .rect(10,10).extrude(16)
    # add bracket attachment
    # .faces(">Y").workplane()
    # .transformed(offset=cq.Vector(0,-3, -20),)
    # .rect(10,thickness*2).extrude(35)
    # subtract negative space
    # .faces(">Y").workplane()
    # .rect(10,10).extrude(16)

    # add attachment
    .workplaneFromTagged('body')
    .transformed(
        offset=cq.Vector(20, attachment['width']/2, -thickness*2-1),
        rotate=cq.Vector(0, angle, 0)
    )
    .rect(attachment['thickness'], attachment['width']).extrude(attachment['depth'])

)
cq.exporters.export(earbuds, str(dir / 'earbuds.stl'))
# show_object(earbuds)


watch = (
    cq.Workplane()
    # draw the back plane
    # TODO: remove +thicknesses?
    .box(watch['height'], watch['width'], thickness*3)
    # round the corners
    .edges("|Z").fillet(8)
    # create inset
    .faces("+Z").shell(thickness/2)

    # locate notch for wire
    .faces(">Y").workplane().transformed(offset=cq.Vector(0, 0, -2))
    # draw wire notch
    .rect(3,6).extrude(2, combine="cut")

    # locate attachment
    .transformed(offset=cq.Vector(0, -thickness*1.75, -20),)
    # draw attachment
    .rect(attachment['thickness'], attachment['depth'])
    .extrude(attachment['width'])
)
cq.exporters.export(watch, str(dir / 'watch.stl'))
# show_object(watch)

base = (cq.Workplane('front')
    # tilt
    .transformed(rotate=cq.Vector(0, angle))
    # add back plane
    .box(phone['height']/1.5, phone['width'], thickness)
    .tag('body')
    
    # add bottom support
    .faces("<Z").workplane(offset=-thickness/2)
    # translate
    .center(0, (phone['depth']/2) + (thickness/2))
    # draw
    .box(phone['width'], phone['depth'], thickness)

    # draw charger hole
    .faces("<Z").workplane()
    .rect(12,6).extrude(-thickness, combine="cut")

    # base
    .workplaneFromTagged('body')
    .transformed(
        rotate=cq.Vector(0, -angle, 0),
        offset=cq.Vector(60, 0, -30)
    )
    .box(phone['height']/2, phone['width'], thickness)
    .transformed(
        rotate=cq.Vector(0, -angle, 0),
        offset=cq.Vector(42, 0, 9)
    )
    .box(20, phone['width'], thickness)
)
cq.exporters.export(base, str(dir / 'base.stl'))
# show_object(base)

assy = (
    cq.Assembly(base, name="base")
    .add(earbuds, name='earbuds',
        loc=cq.Location(cq.Vector(-14,-70,-40)), 
        color=cq.Color("pink")
    )
    .add(watch, name='watch',
        loc=cq.Location(cq.Vector(-6,-65,30), cq.Vector(0,1,0),angle), 
        color=cq.Color("cyan")
    )
)

cq.exporters.export(assy.toCompound(), str(dir / 'main.svg'), 
     opt={"projectionDir": (0.7,-0.3,0.2)})
show_object(assy)