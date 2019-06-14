extends Spatial

## Provided Signals
#signal value_changed(new_value)

## Exported vars
#export var value : int = 0 setget set_value, get_value
export var lightSpeedStar : PackedScene

## Internal Vars
#onready var  : =

var starAmount = 250
var distanceFromPlayer = 15

## Methods
func _ready():
	randomize()
	createStars()

func createStars():
	for i in range(starAmount):
		var newStar : Spatial = lightSpeedStar.instance()
		var pos = getNewStarPosition()
		print("Created star at ", pos)
		add_child(newStar)
		newStar.translate(pos)

func getNewStarPosition() -> Vector3:
	var starPos := Vector3(0,0,0)
	starPos.x = (randf()-0.5) * 2.5 * distanceFromPlayer
	starPos.y = (randf()-0.5) * 2 * distanceFromPlayer
	starPos.z = (randf()-2.0) * distanceFromPlayer
	return starPos.normalized() * ((randf() + 0.25) * distanceFromPlayer)

## Connected Signals