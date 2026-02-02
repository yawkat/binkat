params:
	mkdir -p build/
	openscad -o build/configurable-bin-params.json --export-format param configurable-bin.scad

model file gridx gridy gridz name stackable args:
	mkdir -p build/printables/{{file}}
	openscad -o "build/printables/{{file}}/{{name}} ({{gridx}}x{{gridy}}{{ if stackable == 'true' { ', stackable' } else { '' } }}, height {{gridz}}).stl" --export-format=binstl -D gridx={{gridx}} -D gridy={{gridy}} -D gridz={{gridz}} -D "recess={{stackable}}?0.35:0" {{args}} {{file}}.scad

clean-models file:
	rm -rf build/printables/{{file}}

printables-zip file:
	cp {{file}}.scad build/printables/{{file}}/
	rm -f build/printables/{{file}}.zip
	cd build/printables/{{file}} && zip -r ../{{file}}.zip .

# CELL 		DIA			HEIGHT
# CR2032	20			3.2
# CR2025	20			2.5
# LR44		11.6		5.4
# LR41		7.9			3.6
# CR1/3N	11.6		10.8
# AA		13.7-14.5	50
# AAA 		10.5		44.5
# 18650		19			70	(with protection)
# 10440		11			48	(with protection)

models: (clean-models "coin-cells") (clean-models "cylindrical-cells") \
	(model "coin-cells" "1" "2" "5" "CR2032" "true" "-D cell_diameter=.4+20 -D cell_height=.4+3.2") \
	(model "coin-cells" "1" "2" "4" "CR2032" "false" "-D cell_diameter=.4+20 -D cell_height=.4+3.2") \
	(model "coin-cells" "1" "1" "4" "CR2032" "false" "-D cell_diameter=.4+20 -D cell_height=.4+3.2") \
	(model "coin-cells" "1" "2" "5" "CR2025" "true" "-D cell_diameter=.4+20 -D cell_height=.4+2.5") \
	(model "coin-cells" "1" "2" "4" "CR2025" "false" "-D cell_diameter=.4+20 -D cell_height=.4+2.5") \
	(model "coin-cells" "1" "1" "4" "CR2025" "false" "-D cell_diameter=.4+20 -D cell_height=.4+2.5") \
	(model "coin-cells" "1" "2" "3" "LR44" "true" "-D cell_diameter=.4+11.6 -D cell_height=.4+5.4") \
	(model "coin-cells" "1" "1" "3" "LR44" "true" "-D cell_diameter=.4+11.6 -D cell_height=.4+5.4") \
	(model "coin-cells" "1" "1" "3" "LR41" "true" "-D cell_diameter=.4+7.9 -D cell_height=.4+3.6") \
	(model "coin-cells" "1" "1" "3" "CR1 3N" "true" "-D cell_diameter=.4+11.6 -D cell_height=.4+10.8") \
	(model "cylindrical-cells" "1" "1" "10" "AA" "true" "-D cell_diameter=15 -D cell_height=1+50") \
	(model "cylindrical-cells" "1" "1" "6" "AA" "false" "-D cell_diameter=15 -D cell_height=1+50") \
	(model "cylindrical-cells" "2" "2" "10" "AA" "true" "-D cell_diameter=15 -D cell_height=1+50") \
	(model "cylindrical-cells" "2" "2" "6" "AA" "false" "-D cell_diameter=15 -D cell_height=1+50") \
	(model "cylindrical-cells" "1" "1" "6" "AAA" "false" "-D cell_diameter=11 -D cell_height=1+44.5") \
	(model "cylindrical-cells" "1" "1" "9" "AAA" "true" "-D cell_diameter=11 -D cell_height=1+44.5") \
	(model "cylindrical-cells" "2" "2" "6" "AAA" "false" "-D stagger=true -D cell_diameter=11 -D cell_height=1+44.5") \
	(model "cylindrical-cells" "2" "2" "9" "AAA" "true" "-D stagger=true -D cell_diameter=11 -D cell_height=1+44.5") \
	(model "cylindrical-cells" "2" "2" "8" "18650" "false" "-D cell_gap=0.4 -D cell_diameter=19 -D cell_height=1+70") \
	(model "cylindrical-cells" "1" "1" "6" "10440" "false" "-D cell_diameter=11 -D cell_height=1+48") \
	(printables-zip "coin-cells") \
	(printables-zip "cylindrical-cells")

