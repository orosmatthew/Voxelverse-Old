using Godot;

public class Water : Block
{

	public override BlockMesh Mesh
	{
		get { return mesh; }
	}

	private Vector2[] texturePositions = {new Vector2(5, 0), new Vector2(5, 0), new Vector2(5, 0), 
								          new Vector2(5, 0), new Vector2(5, 0), new Vector2(5, 0)};

	private BlockMesh mesh;

	public override string Type
	{
		get { return "Grass"; }
	}

	public Water(Vector3 chunkBlockPosition, Vector3 chunkPosition) : base(chunkBlockPosition, chunkPosition) 
	{
		mesh = new BlockMesh(texturePositions);
	}
}



