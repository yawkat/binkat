
include <gridfinity-rebuilt-openscad/src/core/standard.scad>
use <gridfinity-rebuilt-openscad/src/core/gridfinity-rebuilt-utility.scad>
use <gridfinity-rebuilt-openscad/src/core/gridfinity-rebuilt-holes.scad>
use <gridfinity-rebuilt-openscad/src/core/bin.scad>
include <configurable-bin.scad>

$fn=40;

// Diameter of each coin cell
cell_diameter = 12;
// Height of each coin cell
cell_height = 11.2;
// Target gap between cells, in mm
cell_gap = 1;
// How much of the cell should stick out of the bin to grab onto? 0.35 means 35% should stick out
cell_grab_length = 0.35; // [0:1]
// How far should the cell be recessed into the box? Setting this to the same or a higher value as cell_grab_length makes the bin stackable.
recess = 0.35;
// Minimum space for the label that is kept clear of cells
min_label_height = 10;

margin = STACKING_LIP_SIZE[0]+0.5;

bin_render(bin1) {
    infill = bin_get_infill_size_mm(bin1);
    recess_abs = recess * cell_diameter;
    translate([-infill[0]/2, -infill[1]/2, -recess_abs])cube([infill[0], infill[1], recess_abs]);
    usable = bin_get_bounding_box(bin1) - [margin * 2, margin * 2 + min_label_height];
    translate([-usable[0]/2, -usable[1]/2+cell_diameter/2-min_label_height/2, -cell_diameter/2+(cell_grab_length-recess)*cell_diameter]) {
        count_x = round(usable[0]/(cell_height+cell_gap));
        gap_x = (usable[0] - count_x * cell_height) / (count_x - 1);
        gap_y = gap_x;
        count_y = floor(usable[1]/(cell_diameter+gap_y));
        for (xi = [0:count_x-1]) for (yi = [0:count_y-1]) translate([xi * (cell_height + gap_x), (cell_diameter+gap_y)*yi, 0]) {
            translate([0, -cell_diameter/2, 0]) cube([cell_height, cell_diameter, 100]);
            rotate([0, 90, 0]) cylinder(h=cell_height, r=cell_diameter/2);
        }
    }
}