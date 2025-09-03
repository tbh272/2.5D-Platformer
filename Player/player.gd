extends CharacterBody3D

@onready var animated_sprite: AnimatedSprite3D = $Sprite
@onready var camera: Camera3D = $SpringArm3D/Camera3D

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5
const DIRECTION_LOCK_TIME: float = 0.1  # Prevent animation jitter

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var last_move_dir: Vector3 = Vector3.FORWARD  # Default for idle
var last_dir_index: int = 2  # Default to 'up' (index 2)
var direction_lock_timer: float = 0.0  # Timer to lock direction

# Animation direction names (4 directions, left uses right with flip)
var direction_names: Array[String] = ["down", "right", "up", "left"]

func _physics_process(delta: float) -> void:
	# Apply gravity if in the air
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get input vector
	var input_dir: Vector2 = Input.get_vector("walk_left", "walk_right", "walk_forward", "walk_backward")

	# Calculate camera-relative movement direction
	var cam_basis: Basis = camera.global_transform.basis
	var forward: Vector3 = -cam_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right: Vector3 = cam_basis.x
	right.y = 0.0
	right = right.normalized()

	var move_dir: Vector3 = forward * -input_dir.y + right * input_dir.x
	if move_dir.length() > 1.0:
		move_dir = move_dir.normalized()

	# Apply movement
	if move_dir != Vector3.ZERO:
		velocity.x = move_dir.x * SPEED
		velocity.z = move_dir.z * SPEED
		last_move_dir = move_dir
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		velocity.z = move_toward(velocity.z, 0.0, SPEED)

	move_and_slide()

	# Update direction lock timer
	direction_lock_timer -= delta
	if direction_lock_timer < 0.0:
		direction_lock_timer = 0.0

	# Update animation
	update_animation()

func update_animation() -> void:
	# Determine if moving
	var ground_velocity: Vector3 = velocity
	ground_velocity.y = 0.0
	var is_moving: bool = ground_velocity.length_squared() > 0.1

	# Use movement direction or last direction if idle
	var anim_dir: Vector3 = last_move_dir if not is_moving else velocity
	anim_dir.y = 0.0
	if anim_dir.length_squared() < 0.01:  # Avoid division by zero
		anim_dir = Vector3.FORWARD
	anim_dir = anim_dir.normalized()

	# Calculate angle relative to camera's forward vector
	var cam_forward: Vector3 = -camera.global_transform.basis.z
	cam_forward.y = 0.0
	cam_forward = cam_forward.normalized()

	var dot: float = anim_dir.dot(cam_forward)
	var cross: float = anim_dir.cross(cam_forward).y
	var angle: float = acos(dot)
	if cross < 0:
		angle = -angle

	# Normalize angle to 0 - 2PI and rotate by 180 degrees to align forward with up
	angle = fmod(angle + PI + 2 * PI, 2 * PI)

	# Quantize to 4 directions
	var dir_index: int = int(round(angle / (PI / 2.0))) % 4

	# Only update direction if timer is expired or movement is significant
	if direction_lock_timer <= 0.0 or abs(dir_index - last_dir_index) > 1:
		last_dir_index = dir_index
		direction_lock_timer = DIRECTION_LOCK_TIME

	# Handle sprite flip for left-facing direction
	var flip_h: bool = dir_index == 1  # Flip for left
	var anim_name: String = direction_names[dir_index]
	if dir_index == 3:  # Use right animation for left with flip
		anim_name = "right"

	# Apply walk or idle prefix
	anim_name = ("walk_" if is_moving else "idle_") + anim_name

	# Debug print to verify animation and flip
	if animated_sprite.animation != anim_name or animated_sprite.flip_h != flip_h:
		print("Playing: ", anim_name, " flip_h: ", flip_h, " dir_index: ", dir_index, " angle: ", angle, " cross: ", cross)

	# Play animation if changed
	if animated_sprite.animation != anim_name:
		animated_sprite.play(anim_name)

	# Apply flip
	animated_sprite.flip_h = flip_h
