extends KinematicBody

var FRICTION = 0.05
var ACCEL = 0.75
var WALKSPEED = 7
var velocity = Vector3(0,0,0)

var mouse_sensitivity = 0.15
var camera_angle_x = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	
	
	var aim = self.get_rotation_degrees()
	if Input.is_action_pressed("move_forward"):
		#if abs(velocity.z)<abs(WALKSPEED*cos(deg2rad(aim.y))):
		velocity.z-=ACCEL*cos(deg2rad(aim.y))
		#if abs(velocity.x)<abs(WALKSPEED*sin(deg2rad(aim.y))):
		velocity.x-=ACCEL*sin(deg2rad(aim.y))
	if Input.is_action_pressed("move_backward"):
		#if abs(velocity.z)<abs(WALKSPEED*cos(deg2rad(aim.y))):
		velocity.z+=ACCEL*cos(deg2rad(aim.y))
		#if abs(velocity.x)<abs(WALKSPEED*sin(deg2rad(aim.y))):
		velocity.x+=ACCEL*sin(deg2rad(aim.y))
	if Input.is_action_pressed("move_left"):
		#if abs(velocity.x)<abs(WALKSPEED*cos(deg2rad(aim.y))):
		velocity.x-=ACCEL*cos(deg2rad(aim.y))
		#if abs(velocity.x)<abs(WALKSPEED*sin(deg2rad(aim.y))):
		velocity.z+=ACCEL*sin(deg2rad(aim.y))
	if Input.is_action_pressed("move_right"):
		#if abs(velocity.x)<abs(WALKSPEED*cos(deg2rad(aim.y))):
		velocity.x+=ACCEL*cos(deg2rad(aim.y))
		#if abs(velocity.x)<abs(WALKSPEED*sin(deg2rad(aim.y))):
		velocity.z-=ACCEL*sin(deg2rad(aim.y))
	if Input.is_action_pressed("move_up"):
		#if abs(velocity.y)<abs(WALKSPEED):
		velocity.y+=ACCEL
	if Input.is_action_pressed("move_down"):
		#if abs(velocity.y)<abs(WALKSPEED):
		velocity.y-=ACCEL
			


	
	
	
	velocity-=(velocity*FRICTION)
	velocity = self.move_and_slide(velocity)
	
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
