extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 8
const SENSITIVITY = 0.02
var gravity = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var hand = $Head/Hand
@onready var raycast = $Head/Camera3D/RayCast3D
@onready var hotbar_ui = $HotbarUI

var hotbar = [null, null, null]
var selected_slot = 0
var held_item = null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	update_hotbar_ui()

func _unhandled_input(event):
	if event is InputEventMouse:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
	
	if event.is_action_pressed("slot1"):
		select_slot(0)
	if event.is_action_pressed("slot2"):
		select_slot(1)
	if event.is_action_pressed("slot3"):
		select_slot(2)
	
	if event.is_action_pressed("interact"):
		interact()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func select_slot(slot: int):
	if slot >= 0 and slot < hotbar.size() and hotbar[slot] != null:
		selected_slot = slot
		update_held_item()
		update_hotbar_ui()

func update_held_item():
	for child in hand.get_children():
		child.queue_free()
	held_item = null
	
	if hotbar[selected_slot]:
		var scene_path = hotbar[selected_slot]["scene_path"]
		if scene_path is String and ResourceLoader.exists(scene_path):
			var item_scene = load(scene_path).instantiate()
			hand.add_child(item_scene)
			held_item = item_scene
		else:
			print("Error: Invalid scene path for item in slot ", selected_slot, ": ", scene_path)

func update_hotbar_ui():
	hotbar_ui.update_hotbar(hotbar, selected_slot)

func add_item_to_hotbar(item_data: Dictionary):
	print("Adding item: ", item_data)
	for i in range(hotbar.size()):
		if hotbar[i] == null:
			hotbar[i] = item_data
			select_slot(i)
			return true
	return false

func interact():
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.is_in_group("pickup"):
			var item_data = collider.get_item_data()
			if add_item_to_hotbar(item_data):
				collider.hide()  # Temporarily hide
				collider.set_collision_layer_value(1, false)  # Disable collision
				#await get_tree().create_timer(0.1).timeout  # Wait for physics step
				#collider.queue_free()  # Remove after delay
		elif collider.is_in_group("temple") and hotbar[selected_slot] and hotbar[selected_slot]["type"] == "artifact":
			collider.place_artifact()
			hotbar[selected_slot] = null
			update_held_item()
			update_hotbar_ui()
			end_game()

#func interact():
	#if raycast.is_colliding():
		#var collider = raycast.get_collider()
		#if collider.is_in_group("pickup"):
			#var item_data = collider.get_item_data()
			#if add_item_to_hotbar(item_data):
				##pass
				#collider.queue_free()
		#elif collider.is_in_group("temple") and hotbar[selected_slot] and hotbar[selected_slot]["type"] == "artifact":
			#collider.place_artifact()
			#hotbar[selected_slot] = null
			#update_held_item()
			#update_hotbar_ui()
			#end_game()

func end_game():
	print("Game Over! Artifact delivered to the temple!")
	get_tree().quit()
