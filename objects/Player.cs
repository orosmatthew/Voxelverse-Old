using Godot;
using System;


public class Player : KinematicBody
{
	
	[Export]
	float Speed = 10.0f;

	[Export]
	float AirAcceleration = 5.0f;

	[Export]
	float NormalAcceleration = 12.0f;

	[Export]
	float Gravity = 40.0f;

	[Export]
	float JumpForce = 14.0f;

	[Export]
	bool IsFlying = false;
	
	[Export]
	float VerticalFlySpeed = 10.0f;

	[Export]
	float HorizontalFlySpeed = 15.0f;

	[Export]
	float HorizontalFlyAcceleration = 5.0f;

	[Export]
	bool IsNoClip = false;

	[Export]
	float MouseSensitivity = 0.03f;

	Vector3 Velocity;
	float HorizontalAcceleration;
	Vector3 Direction;
	Vector3 HorizontalVelocity;
	Vector3 Movement;
	Vector3 GravityVector;
	Spatial HeadNode;

	public Player()
	{
		Velocity = new Vector3();
		Direction = new Vector3();
		HorizontalVelocity = new Vector3();
		Movement = new Vector3();
		GravityVector = new Vector3();
	}

	public override void _Ready()
	{
		HeadNode = (Spatial)GetNode("Head");
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
			HeadNode.RotateX(Mathf.Deg2Rad(-mouseMotionEvent.Relative.y * MouseSensitivity));
			Vector3 HeadRotation = HeadNode.Rotation;
			HeadRotation.x = Mathf.Clamp(HeadNode.Rotation.x, Mathf.Deg2Rad(-89.9f), Mathf.Deg2Rad(89.9f));
			HeadNode.Rotation = HeadRotation;
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

		Direction = new Vector3();

		if (IsFlying == false)
		{
			if (IsOnFloor() == false)
			{
				HorizontalAcceleration = AirAcceleration;
			}
			else
			{
				HorizontalAcceleration = NormalAcceleration;
			}

			GravityVector = Vector3.Down * Gravity * delta;
		}

		if (Input.IsActionPressed("move_forward"))
		{
			Direction -= Transform.basis.z;
		}
		else if (Input.IsActionPressed("move_backward"))
		{
			Direction += Transform.basis.z;
		}

		if (Input.IsActionPressed("move_left"))
		{
			Direction -= Transform.basis.x;
		}
		else if (Input.IsActionPressed("move_right"))
		{
			Direction += Transform.basis.x;
		}

		Direction = Direction.Normalized();

		if (IsFlying == false)
		{
			HorizontalVelocity = HorizontalVelocity.LinearInterpolate(Direction * Speed, HorizontalAcceleration * delta);
			Movement.z = HorizontalVelocity.z;
			Movement.x = HorizontalVelocity.x;

			if (Velocity.y == 0 & Movement.y > 0)
			{
				Movement.y = 0;
			}

			Movement.y += GravityVector.y;

			if (IsOnFloor() == true & Movement.y <= 0)
			{
				Movement.y = 0;
			}

			if (Input.IsActionPressed("move_up") & IsOnFloor() == true & Movement.y <= 0)
			{
				Movement.y = JumpForce;
			}
		}
		else
		{
			HorizontalVelocity = HorizontalVelocity.LinearInterpolate(Direction * HorizontalFlySpeed, HorizontalFlyAcceleration * delta);
			Movement.z = HorizontalVelocity.z;
			Movement.x = HorizontalVelocity.x;

			if (Input.IsActionPressed("move_down"))
			{
				Movement.y = -VerticalFlySpeed;
			}
			else if (Input.IsActionPressed("move_up"))
			{
				Movement.y = VerticalFlySpeed;
			}
			else
			{
				Movement.y = 0;
			}
		}

		Velocity = MoveAndSlide(Movement, Vector3.Up);

	}
}
