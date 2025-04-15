using Godot;

namespace PhantomCamera.Noise;

public partial class PhantomCameraNoiseEmitter2D(GodotObject node) : GodotObject
{
    public Node2D Node2D = (Node2D)node;
    
    public PhantomCameraNoise2D Noise
    {
        get => new((Resource)Node2D.Call(PhantomCameraNoiseEmitter2DMethodName.GetNoise));
        set => Node2D.Call(PhantomCameraNoiseEmitter2DMethodName.SetNoise, (GodotObject)value.Resource);
    }
    
    public bool Continuous
    {
        get => (bool)Node2D.Call(PhantomCameraNoiseEmitter2DMethodName.GetContinuous);
        set => Node2D.Call(PhantomCameraNoiseEmitter2DMethodName.SetContinuous, value);
    }
    
    public float GrowthTime
    {
        get => (float)Node2D.Call(PhantomCameraNoiseEmitter2DMethodName.GetGrowthTime);
        set => Node2D.Call(PhantomCameraNoiseEmitter2DMethodName.SetGrowthTime, value);
    }

    public float Duration
    {
        get => (float)Node2D.Call(PhantomCameraNoiseEmitter2DMethodName.GetDuration);
        set => Node2D.Call(PhantomCameraNoiseEmitter2DMethodName.SetDuration, value);
    }

    public float DecayTime
    {
        get => (float)Node2D.Call(PhantomCameraNoiseEmitter2DMethodName.GetDecayTime);
        set => Node2D.Call(PhantomCameraNoiseEmitter2DMethodName.SetDecayTime, value);
    }
    
    public int NoiseEmitterLayer
    {
        get => (int)Node2D.Call(PhantomCameraNoiseEmitter2DMethodName.GetNoiseEmitterLayer);
        set => Node2D.Call(PhantomCameraNoiseEmitter2DMethodName.SetNoiseEmitterLayer, value);
    }
    
    public void SetNoiseEmitterLayerValue(int layer, bool value) => 
        Node2D.Call(PhantomCameraNoiseEmitter2DMethodName.SetNoiseEmitterLayerValue, layer, value);
    
    public static class PhantomCameraNoiseEmitter2DMethodName
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