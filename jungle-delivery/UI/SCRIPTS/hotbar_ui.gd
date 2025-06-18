extends Control

@onready var slot1 = $HBoxContainer/Slot1
@onready var slot2 = $HBoxContainer/Slot2
@onready var slot3 = $HBoxContainer/Slot3

var slots = []

func _ready():
	slots = [slot1, slot2, slot3]
	for slot in slots:
		var texture_rect = TextureRect.new()
		texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
		texture_rect.size = Vector2(50, 50)
		slot.add_child(texture_rect)
	update_hotbar([], 0)  # Initialize UI

func update_hotbar(hotbar: Array, selected_slot: int):
	print("Updating hotbar UI: selected slot ", selected_slot, ", hotbar ", hotbar)
	for i in range(slots.size()):
		var texture_rect = slots[i].get_child(0)
		if i < hotbar.size() and hotbar[i] != null and hotbar[i].has("icon") and hotbar[i]["icon"] != null:
			var icon_path = hotbar[i]["icon"]
			if ResourceLoader.exists(icon_path):
				texture_rect.texture = load(icon_path)
			else:
				texture_rect.texture = null
				print("Error: Invalid icon path for slot ", i, ": ", icon_path)
		else:
			texture_rect.texture = null
		# Highlight selected slot with bright green, dim others
		slots[i].modulate = Color(0, 1, 0, 1) if i == selected_slot else Color(0.5, 0.5, 0.5, 0.7)
