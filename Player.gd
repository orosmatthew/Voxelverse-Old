extends KinematicBody

var FRICTION = 0.15#0.075
var ACCEL = 5#0.375#0.375
#warning-ignore:unused_class_variable
#var WALKSPEED = 1.5
var velocity = Vector3(0,0,0)

var mouse_sensitivity = 0.15
var camera_angle_x = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
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
	
	if velo.x!=0:
		var angle = atan2(velo.z,velo.x)
		velocity.x = cos(angle)*ACCEL
		velocity.z = sin(angle)*ACCEL
	elif velo.z!=0:
		velocity.x = 0
		velocity.z = ACCEL




	
	if Input.is_action_pressed("move_up") and is_on_floor():
		velocity.y=8
		#velocity.y+=ACCEL
	
	#if Input.is_action_pressed("move_down"):
		#if abs(velocity.y)<abs(WALKSPEED):
		#velocity.y-=ACCEL
	


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
