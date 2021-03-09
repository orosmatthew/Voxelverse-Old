using Godot;

public class Grass : Block
{

	public override BlockMesh Mesh
	{
		get { return mesh; }
	}

	private Vector2[] texturePositions = {new Vector2(1, 0), new Vector2(1, 0), new Vector2(1, 0), 
								  		  new Vector2(1, 0), new Vector2(0, 0), new Vector2(2, 0)};

	private BlockMesh mesh;

	public override string Type
	{
		get { return "Grass"; }
	}

	public Grass(Vector3 chunkBlockPosition, Vector3 chunkPosition) : base(chunkBlockPosition, chunkPosition) 
	{
		mesh = new BlockMesh(texturePositions);
	}
}
