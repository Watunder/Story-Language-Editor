extends Node

onready var edit_panel = $GUI/Panel/VBoxContainer/EditPanel
onready var preview_panel = $GUI/Panel/VBoxContainer/PreviewPanel
onready var button = $GUI/Panel/VBoxContainer/HBoxContainer/HBoxContainer/Button
onready var button2 = $GUI/Panel/VBoxContainer/HBoxContainer/HBoxContainer/Button2

func _ready():
	pass

func _on_Button_button_down():
	edit_panel.visible = true
	preview_panel.visible = false
	button2.pressed = false

func _on_Button2_button_down():
	edit_panel.visible = false
	preview_panel.visible = true
	button.pressed = false
