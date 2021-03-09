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



    public static Vector2[] GetTexturePositionsFromBlockType(int type)
    {
        switch (type)
        {
            case 1: return new Vector2[] {new Vector2(1, 0), new Vector2(1, 0), new Vector2(1, 0), 
                                          new Vector2(1, 0), new Vector2(0, 0), new Vector2(2, 0)};

            case 2: return new Vector2[] {new Vector2(3, 0), new Vector2(3, 0), new Vector2(3, 0), 
                                          new Vector2(3, 0), new Vector2(3, 0), new Vector2(3, 0)};

            case 3: return new Vector2[] {new Vector2(4, 0), new Vector2(4, 0), new Vector2(4, 0), 
                                          new Vector2(4, 0), new Vector2(4, 0), new Vector2(4, 0)};

            case 4: return new Vector2[] {new Vector2(5, 0), new Vector2(5, 0), new Vector2(5, 0), 
                                          new Vector2(5, 0), new Vector2(5, 0), new Vector2(5, 0)};

            default: return new Vector2[] {new Vector2(0, 0), new Vector2(0, 0), new Vector2(0, 0), 
                                          new Vector2(0, 0), new Vector2(0, 0), new Vector2(0, 0)};
        }
    }

}
