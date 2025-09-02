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
