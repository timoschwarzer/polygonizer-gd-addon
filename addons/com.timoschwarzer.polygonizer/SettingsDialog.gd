tool
extends ConfirmationDialog

onready var resolution_spinbox = get_node("ResolutionSpinBox")
onready var margin_spinbox = get_node("MarginSpinBox")
onready var preview_checkbox = get_node("PreviewCheckBox")

func set_poly_resolution(_resolution):
	resolution_spinbox.set_value(_resolution)

func get_poly_resolution():
	return resolution_spinbox.get_value()

func set_poly_margin(_margin):
	margin_spinbox.set_value(_margin)

func get_poly_margin():
	return margin_spinbox.get_value()

func set_poly_preview(_preview):
	preview_checkbox.set_pressed(_preview)

func get_poly_preview():
	return preview_checkbox.is_pressed()