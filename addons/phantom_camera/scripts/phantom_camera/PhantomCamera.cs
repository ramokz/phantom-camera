using Godot;
using PhantomCamera.Noise;

#nullable enable

namespace PhantomCamera;

public enum InactiveUpdateMode
{
    Always,
    Never
}

public abstract class PhantomCamera
{
    protected readonly GodotObject Node;

    public delegate void BecameActiveEventHandler();
    public delegate void BecameInactiveEventHandler();
    public delegate void FollowTargetChangedEventHandler();
    public delegate void DeadZoneChangedEventHandler();
    public delegate void TweenStartedEventHandler();
    public delegate void IsTweeningEventHandler();
    public delegate void TweenCompletedEventHandler();

    public event BecameActiveEventHandler? BecameActive;
    public event BecameInactiveEventHandler? BecameInactive;
    public event FollowTargetChangedEventHandler? FollowTargetChanged;
    public event DeadZoneChangedEventHandler? DeadZoneChanged;
    public event TweenStartedEventHandler? TweenStarted;
    public event IsTweeningEventHandler? IsTweening;
    public event TweenCompletedEventHandler? TweenCompleted;

    private readonly Callable _callableBecameActive;
    private readonly Callable _callableBecameInactive;
    private readonly Callable _callableFollowTargetChanged;
    private readonly Callable _callableDeadZoneChanged;
    private readonly Callable _callableTweenStarted;
    private readonly Callable _callableIsTweening;
    private readonly Callable _callableTweenCompleted;

    public int Priority
    {
        get => (int)Node.Call(MethodName.GetPriority);
        set => Node.Call(MethodName.SetPriority, value);
    }

    public bool IsActive => (bool)Node.Call(MethodName.IsActive);

    public bool FollowDamping
    {
        get => (bool)Node.Call(MethodName.GetFollowDamping);
        set => Node.Call(MethodName.SetFollowDamping, value);
    }

    public bool IsFollowing => (bool)Node.Call(PhantomCamera.MethodName.IsFollowing);

    public float DeadZoneWidth
    {
        get => (float)Node.Get(PropertyName.DeadZoneWidth);
        set => Node.Set(PropertyName.DeadZoneWidth, value);
    }

    public float DeadZoneHeight
    {
        get => (float)Node.Get(PropertyName.DeadZoneHeight);
        set => Node.Set(PropertyName.DeadZoneHeight, value);
    }

    public PhantomCameraTween TweenResource
    {
        get => new((Resource)Node.Call(MethodName.GetTweenResource));
        set => Node.Call(MethodName.SetTweenResource, (GodotObject)value.Resource);
    }

    public bool TweenSkip
    {
        get => (bool)Node.Call(MethodName.GetTweenSkip);
        set => Node.Call(MethodName.SetTweenSkip, value);
    }

    public float TweenDuration
    {
        get => (float)Node.Call(MethodName.GetTweenDuration);
        set => Node.Call(MethodName.SetTweenDuration, value);
    }

    public TransitionType TweenTransition
    {
        get => (TransitionType)(int)Node.Call(MethodName.GetTweenTransition);
        set => Node.Call(MethodName.SetTweenTransition, (int)value);
    }

    public EaseType TweenEase
    {
        get => (EaseType)(int)Node.Call(MethodName.GetTweenEase);
        set => Node.Call(MethodName.SetTweenEase, (int)value);
    }

    public bool TweenOnLoad
    {
        get => (bool)Node.Call(MethodName.GetTweenOnLoad);
        set => Node.Call(MethodName.SetTweenOnLoad, value);
    }

    public InactiveUpdateMode InactiveUpdateMode
    {
        get => (InactiveUpdateMode)(int)Node.Call(MethodName.GetInactiveUpdateMode);
        set => Node.Call(MethodName.SetInactiveUpdateMode, (int)value);
    }

    public int HostLayers
    {
        get => (int)Node.Call(MethodName.GetHostLayers);
        set => Node.Call(MethodName.SetHostLayers, value);
    }

    public int NoiseEmitterLayer
    {
        get => (int)Node.Call(MethodName.GetNoiseEmitterLayer);
        set => Node.Call(MethodName.SetNoiseEmitterLayer, value);
    }

    public void TeleportPosition()
    {
        Node.Call(MethodName.TeleportPosition);
    }

    public void SetHostLayersValue(int layer, bool enabled)
    {
        Node.Call(MethodName.SetHostLayersValue, layer, enabled);
    }

    protected PhantomCamera(GodotObject phantomCameraNode)
    {
        Node = phantomCameraNode;

        _callableBecameActive = Callable.From(() => BecameActive?.Invoke());
        _callableBecameInactive = Callable.From(() => BecameInactive?.Invoke());
        _callableFollowTargetChanged = Callable.From(() => FollowTargetChanged?.Invoke());
        _callableDeadZoneChanged = Callable.From(() => DeadZoneChanged?.Invoke());
        _callableTweenStarted = Callable.From(() => TweenStarted?.Invoke());
        _callableIsTweening = Callable.From(() => IsTweening?.Invoke());
        _callableTweenCompleted = Callable.From(() => TweenCompleted?.Invoke());

        Node.Connect(SignalName.BecameActive, _callableBecameActive);
        Node.Connect(SignalName.BecameInactive, _callableBecameInactive);
        Node.Connect(SignalName.FollowTargetChanged, _callableFollowTargetChanged);
        Node.Connect(SignalName.DeadZoneChanged, _callableDeadZoneChanged);
        Node.Connect(SignalName.TweenStarted, _callableTweenStarted);
        Node.Connect(SignalName.IsTweening, _callableIsTweening);
        Node.Connect(SignalName.TweenCompleted, _callableTweenCompleted);
    }

    ~PhantomCamera()
    {
        Node.Disconnect(SignalName.BecameActive, _callableBecameActive);
        Node.Disconnect(SignalName.BecameInactive, _callableBecameInactive);
        Node.Disconnect(SignalName.FollowTargetChanged, _callableFollowTargetChanged);
        Node.Disconnect(SignalName.DeadZoneChanged, _callableDeadZoneChanged);
        Node.Disconnect(SignalName.TweenStarted, _callableTweenStarted);
        Node.Disconnect(SignalName.IsTweening, _callableIsTweening);
        Node.Disconnect(SignalName.TweenCompleted, _callableTweenCompleted);
    }

    public static class MethodName
    {
        public const string GetFollowMode = "get_follow_mode";
        public const string IsActive = "is_active";

        public const string GetPriority = "get_priority";
        public const string SetPriority = "set_priority";

        public const string IsFollowing = "is_following";

        public const string GetFollowTarget = "get_follow_target";
        public const string SetFollowTarget = "set_follow_target";

        public const string GetFollowTargets = "get_follow_targets";
        public const string SetFollowTargets = "set_follow_targets";

        public const string TeleportPosition = "teleport_position";

        public const string AppendFollowTargets = "append_follow_targets";
        public const string AppendFollowTargetsArray = "append_follow_targets_array";
        public const string EraseFollowTargets = "erase_follow_targets";

        public const string GetFollowPath = "get_follow_path";
        public const string SetFollowPath = "set_follow_path";

        public const string GetFollowOffset = "get_follow_offset";
        public const string SetFollowOffset = "set_follow_offset";

        public const string GetFollowDamping = "get_follow_damping";
        public const string SetFollowDamping = "set_follow_damping";

        public const string GetFollowDampingValue = "get_follow_damping_value";
        public const string SetFollowDampingValue = "set_follow_damping_value";

        public const string GetFollowAxisLock = "get_follow_axis_lock";
        public const string SetFollowAxisLock = "set_follow_axis_lock";

        public const string GetTweenResource = "get_tween_resource";
        public const string SetTweenResource = "set_tween_resource";

        public const string GetTweenSkip = "get_tween_skip";
        public const string SetTweenSkip = "set_tween_skip";

        public const string GetTweenDuration = "get_tween_duration";
        public const string SetTweenDuration = "set_tween_duration";

        public const string GetTweenTransition = "get_tween_transition";
        public const string SetTweenTransition = "set_tween_transition";

        public const string GetTweenEase = "get_tween_ease";
        public const string SetTweenEase = "set_tween_ease";

        public const string GetTweenOnLoad = "get_tween_on_load";
        public const string SetTweenOnLoad = "set_tween_on_load";

        public const string GetInactiveUpdateMode = "get_inactive_update_mode";
        public const string SetInactiveUpdateMode = "set_inactive_update_mode";

        public const string GetHostLayers = "get_host_layers";
        public const string SetHostLayers = "set_host_layers";
        public const string SetHostLayersValue = "set_host_layers_value";

        public const string GetNoiseEmitterLayer = "get_noise_emitter_layer";
        public const string SetNoiseEmitterLayer = "set_noise_emitter_layer";

        public const string EmitNoise = "emit_noise";
    }

    public static class PropertyName
    {
        public const string DeadZoneWidth = "dead_zone_width";
        public const string DeadZoneHeight = "dead_zone_height";
    }

    public static class SignalName
    {
        public const string BecameActive = "became_active";
        public const string BecameInactive = "became_inactive";
        public const string FollowTargetChanged = "follow_target_changed";
        public const string DeadZoneChanged = "dead_zone_changed";
        public const string DeadZoneReached = "dead_zone_reached";
        public const string TweenStarted = "tween_started";
        public const string IsTweening = "is_tweening";
        public const string TweenCompleted = "tween_completed";
        public const string TweenInterrupted = "tween_interrupted";
        public const string NoiseEmitted = "noise_emitted";
    }
}
