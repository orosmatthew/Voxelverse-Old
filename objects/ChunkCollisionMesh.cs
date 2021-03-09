using Godot;

public class ChunkCollisionMesh : Spatial
{
	
    public StaticBody StaticBodyNode
    {
        get { return staticBodyNode; }
    }

	private StaticBody staticBodyNode;

    public void CreateChunkCollision(Godot.Collections.Dictionary<Vector3, Block> blocks)
	{

        if (staticBodyNode != null)
		{
			staticBodyNode.Free();
            staticBodyNode = null;
		}

		Godot.Collections.Array<Vector3> collisionVertices = new Godot.Collections.Array<Vector3>();

		foreach (System.Collections.Generic.KeyValuePair<Vector3, Block> block in blocks)
		{
			for (int a = 0; a < 6; a++)
			{
				if (block.Value.AdjacentBlocks[a] == false)
				{
					foreach (Vector3 v in block.Value.Mesh.GetVertices(a))
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
		CollisionShape collisionShape = new CollisionShape();
		staticBody.AddChild(collisionShape);
		ConcavePolygonShape concavePolygonShape = new ConcavePolygonShape();
		Vector3[] collisionArray = new Vector3[collisionVertices.Count];
		collisionVertices.CopyTo(collisionArray, 0);
		concavePolygonShape.Data = collisionArray;
		collisionShape.Shape = concavePolygonShape;
        staticBodyNode = staticBody;
        AddChild(StaticBodyNode);
	}

}
	