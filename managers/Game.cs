using Godot;
using System;

public class Game : Node
{

	public uint GenerationSeed { get; }

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
		
	}

	public void PlaceChunk(Chunk chunk)
	{
		AddChild(chunk);
		Transform chunkTransform = chunk.GlobalTransform;
		chunkTransform[3] = chunk.ChunkPosition * 8;
		chunk.GlobalTransform = chunkTransform;
	}
}
