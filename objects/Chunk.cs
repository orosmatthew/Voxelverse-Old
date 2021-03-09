using Godot;

public class Chunk : Spatial
{
	
	public Vector3 ChunkPosition { get; set; }
	
	public Godot.Collections.Dictionary<Vector3, Block> Blocks
	{
		get { return blocks; }
	}

	public Godot.Collections.Array<Vector3> BlockPositions
	{
		get { return blockPositions; }
	}
	
	private Godot.Collections.Dictionary<Vector3, Block> blocks = new Godot.Collections.Dictionary<Vector3, Block>();
	private Godot.Collections.Array<Vector3> blockPositions = new Godot.Collections.Array<Vector3>();
	private ChunkMesh chunkMesh = new ChunkMesh();
	private ChunkCollisionMesh chunkCollisionMesh = new ChunkCollisionMesh();

	public Chunk()
	{
		AddChild(chunkCollisionMesh);
		AddChild(chunkMesh);
	}

	public void PlaceBlock(Vector3 chunkBlockPosition, int type)
	{
		if (blocks.ContainsKey(chunkBlockPosition))
		{
			return;
		}
		Block block = new Grass(chunkBlockPosition, ChunkPosition);
		blocks.Add(block.ChunkBlockPosition, block);
		Godot.Collections.Array<Vector3> updateList = new Godot.Collections.Array<Vector3>();
		for (int a = 0; a < 6; a++)
		{
			updateList.Add(block.ChunkBlockPosition + ChunkHelper.GetAdjacentBlockPosition(a));
		}
		UpdateChunk(updateList);
		chunkCollisionMesh.CreateChunkCollision(blocks);
	}

	public void RemoveBlock(Vector3 chunkBlockPosition)
	{
		if (blocks.ContainsKey(chunkBlockPosition))
		{
			blocks.Remove(chunkBlockPosition);
			Godot.Collections.Array<Vector3> updateList = new Godot.Collections.Array<Vector3>();
			for (int a = 0; a < 6; a++)
			{
				updateList.Add(chunkBlockPosition + ChunkHelper.GetAdjacentBlockPosition(a));
			}
			UpdateChunk(updateList);
			chunkCollisionMesh.CreateChunkCollision(blocks);
		}
	}

	public void GenerateChunk(WorldGenerator worldGenerator)
	{

		for (int x = 0; x < WorldHelper.ChunkSize; x++)
		{
			for (int y = 0; y < WorldHelper.ChunkSize; y++)
			{
				for (int z = 0; z < WorldHelper.ChunkSize; z++)
				{
					Vector3 queryPosition = WorldHelper.GetWorldBlockFromChunkBlock(ChunkPosition, new Vector3(x, y, z));
					int b = worldGenerator.QueryBlock(queryPosition);
					if (b != 0)
					{
						if (b == 1)
						{
							Block block = new Grass(new Vector3(x, y, z), ChunkPosition);
							blocks.Add(block.ChunkBlockPosition, block);
						}
						else if (b == 2)
						{
							Block block = new Stone(new Vector3(x, y, z), ChunkPosition);
							blocks.Add(block.ChunkBlockPosition, block);
						}
						else if (b == 3)
						{
							Block block = new Sand(new Vector3(x, y, z), ChunkPosition);
							blocks.Add(block.ChunkBlockPosition, block);
						}
						else if (b == 4)
						{
							Block block = new Water(new Vector3(x, y, z), ChunkPosition);
							blocks.Add(block.ChunkBlockPosition, block);
						}
						
					}
				}
			}
		}
		UpdateChunk();
		chunkCollisionMesh.CreateChunkCollision(blocks);
	}

	public void UpdateChunk(Godot.Collections.Array<Vector3> updateList = null)
	{
		if (updateList == null)
		{
			foreach (System.Collections.Generic.KeyValuePair<Vector3, Block> block in blocks)
			{
				for (int a = 0; a < 6; a++)
				{
					block.Value.AdjacentBlocks[a] = blocks.ContainsKey(block.Value.ChunkBlockPosition + ChunkHelper.GetAdjacentBlockPosition(a));
				}
			}
		}
		else
		{
			foreach (Vector3 chunkBlockPosition in updateList)
			{
				if (blocks.ContainsKey(chunkBlockPosition))
				{
					for (int a = 0; a < 6; a++)
					{
						blocks[chunkBlockPosition].AdjacentBlocks[a] = blocks.ContainsKey(chunkBlockPosition + ChunkHelper.GetAdjacentBlockPosition(a));
					}
				}
			}
		}
		chunkMesh.BuildChunk(blocks);
	}



}
