extends Spatial

export (NodePath) var camera_path
onready var camera = get_node(camera_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	transform.origin = Vector3(0,0,0) ## Combine this and the below line?
	translate(camera.global_transform.origin)
	transform.basis = Basis()
	pass
