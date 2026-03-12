extends Control

@onready var controls_panel = $Panel

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/game.tscn")

func _on_controls_button_pressed() -> void:
	controls_panel.visible = true

func _on_button_pressed() -> void:
	controls_panel.visible = false

func _on_exit_button_pressed() -> void:
	get_tree().quit()
