extends MeshInstance

## Provided Signals

## Exported vars
export(Array, NodePath) var hardPoints : Array
export(PackedScene) var packedLaser : PackedScene
export var shootInteval : float = 2

## Internal Vars
onready var tween : Tween = $Tween

var shootCounter : float = 2

enum states {IDLE, ATTACK, FLEE, DESTROYED}
var state = states.IDLE
export var stateChangeInteval : float = 5
var stateCounter : float = stateChangeInteval

var target = null
var lookAtTarget : float = -1
var startingBasis : Basis = Basis()
var targetBasis : Basis = Basis()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	### STATES!
	## Decision point
	stateCounter -= delta
	if stateCounter < 0:
		stateCounter = stateChangeInteval
		match state:
			states.IDLE:
				try_to_find_target()
				
			states.ATTACK:
				if !target:
					state = states.IDLE
					print("Idling Turret")
				
			_:
				pass
	
	### Every process loop check what we do for this state
	match state:
		states.ATTACK:
			if target:
				attack_target(delta)
	pass

func try_to_find_target():
	var closest_target
	var closest_distance : float = 25
	for ship in get_tree().get_nodes_in_group("RebelShips"):
		var distance = self.transform.origin.distance_to(ship.transform.origin)
		if closest_distance > distance:
			closest_target = ship
			closest_distance = distance
			print("Found a rebel at ", distance, "!")
	
	if closest_target:
		target = closest_target
		look_at_target()
		state = states.ATTACK
		print("TURBO LASER ATTACK!")

func attack_target(delta):
	look_at_target()
	
	shootCounter -= delta
	if shootCounter < 0:
		shootCounter = shootInteval
		fire_all()
		
func look_at_target():
	turn_towards(target.transform.looking_at(global_transform.origin, Vector3.UP).basis)
	
func turn_towards(basis:Basis):
	if tween.is_active():
		return
	
	startingBasis = global_transform.basis
	targetBasis = basis
	
	var rotSpeed = 90 #rotation speed in degrees per second # TODO Export this.
	var angleDiff = acos(transform.basis.z.dot(targetBasis.z))
	
	var timeToTurn = angleDiff/deg2rad(rotSpeed)
	
	lookAtTarget = 0
	tween.interpolate_property(self, "lookAtTarget", 0, 1.0,
		2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()

func fire_all():
	for hardPointPath in hardPoints:
		var hardPoint : Spatial = get_node(hardPointPath)
		var laser = packedLaser.instance()
		get_parent().add_child(laser)
		laser.transform.origin = hardPoint.global_transform.origin
		laser.transform.basis = self.transform.basis
