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

var roll : float = 0
var yaw : float = 0
var pitch : float = 0
var currentSpeed : float = maxSpeed * 0.5

var sfoilsClosed := false

## Methods
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.rotate(transform.basis.z, PI * ((0.0025 * yaw) + (0.005 * roll)))
	self.rotate(transform.basis.y, PI * -1 * 0.005 * yaw)
	self.rotate(transform.basis.x, PI * 0.0075 * pitch)
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
			currentSpeed = maxSpeed * 0.5
		else:
			anim.play("CloseSFoils")
			currentSpeed = maxSpeed
		sfoilsClosed = !sfoilsClosed
	
	if event.is_action_released("ui_left") or event.is_action_released("ui_right"):
		yaw = 0
	if event.is_action_pressed("ui_left"):
		yaw = -1
	if event.is_action_pressed("ui_right"):
		yaw = 1
		
	if event.is_action_released("ui_down") or event.is_action_released("ui_up"):
		pitch = 0
	if event.is_action_pressed("ui_down"):
		pitch = -1
	if event.is_action_pressed("ui_up"):
		pitch = 1
	
	if event.is_action_released("roll_left") or event.is_action_released("roll_right"):
		roll = 0
	if event.is_action_pressed("roll_left"):
		roll = -1
	elif event.is_action_pressed("roll_right"):
		roll = 1
		
	if event is InputEventScreenDrag:
		var screenSize := get_viewport().get_visible_rect().size
		var screenSizeHalved := screenSize * 0.5
		var event_position = event.position
		#print (str(event_position.x-screenSizeHalved.x), ", ", str(event_position.y-screenSizeHalved.y))
		yaw = (event_position.x-screenSizeHalved.x) / screenSizeHalved.x
		pitch = (event_position.y-screenSizeHalved.y) / screenSizeHalved.y
	
	if event is InputEventScreenTouch:
		if !event.pressed:
			yaw = 0
			pitch = 0

## Connected Signals
func hit():
	print("BWing hit!!!")