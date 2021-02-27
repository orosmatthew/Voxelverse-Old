using Godot;
using System;

public class WorldGenerator : Reference
{

    public int GenerationSeed
    {
        get { return generationSeed; }
    }

    private int generationSeed;
    private OpenSimplexNoise noise = new OpenSimplexNoise();

    public WorldGenerator()
    {
        GD.Randomize();
		generationSeed = (int)GD.Randi();
        noise.Seed = GenerationSeed;
        noise.Octaves = 3;
        noise.Period = 25;
        noise.Persistence = 0.3f;
    }

    public int QueryBlock(Vector3 worldBlockPosition)
    {
        float n = noise.GetNoise3d(worldBlockPosition.x, worldBlockPosition.y, worldBlockPosition.z);
        n /= 2;
        n += 0.5f;
        float threshold = Mathf.Pow(0.955f, worldBlockPosition.y);
        if (n < threshold)
        {
            if (worldBlockPosition.y < 14)
            {
                return 3;
            }
            else
            {
                return 1;
            }
        }
        else if (worldBlockPosition.y < 12)
        {
            return 4;
        }
        return 0;
    }
}
