using Godot;
using System;

public class Chunk : Spatial
{
    
    Vector3 ChunkPosition;
    OpenSimplexNoise Noise;
    Node GameNode;
    MeshInstance ChunkMesh;
    StaticBody StaticNode;
    Godot.Collections.Dictionary BlockDictionary;
    Vector2 TextureAtlasSize;
    Resource Material = GD.Load("res://TextureMaterial.tres");

    public void updateChunk(Godot.Collections.Array updateBlocks, bool inChunkCheck)
    {
        if (updateBlocks.Count == 0)
        {
            updateBlocks = (Godot.Collections.Array)BlockDictionary.Keys;
        }

        foreach (Vector3 block in updateBlocks)
        {
            if (!BlockDictionary.Contains(block))
            {
                continue;
            }

            //BlockDictionary[block]["adjacent"] = Godot.Collections.Array;

        }

    }

    public override void _Process(float delta)
    {
        
    }
}
