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

	public Vector3 Position
	{
		get { return position; }
	}

	public Vector3 ChunkPosition
	{
		get { return chunkPosition; }
	}

	public Vector3 BlockPosition 
	{ 
		get { return blockPosition; }
	}

	public Vector3 ChunkBlockPosition
	{
		get { return chunkBlockPosition; }
	}

	private Vector3 position;
	private Vector3 chunkPosition;
	private Vector3 blockPosition;
	private Vector3 chunkBlockPosition;

	private Vector3 velocity;
	private float horizontalAcceleration;
	private Vector3 direction;
	private Vector3 horizontalVelocity;
	private Vector3 movement;
	private Vector3 gravityVector;

	private Spatial headNode;
	private RayCast rayCastNode;
	private Spatial selectBoxNode;

	public Player()
	{
		velocity = new Vector3();
		direction = new Vector3();
		horizontalVelocity = new Vector3();
		movement = new Vector3();
		gravityVector = new Vector3();
	}

	public override void _Ready()
	{
		headNode = (Spatial)GetNode("Head");
		rayCastNode = (RayCast)GetNode("Head/RayCast");
		selectBoxNode = (Spatial)GetNode("SelectBox");
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
			headNode.RotateX(Mathf.Deg2Rad(-mouseMotionEvent.Relative.y * MouseSensitivity));
			Vector3 headRotation = headNode.Rotation;
			headRotation.x = Mathf.Clamp(headNode.Rotation.x, Mathf.Deg2Rad(-89.9f), Mathf.Deg2Rad(89.9f));
			headNode.Rotation = headRotation;
		}
	}

	public override void _Process(float delta)
	{
		HandleMovement(delta);
		HandleSelection();
	}

	private void UpdatePositions() 
	{
		position = GlobalTransform[3];
		chunkPosition = WorldHelper.GetChunkFromWorld(Position);
		blockPosition = WorldHelper.GetBlockFromWorld(Position);
		chunkBlockPosition = WorldHelper.GetChunkBlockFromWorld(Position);
	}

	private void HandleSelection()
	{
		bool blockExist = false;
		Vector3 breakBlockPosition = new Vector3(0, 0, 0);
		Vector3 placeBlockPosition = new Vector3(0, 0, 0);

		if (rayCastNode.GetCollider() != null)
		{
			blockExist = true;
			Vector3 rayCastPosition = rayCastNode.GetCollisionPoint();
			Vector3 rayCastNormal = rayCastNode.GetCollisionNormal();
			Vector3 queryPoint = rayCastPosition + new Vector3(-0.5f, -0.5f, -0.5f);

			int[,] axisMatrix = new int[,] { {0, 1, 2}, {1, 0, 2}, {2, 1, 0} };

			for (int i = 0; i < 3; i++)
			{
				if (Mathf.Abs(rayCastNormal[axisMatrix[i, 0]]) == 1)
				{
					breakBlockPosition[axisMatrix[i, 1]] = Mathf.Round(queryPoint[axisMatrix[i, 1]]);
					breakBlockPosition[axisMatrix[i, 2]] = Mathf.Round(queryPoint[axisMatrix[i, 2]]);

					placeBlockPosition[axisMatrix[i, 1]] = Mathf.Round(queryPoint[axisMatrix[i, 1]]);
					placeBlockPosition[axisMatrix[i, 2]] = Mathf.Round(queryPoint[axisMatrix[i, 2]]);
					
					if (rayCastNormal[axisMatrix[i, 0]] > 0)
					{
						breakBlockPosition[axisMatrix[i, 0]] = Mathf.Floor(queryPoint[axisMatrix[i, 0]]);
						placeBlockPosition[axisMatrix[i, 0]] = Mathf.Floor(queryPoint[axisMatrix[i, 0]]) + 1;
					}
					else
					{
						breakBlockPosition[axisMatrix[i, 0]] = Mathf.Ceil(queryPoint[axisMatrix[i, 0]]);
						placeBlockPosition[axisMatrix[i, 0]] = Mathf.Ceil(queryPoint[axisMatrix[i, 0]]) - 1;
					}
				}
			}
		}
		else
		{
			blockExist = false;
		}

		if (blockExist == true)
		{
			selectBoxNode.Show();
			Transform selectBoxTransform = selectBoxNode.GlobalTransform;
			selectBoxTransform[3] = breakBlockPosition + new Vector3(0.5f, 0.5f, 0.5f);
			selectBoxTransform.basis = new Basis(new Vector3(0, 0, 0));
			selectBoxNode.GlobalTransform = selectBoxTransform;
		}
		else
		{
			selectBoxNode.Hide();
		}

	}

	private void HandleMovement(float delta)
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

		direction = new Vector3();

		if (IsFlying == false)
		{
			if (IsOnFloor() == false)
			{
				horizontalAcceleration = AirAcceleration;
			}
			else
			{
				horizontalAcceleration = NormalAcceleration;
			}

			gravityVector = Vector3.Down * Gravity * delta;
		}

		if (Input.IsActionPressed("move_forward"))
		{
			direction -= Transform.basis.z;
		}
		else if (Input.IsActionPressed("move_backward"))
		{
			direction += Transform.basis.z;
		}

		if (Input.IsActionPressed("move_left"))
		{
			direction -= Transform.basis.x;
		}
		else if (Input.IsActionPressed("move_right"))
		{
			direction += Transform.basis.x;
		}

		direction = direction.Normalized();

		if (IsFlying == false)
		{
			horizontalVelocity = horizontalVelocity.LinearInterpolate(direction * Speed, horizontalAcceleration * delta);
			movement.z = horizontalVelocity.z;
			movement.x = horizontalVelocity.x;

			if (velocity.y == 0 & movement.y > 0)
			{
				movement.y = 0;
			}

			movement.y += gravityVector.y;

			if (IsOnFloor() == true & movement.y <= 0)
			{
				movement.y = 0;
			}

			if (Input.IsActionPressed("move_up") & IsOnFloor() == true & movement.y <= 0)
			{
				movement.y = JumpForce;
			}
		}
		else
		{
			horizontalVelocity = horizontalVelocity.LinearInterpolate(direction * HorizontalFlySpeed, HorizontalFlyAcceleration * delta);
			movement.z = horizontalVelocity.z;
			movement.x = horizontalVelocity.x;

			if (Input.IsActionPressed("move_down"))
			{
				movement.y = -VerticalFlySpeed;
			}
			else if (Input.IsActionPressed("move_up"))
			{
				movement.y = VerticalFlySpeed;
			}
			else
			{
				movement.y = 0;
			}
		}

		velocity = MoveAndSlide(movement, Vector3.Up);

	}

}
