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
	private ChunkManager chunkManager;
	private Thread chunkThread;

	public Game()
	{
		GD.Randomize();
		GenerationSeed = GD.Randi();
	}

	public override void _Ready()
	{
		chunkManager = new ChunkManager(this);
		chunkThread = new Thread();
		chunkThread.Start(chunkManager, "Start");
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

	public void PlaceChunk(Chunk chunk)
	{
		AddChild(chunk);
		Transform chunkTransform = chunk.GlobalTransform;
		chunkTransform[3] = chunk.ChunkPosition * 8;
		chunk.GlobalTransform = chunkTransform;
	}
}
