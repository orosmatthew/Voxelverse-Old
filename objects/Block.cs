using Godot;
using System;

public class Block : Reference
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

    public Vector3 ChunkBlockPosition { get; }
    public Vector3 WorldBlockPosition { get; }
    public Vector3 ChunkPosition { get; }
    public int Type { get; }

    public bool[] AdjacentBlocks { get; set; }

    public Block(Vector3 chunkBlockPosition, Vector3 chunkPosition, int type = 0)
    {
        ChunkBlockPosition = chunkBlockPosition;
        ChunkPosition = chunkPosition;
        WorldBlockPosition = WorldHelper.GetWorldBlockFromChunkBlock(chunkPosition, ChunkBlockPosition);
        AdjacentBlocks = new bool[6];
        Type = type;
    }

}
