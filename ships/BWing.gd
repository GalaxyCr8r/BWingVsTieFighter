extends KinematicBody

var isPlayer = true

var roll : float = 0
var pitch : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.rotate(transform.basis.z, PI * 0.005 * roll)
	self.rotate(transform.basis.x, PI * 0.0075 * pitch)
	self.move_and_collide(transform.basis.z * .5 * delta)
	

func _input(event):
	if event.is_action_released("ui_left") or event.is_action_released("ui_right"):
		roll = 0
	if event.is_action_pressed("ui_left"):
		roll = -1
	if event.is_action_pressed("ui_right"):
		roll = 1
		
	if event.is_action_released("ui_down") or event.is_action_released("ui_up"):
		pitch = 0
	if event.is_action_pressed("ui_down"):
		pitch = -1
	if event.is_action_pressed("ui_up"):
		pitch = 1
		
	if event is InputEventScreenDrag:
		var screenSize := get_viewport().get_visible_rect().size
		var screenSizeHalved := screenSize * 0.5
		var event_position = event.position
		#print (str(event_position.x-screenSizeHalved.x), ", ", str(event_position.y-screenSizeHalved.y))
		roll = (event_position.x-screenSizeHalved.x) / screenSizeHalved.x
		pitch = (event_position.y-screenSizeHalved.y) / screenSizeHalved.y
	
	if event is InputEventScreenTouch:
		if !event.pressed:
			roll = 0
			pitch = 0

#func _input(event):
#
#	if event is InputEventScreenTouch or event is InputEventScreenDrag:# or event is InputEventMouseButton:
#		var screenSize := OS.get_screen_size()
#		var event_position := Vector2();
#		var event_ID = null;
#
#		if event is InputEventScreenTouch:
#			event_position = event.position;
#			event_ID = event.index;
#			print (str((screenSize.x / 2) - event_position.x), ", ", str((screenSize.y / 2) - event_position.y))
##		elif event is InputEventMouseButton:
##			event_position = get_global_mouse_position();
##			event_ID = null;
