using Godot;

namespace PhantomCamera.Noise;

public partial class PhantomCameraNoiseEmitter3D(GodotObject node) : GodotObject
{
    public Node3D Node3D = (Node3D)node;
    
    public PhantomCameraNoise3D Noise
    {
        get => new((Resource)Node3D.Call(PhantomCameraNoiseEmitter3DMethodName.GetNoise));
        set => Node3D.Call(PhantomCameraNoiseEmitter3DMethodName.SetNoise, (GodotObject)value.Resource);
    }

    public bool Continuous
    {
        get => (bool)Node3D.Call(PhantomCameraNoiseEmitter3DMethodName.GetContinuous);
        set => Node3D.Call(PhantomCameraNoiseEmitter3DMethodName.SetContinuous, value);
    }
    
    public float GrowthTime
    {
        get => (float)Node3D.Call(PhantomCameraNoiseEmitter3DMethodName.GetGrowthTime);
        set => Node3D.Call(PhantomCameraNoiseEmitter3DMethodName.SetGrowthTime, value);
    }

    public float Duration
    {
        get => (float)Node3D.Call(PhantomCameraNoiseEmitter3DMethodName.GetDuration);
        set => Node3D.Call(PhantomCameraNoiseEmitter3DMethodName.SetDuration, value);
    }

    public float DecayTime
    {
        get => (float)Node3D.Call(PhantomCameraNoiseEmitter3DMethodName.GetDecayTime);
        set => Node3D.Call(PhantomCameraNoiseEmitter3DMethodName.SetDecayTime, value);
    }
    
    public int NoiseEmitterLayer
    {
        get => (int)Node3D.Call(PhantomCameraNoiseEmitter3DMethodName.GetNoiseEmitterLayer);
        set => Node3D.Call(PhantomCameraNoiseEmitter3DMethodName.SetNoiseEmitterLayer, value);
    }
    
    public void SetNoiseEmitterLayerValue(int layer, bool value) => 
        Node3D.Call(PhantomCameraNoiseEmitter3DMethodName.SetNoiseEmitterLayerValue, layer, value);
    
    public static class PhantomCameraNoiseEmitter3DMethodName
    {
        public const string GetNoise = "get_noise";
        public const string SetNoise = "set_noise";
        
        public const string GetContinuous = "get_continuous";
        public const string SetContinuous = "set_continuous";
        
        public const string GetGrowthTime = "get_growth_time";
        public const string SetGrowthTime = "set_growth_time";
        
        public const string GetDuration = "get_duration";
        public const string SetDuration = "set_duration";
        
        public const string GetDecayTime = "get_decay_time";
        public const string SetDecayTime = "set_decay_time";
        
        public const string GetNoiseEmitterLayer = "get_noise_emitter_layer";
        public const string SetNoiseEmitterLayer = "set_noise_emitter_layer";
        
        public const string SetNoiseEmitterLayerValue = "set_noise_emitter_layer_value";
    }
}