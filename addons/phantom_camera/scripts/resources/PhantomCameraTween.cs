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

public partial class PhantomCameraTween(Resource tweenResource) : Resource
{
    public Resource Resource { get; } = tweenResource;

    public float Duration
    {
        get => (float)Resource.Get(PhantomCameraTweenPropertyName.Duration);
        set => Resource.Set(PhantomCameraTweenPropertyName.Duration, value);
    }

    public TransitionType Transition
    {
        get => (TransitionType)(int)Resource.Get(PhantomCameraTweenPropertyName.Transition);
        set => Resource.Set(PhantomCameraTweenPropertyName.Transition, (int)value);
    }

    public EaseType Ease
    {
        get => (EaseType)(int)Resource.Get(PhantomCameraTweenPropertyName.Ease);
        set => Resource.Set(PhantomCameraTweenPropertyName.Ease, (int)value);
    }

    public static class PhantomCameraTweenPropertyName
    {
        public const string Duration = "durartion";
        public const string Transition = "transition";
        public const string Ease = "ease";
    }
}