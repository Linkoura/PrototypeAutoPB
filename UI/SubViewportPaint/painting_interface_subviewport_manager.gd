extends Control

@onready var save_file_dialog = $SaveFileDialog
@onready var sub_viewport_container = $MainContainer/HBoxContainer/SubViewportContainer


func _ready() -> void:
	save_file_dialog.file_selected.connect(sub_viewport_container.save_picture)

func _on_save_button_pressed() -> void:
	save_file_dialog.popup_centered()

