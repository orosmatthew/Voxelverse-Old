using Godot;
using System;

public class Game : Node
{

	public uint GenerationSeed { get; }

	public Vector3 PlayerPosition
	{
		get { return playerPosition; }
	}

	public Vector3 PlayerChunkPosition
	{
		get { return playerChunkPosition; }
	}

	public Vector3 PlayerBlockPosition 
	{ 
		get { return playerBlockPosition; }
	}

	public Vector3 PlayerChunkBlockPosition
	{
		get { return playerChunkBlockPosition; }
	}

	private Vector3 playerPosition;
	private Vector3 playerChunkPosition;
	private Vector3 playerBlockPosition;
	private Vector3 playerChunkBlockPosition;

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
		playerPosition = ((Player)GetNode("Player")).GlobalTransform[3];
		playerChunkPosition = WorldHelper.GetChunkFromWorld(PlayerPosition);
		playerBlockPosition = WorldHelper.GetBlockFromWorld(PlayerPosition);
		playerChunkBlockPosition = WorldHelper.GetChunkBlockFromWorld(PlayerPosition);
	}

	private void GenerateWorld()
	{
		PackedScene chunkScene = (PackedScene)ResourceLoader.Load("res://objects/Chunk.tscn");
		Chunk chunk = (Chunk)chunkScene.Instance();
		AddChild(chunk);
		chunk.GenerateChunk();
	}
}
