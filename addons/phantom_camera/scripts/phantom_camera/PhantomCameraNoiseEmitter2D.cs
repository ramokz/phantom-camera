using Godot;

namespace PhantomCamera.Noise;

public class PhantomCameraNoiseEmitter2D(GodotObject node)
{
    public Node2D Node2D = (Node2D)node;

    public PhantomCameraNoise2D Noise
    {
        get => new((Resource)Node2D.Call(MethodName.GetNoise));
        set => Node2D.Call(MethodName.SetNoise, (GodotObject)value.Resource);
    }

    public bool Continuous
    {
        get => (bool)Node2D.Call(MethodName.GetContinuous);
        set => Node2D.Call(MethodName.SetContinuous, value);
    }

    public float GrowthTime
    {
        get => (float)Node2D.Call(MethodName.GetGrowthTime);
        set => Node2D.Call(MethodName.SetGrowthTime, value);
    }

    public float Duration
    {
        get => (float)Node2D.Call(MethodName.GetDuration);
        set => Node2D.Call(MethodName.SetDuration, value);
    }

    public float DecayTime
    {
        get => (float)Node2D.Call(MethodName.GetDecayTime);
        set => Node2D.Call(MethodName.SetDecayTime, value);
    }

    public int NoiseEmitterLayer
    {
        get => (int)Node2D.Call(MethodName.GetNoiseEmitterLayer);
        set => Node2D.Call(MethodName.SetNoiseEmitterLayer, value);
    }

    public void SetNoiseEmitterLayerValue(int layer, bool value) =>
        Node2D.Call(MethodName.SetNoiseEmitterLayerValue, layer, value);

    public void Emit() => Node2D.Call(MethodName.Emit);

    public bool IsEmitting() => (bool)Node2D.Call(MethodName.IsEmitting);

    public void Stop() => Node2D.Call(MethodName.Stop);

    public void Toggle() => Node2D.Call(MethodName.Toggle);

    public static class MethodName
    {
        public static readonly StringName GetNoise = new("get_noise");
        public static readonly StringName SetNoise = new("set_noise");

        public static readonly StringName GetContinuous = new("get_continuous");
        public static readonly StringName SetContinuous = new("set_continuous");

        public static readonly StringName GetGrowthTime = new("get_growth_time");
        public static readonly StringName SetGrowthTime = new("set_growth_time");

        public static readonly StringName GetDuration = new("get_duration");
        public static readonly StringName SetDuration = new("set_duration");

        public static readonly StringName GetDecayTime = new("get_decay_time");
        public static readonly StringName SetDecayTime = new("set_decay_time");

        public static readonly StringName GetNoiseEmitterLayer = new("get_noise_emitter_layer");
        public static readonly StringName SetNoiseEmitterLayer = new("set_noise_emitter_layer");

        public static readonly StringName SetNoiseEmitterLayerValue = new("set_noise_emitter_layer_value");

        public static readonly StringName Emit = new("emit");
        public static readonly StringName IsEmitting = new("is_emitting");
        public static readonly StringName Stop = new("stop");
        public static readonly StringName Toggle = new("toggle");
    }
}
