using Godot;

namespace PhantomCamera.Noise;

public class PhantomCameraNoise2D(Resource resource)
{
    public readonly Resource Resource = resource;

    public float Amplitude
    {
        get => (float)Resource.Call(MethodName.GetAmplitude);
        set => Resource.Call(MethodName.SetAmplitude, value);
    }

    public float Frequency
    {
        get => (float)Resource.Call(MethodName.GetFrequency);
        set => Resource.Call(MethodName.SetFrequency, value);
    }

    public bool RandomizeNoiseSeed
    {
        get => (bool)Resource.Call(MethodName.GetRandomizeNoiseSeed);
        set => Resource.Call(MethodName.SetRandomizeNoiseSeed, value);
    }

    public int NoiseSeed
    {
        get => (int)Resource.Call(MethodName.GetNoiseSeed);
        set => Resource.Call(MethodName.SetNoiseSeed, value);
    }

    public bool RotationalNoise
    {
        get => (bool)Resource.Call(MethodName.GetRotationalNoise);
        set => Resource.Call(MethodName.SetRotationalNoise, value);
    }

    public bool PositionalNoise
    {
        get => (bool)Resource.Call(MethodName.GetPositionalNoise);
        set => Resource.Call(MethodName.SetPositionalNoise, value);
    }

    public float RotationalMultiplier
    {
        get => (float)Resource.Call(MethodName.GetRotationalMultiplier);
        set => Resource.Call(MethodName.SetRotationalMultiplier, value);
    }

    public float PositionalMultiplierX
    {
        get => (float)Resource.Call(MethodName.GetPositionalMultiplierX);
        set => Resource.Call(MethodName.SetPositionalMultiplierX, value);
    }

    public float PositionalMultiplierY
    {
        get => (float)Resource.Call(MethodName.GetPositionalMultiplierY);
        set => Resource.Call(MethodName.SetPositionalMultiplierY, value);
    }

    public static class MethodName
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
