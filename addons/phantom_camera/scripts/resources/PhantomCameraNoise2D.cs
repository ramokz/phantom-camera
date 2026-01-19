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
    
    public static PhantomCameraNoise2D New()
    {
        Resource resource = new();
#if GODOT4_4_OR_GREATER
        resource.SetScript(GD.Load<GDScript>("uid://dimvdouy8g0sv"));
#else
        resource.SetScript(GD.Load<GDScript>("res://addons/phantom_camera/scripts/resources/phantom_camera_noise_2d.gd"));
#endif
        return new PhantomCameraNoise2D(resource);
    }

    public static class MethodName
    {
        public static readonly StringName GetAmplitude = new("get_amplitude");
        public static readonly StringName SetAmplitude = new("set_amplitude");

        public static readonly StringName GetFrequency = new("get_frequency");
        public static readonly StringName SetFrequency = new("set_frequency");

        public static readonly StringName GetRandomizeNoiseSeed = new("get_randomize_noise_seed");
        public static readonly StringName SetRandomizeNoiseSeed = new("set_randomize_noise_seed");

        public static readonly StringName GetNoiseSeed = new("get_noise_seed");
        public static readonly StringName SetNoiseSeed = new("set_noise_seed");

        public static readonly StringName GetRotationalNoise = new("get_rotational_noise");
        public static readonly StringName SetRotationalNoise = new("set_rotational_noise");

        public static readonly StringName GetPositionalNoise = new("get_positional_noise");
        public static readonly StringName SetPositionalNoise = new("set_positional_noise");

        public static readonly StringName GetRotationalMultiplier = new("get_rotational_multiplier");
        public static readonly StringName SetRotationalMultiplier = new("set_rotational_multiplier");

        public static readonly StringName GetPositionalMultiplierX = new("get_positional_multiplier_x");
        public static readonly StringName SetPositionalMultiplierX = new("set_positional_multiplier_x");

        public static readonly StringName GetPositionalMultiplierY = new("get_positional_multiplier_y");
        public static readonly StringName SetPositionalMultiplierY = new("set_positional_multiplier_y");
    }
}
