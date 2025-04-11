using Godot;

namespace PhantomCamera;

public enum TransitionType
{
    Linear,
    Sine,
    Quintic,
    Quartic,
    Quadratic,
    Exponential,
    Elastic,
    Cubic,
    Circ,
    Bounce,
    Back
}

public enum EaseType
{
    In,
    Out,
    InOut,
    OutIn
}

public class PhantomCameraTween
{
    public Resource Resource { get; }

    public float Duration
    {
        get => (float)Resource.Get(PropertyName.Duration);
        set => Resource.Set(PropertyName.Duration, value);
    }

    public TransitionType Transition
    {
        get => (TransitionType)(int)Resource.Get(PropertyName.Transition);
        set => Resource.Set(PropertyName.Transition, (int)value);
    }

    public EaseType Ease
    {
        get => (EaseType)(int)Resource.Get(PropertyName.Ease);
        set => Resource.Set(PropertyName.Ease, (int)value);
    }

    public PhantomCameraTween(Resource tweenResource) => Resource = tweenResource;

    public static class PropertyName
    {
        public const string Duration = "durartion";
        public const string Transition = "transition";
        public const string Ease = "ease";
    }
}