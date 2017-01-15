#World properties
extends Control

#properties
export (int) var cam_id = 0
export (Quat) var margin = Quat(0,0,0,0)
export (int, "NONE", "FLIP_V", "FLIP_H", "FLIP_VH") var mirrow = 0

export (int, 0, 255) var sobel_volume = 16
export (int, 0, 5) var sobel_kernel = 0
export (int, 0, 255) var lk_max = 50
export (float, 0, 1, 0.01) var lk_quality = 0.1
export (float, 0, 128, 0.001) var flann_quality = 0.1

export (String, DIR) var flann_db = "flannDB/"

#state
var show_frame_pressed = false
var show_flow_pressed = false
var show_lk_pressed = false

#functions

func _ready():
	Main.connect("drag_shape_changed", self, "update")
	Main.connect("drag_released", self, "update")
	ObjectRecognition.set_root_dir(flann_db)
	ObjectRecognition.set_min_distance(flann_quality);
	update_states()
	WebCam.start(cam_id)
	Optflow.start(Optflow.SOBEL)
	set_process(true);
	pass
	
func _process(delta):
	if Input.is_action_pressed("show_webcam"):
		show_frame_pressed = true
	elif show_frame_pressed:
		WebCam.show_frame(!WebCam.is_showing())
		show_frame_pressed = false
		pass
		
	if Input.is_action_pressed("show_optflow"):
		show_flow_pressed = true
	elif show_flow_pressed:
		Optflow.show(~Optflow.is_showing() & Optflow.SOBEL)
		show_flow_pressed = false
		pass
		
	if Input.is_action_pressed("show_lucask"):
		show_lk_pressed = true
	elif show_lk_pressed:
		Optflow.show(~Optflow.is_showing() & Optflow.LUCAS_KANADE)
		show_lk_pressed = false
		pass
	pass

func _draw():
	var a_width = get_viewport_rect().size.x / WebCam.get_width()
	var a_height = get_viewport_rect().size.y / WebCam.get_height() 
	var pos = Vector2(Main.drag_shape["center"].x * a_width, Main.drag_shape["center"].y * a_height)
	
	if Main.drag_shape["shape"] != 0:
		draw_circle(pos, Main.drag_shape["size_x"] * a_width /2, Color(0, 0, 1))
	pass

func update_states():
	WebCam.set_flipping(mirrow)
	WebCam.set_margin(margin.x, margin.z, margin.y, margin.w)
	
	Optflow.set_sobel_volume(sobel_volume)
	Optflow.set_sobel_kernel(sobel_kernel)
	Optflow.set_lk_quality(lk_quality)
	Optflow.set_lk_max(lk_max)
	pass
	
func stop_all():
	WebCam.stop()
	print("... webcam stopped.")
	Optflow.stop()
	print("... optflow stopped.")
	pass
	
func _exit_tree():
	stop_all()
	pass