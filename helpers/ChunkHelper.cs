using Godot;
using System;

public class ChunkHelper : Reference
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

    public static Vector3 GetAdjacentBlockPosition(int side)
    {
        switch (side)
        {
            case (int)Sides.Front: return new Vector3(0, 0, 1);
            case (int)Sides.Back: return new Vector3(0, 0, -1);
            case (int)Sides.Right: return new Vector3(1, 0, 0);
            case (int)Sides.Left: return new Vector3(-1, 0, 0);
            case (int)Sides.Top: return new Vector3(0, 1, 0);
            case (int)Sides.Bottom: return new Vector3(0, -1, 0);
        }
        return new Vector3(0, 0, 0);
    }

    public static int GetOppositeSide(int side)
    {
        switch (side)
        {
            case 0: return 1;
            case 1: return 0;
            case 2: return 3;
            case 3: return 2;
            case 4: return 5;
            case 5: return 4;
            default: return 0;
        }
    }

    private static Vector2[] GetAtlasUvCoordinates(Vector2 atlasSize, Vector2 atlasPosition)
    {
        Vector2 offset = new Vector2(atlasPosition.x / atlasSize.x, atlasPosition.y / atlasSize.y);
        Vector2 bottomRight = new Vector2(offset.x + (1 / atlasSize.x), offset.y + (1 / atlasSize.y));
        Vector2 topLeft = new Vector2(offset.x, offset.y);
	    Vector2 topRight = new Vector2(offset.x + (1 / atlasSize.x), offset.y);
	    Vector2 bottomLeft = new Vector2(offset.x, offset.y + (1 / atlasSize.y));
        Vector2[] returnArray = {topLeft, topRight, bottomLeft, bottomRight};
        return returnArray;
    }

    public static Vector2[] GetCubeUvs(int orientation, int type, Vector2 textureAtlasSize)
    {


        if (orientation == (int)Sides.Front)
        {
            Vector2[] coordinates = GetAtlasUvCoordinates(textureAtlasSize, new Vector2(0, 0));
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
            Vector2[] coordinates = GetAtlasUvCoordinates(textureAtlasSize, new Vector2(0, 0));
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
            Vector2[] coordinates = GetAtlasUvCoordinates(textureAtlasSize, new Vector2(0, 0));
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
            Vector2[] coordinates = GetAtlasUvCoordinates(textureAtlasSize, new Vector2(0, 0));
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
            Vector2[] coordinates = GetAtlasUvCoordinates(textureAtlasSize, new Vector2(0, 0));
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
            Vector2[] coordinates = GetAtlasUvCoordinates(textureAtlasSize, new Vector2(0, 0));
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

    public static Vector3[] GetCubeVertices(int orientation)
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
