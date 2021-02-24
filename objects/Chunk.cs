using Godot;
using System;

public class Chunk : Spatial
{
	
	public Vector3 ChunkPosition { get; set; }
	
	public Godot.Collections.Array<Block> Blocks
	{
		get { return blocks; }
	}

	public Godot.Collections.Array<Vector3> BlockPositions
	{
		get { return blockPositions; }
	}
	
	private Node gameNode;
	private MeshInstance chunkMesh;
	private StaticBody staticNode;
	private Vector2 textureAtlasSize = new Vector2(8, 8);
	private Godot.Collections.Array<Block> blocks = new Godot.Collections.Array<Block>();
	private Material material = (Material)(GD.Load("res://TextureMaterial.tres"));
	private Godot.Collections.Array<Vector3> blockPositions = new Godot.Collections.Array<Vector3>();

	public void GenerateChunk()
	{

		for (int x = 0; x < 8; x++)
		{
			for (int y = 0; y < 8; y++)
			{
				for (int z = 0; z < 8; z++)
				{
					Block block = new Block(new Vector3(x, y, z), ChunkPosition);
					blocks.Add(block);
				}
			}
		}
		UpdateChunk();
		CreateChunkCollision();
	}

	public void UpdateChunk()
	{

		blockPositions.Clear();

		foreach (Block block in blocks)
		{
			blockPositions.Add(block.ChunkBlockPosition);
		}

		foreach (Block block in blocks)
		{
			for (int a = 0; a < 6; a++)
			{
				block.AdjacentBlocks[a] = blockPositions.Contains(block.ChunkBlockPosition + ChunkHelper.GetAdjacentBlockPosition(a));
			}
		}

		BuildChunk();
	}

	public void BuildChunk()
	{
		MeshInstance meshInstance = new MeshInstance();
		SurfaceTool surfaceTool = new SurfaceTool();

		surfaceTool.Begin(Mesh.PrimitiveType.Triangles);

		Godot.Collections.Array<Vector3> vertices = new Godot.Collections.Array<Vector3>();
		Godot.Collections.Array<Vector2> uvs = new Godot.Collections.Array<Vector2>();

		foreach (Block block in blocks)
		{
			for (int side = 0; side < 6; side++)
			{
				if (block.AdjacentBlocks[side] == false)
				{
					foreach (Vector3 v in ChunkHelper.GetCubeVertices(side))
					{
						vertices.Add(block.ChunkBlockPosition + v);
					}

					foreach (Vector2 u in ChunkHelper.GetCubeUvs(side, 1, textureAtlasSize))
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
		Godot.Collections.Array<Vector3> collisionVertices = new Godot.Collections.Array<Vector3>();

		foreach (Block block in blocks)
		{
			for (int a = 0; a < 6; a++)
			{
				if (block.AdjacentBlocks[a] == false)
				{
					foreach (Vector3 v in ChunkHelper.GetCubeVertices(a))
					collisionVertices.Add(block.ChunkBlockPosition + v);
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
