extends KinematicBody

## Provided Signals
#signal value_changed(new_value)

## Exported vars
export(Array, NodePath) var hardPoints : Array
export(PackedScene) var packedLaser : PackedScene

## Internal Vars
#onready var  : =

var roll : float = 0
var pitch : float = 0
var currentSpeed : float = 75
var maxSpeed : float = currentSpeed

var destroyed := false
var destroyedCounter : float = 1.5

export var shootInteval : float = 2
var shootCounter : float = 2

## Methods
func _ready():
	randomize()

func fire_all():
	for hardPointPath in hardPoints:
		var hardPoint : Position3D = get_node(hardPointPath)
		var laser : RebelLaser = packedLaser.instance()
		get_parent().add_child(laser)
		laser.transform.origin = hardPoint.global_transform.origin
		laser.transform.basis = self.transform.basis

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.rotate(transform.basis.z, PI * 0.005 * roll)
	self.rotate(transform.basis.x, PI * 0.0075 * pitch)
	self.move_and_collide(transform.basis.z * (currentSpeed * 0.01) * delta)
	
	shootCounter -= delta
	if shootCounter < 0:
		shootCounter = shootInteval
		fire_all()
	
	if destroyed:
		destroyedCounter -= delta
	if destroyedCounter < 0:
		queue_free()

## Connected Signals
func hit():
	destroyed = true
	roll = (randf() + 0.1) * 5
	pitch = (randf() + 0.1) * 2 #1.2575
	#self.rotate(transform.basis.x, PI * ((randf()/2)+0.1) * pitch)
	#currentSpeed *= 1.5