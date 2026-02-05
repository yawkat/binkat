include <configurable-bin.scad>
gridx = 2;
gridy = 5;
gridz = 4;

$fa = 4;
$fs = 0.25; // .01

hex_height = 9;
hex_diameter = 7;
cylinder_diameter = 11;
cylinder_position = 70;
block_width = 16;
block_height = 9;
columns = 4;
inset = 2;

module hexagon() {
    rotate(30) polygon([for (a = [0:60:360]) [sin(a), cos(a)]]);
}

module driver_cutout() {
    translate([0, 0, hex_height/3]) mirror([0, 0, 1]) linear_extrude(hex_height/3, scale=0.7) scale(hex_diameter) hexagon(); 
    translate([0, 0, hex_height/3]) linear_extrude(hex_height/3) scale(hex_diameter) hexagon(); 
    translate([0, 0, 2*hex_height/3]) linear_extrude(hex_height/3, scale=0.7) scale(hex_diameter) hexagon();

    translate([0, 0, cylinder_position]) cylinder(d=cylinder_diameter, h=hex_height);
}

module driver() {
    translate([0, 0, inset]) difference() {
        rotate([90, 0, 0]) linear_extrude(block_height) {
            translate([-block_width/2, 0]) square([block_width, hex_height]);
            translate([-block_width/2, cylinder_position]) square([block_width, hex_height]);
        }
        driver_cutout();
    }
}

bin_render(bin1) {
    infill = bin_get_infill_size_mm(bin1);
    difference() {
        translate([-infill.x/2, -infill.y/2, -infill.z]) cube(infill);
        usable = infill;
        col_width = usable.x / columns;
        translate([0, 0, -infill.z+block_height]) for (i = [0:columns-1]) {
            translate([-usable.x/2+(i+0.5)*col_width, 0]) rotate([90, 0, 0]) driver();
            if (i != 0) translate([-usable.x/2+i*col_width, 0]) rotate([90, 0, 180]) driver();
        }
    }
}