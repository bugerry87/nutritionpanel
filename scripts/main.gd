#Main Script
#Initialize all start conditions here.
extends Node

const TO_CIRCLE_AREA = 3.14159 / 4

#states
var selected_label = ""
var label_id = 0
var drag_shape = {"shape":0, "center":Vector2(), "size_x":0, "size_y":0}
var has_drag = false

#signals
signal label_changed(string)
signal drag_shape_changed()
signal drag_released()

#help functions
static func calc_mean_flow(node, shape):
	if !node.is_inside_tree():
		return Vector3()
	var v_width = node.get_viewport_rect().size.x
	var v_height = node.get_viewport_rect().size.y
	var aspect = Vector2(Optflow.get_width() / v_width, Optflow.get_height() / v_height)
	var size_x = node.get_global_transform().x.x * node.get_size().width * aspect.x
	var size_y = node.get_global_transform().y.y * node.get_size().height * aspect.y
	var pos_x = node.get_global_transform().o.x * aspect.x
	var pos_y = node.get_global_transform().o.y * aspect.y
	if shape == Optflow.CIRCLE:
		var anchor = Vector2(pos_x + size_x/2, pos_y + size_y/2)
		return Optflow.get_mean(shape, anchor, size_x) / (size_x * size_x * TO_CIRCLE_AREA)
	elif shape == Optflow.RECT:
		var anchor = Vector2(pos_x, pos_y)
		return Optflow.get_mean(shape, anchor, size_x, size_y) / (size_x * size_y)
	pass
	
static func analyse_surf(node, shape):
	if !node.is_inside_tree():
		return
	var a_width = WebCam.get_width() / node.get_viewport_rect().size.x
	var a_height = WebCam.get_height() / node.get_viewport_rect().size.y
	var size_x = node.get_global_transform().x.x * node.get_size().width * a_width
	var size_y = node.get_global_transform().y.y * node.get_size().height * a_height
	var pos_x = node.get_global_transform().o.x * a_width
	var pos_y = node.get_global_transform().o.y * a_height
	if shape == ObjectRecognition.CIRCLE:
		var anchor = Vector2(pos_x + size_x/2, pos_y + size_y/2)
		ObjectRecognition.analyse(shape, anchor, size_x)
		pass
	elif shape == ObjectRecognition.RECT:
		var anchor = Vector2(pos_x, pos_y)
		ObjectRecognition.analyse(shape, anchor, size_x, size_y)
		pass
	pass
	
func check_drag_hit(node, shape):
	if !node.is_inside_tree():
		return
	var a_width = node.get_viewport_rect().size.x / WebCam.get_width()
	var a_height = node.get_viewport_rect().size.y / WebCam.get_height()
	var size_x = node.get_global_transform().x.x * node.get_size().width * 0.5
	var size_y = node.get_global_transform().y.y * node.get_size().height * 0.5
	var pos_x = node.get_global_transform().o.x + size_x
	var pos_y = node.get_global_transform().o.y + size_y
	var center = Vector2(drag_shape["center"].x * a_width, drag_shape["center"].y * a_height)
	if shape == Optflow.CIRCLE:
		var anchor = Vector2(pos_x, pos_y)
		return (center - anchor).length() < size_x
	elif shape == Optflow.RECT:
		return abs(center.x - pos_x) < size_x &&\
			abs(center.y - pos_y) < size_y
	pass

func _ready():
	WebCam.connect("on_error", self, "handle_error")
	Optflow.connect("on_error", self, "handle_error")
	Optflow.connect("on_velocities", self, "handle_velocities")
	ObjectRecognition.connect("on_error", self, "handle_error")
	pass
	
func handle_error(err):
	print(err)
	pass
	
func start_drag(node, shape):
	has_drag = false
	var a_width = WebCam.get_width() / node.get_viewport_rect().size.x
	var a_height = WebCam.get_height() / node.get_viewport_rect().size.y
	var size_x = node.get_global_transform().x.x * node.get_size().width * a_width
	var size_y = node.get_global_transform().y.y * node.get_size().height * a_height
	var pos_x = node.get_global_transform().o.x * a_width
	var pos_y = node.get_global_transform().o.y * a_height
	if shape == Optflow.CIRCLE:
		var anchor = Vector2(pos_x + size_x/2, pos_y + size_y/2)
		Optflow.new_track(shape, anchor, size_x)
		Optflow.start(Optflow.LUCAS_KANADE)
		pass
	elif shape == Optflow.RECT:
		var anchor = Vector2(pos_x, pos_y)
		Optflow.new_track(shape, anchor, size_x, size_y)
		Optflow.start(Optflow.LUCAS_KANADE)
		pass
	drag_shape["shape"] = shape
	drag_shape["center"] = Vector2(pos_x + size_x/2, pos_y + size_y/2)
	drag_shape["size_x"] = size_x
	drag_shape["size_y"] = size_y
	pass
	
func release_drag():
	Optflow.pause(Optflow.LUCAS_KANADE)
	drag_shape["shape"] = 0
	drag_shape["center"] = Vector2()
	drag_shape["size_x"] = 0
	drag_shape["size_y"] = 0
	emit_signal("drag_released")
	pass
	
func handle_velocities(from, to):
	var count = 0
	var new_pos = Vector2()
	
	print(from.size())
	
	if has_drag && from.size() == 0 && to.size() == 0:
		has_drag = false
		print("drag_released")
		emit_signal("drag_released")
		
	
	if drag_shape["shape"] == Optflow.CIRCLE:
		for p in range(from.size()):
			if to.size() > p:
				var length = (from[p] - drag_shape["center"]).length()
				if length < drag_shape["size_x"]:
					new_pos += from[p]
					count += 1
					pass
			else:
				break
			pass
		pass
	elif drag_shape["shape"] == Optflow.RECT:
		for p in range(from.size()):
			if to.size() > p:
				if abs(from[p].x - drag_shape["center"].x) > drag_shape["size_x"]/2:
					pass
				elif abs(from[p].y - drag_shape["center"].y) > drag_shape["size_y"]/2:
					pass
				else:
					new_pos += from[p]
					count += 1
					pass
			else:
				break
			pass
		pass
		
	if count != 0:
		has_drag = true
		drag_shape["center"] = new_pos / count
		emit_signal("drag_shape_changed")
	pass
	
func set_label(label):
	label_id += 1
	selected_label = label
	emit_signal("label_changed", label)
	pass
