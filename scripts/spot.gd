extends Control

#properties
export(int, "NONE", "RECT", "CIRCLE") var shape = 1
export var min_change = 0.1
export(float, 0.0, 1.0, 0.01) var cooldown = 0.9
export var timeout = 0.0

#states
var old_mean = 0
var change = 0
var timer = 0
var trigger_entered = false
var drag_entered = false

#signals
signal trigger_enter()
signal trigger_exit()
signal drag_enter()
signal drag_exit()

func _ready():
	Optflow.connect("on_flow", self, "check_trigger")
	Main.connect("drag_shape_changed", self, "check_drag")
	set_process(true)
	pass

func _process(delta):
	if timer > 0:
		timer -= delta
	pass
	
func check_trigger():
	if !is_inside_tree():
		return
	
	if !is_ignoring_mouse():
		var mean = Main.calc_mean_flow(self, shape) * 100
		var velo = pow(mean.x, 2) + pow(mean.y, 2)
		change += abs(velo - old_mean)
		if timer > 0:
			pass
		elif change > min_change:
			if !trigger_entered:
				emit_signal("trigger_enter")
				trigger_entered = true
				timer = timeout
		else:
			if trigger_entered:
				emit_signal("trigger_exit")
				trigger_entered = false
		old_mean = velo
		change *= cooldown
	pass
	
func check_drag():
	if !is_inside_tree():
		return
	
	if !is_ignoring_mouse():
		var hit = Main.check_drag_hit(self, shape)
		if hit && !drag_entered:
			drag_entered = true
			emit_signal("drag_enter")
			pass
			
		if !hit && drag_entered:
			drag_entered = false
			emit_signal("drag_exit")
			pass
	pass

func cancel_drag():
	drag_entered = false
	emit_signal("drag_exit")
	pass

func _exit_tree():
	Optflow.disconnect("on_flow", self, "check_trigger")
	pass
