extends KinematicBody

class_name Skunk

const ANIM_BLEND_IDLE_RUN = "parameters/Blend_IdleRun/blend_amount"

export(int, 1, 20, 1) var move_speed : int = 7
export(int, 1, 20, 1) var acceleration : int = 3
export(int, 1, 20, 1) var de_acceleration : int = 5
export(int, 1, 20, 1) var jump_force : int = 5
export(int, 1, 100, 1) var max_fall_speed : int = 30

export(NodePath) var starting_camera : NodePath

var alive : bool = true

var velocity : Vector3 = Vector3()
var h_velocity : Vector3 = Vector3()
var new_dir : Vector3 = Vector3()
var direction : Vector3 = Vector3()

var starting_vec : Vector3 = Vector3()

var current_camera : CameraForZone setget set_current_camera, get_current_camera
var camera_transform : Transform

var key_map : Dictionary = {
	"move_forward": { "state": false, "str": 0 },
	"move_backward": { "state": false, "str": 0 },
	"move_left": { "state": false, "str": 0 },
	"move_right": { "state": false, "str": 0 },
	"move_jump": { "state": false, "str": 0 },
	"move_attack": { "state": false, "str": 0 }
}

func _ready():
	current_camera = get_node(starting_camera)
	current_camera.target = self
	current_camera.make_current()

	starting_vec = translation
	alive = true

func _input(event):
	for key_name in key_map:
		if event.is_action_pressed(key_name) and alive:
			key_map[key_name].state = true
			key_map[key_name].str = event.get_action_strength(key_name)
		elif event.is_action_released(key_name):
			key_map[key_name].state = false
			key_map[key_name].str = event.get_action_strength(key_name)

func _physics_process(delta):
	handle_movement(delta)
	handle_animation(delta)

func _process(delta):
	pass

# object functions

func handle_movement(delta):
	var str_to_use : float = 1.0

	direction = Vector3()
	camera_transform = current_camera.global_transform

	var mult = 1

	if key_map.move_forward.state:
		direction -= camera_transform.basis.z * mult
		str_to_use = key_map.move_forward.str
		# rotation here
	if key_map.move_backward.state:
		direction += camera_transform.basis.z * mult
		str_to_use = key_map.move_backward.str
		# rotation here
	if key_map.move_left.state:
		direction -= camera_transform.basis.x * mult
		str_to_use = key_map.move_left.str
		# rotation here
	if key_map.move_right.state:
		direction += camera_transform.basis.x * mult
		str_to_use = key_map.move_right.str
		# rotation here

	direction.y = 0
	direction = direction.normalized()

	new_dir = direction

	velocity.y += delta * Globals.GRAVITY

	h_velocity = velocity
	h_velocity.y = 0

	var speed_to_use = move_speed

	var new_pos = new_dir * speed_to_use * str_to_use
	var accel_to_use = de_acceleration

	if direction.dot(h_velocity):
		accel_to_use = acceleration

	h_velocity = h_velocity.linear_interpolate(new_pos, accel_to_use * delta)

	velocity.x = h_velocity.x
	velocity.z = h_velocity.z

	velocity = move_and_slide(velocity, Globals.UP, 0.15)

	if can_jump():
		jump()

func handle_animation(delta):
	var blend_idle_run : float = $AnimationTree.get(ANIM_BLEND_IDLE_RUN)

	if is_moving():
		var angle = atan2(h_velocity.x, h_velocity.z)
		var char_rot = rotation

		char_rot.y = angle
		self.rotation = char_rot

		blend_idle_run = lerp(blend_idle_run, 1.0, 0.11)
	else:
		blend_idle_run = lerp(blend_idle_run, 0.0, 0.11)

	$AnimationTree.set(ANIM_BLEND_IDLE_RUN, blend_idle_run)

# movement specific functions

func jump(jump_scale : float = 1.0):
	velocity.y = jump_force * jump_scale

# movement getters

func is_moving():
	return (key_map.move_forward.state
		or key_map.move_backward.state
		or key_map.move_left.state
		or key_map.move_right.state)

func is_jumping():
	return !is_on_floor() and velocity.y > 0

func is_falling():
	return !is_on_floor() and velocity.y < 0

func can_jump():
	return (is_on_floor()
		and key_map.move_jump.state)

# setters and getters

func set_current_camera(new_camera : CameraForZone):
	current_camera = new_camera

func get_current_camera() -> CameraForZone:
	return current_camera