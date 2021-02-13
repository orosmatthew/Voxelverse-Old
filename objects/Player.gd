extends KinematicBody

class_name Player

export var speed: float = 10.0
export var air_acceleration: float = 5.0
export var normal_acceleration: float = 12.0
export var gravity: float = 40.0
export var jump: float = 14.0

var h_acceleration: float = 12.0

export var is_flying: bool = false
export var v_fly_speed: float = 10.0
export var h_fly_speed: float = 15.0
export var h_fly_acceleration: float = 5.0

export var mouse_sensitivity: float = 0.03

var direction: Vector3 = Vector3()
var h_velocity: Vector3 = Vector3()
var movement: Vector3 = Vector3()
var gravity_vector: Vector3 = Vector3()
var velocity: Vector3 = Vector3()

onready var head := $Head

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var viewport_size: Vector2 = get_viewport().size
	get_node("HUD/Cross").position = viewport_size / 2.0
	
func _input(event: InputEvent):
	
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89.9), deg2rad(89.9))

var count = 0

func _process(delta: float):

	
	direction = Vector3()
	
	if not is_flying:
			
		if not is_on_floor():
			h_acceleration = air_acceleration
		else:
			h_acceleration = normal_acceleration
			
		gravity_vector = Vector3.DOWN * gravity * delta
		
		
	
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	elif Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
		
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("move_right"):
		direction += transform.basis.x
		
	direction = direction.normalized()
	
	if not is_flying:
		h_velocity = h_velocity.linear_interpolate(direction * speed, h_acceleration * delta)
		movement.z = h_velocity.z
		movement.x = h_velocity.x
		movement.y += gravity_vector.y
		if is_on_floor() and movement.y <= 0:
			movement.y = 0
		if Input.is_action_pressed("move_up") and is_on_floor() and movement.y <= 0:
			movement.y = jump
	else:
		h_velocity = h_velocity.linear_interpolate(direction * h_fly_speed, h_fly_acceleration * delta)
		movement.z = h_velocity.z
		movement.x = h_velocity.x
		if Input.is_action_pressed("move_down"):
			movement.y = -v_fly_speed
		elif Input.is_action_pressed("move_up"):
			movement.y = v_fly_speed
		else:
			movement.y = 0
	
	velocity = move_and_slide(movement, Vector3.UP)
