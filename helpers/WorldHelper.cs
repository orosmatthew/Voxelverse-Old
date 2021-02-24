using Godot;
using System;

public class WorldHelper : Reference
{
    public static Vector3 GetChunkFromWorld(Vector3 worldPosition)
    {
        Vector3 chunkPosition = new Vector3(Mathf.Floor(worldPosition.x / 8.0f), 
                                            Mathf.Floor(worldPosition.y / 8.0f), 
                                            Mathf.Floor(worldPosition.z / 8.0f));
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
        Vector3 chunkBlockPosition = new Vector3((int)(worldPosition.x) % 8, 
                                                 (int)(worldPosition.y) % 8, 
                                                 (int)(worldPosition.z) % 8);
        return chunkBlockPosition;
    }

}
