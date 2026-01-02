using Godot;

namespace PhantomCamera;

public enum TransitionType
{
    Linear,
    Sine,
    Quint,
    Quart,
    Quad,
    Expo,
    Elastic,
    Cubic,
    Circ,
    Bounce,
    Back
}

public enum EaseType
{
    EaseIn,
    EaseOut,
    EaseInOut,
    EaseOutIn
}

public static class PhantomCameraTweenExtensions
{
    public static PhantomCameraTween AsPhantomCameraTween(this Resource resource)
    {
        return new PhantomCameraTween(resource);
    }
}

public class PhantomCameraTween(Resource tweenResource)
{
    public Resource Resource { get; } = tweenResource;

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
    
    public static PhantomCameraTween New()
    {
        Resource resource = new();
#if GODOT4_4_OR_GREATER
        resource.SetScript(GD.Load<GDScript>("uid://8umksf8e80fw"));
#else
        resource.SetScript(GD.Load<GDScript>("res://addons/phantom_camera/scripts/resources/tween_resource.gd"));
#endif
        return new PhantomCameraTween(resource);
    }

    public static class PropertyName
    {
        public static readonly StringName Duration = new("duration");
        public static readonly StringName Transition = new("transition");
        public static readonly StringName Ease = new("ease");
    }
}
