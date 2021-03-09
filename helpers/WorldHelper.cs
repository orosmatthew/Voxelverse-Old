using Godot;
using System;

public class WorldHelper : Reference
{

    public static int ChunkSize
    {
        get { return 8; }
    }

    public static Vector3 GetChunkFromWorld(Vector3 worldPosition)
    {
        Vector3 chunkPosition = new Vector3(Mathf.Floor(worldPosition.x / (float)ChunkSize), 
                                            Mathf.Floor(worldPosition.y / (float)ChunkSize), 
                                            Mathf.Floor(worldPosition.z / (float)ChunkSize));
        return chunkPosition;
    }

    public static Vector3 GetBlockFromWorld(Vector3 worldPosition)
    {
        Vector3 blockPosition = new Vector3(Mathf.Floor(worldPosition.x), 
                                            Mathf.Floor(worldPosition.y), 
                                            Mathf.Floor(worldPosition.z));
        return blockPosition;
    }

    public static Vector3 GetChunkBlockFromWorld(Vector3 worldPosition)
    {
        Vector3 chunkBlockPosition = new Vector3(Mathf.Floor(worldPosition.x) % ChunkSize, 
                                                 Mathf.Floor(worldPosition.y) % ChunkSize, 
                                                 Mathf.Floor(worldPosition.z) % ChunkSize);
        if (chunkBlockPosition.x < 0) 
        {
            chunkBlockPosition.x += ChunkSize;
        }
        if (chunkBlockPosition.y < 0) 
        {
            chunkBlockPosition.y += ChunkSize;
        }
        if (chunkBlockPosition.z < 0) 
        {
            chunkBlockPosition.z += ChunkSize;
        }
        return chunkBlockPosition;
    }

    public static Vector3 GetWorldBlockFromChunkBlock(Vector3 chunkPosition, Vector3 chunkBlockPosition)
    {
        Vector3 worldBlockPosition = new Vector3((chunkPosition.x * ChunkSize) + chunkBlockPosition.x, 
                                                 (chunkPosition.y * ChunkSize) + chunkBlockPosition.y, 
                                                 (chunkPosition.z * ChunkSize) + chunkBlockPosition.z);
        return worldBlockPosition;
    }

}
