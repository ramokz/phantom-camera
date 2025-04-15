using Godot;

namespace PhantomCamera.Noise;

/// <summary>
/// <para>A resource type used to apply noise, or shake, to Camera3Ds that have a PhantomCameraHost as a child.</para>
/// <para>It can be applied to either PhantomCameraNoiseEmitter3D or a PhantomCamera3D noise property directly</para>
/// </summary>
public partial class PhantomCameraNoise3D(Resource resource) : Resource
{
    public readonly Resource Resource = resource;

    public float Amplitude
    {
        get => (float)Resource.Call(PhantomCameraNoise3DMethodName.GetAmplitude);
        set => Resource.Call(PhantomCameraNoise3DMethodName.SetAmplitude, value);
    }

    public float Frequency
    {
        get => (float)Resource.Call(PhantomCameraNoise3DMethodName.GetFrequency);
        set => Resource.Call(PhantomCameraNoise3DMethodName.SetFrequency, value);
    }

    public bool RandomizeNoiseSeed
    {
        get => (bool)Resource.Call(PhantomCameraNoise3DMethodName.GetRandomizeNoiseSeed);
        set => Resource.Call(PhantomCameraNoise3DMethodName.SetRandomizeNoiseSeed, value);
    }

    public int NoiseSeed
    {
        get => (int)Resource.Call(PhantomCameraNoise3DMethodName.GetNoiseSeed);
        set => Resource.Call(PhantomCameraNoise3DMethodName.SetNoiseSeed, value);
    }

    public bool RotationalNoise
    {
        get => (bool)Resource.Call(PhantomCameraNoise3DMethodName.GetRotationalNoise);
        set => Resource.Call(PhantomCameraNoise3DMethodName.SetRotationalNoise, value);
    }

    public bool PositionalNoise
    {
        get => (bool)Resource.Call(PhantomCameraNoise3DMethodName.GetPositionalNoise);
        set => Resource.Call(PhantomCameraNoise3DMethodName.SetPositionalNoise, value);
    }

    public float RotationalMultiplierX
    {
        get => (float)Resource.Call(PhantomCameraNoise3DMethodName.GetRotationalMultiplierX);
        set => Resource.Call(PhantomCameraNoise3DMethodName.SetRotationalMultiplierX, value);
    }
    
    public float RotationalMultiplierY
    {
        get => (float)Resource.Call(PhantomCameraNoise3DMethodName.GetRotationalMultiplierY);
        set => Resource.Call(PhantomCameraNoise3DMethodName.SetRotationalMultiplierY, value);
    }
    
    public float RotationalMultiplierZ
    {
        get => (float)Resource.Call(PhantomCameraNoise3DMethodName.GetRotationalMultiplierZ);
        set => Resource.Call(PhantomCameraNoise3DMethodName.SetRotationalMultiplierZ, value);
    }

    public float PositionalMultiplierX
    {
        get => (float)Resource.Call(PhantomCameraNoise3DMethodName.GetPositionalMultiplierX);
        set => Resource.Call(PhantomCameraNoise3DMethodName.SetPositionalMultiplierX, value);
    }
    
    public float PositionalMultiplierY
    {
        get => (float)Resource.Call(PhantomCameraNoise3DMethodName.GetPositionalMultiplierY);
        set => Resource.Call(PhantomCameraNoise3DMethodName.SetPositionalMultiplierY, value);
    }
    
    public float PositionalMultiplierZ
    {
        get => (float)Resource.Call(PhantomCameraNoise3DMethodName.GetPositionalMultiplierZ);
        set => Resource.Call(PhantomCameraNoise3DMethodName.SetPositionalMultiplierZ, value);
    }

    public static class PhantomCameraNoise3DMethodName
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
        
        public const string GetRotationalMultiplierX = "get_rotational_multiplier_x";
        public const string SetRotationalMultiplierX = "set_rotational_multiplier_x";
        
        public const string GetRotationalMultiplierY = "get_rotational_multiplier_y";
        public const string SetRotationalMultiplierY = "set_rotational_multiplier_y";
        
        public const string GetRotationalMultiplierZ = "get_rotational_multiplier_z";
        public const string SetRotationalMultiplierZ = "set_rotational_multiplier_z";
        
        public const string GetPositionalMultiplierX = "get_positional_multiplier_x";
        public const string SetPositionalMultiplierX = "set_positional_multiplier_x";
        
        public const string GetPositionalMultiplierY = "get_positional_multiplier_y";
        public const string SetPositionalMultiplierY = "set_positional_multiplier_y";
        
        public const string GetPositionalMultiplierZ = "get_positional_multiplier_z";
        public const string SetPositionalMultiplierZ = "set_positional_multiplier_z";
    }
}