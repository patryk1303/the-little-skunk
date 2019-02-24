extends Camera

class_name CameraForZone

export(float, 1, 100, 0.5) var turn_speed : float = 60.0

export(bool) var follow_enabled : bool = false
export(float, 1, 10, 0.5) var follow_distance : float = 5.0
export(float, 1, 10, 0.5) var follow_speed : float = 2.0

var target : KinematicBody setget set_target

func _process(delta):
	if !target:
		return

	var to_target : Vector3 = target.global_transform.origin - global_transform.origin
	var dist : float = to_target.length()
	var move_vec : Vector3 = to_target

	move_vec.y = 0
	to_target = to_target.normalized()

	if follow_enabled:
		var accel = dist - follow_distance
		global_transform.origin += accel * move_vec * follow_speed * delta

	var up : Vector3 = global_transform.basis.y
	var right : Vector3 = global_transform.basis.x

	var u_dot : float = to_target.dot(up)
	var r_dot : float = to_target.dot(right)

	rotation_degrees.y += turn_speed * -r_dot * delta
	rotation_degrees.x += turn_speed * u_dot * delta

func set_target(new_target : KinematicBody):
	target = new_target