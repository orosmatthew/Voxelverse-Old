using Godot;
using System;

public class Block : Reference
{

    public Vector3 ChunkBlockPosition { get; }
    public Vector3 WorldBlockPosition { get; }
    public Vector3 ChunkPosition { get; }

    public bool[] AdjacentBlocks { get; set; }

    public Block(Vector3 chunkBlockPosition, Vector3 chunkPosition)
    {
        ChunkBlockPosition = chunkBlockPosition;
        ChunkPosition = chunkPosition;
        WorldBlockPosition = WorldHelper.GetWorldBlockFromChunkBlock(chunkPosition, ChunkBlockPosition);
        AdjacentBlocks = new bool[6];
    }

}
