extends Node

onready var item_list = $GUI/Panel/GridContainer/Panel4/HBoxContainer/ItemList
onready var item_list1_container = $GUI/Panel/GridContainer/Panel6/HBoxContainer
onready var text_edit = $GUI/Panel/GridContainer/Panel5/VBoxContainer/TextEdit
onready var change_panel = $GUI/Panel/GridContainer/Panel5/VBoxContainer/ChangePanel

var load_template_thread = Thread.new()
var save_keywords_thread = Thread.new()

func _ready():
	text_edit.add_color_region("[", "]", Color.orange)
	text_edit.add_color_region(";", "", Color.dimgray)
	
	load_template_thread.start(self, "load_template")

func _enter_tree():
	pass

func _exit_tree():
	if load_template_thread.is_active():
		load_template_thread.wait_to_finish()

func load_template(userdata):
	var file = File.new()
	if file.open("res://template/start.story", File.READ) != OK:
		return
	var text = file.get_as_text()
	var text_arr = text.split("\n")
	file.close()
	
	var part_name = ""
	var part_from = 0
	var part_end = 0
	var meta_data = ""
	var num_parts = 0
	var is_part =  false
	
	for element in text_arr:
		#
		if element == "":
			continue
		#
		var _str = element[0]
		if _str == "@" || _str == "|" || _str == "#" || _str == "~":
			pass
		else:
			var _item = element.split(":")
			part_name = str(num_parts) + "_" + _item[0]
			meta_data = _item[2]
			
			var _file = File.new()
			_file.open("res://out/" + part_name + ".txt", File.WRITE)
			_file.store_string(meta_data)
			_file.close()
			
			item_list.add_item(part_name)
			item_list.set_item_metadata(num_parts, { "text" : meta_data })
			
			num_parts += 1

func _on_ItemList_item_selected(index):
	text_edit.text = item_list.get_item_metadata(index)["text"]
	item_list1_container.get_child(0).clear()
	
	var part_name =  item_list.get_item_text(item_list.get_selected_items()[0])
	var dir = Directory.new()
	if dir.file_exists("res://temp/" + part_name + ".tscn"):
		var _item_list1_file = load("res://temp/" + part_name + ".tscn")
		var _item_list1 = _item_list1_file.instance()

		item_list1_container.remove_child(item_list1_container.get_child(0))
		item_list1_container.add_child(_item_list1)
	else:
		save_keywords_thread.start(self, "save_keywords")

func save_keywords(userdata):
	item_list.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var key_word = ""
	var is_key_word = false
	var key_words = 0
	var meta_data = item_list.get_item_metadata(item_list.get_selected_items()[0])
	var part_name =  item_list.get_item_text(item_list.get_selected_items()[0])
	
	var startIndex = 0;
	while startIndex != -1:
		startIndex = text_edit.text.find("$", startIndex)
		if startIndex != -1:
			var endIndex = text_edit.text.find("$", startIndex + 1)
			if endIndex != -1:
				var variable = text_edit.text.substr(startIndex + 1, endIndex - startIndex - 1)
				item_list1_container.get_child(0).add_item(variable)
				
				startIndex = startIndex + variable.length() + 2
		else:
			break
	
	item_list.set_item_metadata(item_list.get_selected_items()[0], meta_data)
	
	var meta_data_res = Metadata.new()
	meta_data_res.data = meta_data
	ResourceSaver.save("res://temp/" + part_name + ".tres", meta_data_res)
	
	var packed_scene = PackedScene.new()
	packed_scene.pack(item_list1_container.get_child(0))
	ResourceSaver.save("res://temp/" + part_name + ".tscn", packed_scene)
	
	item_list.mouse_filter = Control.MOUSE_FILTER_STOP
	
	save_keywords_thread.call_deferred("wait_to_finish")

func _on_GUI_resized():
	$GUI/Panel/GridContainer/Panel4.rect_min_size.x = ($GUI.rect_size / Vector2(1280, 720) * 150).x
	$GUI/Panel/GridContainer/Panel6.rect_min_size.x = $GUI/Panel/GridContainer/Panel4.rect_min_size.x
	$GUI/Panel/GridContainer/Panel4/HBoxContainer/ItemList.fixed_column_width = ($GUI.rect_size / Vector2(1280, 720) * 130).x
	$GUI/Panel/GridContainer/Panel6/HBoxContainer/ItemList.fixed_column_width = $GUI/Panel/GridContainer/Panel4/HBoxContainer/ItemList.fixed_column_width

func _on_Button_button_down():
	text_edit.visible = false if text_edit.visible == true else true

func _on_Button2_button_down():
	change_panel.visible = false if change_panel.visible == true else true
