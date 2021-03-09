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
}
