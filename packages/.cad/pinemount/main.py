import cadquery as cq
from cq_server.ui import ui, show_object
from pathlib import Path
dir = Path(__file__).resolve().parent

thickness = 2
angle = 60

phone = {
    "width": 80,
    "height": 160,
    "depth": 14,
    "usb": {
        "width": 12,
        "height": 6,
    }
}

watch = {
    "width": 37,
    "height": 40,
    "offset": 50 # vertical location on base
}

earbuds = {
    "width": 48,
    "depth": 67,
    "offset": 40, # distance from the bottom of phone back plate
    "usb": {
        "depth": 18.75,
        "width": 12,
        "height": 6,
        "offset": 8, # distance from bottom of case to usb port
    }
}
attachment = {
    "spread": 10,
    "width": 30,
    "depth": thickness,
    "thickness": 6,
    "taper": 20
}

bracket = {
    "length": 200,
    "width": 10,
    "size": 20 # length of one edge on the attachment
}

earbuds_obj = (
    cq.Workplane()
    # draw the main body
    .box(earbuds['depth'], earbuds['width'], thickness*3)
    .tag("body")
    # round corners
    .edges("|Z").fillet(12)
    # create lip
    .faces("+Z").shell(thickness)

    # add wire bracket
    .faces(">Y").workplane()
    .transformed(offset=cq.Vector(0, 4, 0))
    # create outer shell
    .rect(
        earbuds['usb']['width']+thickness*2,
        earbuds['usb']['height']+thickness*2+earbuds['usb']['offset']
    ).extrude(earbuds['usb']['depth'] + thickness*2)
    # subtract negative space
    .faces(">Y").workplane()
    .transformed(offset=cq.Vector(0, earbuds['usb']['height']-thickness, -thickness))
    .rect(
        earbuds['usb']['width'],
        earbuds['usb']['height'],
    ).extrude(-earbuds['usb']['depth']-thickness, combine='cut')
    # add wire cutout
    .faces(">Z").workplane()
    .transformed(offset=cq.Vector(0, -thickness*4, -earbuds['usb']['height']-thickness))
    .rect(6,earbuds['usb']['depth']+thickness*4)
    .extrude(earbuds['usb']['height']+thickness, combine='cut')

    # add attachment
    .workplaneFromTagged('body')
    .transformed(
        offset=cq.Vector(20, attachment['width']*1.3, -thickness),
        rotate=cq.Vector(0, angle, 0)
    )
    .rect(attachment['thickness'], attachment['width']).extrude(attachment['depth'])

)
cq.exporters.export(earbuds_obj, str(dir / 'earbuds.stl'))
# show_object(earbuds_obj)

watch_obj = (
    cq.Workplane()
    # draw the back plane
    # TODO: remove +thicknesses?
    .box(watch['height'], watch['width'], thickness*3)
    # round the corners
    .edges("|Z").fillet(8)
    # create inset
    .faces("+Z").shell(thickness)

    # locate notch for wire
    .faces(">Y").workplane()
    .transformed(offset=cq.Vector(0, 0, -2))
    # draw wire notch
    .rect(3,6).extrude(2, combine="cut")

    # locate attachment
    .transformed(offset=cq.Vector(0, -thickness*1.5, 1))
    # draw attachment
    .rect(attachment['thickness'], attachment['depth'])
    .extrude(attachment['width'])
)
cq.exporters.export(watch_obj, str(dir / 'watch.stl'))
# show_object(watch_obj)

base = (cq.Workplane('front')
    # tilt
    .transformed(rotate=cq.Vector(0, angle))
    # add back plane
    .box(phone['height'], phone['width'], thickness)
    .tag('body')
    
    # add bottom support
    .faces("<Z").workplane(offset=-thickness/2)
    # translate
    .center(0, (phone['depth']/2) + (thickness/2))
    # draw
    .box(phone['width'], phone['depth'], thickness)

    # draw charger hole
    .faces("<Z").workplane()
    .rect(phone['usb']['width'],phone['usb']['height']).extrude(-thickness, combine="cut")

    # base
    .workplaneFromTagged('body')
    .transformed(
        rotate=cq.Vector(0, -angle, 0),
        offset=cq.Vector(phone['height']/2, 0, -30)
    )
    .box(phone['height']/2, phone['width'], thickness)
    # front connection between base and back support
    .faces(">X").workplane()
    .transformed(
        rotate=cq.Vector(10, 0, 0),
        offset=cq.Vector(0, 10, 0)
    )
    .box(phone['width'], 20, thickness)

    # add attachment support brackets
    .workplaneFromTagged('body')
    .transformed(offset=cq.Vector(0, -phone['width']/3,-thickness/2))
    .pushPoints([
        (-watch["offset"],0),
        (earbuds['offset'],0)
    ])
    .rect(attachment['thickness']+(thickness*4),attachment['width']/2)
    .extrude(-thickness*4, taper=20)
    # cut attachment hole
    .pushPoints([
        (-watch["offset"],0),
        (earbuds['offset'],0)
    ])
    # add 0.5mm for tolerance
    .rect(attachment['thickness']+0.5,attachment['width']/2)
    .extrude(-thickness*2, combine='cut')
)
cq.exporters.export(base, str(dir / 'base.stl'))
# show_object(base)

assy = (
    cq.Assembly(base, name="base")
    .add(earbuds_obj, name='earbuds',
        loc=cq.Location(cq.Vector(-16,-70,-38)), 
        color=cq.Color("pink")
    )
    .add(watch_obj, name='watch',
        loc=cq.Location(cq.Vector(-4,-65,watch['offset']), cq.Vector(0,1,0),angle), 
        color=cq.Color("cyan")
    )
)

cq.exporters.export(assy.toCompound(), str(dir / 'main.svg'), 
     opt={"projectionDir": (0.7, -0.6, 0.5)})
show_object(assy)