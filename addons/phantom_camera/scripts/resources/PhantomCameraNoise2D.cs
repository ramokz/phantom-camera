using Godot;

namespace PhantomCamera.Noise;

public partial class PhantomCameraNoise2D(Resource resource) : Resource
{
    public readonly Resource Resource = resource;
    
    public float Amplitude
    {
        get => (float)Resource.Call(PhantomCameraNoise2DMethodName.GetAmplitude);
        set => Resource.Call(PhantomCameraNoise2DMethodName.SetAmplitude, value);
    }

    public float Frequency
    {
        get => (float)Resource.Call(PhantomCameraNoise2DMethodName.GetFrequency);
        set => Resource.Call(PhantomCameraNoise2DMethodName.SetFrequency, value);
    }

    public bool RandomizeNoiseSeed
    {
        get => (bool)Resource.Call(PhantomCameraNoise2DMethodName.GetRandomizeNoiseSeed);
        set => Resource.Call(PhantomCameraNoise2DMethodName.SetRandomizeNoiseSeed, value);
    }

    public int NoiseSeed
    {
        get => (int)Resource.Call(PhantomCameraNoise2DMethodName.GetNoiseSeed);
        set => Resource.Call(PhantomCameraNoise2DMethodName.SetNoiseSeed, value);
    }

    public bool RotationalNoise
    {
        get => (bool)Resource.Call(PhantomCameraNoise2DMethodName.GetRotationalNoise);
        set => Resource.Call(PhantomCameraNoise2DMethodName.SetRotationalNoise, value);
    }

    public bool PositionalNoise
    {
        get => (bool)Resource.Call(PhantomCameraNoise2DMethodName.GetPositionalNoise);
        set => Resource.Call(PhantomCameraNoise2DMethodName.SetPositionalNoise, value);
    }

    public float RotationalMultiplier
    {
        get => (float)Resource.Call(PhantomCameraNoise2DMethodName.GetRotationalMultiplier);
        set => Resource.Call(PhantomCameraNoise2DMethodName.SetRotationalMultiplier, value);
    }
    
    public float PositionalMultiplierX
    {
        get => (float)Resource.Call(PhantomCameraNoise2DMethodName.GetPositionalMultiplierX);
        set => Resource.Call(PhantomCameraNoise2DMethodName.SetPositionalMultiplierX, value);
    }
    
    public float PositionalMultiplierY
    {
        get => (float)Resource.Call(PhantomCameraNoise2DMethodName.GetPositionalMultiplierY);
        set => Resource.Call(PhantomCameraNoise2DMethodName.SetPositionalMultiplierY, value);
    }

    public static class PhantomCameraNoise2DMethodName
    {
        public const string GetAmplitude = "get_amplitude";
        public const string SetAmplitude = "set_amplitude";

        public const string GetFrequency = "get_frequency";
        public const string SetFrequency = "set_frequency";

        public const string GetRandomizeNoiseSeed = "get_randomize_noise_seed";
        public const string SetRandomizeNoiseSeed = "set_randomize_noise_seed";

        public const string GetNoiseSeed = "get_noise_seed";
        public const string SetNoiseSeed = "set_noise_seed";

        public const string GetRotationalNoise = "get_rotational_noise";
        public const string SetRotationalNoise = "set_rotational_noise";

        public const string GetPositionalNoise = "get_positional_noise";
        public const string SetPositionalNoise = "set_positional_noise";

        public const string GetRotationalMultiplier = "get_rotational_multiplier";
        public const string SetRotationalMultiplier = "set_rotational_multiplier";

        public const string GetPositionalMultiplierX = "get_positional_multiplier_x";
        public const string SetPositionalMultiplierX = "set_positional_multiplier_x";

        public const string GetPositionalMultiplierY = "get_positional_multiplier_y";
        public const string SetPositionalMultiplierY = "set_positional_multiplier_y";
    }
}