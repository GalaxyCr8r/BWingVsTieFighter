extends KinematicBody
class_name ImpLaser

## Provided Signals
#signal value_changed(new_value)

## Exported vars
export var speed : float = 250
export var lifetime : float = 10

## Internal Vars
#onready var  : =

var hit := false

## Methods
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hit:
		return
	
	lifetime -= delta
	if lifetime < 0:
		hit = true
		queue_free()
		return
	
	var collision_info = move_and_collide(transform.basis.z * (speed * 0.01) * delta)
	if collision_info:
		if collision_info.collider and collision_info.collider.has_method("hit"):
			collision_info.collider.hit()
			print ("Imp laser hit, hittable col: ", collision_info.collider)
		else:
			print ("Imp laser hit, non-hittable col: ", collision_info.collider)

## Connected Signals