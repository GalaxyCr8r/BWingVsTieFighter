extends Particles

## Provided Signals
#signal value_changed(new_value)

## Exported vars
#export var value : int = 0 setget set_value, get_value

## Internal Vars
#onready var  : =
var exploded := false

## Methods
func _process(delta):
	if exploded and emitting == false:
		queue_free()
		print ("Explosion freed itself!")

func poof():
	# Set transform to the current laser's transform.
	transform = get_parent().global_transform
	emitting = true
	exploded = true
	
	# Reparent to the node above the current laser.
	var parent = get_parent()
	parent.remove_child(self)
	parent.get_parent().add_child(self)
	owner = parent.get_parent()

## Connected Signals