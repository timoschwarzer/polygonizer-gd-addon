tool
extends Node2D

var polygon = []

func set_polygon(_polygon):
	polygon = _polygon
	update()

func _draw():
	for coord in polygon:
		draw_circle(coord, 3, Color(0, 1, 0))
	
	var last_coord = null
	for coord in polygon:
		if (last_coord == null):
			last_coord = coord
			continue
		draw_line(last_coord, coord, Color(1, 1, 1))
		last_coord = coord
	draw_line(last_coord, polygon[0], Color(1, 1, 1))