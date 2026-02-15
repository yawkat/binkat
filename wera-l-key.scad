include <configurable-bin.scad>
gridx = 2;
gridy = 6;
gridz = 4;

$fa = 4;
$fs = 0.25; // .01

// 0: diameter of the plastic handle sleeve
// 1: length of the main body
// 2: length of the short arm
wrench_dimensions = [
    [13.75, 236, 54.3],
    [11.68, 205, 48.5],
    [8.46, 179, 39.5],
    [7.64, 159, 34],
    [6.23, 141, 30.3],
    [5.01, 127, 24.7],
    [4.07, 114, 22.7],
    [4.02, 103, 19.2],
    [4.11, 93, 17.1],
];

// Extra length for the short arm of each wrench
tolerance_short_arm = 1;
// Extra length for the short arm of the last wrench. Note that if this is too high, the wrench diameters will shrink to compensate!
tolerance_short_arm_last = 0.2;
// Extra length of the main arm of each wrench. This ends up as a gap to the south side of the bin
tolerance_main_arm = 10;
// How far to drop the wrench. The first value is the north drop, the second value the south drop. Different values for north and south lead to the wrenches being placed at an angle. For example, with 4mm north drop and 1mm south drop, the wrenches will be angled so that the south side will point slightly upwards.
drop = [4, 1];

// Dimensions of the pocket at the bottom of the bin, which is used to press down on a wrench to take it out. First value is height, second value is depth.
press_pocket = [40, 10];

// Should the bin be stackable?
stackable = true;

/* [Hidden] */

_D = 0;
_L_MAIN = 1;
_L_SHORT = 2;

cumulative_diameter = [for (i = 0, sum = wrench_dimensions[0][_D]; i < len(wrench_dimensions); sum = sum + wrench_dimensions[i+1][_D], i = i + 1) sum];

extend_up = 20;

module wrench_cylinder(d, h) {
    if (extend_up == 0) {
        cylinder(d=d, h=h);
    } else {
        linear_extrude(h) {
            circle(d=d);
            translate([-d/2, -extend_up]) square([d, extend_up]);
        }
    }
}

module wrench_angle(d, min_r, max_r) {
    intersection() {
        hull() {
            translate([min_r, min_r]) rotate([0, 0, 180]) rotate_extrude(angle=90) translate([min_r, 0]) {
                circle(d=d);
                if (extend_up != 0) {
                    translate([-d/2, 0]) square([d, extend_up]);
                }
            }
            translate([min_r, 0]) rotate([0, 90]) rotate([0, 0, -90]) wrench_cylinder(d=d, h=max_r-min_r);
            translate([0, min_r]) rotate([-90, 0]) wrench_cylinder(d=d, h=max_r-min_r);
        }
        
        translate([max_r, max_r]) rotate([0, 0, 180]) rotate_extrude(angle=90) translate([max_r, 0]) {
            circle(d=d);
            translate([0, -d/2]) square([max_r-min_r, d]);
            if (extend_up != 0) {
                translate([-d/2, 0]) square([max_r-min_r+d/2, extend_up]);
            }
        }
    }
}

module wrench(d, length_main, length_short) {
    min_r = d/2+1;
    max_r = (length_short-d/2)/2;
    wrench_angle(d = d, min_r = min_r, max_r = max_r);
    
    extra = 0.01; // avoids rounding errors
    translate([max_r-extra, 0]) rotate([0, 90]) rotate([0, 0, -90]) wrench_cylinder(d=d, h=length_short-max_r-d/2+extra);
    translate([0, max_r-extra]) rotate([-90, 0]) wrench_cylinder(d=d, h=length_main-max_r-d/2+extra);
}

//wrench(d = 10, length_main = 100, length_short = 50);

bin_render(bin1) mirror([1, 0]) {
    infill = bin_get_infill_size_mm(bin1);
    inset = stackable ? wrench_dimensions[0][_D]*0.6 : 0;
    echo(infill=infill);
    gap = (infill.x - cumulative_diameter[len(cumulative_diameter)-2] - wrench_dimensions[len(wrench_dimensions)-1][2] - tolerance_short_arm_last) / len(wrench_dimensions);
    echo(cumulative_diameter=cumulative_diameter);
    echo(gap=gap);
    for (i = [0:len(wrench_dimensions)-1]) {
        wd = wrench_dimensions[i];
        translate([
            -infill.x/2 + cumulative_diameter[i] - wd[_D]/2 + (i+0.5) * gap,
            infill.y/2 - tolerance_main_arm - wd[_L_MAIN] + (wd[_D]+gap)/2,
            -inset - drop[0]
            ]) {
                rotate([-asin((drop[1]-drop[0])/wd[_L_MAIN]), 0]) wrench(wd[_D]+gap, wd[_L_MAIN]+tolerance_main_arm, wd[_L_SHORT]+tolerance_short_arm);
            };
    }
    // press pocket
    translate([-infill.x/2, infill.y/2-press_pocket.x, -press_pocket.y-inset]) cube([infill.x, press_pocket.x, press_pocket.y]);
    // inset to make the bin stackable
    translate([-infill.x/2, -infill.y/2, -inset]) cube([infill.x, infill.y, inset]);
}