extends KinematicBody

## Provided Signals
#signal value_changed(new_value)

## Exported vars
#export var value : int = 0 setget set_value, get_value

## Internal Vars
#onready var  : =

var roll : float = 0
var pitch : float = 0
var currentSpeed : float = 75
var maxSpeed : float = currentSpeed

## Methods

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.rotate(transform.basis.z, PI * 0.005 * roll)
	self.rotate(transform.basis.x, PI * 0.0075 * pitch)
	self.move_and_collide(transform.basis.z * (currentSpeed * 0.01) * delta)

## Connected Signals