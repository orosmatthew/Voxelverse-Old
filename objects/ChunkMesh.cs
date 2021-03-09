using Godot;

public class ChunkMesh : Spatial
{
	
    public MeshInstance ChunkMeshInstance
    {
        get { return chunkMeshInstance; }
    }
	
    private MeshInstance chunkMeshInstance;
    private Vector2 textureAtlasSize = new Vector2(8, 8);
    private Material material = (Material)(GD.Load("res://TextureMaterial.tres"));

    public void BuildChunk(Godot.Collections.Dictionary<Vector3, Block> blocks)
	{

        if (chunkMeshInstance != null)
		{
			chunkMeshInstance.Free();
            chunkMeshInstance = null;
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
					foreach (Vector3 v in block.Value.Mesh.GetVertices(side))
					{
						vertices.Add(block.Value.ChunkBlockPosition + v);
					}

					foreach (Vector2 u in block.Value.Mesh.GetUVs(side, textureAtlasSize))
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
		chunkMeshInstance = meshInstance;
		AddChild(chunkMeshInstance);
	}

}
	