extends KinematicBody

var FRICTION = 0.15
var accel = 5
var WALK_SPEED = 5
var SPRINT_SPEED = WALK_SPEED*1.3
var SNEAK_SPEED = WALK_SPEED*0.3

var velocity = Vector3(0,0,0)
var velocityGoal = Vector3(0,0,0)
var velocityGoalPrev = Vector3(0,0,0)
var mouse_sensitivity = 0.1
var camera_angle_x = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var viewportSize = get_viewport().size
	get_node("HUD/Cross").position = viewportSize/2.0

func _physics_process(delta):
	if Input.is_action_just_pressed("sprint"):
		$TweenCameraFov.interpolate_property($Camera,"fov", 90, 100, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$TweenCameraFov.start()
	elif Input.is_action_just_released("sprint"):
		$TweenCameraFov.interpolate_property($Camera,"fov", 100, 90, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$TweenCameraFov.start()
	if Input.is_action_pressed("sprint"):
		accel = SPRINT_SPEED
	elif Input.is_action_pressed("sneak"):
		accel = SNEAK_SPEED
	else:
		accel = WALK_SPEED
	if not is_on_floor():
		velocity.y-=0.5
	velocity.x-=(velocity.x*FRICTION)
	velocity.z-=(velocity.z*FRICTION)
	var velo = Vector3(0,0,0)
	var aim = self.get_rotation_degrees()
	if Input.is_action_pressed("move_forward"):
		velo.z+=-cos(deg2rad(aim.y))
		velo.x+=-sin(deg2rad(aim.y))
	if Input.is_action_pressed("move_backward"):
		velo.z+=cos(deg2rad(aim.y))
		velo.x+=sin(deg2rad(aim.y))
	if Input.is_action_pressed("move_left"):
		velo.x+=-cos(deg2rad(aim.y))
		velo.z+=sin(deg2rad(aim.y))
	if Input.is_action_pressed("move_right"):
		velo.x+=cos(deg2rad(aim.y))
		velo.z+=-sin(deg2rad(aim.y))
	velocityGoal=velocityGoal.normalized()
	if velo == Vector3(0,0,0):
		velocityGoal=Vector3(0,0,0)
	if is_on_floor():
		velocityGoal+=(velo*0.4)
	else:
		velocityGoal+=(velo*0.2)
	if velocityGoal.x!=0:
		var angle = atan2(velocityGoal.z,velocityGoal.x)
		velocity.x = cos(angle)*accel
		velocity.z = sin(angle)*accel
	elif velocityGoal.z!=0:
		velocity.x = 0
		velocity.z = accel

	velocityGoalPrev = velo
	
	if Input.is_action_pressed("move_up") and is_on_floor():
		velocity.y=8

	velocity = self.move_and_slide(velocity, Vector3(0,1,0))
	
func _process(delta):
	pass
func _input(event):
	
	if event is InputEventMouseMotion:
		self.rotate_y(deg2rad(-event.relative.x*mouse_sensitivity))
		var mouse_change_x = -event.relative.y*mouse_sensitivity
		if mouse_change_x + camera_angle_x < -90:
		    mouse_change_x = -90-camera_angle_x
		elif mouse_change_x + camera_angle_x > 90:
		    mouse_change_x = 90-camera_angle_x
		get_node("Camera").rotate_x(deg2rad(mouse_change_x))
		camera_angle_x+=mouse_change_x
