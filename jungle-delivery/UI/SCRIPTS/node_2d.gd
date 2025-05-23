extends Control







func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://GAME/node_3d.tscn")


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/settings.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
