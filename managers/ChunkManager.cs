using Godot;
using System;

public class ChunkManager : Reference
{

	private Game game;

	public ChunkManager(Game game)
	{
		this.game = game;
	}

	public void Start(object n)
	{
		for (int x = -8; x < 8; x++)
		{
			for (int y = 0; y < 8; y++)
			{
				for (int z = -8; z < 8; z++)
				{
					PackedScene chunkScene = (PackedScene)ResourceLoader.Load("res://objects/Chunk.tscn");
					Chunk chunk = (Chunk)chunkScene.Instance();
					chunk.ChunkPosition = new Vector3(x, y, z);
					chunk.GenerateChunk(game.MainWorldGenerator);
					game.CallDeferred("PlaceChunk", chunk);
				}
			}
		}
	}

}
