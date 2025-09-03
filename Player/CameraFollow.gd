extends SpringArm3D

@export var target: Node3D  # The node to follow (e.g., player)
@export var follow_speed: float = 5.0  # Speed of camera following target
@export var min_length: float = 2.0  # Minimum spring arm length when colliding
@export var max_length: float = 5.0  # Default/maximum spring arm length
@export var offset: Vector3 = Vector3(0, 2, 0)  # Offset from target
#@export var collision_mask: int = 1  # Layers to check for collisions

@onready var camera: Camera3D = $Camera3D
var camera_rig_height: float

func _ready() -> void:
	# Initialize spring arm properties
	spring_length = max_length
	camera_rig_height = position.y
	# Enable collision detection
	collision_mask = collision_mask
	# Capture mouse for input
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Ensure the camera is positioned correctly at start
	if target:
		global_position = target.global_position + offset

func _physics_process(delta: float) -> void:
	if target:
		# Smoothly follow the target's X and Z position, maintain Y height
		var target_pos = target.global_position + offset
		var new_pos = global_position.lerp(target_pos, follow_speed * delta)
		new_pos.y = camera_rig_height  # Lock Y to maintain consistent height
		global_position = new_pos

		# Adjust spring length based on collision
		#var collision_point = get_collision_point()
		#if collision_point:
			#var distance_to_collision = global_position.distance_to(collision_point)
			## Clamp spring length between min_length and max_length
			#spring_length = clamp(distance_to_collision, min_length, max_length)
		#else:
			## No collision, return to max length
			#spring_length = lerp(spring_length, max_length, 10.0 * delta)

func _input(event: InputEvent) -> void:
	# Handle ESC to free mouse
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# Handle left-click to recapture mouse
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
