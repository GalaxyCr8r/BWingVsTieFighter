extends KinematicBody

## Provided Signals
#signal value_changed(new_value)

## Exported vars
export(Array, NodePath) var hardPoints : Array
export(PackedScene) var packedLaser : PackedScene

## Internal Vars
onready var tween : Tween = $Tween
onready var targetingNode : Spatial = $TargetingNode
onready var explosionEffect : Particles = $ExplosionEffect

var roll : float = 0
var pitch : float = 0
var currentSpeed : float = 75
var maxSpeed : float = currentSpeed

var destroyed := false
var destroyedCounter : float = 1.5

export var shootInteval : float = 2
var shootCounter : float = 2

enum states {IDLE, ATTACK, FLEE, DESTROYED}
var state = states.IDLE
export var stateChangeInteval : float = 5
var stateCounter : float = stateChangeInteval

var target = null
var lookAtTarget : float = -1
var startingBasis : Basis = Basis()
var targetBasis : Basis = Basis()

var hp := 2

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
	# Do the moving/turning stuff
	self.rotate(transform.basis.z, PI * 0.005 * roll)
	self.rotate(transform.basis.x, PI * 0.0075 * pitch)
	self.move_and_collide(transform.basis.z * (currentSpeed * 0.01) * delta)
	
	### STATES!
	## Decision point
	stateCounter -= delta
	if stateCounter < 0:
		stateCounter = stateChangeInteval
		match state:
			states.IDLE:
				try_to_find_target()
				
				if !target:
					fly_to_friendly_cap_ship()
				
			states.ATTACK:
				if !target:
					state = states.IDLE
					print("Idling Tie")
				
			states.FLEE:
				if target_is_far_enough_away():
					state = states.IDLE
					print("Idling Tie")
			_:
				pass
	
	### Every process loop check what we do for this state
	match state:
		states.ATTACK:
			if target_is_to_close():
				state = states.FLEE
				fly_away_from_target()
				
				print("Oh crap - FLEE!!!")
			else:
				attack_target(delta)
			
		states.FLEE:
			fly_away_from_target()
			
		_:
			pass
	
	### Other!
	# If there's something to look at, look at it!
	if lookAtTarget > -1:
		## Basis must slerp, no tween for you
		global_transform.basis = startingBasis.slerp(targetBasis, lookAtTarget)
	
	## Countdown to actually destroying it
	if destroyed:
		destroyedCounter -= delta
	if destroyedCounter < 0:
		explosionEffect.explode()
		queue_free()

## AI State Helper Funcs
func fly_to_friendly_cap_ship():
	# Find closest friendly captial ship and fly to/around it.
	pass

func try_to_find_target():
	var closest_target
	var closest_distance : float = 25
	for ship in get_tree().get_nodes_in_group("RebelShips"):
		var distance = self.transform.origin.distance_to(ship.transform.origin)
		if closest_distance > distance:
			closest_target = ship
			closest_distance = distance
			#print("Found a rebel at ", distance, "!")
	
	if closest_target:
		target = closest_target
		look_at_target()
		state = states.ATTACK
		print("TIE ATTACK!")

func attack_target(delta):
	look_at_target()
	
	shootCounter -= delta
	if shootCounter < 0:
		shootCounter = shootInteval
		fire_all()

func target_is_to_close() -> bool:
	if !target:
		return true
	return self.transform.origin.distance_to(target.transform.origin) < 2.75

func target_is_far_enough_away() -> bool:
	if !target:
		return true
	return self.transform.origin.distance_to(target.transform.origin) > 7

func look_at_target():
	turn_towards(target.transform.looking_at(global_transform.origin, Vector3.UP).basis)

func fly_away_from_target():
	var targetTransform := global_transform.looking_at(target.transform.origin, Vector3.UP)
	targetTransform = targetTransform.rotated(transform.basis.x, PI/3 * (randf() - 0.5))
	
	turn_towards(targetTransform.basis)

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

## Connected Signals
func hit():
	if hp > 0:
		hp -= 1
		return
	
	tween.stop_all()
	lookAtTarget = -1
	state = states.DESTROYED
	print("TIE DESTROYED!")
	destroyed = true
	# TODO Stop the TIE from colliding with future bullets?
	roll = (randf() + 0.1) * 15
	pitch = (randf() + 0.1) * 2 #1.2575