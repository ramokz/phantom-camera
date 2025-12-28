using Godot;

namespace PhantomCamera.Noise;

public class PhantomCameraNoiseEmitter3D(GodotObject node)
{
    public Node3D Node3D = (Node3D)node;

    public PhantomCameraNoise3D Noise
    {
        get => new((Resource)Node3D.Call(MethodName.GetNoise));
        set => Node3D.Call(MethodName.SetNoise, (GodotObject)value.Resource);
    }

    public bool Continuous
    {
        get => (bool)Node3D.Call(MethodName.GetContinuous);
        set => Node3D.Call(MethodName.SetContinuous, value);
    }

    public float GrowthTime
    {
        get => (float)Node3D.Call(MethodName.GetGrowthTime);
        set => Node3D.Call(MethodName.SetGrowthTime, value);
    }

    public float Duration
    {
        get => (float)Node3D.Call(MethodName.GetDuration);
        set => Node3D.Call(MethodName.SetDuration, value);
    }

    public float DecayTime
    {
        get => (float)Node3D.Call(MethodName.GetDecayTime);
        set => Node3D.Call(MethodName.SetDecayTime, value);
    }

    public int NoiseEmitterLayer
    {
        get => (int)Node3D.Call(MethodName.GetNoiseEmitterLayer);
        set => Node3D.Call(MethodName.SetNoiseEmitterLayer, value);
    }

    public void SetNoiseEmitterLayerValue(int layer, bool value) =>
        Node3D.Call(MethodName.SetNoiseEmitterLayerValue, layer, value);

    public void Emit() => Node3D.Call(MethodName.Emit);

    public bool IsEmitting() => (bool)Node3D.Call(MethodName.IsEmitting);

    public void Stop() => Node3D.Call(MethodName.Stop);

    public void Toggle() => Node3D.Call(MethodName.Toggle);

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
