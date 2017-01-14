extends AnimationPlayer

#properties
export var mouse_control = true
export var optflow_control = false
export var surf_control = false

#members
var surf_spot
var unmatch_spot
var label_input
var match_spot1
var match_spot2
var match_spot3
var match_label1
var match_label2
var match_label3
var status

#states
var hold = false
var labels = Array()

func _ready():
	surf_spot = get_node("SurfSpot")
	unmatch_spot = get_node("SurfSpot/UnmatchSpot")
	label_input = get_node("SurfSpot/UnmatchSpot/LineEdit")
	match_spot1 = get_node("SurfSpot/MatchSpot1")
	match_spot2 = get_node("SurfSpot/MatchSpot2")
	match_spot3 = get_node("SurfSpot/MatchSpot3")
	match_label1 = get_node("SurfSpot/MatchSpot1/Label")
	match_label2 = get_node("SurfSpot/MatchSpot2/Label")
	match_label3 = get_node("SurfSpot/MatchSpot3/Label")
	status = get_node("SurfSpot/Status")
	
	label_input.connect("text_entered", Main, "set_label")
	Main.connect("label_changed", status, "set_text")
	
	if mouse_control:
		surf_spot.connect("mouse_enter", self, "spawn_labels")
		unmatch_spot.connect("mouse_enter", self, "show_label_input")
		match_spot1.connect("mouse_enter", self, "select_match", [match_spot1])
		match_spot2.connect("mouse_enter", self, "select_match", [match_spot2])
		match_spot3.connect("mouse_enter", self, "select_match", [match_spot3])
		get_parent().get_parent().connect("mouse_enter", self, "despawn_labels", [true])
		
	if optflow_control:
		unmatch_spot.connect("drag_enter", self, "show_label_input")
		match_spot1.connect("drag_enter", self, "select_match", [match_spot1])
		match_spot2.connect("drag_enter", self, "select_match", [match_spot2])
		match_spot3.connect("drag_enter", self, "select_match", [match_spot3])
		Main.connect("drag_released", self, "despawn_labels", [true])
		if !surf_control:
			surf_spot.connect("trigger_enter", self, "spawn_labels")
			surf_spot.connect("drag_enter", self, "spawn_labels", [true])
		
	if surf_control:
		ObjectRecognition.connect("on_histogram", self, "show_histogram")
		surf_spot.connect("trigger_enter", Main, "analyse_surf", [surf_spot, surf_spot.shape])
		label_input.connect("text_entered", ObjectRecognition, "feedback")
		
	despawn_labels()
	pass

func show_histogram(_labels, _distances):
	if !hold:
		labels = _labels
		if labels.size() >= 1:
			match_label1.set_text(labels[0])
		if labels.size() >= 2:
			match_label2.set_text(labels[1])
		if labels.size() >= 3:
			match_label3.set_text(labels[2])
		spawn_labels()
	pass
	
func spawn_labels(force = false):
	if force:
		hold = false
	elif hold:
		pass
	else:
		play("spawn_spots")
		label_input.set_hidden(true)
		if optflow_control:
			Main.start_drag(surf_spot, Optflow.CIRCLE)
			pass
		pass
	pass

func despawn_labels(force = false):
	print("despawn")
	if force || !hold:
		play("despawn_spots")
		match_label1.set_text("N/A")
		match_label2.set_text("N/A")
		match_label3.set_text("N/A")
		label_input.set_hidden(true)
		hold = false
	pass
	
func show_label_input():
	play("only_unmatch")
	label_input.clear()
	label_input.set_hidden(false)
	label_input.grab_focus()
	hold = true
	pass
	
func select_match(node):
	if node == match_spot1:
		play("only_match1")
		Main.set_label(match_label1.get_text())
	elif node == match_spot2:
		play("only_match2")
		Main.set_label(match_label2.get_text())
	elif node == match_spot3:
		play("only_match3")
		Main.set_label(match_label3.get_text())
	label_input.set_hidden(true)
	hold = true
	pass
	
func release_hold():
	hold = false
	pass