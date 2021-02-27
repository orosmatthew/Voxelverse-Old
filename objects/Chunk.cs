using Godot;
using System;

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
	
	private MeshInstance chunkMesh;
	private StaticBody staticNode;
	private Vector2 textureAtlasSize = new Vector2(8, 8);
	private Godot.Collections.Dictionary<Vector3, Block> blocks = new Godot.Collections.Dictionary<Vector3, Block>();
	private Material material = (Material)(GD.Load("res://TextureMaterial.tres"));
	private Godot.Collections.Array<Vector3> blockPositions = new Godot.Collections.Array<Vector3>();

	public void PlaceBlock(Vector3 chunkBlockPosition, int type)
	{
		if (blocks.ContainsKey(chunkBlockPosition))
		{
			return;
		}
		Block block = new Block(chunkBlockPosition, ChunkPosition, 1);
		blocks.Add(block.ChunkBlockPosition, block);
		Godot.Collections.Array<Vector3> updateList = new Godot.Collections.Array<Vector3>();
		for (int a = 0; a < 6; a++)
		{
			updateList.Add(block.ChunkBlockPosition + ChunkHelper.GetAdjacentBlockPosition(a));
		}
		UpdateChunk(updateList);
		CreateChunkCollision();
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
			CreateChunkCollision();
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
						Block block = new Block(new Vector3(x, y, z), ChunkPosition, b);
						blocks.Add(block.ChunkBlockPosition, block);
					}
				}
			}
		}
		UpdateChunk();
		CreateChunkCollision();
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
		BuildChunk();
	}

	public void BuildChunk()
	{

		if (chunkMesh != null)
		{
			chunkMesh.Free();
		}

		MeshInstance meshInstance = new MeshInstance();
		SurfaceTool surfaceTool = new SurfaceTool();

		surfaceTool.Begin(Mesh.PrimitiveType.Triangles);

		Godot.Collections.Array<Vector3> vertices = new Godot.Collections.Array<Vector3>();
		Godot.Collections.Array<Vector2> uvs = new Godot.Collections.Array<Vector2>();

		foreach (System.Collections.Generic.KeyValuePair<Vector3, Block> block in blocks)
		{
			for (int side = 0; side < 6; side++)
			{
				if (block.Value.AdjacentBlocks[side] == false)
				{
					foreach (Vector3 v in ChunkHelper.GetCubeVertices(side))
					{
						vertices.Add(block.Value.ChunkBlockPosition + v);
					}

					foreach (Vector2 u in ChunkHelper.GetCubeUvs(side, block.Value.Type, textureAtlasSize))
					{
						uvs.Add(u);
					}
				}
			}
		}

		for (int i = 0; i < vertices.Count; i++)
		{
			surfaceTool.AddUv(uvs[i]);
			surfaceTool.AddVertex(vertices[i]);
		}

		surfaceTool.GenerateNormals();
		surfaceTool.SetMaterial(material);
		ArrayMesh arrayMesh = surfaceTool.Commit();
		meshInstance.Mesh = arrayMesh;
		meshInstance.Name = "mesh";
		chunkMesh = meshInstance;
		AddChild(chunkMesh);
	}

	public void CreateChunkCollision()
	{

		if (staticNode != null)
		{
			staticNode.Free();
		}

		Godot.Collections.Array<Vector3> collisionVertices = new Godot.Collections.Array<Vector3>();

		foreach (System.Collections.Generic.KeyValuePair<Vector3, Block> block in blocks)
		{
			for (int a = 0; a < 6; a++)
			{
				if (block.Value.AdjacentBlocks[a] == false)
				{
					foreach (Vector3 v in ChunkHelper.GetCubeVertices(a))
					collisionVertices.Add(block.Value.ChunkBlockPosition + v);
				}
			}
		}

		if (collisionVertices.Count == 0)
		{
			return;
		}

		StaticBody staticBody = new StaticBody();
		staticBody.Name = "StaticBody";
		AddChild(staticBody);
		staticNode = staticBody;
		CollisionShape collisionShape = new CollisionShape();
		staticBody.AddChild(collisionShape);
		ConcavePolygonShape concavePolygonShape = new ConcavePolygonShape();
		Vector3[] collisionArray = new Vector3[collisionVertices.Count];
		collisionVertices.CopyTo(collisionArray, 0);
		concavePolygonShape.Data = collisionArray;
		collisionShape.Shape = concavePolygonShape;
	}
}
