extends Spatial

## Provided Signals
#signal value_changed(new_value)

## Exported vars
#export var value : int = 0 setget set_value, get_value

## Internal Vars
#onready var  : =

## Methods
func _ready():
	$AnimationPlayer.play("LeaveLightspeed")

## Connected Signals