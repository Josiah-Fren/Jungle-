extends RigidBody3D

@export var item_type: String = ""
@export var item_scene_path: String = ""
@export var item_icon: Texture2D = null

func _ready():
	add_to_group("pickup")
	if item_scene_path == "" or not ResourceLoader.exists(item_scene_path):
		print("Error: Invalid item_scene_path for ", name, ": ", item_scene_path)

func get_item_data() -> Dictionary:
	return {
		"type": item_type,
		"scene_path": item_scene_path,
		"icon": item_icon
	}
