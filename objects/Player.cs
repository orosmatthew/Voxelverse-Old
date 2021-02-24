using Godot;
using System;


public class Player : KinematicBody
{
	
	[Export]
	public float Speed { get; set; } = 10.0f;

	[Export]
	public float AirAcceleration { get; set; } = 5.0f;

	[Export]
	public float NormalAcceleration { get; set; } = 12.0f;

	[Export]
	float Gravity { get; set; } = 40.0f;

	[Export]
	float JumpForce { get; set; } = 14.0f;

	[Export]
	bool IsFlying { get; set; } = false;
	
	[Export]
	float VerticalFlySpeed { get; set; } = 10.0f;

	[Export]
	float HorizontalFlySpeed { get; set; } = 15.0f;

	[Export]
	float HorizontalFlyAcceleration { get; set; } = 5.0f;

	[Export]
	bool IsNoClip { get; set; } = false;

	[Export]
	float MouseSensitivity { get; set; } = 0.03f;

	private Vector3 _velocity;
	private float _horizontalAcceleration;
	private Vector3 _direction;
	private Vector3 _horizontalVelocity;
	private Vector3 _movement;
	private Vector3 _gravityVector;
	private Spatial _headNode;

	public Player()
	{
		_velocity = new Vector3();
		_direction = new Vector3();
		_horizontalVelocity = new Vector3();
		_movement = new Vector3();
		_gravityVector = new Vector3();
	}

	public override void _Ready()
	{
		_headNode = (Spatial)GetNode("Head");
		Input.SetMouseMode(Input.MouseMode.Captured);
		Vector2 viewportSize = GetViewport().Size;
		((Sprite)GetNode("HUD/Cross")).Position = new Vector2(viewportSize.x / 2.0f, viewportSize.y / 2.0f);
	}

	public override void _Input(InputEvent @event)
	{
		base._Input(@event);
		if (@event is InputEventMouseMotion)
		{
			InputEventMouseMotion mouseMotionEvent = (InputEventMouseMotion)@event;
			RotateY(Mathf.Deg2Rad(-mouseMotionEvent.Relative.x * MouseSensitivity));
			_headNode.RotateX(Mathf.Deg2Rad(-mouseMotionEvent.Relative.y * MouseSensitivity));
			Vector3 headRotation = _headNode.Rotation;
			headRotation.x = Mathf.Clamp(_headNode.Rotation.x, Mathf.Deg2Rad(-89.9f), Mathf.Deg2Rad(89.9f));
			_headNode.Rotation = headRotation;
		}
	}

	public override void _Process(float delta)
	{
		if (Input.IsActionJustPressed("toggle_fly"))
		{
			if (IsFlying) {
				IsFlying = false;
			} 
			else 
			{
				IsFlying = true;
			}
		}

		if (Input.IsActionJustPressed("toggle_noclip"))
		{
			if (IsNoClip)
			{
				IsNoClip = false;
			}
			else
			{
				IsNoClip = true;
			}
		}

		if (IsNoClip)
		{
			SetCollisionMaskBit(0, false);
		}
		else
		{
			SetCollisionMaskBit(0, true);
		}

		_direction = new Vector3();

		if (IsFlying == false)
		{
			if (IsOnFloor() == false)
			{
				_horizontalAcceleration = AirAcceleration;
			}
			else
			{
				_horizontalAcceleration = NormalAcceleration;
			}

			_gravityVector = Vector3.Down * Gravity * delta;
		}

		if (Input.IsActionPressed("move_forward"))
		{
			_direction -= Transform.basis.z;
		}
		else if (Input.IsActionPressed("move_backward"))
		{
			_direction += Transform.basis.z;
		}

		if (Input.IsActionPressed("move_left"))
		{
			_direction -= Transform.basis.x;
		}
		else if (Input.IsActionPressed("move_right"))
		{
			_direction += Transform.basis.x;
		}

		_direction = _direction.Normalized();

		if (IsFlying == false)
		{
			_horizontalVelocity = _horizontalVelocity.LinearInterpolate(_direction * Speed, _horizontalAcceleration * delta);
			_movement.z = _horizontalVelocity.z;
			_movement.x = _horizontalVelocity.x;

			if (_velocity.y == 0 & _movement.y > 0)
			{
				_movement.y = 0;
			}

			_movement.y += _gravityVector.y;

			if (IsOnFloor() == true & _movement.y <= 0)
			{
				_movement.y = 0;
			}

			if (Input.IsActionPressed("move_up") & IsOnFloor() == true & _movement.y <= 0)
			{
				_movement.y = JumpForce;
			}
		}
		else
		{
			_horizontalVelocity = _horizontalVelocity.LinearInterpolate(_direction * HorizontalFlySpeed, HorizontalFlyAcceleration * delta);
			_movement.z = _horizontalVelocity.z;
			_movement.x = _horizontalVelocity.x;

			if (Input.IsActionPressed("move_down"))
			{
				_movement.y = -VerticalFlySpeed;
			}
			else if (Input.IsActionPressed("move_up"))
			{
				_movement.y = VerticalFlySpeed;
			}
			else
			{
				_movement.y = 0;
			}
		}

		_velocity = MoveAndSlide(_movement, Vector3.Up);

	}
}
