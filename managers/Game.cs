using Godot;
using System;

public class Game : Node
{

	public uint GenerationSeed { get; }

	public Vector3 PlayerPosition
	{
		get { return _playerPosition; }
	}

	public Vector3 PlayerChunkPosition
	{
		get { return _playerChunkPosition; }
	}

	public Vector3 PlayerBlockPosition 
	{ 
		get { return _playerBlockPosition; }
	}

	public Vector3 PlayerChunkBlockPosition
	{
		get { return _playerChunkBlockPosition; }
	}

	private Vector3 _playerPosition;
	private Vector3 _playerChunkPosition;
	private Vector3 _playerBlockPosition;
	private Vector3 _playerChunkBlockPosition;

	public Game()
	{
		GD.Randomize();
		GenerationSeed = GD.Randi();
	}

	public override void _Ready()
	{
		GenerateWorld();
	}

	public override void _Process(float delta)
	{
		((Label)GetNode("FPSLabel")).Text = Engine.GetFramesPerSecond().ToString();
		UpdatePlayerPositions();
		
	}

	private void UpdatePlayerPositions() 
	{
		_playerPosition = ((Player)GetNode("Player")).GlobalTransform[3];
		_playerChunkPosition = WorldHelper.GetChunkFromWorldPosition(PlayerPosition);
		_playerBlockPosition = WorldHelper.GetBlockFromWorldPosition(PlayerPosition);
		_playerChunkBlockPosition = WorldHelper.GetChunkBlockFromWorldPosition(PlayerPosition);
	}

	private void GenerateWorld()
	{
		PackedScene chunkScene = (PackedScene)ResourceLoader.Load("res://objects/Chunk.tscn");
		Chunk chunk = (Chunk)chunkScene.Instance();
		AddChild(chunk);
	}
}
