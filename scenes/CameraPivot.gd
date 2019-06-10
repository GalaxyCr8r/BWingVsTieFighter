extends Spatial

## Provided Signals
#signal value_changed(new_value)

## Exported vars
#export var value : int = 0 setget set_value, get_value

## Internal Vars
onready var camera : Camera = $Camera
var state = 0

## Methods
func goFast():
	if state == 0:
		return
	$Tween.interpolate_property(self, "transform", transform, transform.translated(Vector3(0,0,-.1)),
		2, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property($Camera, "fov", 65, 70,
		2, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()
	state = 0
	
func goSlow():
	if state == 1:
		return
	$Tween.interpolate_property(self, "transform", transform, transform.translated(Vector3(0,0,.1)),
		2, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property($Camera, "fov", 70, 65,
		2, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()
	state = 1

## Connected Signals