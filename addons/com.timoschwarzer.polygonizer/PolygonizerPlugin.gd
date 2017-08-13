tool
extends EditorPlugin

const Polygonizer = preload("Polygonizer.gd")
const SettingsDialog = preload("SettingsDialog.tscn")
const PolygonPreview = preload("PolygonPreview.tscn")

var button
var settings_button
var settings_dialog
var enable_preview = false
var polygonizer = Polygonizer.new()
var previews = []

func _enter_tree():
	settings_button = ToolButton.new()
	settings_button.set_text("Polygonizer Settings")
	settings_button.connect("pressed", self, "_on_settings_button_clicked")
	button = ToolButton.new()
	button.set_text("Polygonize")
	button.connect("pressed", self, "_on_polygonize_button_clicked")
	button.hide()
	settings_dialog = SettingsDialog.instance()
	get_base_control().add_child(settings_dialog)
	
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, settings_button)
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, button)
	get_selection().connect("selection_changed", self, "_on_selection_changed")
	settings_dialog.connect("confirmed", self, "_on_settings_dialog_confirmed")

func _on_selection_changed():
	update_previews()
	if (get_selection().get_selected_nodes().size() == 0):
		button.hide()
	else:
		for node in get_selection().get_selected_nodes():
			if (!is_valid_node(node)):
				button.hide()
				return
		button.show()

func _on_settings_button_clicked():
	settings_dialog.set_poly_resolution(polygonizer.resolution)
	settings_dialog.set_poly_margin(polygonizer.margin)
	settings_dialog.set_poly_preview(enable_preview)
	settings_dialog.popup_centered()

func _on_settings_dialog_confirmed():
	polygonizer.resolution = settings_dialog.get_poly_resolution()
	polygonizer.margin = settings_dialog.get_poly_margin()
	enable_preview = settings_dialog.get_poly_preview()
	update_previews()

func _on_polygonize_button_clicked():
	var added_polygons = []
	var selected_nodes = get_selection().get_selected_nodes()
	get_selection().clear()
	
	for node in selected_nodes:
		if (is_valid_node(node)):
			var image = get_image_from_node(node)
			var polygon = polygonizer.scan(image)
			var polygon2d = Polygon2D.new()
			var node_name = node.get_name()
			var target_pos = get_target_polygon_pos(node, image)
			var parent = node.get_parent()
			var target_node_pos = parent.get_children().find(node)
			
			polygon2d.set_polygon(Vector2Array(polygon))
			polygon2d.set_pos(target_pos)
			polygon2d.set_rot(node.get_rot())
			polygon2d.set_scale(node.get_scale())
			polygon2d.set_texture(node.get_texture())
			polygon2d.get_texture()
			node.get_parent().remove_child(node)
			polygon2d.set_name(node_name)
			parent.add_child(polygon2d)
			parent.move_child(polygon2d, target_node_pos)
			polygon2d.set_owner(get_tree().get_edited_scene_root())
			added_polygons.append(polygon2d)
	
	if (added_polygons.size() > 0):
		for node in added_polygons:
			get_selection().add_node(node)
			node.update()

func _exit_tree():
	button.queue_free()
	settings_dialog.queue_free()
	settings_button.queue_free()
	for preview in previews:
		preview.queue_free()

func update_previews():
	for preview in previews:
		preview.queue_free()
	previews.clear()
	
	if (!enable_preview): return
	for node in get_selection().get_selected_nodes():
		if (is_valid_node(node)):
			var image = get_image_from_node(node)
			var polygon = polygonizer.scan(image)
			var preview_node = PolygonPreview.instance()
			node.add_child(preview_node)
			preview_node.set_polygon(polygon)
			preview_node.set_global_pos(get_target_polygon_pos(node, image))
			previews.append(preview_node)

func is_valid_node(node):
	return (node extends Sprite)

func get_image_from_node(node):
	return node.get_texture().get_data()

func get_target_polygon_pos(node, image):
	var target_pos = node.get_pos()
	if (node extends Sprite):
		target_pos += node.get_offset()
		if (node.is_centered()):
			target_pos -= Vector2(image.get_width(), image.get_height()) * node.get_scale() * 0.5
	return target_pos
