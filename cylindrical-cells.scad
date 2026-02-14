include <configurable-bin.scad>
gridz = 10;

$fa = 4;
$fs = 0.25; // .01

// Diameter of each cell
cell_diameter = 16;
// Height of each cell
cell_height = 85;
// Target gap between cells
cell_gap = 1;
// How much of the cell should stick out of the bin to grab onto? 0.35 means 35% should stick out
cell_grab_length = 0.35;
// How far should the cell be recessed into the box? Setting this to the same or a higher value as cell_grab_length makes the bin stackable.
recess = 0;
// Should cells be staggered (hex pattern)? In some circumstances, this can fit slightly more cells
stagger = false;

margin = STACKING_LIP_SIZE[0] + 0.5;

bin_render(bin1) {
    infill = bin_get_infill_size_mm(bin1);
    assert(infill.z >= (1-cell_grab_length+recess)*cell_height, "Not enough vertical height! Increase gridz, increase the cell_grab_length, or reduce the recess");
    translate([-infill[0]/2, -infill[1]/2, -recess*cell_height]) cube([infill[0], infill[1], recess*cell_height]);
    usable = bin_get_bounding_box(bin1) - [margin * 2, margin * 2];
    dia_adj = stagger?sqrt(3)/2:1;
    county = floor((usable[1]+cell_gap*dia_adj)/(cell_diameter+cell_gap)/dia_adj);
    gapy = county == 1 ? 0 : (usable[1]-cell_diameter)/(county-1);
    countx_standard = floor((usable[0]+cell_gap)/(cell_diameter+cell_gap));
    gapx = countx_standard == 1 ? cell_diameter+cell_gap : (usable[0]-cell_diameter)/(countx_standard-1);
    for (yi = [0:county-1]) {
        stagger_here = stagger && yi%2==1;
        countx = stagger_here && countx_standard > 1 ? floor((usable[0]+cell_gap-(stagger_here?cell_diameter:0))/(cell_diameter+cell_gap)) : countx_standard;
        shiftx = !stagger_here ? 0 : countx_standard == 1 ? usable[0]-cell_diameter : (usable[0]-(countx-1)*gapx-cell_diameter)/2;
        for (xi = [0:countx-1]) translate([(-usable[0]+cell_diameter)/2+gapx*xi+shiftx, (-usable[1]+cell_diameter)/2+gapy*yi, (cell_grab_length-recess-1)*cell_height]) cylinder(r = cell_diameter/2, h = cell_height);
    }
}
