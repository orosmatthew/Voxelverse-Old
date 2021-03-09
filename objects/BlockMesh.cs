using Godot;
using System;

public class BlockMesh : Reference
{
	public enum Sides
	{
		Front,
		Back,
		Right,
		Left,
		Top,
		Bottom
	}

	public Vector2[] TexturePositions { get; }

	public BlockMesh(Vector2[] texturePositions) {
		TexturePositions = texturePositions;
	}

	private Vector2[] GetAtlasUVCoordinates(Vector2 atlasSize, Vector2 atlasPosition)
	{
		Vector2 offset = new Vector2(atlasPosition.x / atlasSize.x, atlasPosition.y / atlasSize.y);
		Vector2 bottomRight = new Vector2(offset.x + (1 / atlasSize.x), offset.y + (1 / atlasSize.y));
		Vector2 topLeft = new Vector2(offset.x, offset.y);
		Vector2 topRight = new Vector2(offset.x + (1 / atlasSize.x), offset.y);
		Vector2 bottomLeft = new Vector2(offset.x, offset.y + (1 / atlasSize.y));
		Vector2[] returnArray = {topLeft, topRight, bottomLeft, bottomRight};
		return returnArray;
	}

	public Vector2[] GetUVs(int orientation, Vector2 textureAtlasSize)
	{

		if (orientation == (int)Sides.Front)
		{
			
			Vector2[] coordinates = GetAtlasUVCoordinates(textureAtlasSize, TexturePositions[(int)Sides.Front]);
			Vector2[] uvArray = 
			{
				coordinates[0],
				coordinates[3],
				coordinates[2],

				coordinates[1],
				coordinates[3],
				coordinates[0]
			};
			return uvArray;
		}

		if (orientation == (int)Sides.Back)
		{
			Vector2[] coordinates = GetAtlasUVCoordinates(textureAtlasSize, TexturePositions[(int)Sides.Back]);
			Vector2[] uvArray = 
			{
				coordinates[0],
				coordinates[1],
				coordinates[3],

				coordinates[0],
				coordinates[3],
				coordinates[2]
			};
			return uvArray;
		}

		if (orientation == (int)Sides.Right)
		{
			Vector2[] coordinates = GetAtlasUVCoordinates(textureAtlasSize, TexturePositions[(int)Sides.Right]);
			Vector2[] uvArray = 
			{
				coordinates[0],
				coordinates[1],
				coordinates[3],

				coordinates[3],
				coordinates[2],
				coordinates[0]
			};
			return uvArray;
		}

		if (orientation == (int)Sides.Left)
		{
			Vector2[] coordinates = GetAtlasUVCoordinates(textureAtlasSize, TexturePositions[(int)Sides.Left]);
			Vector2[] uvArray = 
			{
				coordinates[2],
				coordinates[1],
				coordinates[3],

				coordinates[2],
				coordinates[0],
				coordinates[1]
			};
			return uvArray;
		}

		if (orientation == (int)Sides.Top)
		{
			Vector2[] coordinates = GetAtlasUVCoordinates(textureAtlasSize, TexturePositions[(int)Sides.Top]);
			Vector2[] uvArray = 
			{
				coordinates[3],
				coordinates[0],
				coordinates[1],

				coordinates[3],
				coordinates[2],
				coordinates[0]
			};
			return uvArray;
		}

		if (orientation == (int)Sides.Bottom)
		{
			Vector2[] coordinates = GetAtlasUVCoordinates(textureAtlasSize, TexturePositions[(int)Sides.Bottom]);
			Vector2[] uvArray = 
			{
				coordinates[2],
				coordinates[0],
				coordinates[1],

				coordinates[2],
				coordinates[1],
				coordinates[3]
			};
			return uvArray;
		}

		Vector2[] returnArray = new Vector2[6];
		return returnArray;

	}

	public Vector3[] GetVertices(int orientation)
	{
		if (orientation == (int)Sides.Front)
		{
			Vector3[] verticeArray = 
			{
				new Vector3(0,1,1),
				new Vector3(1,0,1),
				new Vector3(0,0,1),
				
				new Vector3(1,1,1),
				new Vector3(1,0,1),
				new Vector3(0,1,1)
			};
			return verticeArray;
		}
		
		if (orientation == (int)Sides.Back)
		{
			Vector3[] verticeArray = 
			{
				new Vector3(1,1,0),
				new Vector3(0,1,0),
				new Vector3(0,0,0),
				
				new Vector3(1,1,0),
				new Vector3(0,0,0),
				new Vector3(1,0,0)
			};
			return verticeArray;
		}

		if (orientation == (int)Sides.Right)
		{
			Vector3[] verticeArray = 
			{
				new Vector3(1,1,1),
				new Vector3(1,1,0),
				new Vector3(1,0,0),
				
				new Vector3(1,0,0),
				new Vector3(1,0,1),
				new Vector3(1,1,1)
			};
			return verticeArray;
		}

		if (orientation == (int)Sides.Left)
		{
			Vector3[] verticeArray = 
			{
				new Vector3(0,0,0),
				new Vector3(0,1,1),
				new Vector3(0,0,1),
				
				new Vector3(0,0,0),
				new Vector3(0,1,0),
				new Vector3(0,1,1)
			};
			return verticeArray;
		}

		if (orientation == (int)Sides.Top)
		{
			Vector3[] verticeArray = 
			{
				new Vector3(1,1,1),
				new Vector3(0,1,0),
				new Vector3(1,1,0),
				
				new Vector3(1,1,1),
				new Vector3(0,1,1),
				new Vector3(0,1,0)
			};
			return verticeArray;
		}

		if (orientation == (int)Sides.Bottom)
		{
			Vector3[] verticeArray = 
			{
				new Vector3(1,0,1),
				new Vector3(1,0,0),
				new Vector3(0,0,0),
				
				new Vector3(1,0,1),
				new Vector3(0,0,0),
				new Vector3(0,0,1)
			};
			return verticeArray;
		}

		Vector3[] returnArray = new Vector3[6];
		return returnArray;
	}
}
