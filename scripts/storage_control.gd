extends AnimationPlayer

#properties
export var mouse_control = true
export var optflow_control = false
export var surf_control = false

#members
var storage
var freezer
var fridge
var storage_text
var freezer_text
var fridge_text

#states
var article_list = {}
var storage_list = {}
var freezer_list = {}
var fridge_list = {}

func _ready():
	storage = get_node("Storage")
	freezer = get_node("Freezer")
	fridge = get_node("Fridge")
	storage_text = get_node("Storage/ListText")
	freezer_text = get_node("Freezer/ListText")
	fridge_text = get_node("Fridge/ListText")
	
	if mouse_control:
		storage.connect("mouse_enter", self, "put_label_to", [storage])
		freezer.connect("mouse_enter", self, "put_label_to", [freezer])
		fridge.connect("mouse_enter", self, "put_label_to", [fridge])
		get_parent().connect("mouse_enter", self, "play", ["de_lit"])
		pass
	
	if optflow_control:
		storage.connect("drag_enter", self, "put_label_to", [storage])
		freezer.connect("drag_enter", self, "put_label_to", [freezer])
		fridge.connect("drag_enter", self, "put_label_to", [fridge])
		get_parent().connect("drag_exit", Main, "release_drag")
		get_parent().connect("drag_exit", self, "play", ["de_lit"])
		pass
	
	if surf_control:
		pass
	pass

func put_label_to(node):
	if node == storage:
		play("lit_storage")
	elif node == freezer:
		play("lit_freezer")
	elif node == fridge:
		play("lit_fridge")
	else:
		return
	
	if Main.selected_label == "" || Main.selected_label == "N/A":
		return
	if article_list.has(Main.label_id):
		article_list[Main.label_id]["place"] = node
	else:
		article_list[Main.label_id] = {"name":Main.selected_label, "place":node}
	
	update_lists()
	plot_lists()
	pass

func update_lists():
	storage_list.clear()
	freezer_list.clear()
	fridge_list.clear()
	
	for key in article_list:
		var value = article_list[key]
		var node = value["place"]
		var name = value["name"]
		if node == storage:
			if storage_list.has(name):
				storage_list[name] += 1
			else:
				storage_list[name] = 1
		elif node == freezer:
			if freezer_list.has(name):
				freezer_list[name] += 1
			else:
				freezer_list[name] = 1
		elif node == fridge:
			if fridge_list.has(name):
				fridge_list[name] += 1
			else:
				fridge_list[name] = 1
	pass

func plot_lists():
	storage_text.clear()
	freezer_text.clear()
	fridge_text.clear()
	
	storage_text.push_table(2)
	freezer_text.push_table(2)
	fridge_text.push_table(2)
	
	for key in storage_list:
		storage_text.push_cell()
		storage_text.append_bbcode("%s:" % key)
		storage_text.pop()
		storage_text.push_cell()
		storage_text.append_bbcode("[right]%d[/right]" % storage_list[key])
		storage_text.pop()
	for key in freezer_list:
		freezer_text.push_cell()
		freezer_text.append_bbcode("%s:" % key)
		freezer_text.pop()
		freezer_text.push_cell()
		freezer_text.append_bbcode("[right]%d[/right]" % freezer_list[key])
		freezer_text.pop()
	for key in fridge_list:
		fridge_text.push_cell()
		fridge_text.append_bbcode("%s:" % key)
		fridge_text.pop()
		fridge_text.push_cell()
		fridge_text.append_bbcode("[right]%d[/right]" % fridge_list[key])
		fridge_text.pop()
		
	storage_text.pop()
	freezer_text.pop()
	fridge_text.pop()
	pass

