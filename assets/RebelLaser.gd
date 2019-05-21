extends KinematicBody

## Provided Signals
#signal value_changed(new_value)

## Exported vars
export var speed : float = 250 #setget set_value, get_value

## Internal Vars
#onready var  : =

## Methods
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var collision_info = move_and_collide(transform.basis.z * (speed * 0.01) * delta)
	if collision_info:
		var collision_point = collision_info.position
		print ("Rebel laser hit, ", collision_point)
		queue_free()

## Connected Signals