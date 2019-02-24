extends Area

export(NodePath) var camera_path : NodePath = "CameraForZone"

func _ready():
	connect("body_entered", self, "_on_CameraZone_body_entered")

func _on_CameraZone_body_entered(skunk : Skunk):
	print('aaa')
	if has_node(camera_path):
		var cam : CameraForZone = get_node(camera_path)
		cam.make_current()

		if cam.has_method("set_target"):
			cam.set_target(skunk)
			skunk.set_current_camera(cam)
