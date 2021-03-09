using Godot;
using System;

public abstract class Block : Reference
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
    public bool[] AdjacentBlocks { get; set; }

    public abstract BlockMesh Mesh { get; }
    public abstract string Type { get; }

    public Block(Vector3 chunkBlockPosition, Vector3 chunkPosition)
    {
        ChunkBlockPosition = chunkBlockPosition;
        ChunkPosition = chunkPosition;
        WorldBlockPosition = WorldHelper.GetWorldBlockFromChunkBlock(chunkPosition, ChunkBlockPosition);
        AdjacentBlocks = new bool[6];
    }

}
