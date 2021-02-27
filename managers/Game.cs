using Godot;
using System;

public class Game : Node
{

	public Godot.Collections.Dictionary<Vector3, Chunk> Chunks
	{
		get { return chunks; }
	}

	public WorldGenerator MainWorldGenerator
	{
		get { return mainWorldGenerator; }
	}

	private ChunkManager chunkManager;
	private Thread chunkThread;
	private Godot.Collections.Dictionary<Vector3, Chunk> chunks = new Godot.Collections.Dictionary<Vector3, Chunk>();
	private WorldGenerator mainWorldGenerator;

	public override void _Ready()
	{
		mainWorldGenerator = new WorldGenerator();
		chunkManager = new ChunkManager(this);
		chunkThread = new Thread();
		chunkThread.Start(chunkManager, "Start");
	}

	public override void _Process(float delta)
	{
		((Label)GetNode("FPSLabel")).Text = Engine.GetFramesPerSecond().ToString();
	}

	public void PlaceChunk(Chunk chunk)
	{
		AddChild(chunk);
		Transform chunkTransform = chunk.GlobalTransform;
		chunkTransform[3] = chunk.ChunkPosition * WorldHelper.ChunkSize;
		chunk.GlobalTransform = chunkTransform;
		chunks.Add(chunk.ChunkPosition, chunk);
	}
}
