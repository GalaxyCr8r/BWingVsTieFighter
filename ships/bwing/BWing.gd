extends KinematicBody

## Provided Signals
#signal value_changed(new_value)

## Exported vars
export(Array, NodePath) var hardPoints : Array
export(PackedScene) var packedLaser : PackedScene
export var maxSpeed : float = 50

## Internal Vars
onready var anim : AnimationPlayer = $AnimationPlayer

var isPlayer = true

var roll_input : float = 0
var yaw_input : float = 0
var pitch_input : float = 0
var inertia : Vector3 = Vector3(0,0,0)
var currentSpeed : float = maxSpeed
var targetSpeed : float = currentSpeed

var sfoilsClosed := true

var tween := Tween.new()

## Methods
func _ready():
	add_child(tween)
	tween.interpolate_property(self, "transform",
		transform.translated(Vector3(0,0,-500)),
		transform, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func _process(delta):
	if tween.is_active():
		return
	
	if yaw_input == 0 and pitch_input == 0 and roll_input == 0:
		#inertia.slerp(Vector3(), 0.25)
		inertia = lerp(inertia, Vector3(0,0,0), 0.05)
	else:
		var new = Vector3()
		new.z = PI * ((0.0025 * yaw_input) + (0.005 * roll_input))
		new.y = PI * -1 * 0.005 * yaw_input
		new.x = PI * 0.0075 * pitch_input
		inertia = lerp(inertia, new, 0.05)
	
	self.rotate(transform.basis.z, inertia.z)
	self.rotate(transform.basis.y, inertia.y)
	self.rotate(transform.basis.x, inertia.x)
	
	currentSpeed = lerp(currentSpeed, targetSpeed, 0.25)
	self.move_and_collide(transform.basis.z * (currentSpeed * 0.01) * delta)

func fire_all():
	for hardPointPath in hardPoints:
		var hardPoint : Position3D = get_node(hardPointPath)
		var laser : RebelLaser = packedLaser.instance()
		get_parent().add_child(laser)
		laser.transform.origin = hardPoint.global_transform.origin
		laser.transform.basis = self.transform.basis

func _input(event):
	if !isPlayer:
		return
	
	if event.is_action_released("ui_accept"):
		fire_all()
	
	if event.is_action_released("ui_select"):
		if sfoilsClosed:
			anim.play_backwards("CloseSFoils")
			targetSpeed = maxSpeed * 0.5
		else:
			anim.play("CloseSFoils")
			targetSpeed = maxSpeed
		sfoilsClosed = !sfoilsClosed
	
	if event.is_action_released("ui_left") or event.is_action_released("ui_right"):
		yaw_input = 0
	if event.is_action_pressed("ui_left"):
		yaw_input = -1
	if event.is_action_pressed("ui_right"):
		yaw_input = 1
		
	if event.is_action_released("ui_down") or event.is_action_released("ui_up"):
		pitch_input = 0
	if event.is_action_pressed("ui_down"):
		pitch_input = -1
	if event.is_action_pressed("ui_up"):
		pitch_input = 1
	
	if event.is_action_released("roll_left") or event.is_action_released("roll_right"):
		roll_input = 0
	if event.is_action_pressed("roll_left"):
		roll_input = -1
	if event.is_action_pressed("roll_right"):
		roll_input = 1
	
	if event is InputEventScreenDrag:
		var screenSize := get_viewport().get_visible_rect().size
		var screenSizeHalved := screenSize * 0.5
		var event_position = event.position
		#print (str(event_position.x-screenSizeHalved.x), ", ", str(event_position.y-screenSizeHalved.y))
		yaw_input = (event_position.x-screenSizeHalved.x) / screenSizeHalved.x
		pitch_input = (event_position.y-screenSizeHalved.y) / screenSizeHalved.y
	
	if event is InputEventScreenTouch:
		if !event.pressed:
			yaw_input = 0
			pitch_input = 0

## Connected Signals
func hit():
	print("BWing hit!!!")