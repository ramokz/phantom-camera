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

        public const string Emit = "emit";
        public const string IsEmitting = "is_emitting";
        public const string Stop = "stop";
        public const string Toggle = "toggle";
    }
}
