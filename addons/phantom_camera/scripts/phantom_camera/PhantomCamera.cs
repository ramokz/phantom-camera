using Godot;

#nullable enable

namespace PhantomCamera;

public enum InactiveUpdateMode
{
    Always,
    Never
}

public abstract partial class PhantomCamera : GodotObject
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
        get => (int)Node.Call(PhantomCameraMethodName.GetPriority);
        set => Node.Call(PhantomCameraMethodName.SetPriority, value);
    }
    
    public bool IsActive => (bool)Node.Call(PhantomCameraMethodName.IsActive);

    public PhantomCameraHost PhantomCameraHostOwner
    {
        get => Node.Call(PhantomCameraMethodName.GetPCamHostOwner).As<PhantomCameraHost>();
        set => Node.Call(PhantomCameraMethodName.SetPCamHostOwner, value.Node);
    }
    
    public bool FollowDamping
    {
        get => (bool)Node.Call(PhantomCameraMethodName.GetFollowDamping);
        set => Node.Call(PhantomCameraMethodName.SetFollowDamping, value);
    }

    public float DeadZoneWidth
    {
        get => (float)Node.Get(PhantomCameraPropertyName.DeadZoneWidth);
        set => Node.Set(PhantomCameraPropertyName.DeadZoneWidth, value);
    }
    
    public float DeadZoneHeight
    {
        get => (float)Node.Get(PhantomCameraPropertyName.DeadZoneHeight);
        set => Node.Set(PhantomCameraPropertyName.DeadZoneHeight, value);
    }

    public PhantomCameraTween TweenResource
    {
        get => new((Resource)Node.Call(PhantomCameraMethodName.GetTweenResource));
        set => Node.Call(PhantomCameraMethodName.SetTweenResource, (GodotObject)value.Resource);
    }
    
    public bool TweenSkip
    {
        get => (bool)Node.Call(PhantomCameraMethodName.GetTweenSkip);
        set => Node.Call(PhantomCameraMethodName.SetTweenSkip, value);
    }

    public float TweenDuration
    {
        get => (float)Node.Call(PhantomCameraMethodName.GetTweenDuration);
        set => Node.Call(PhantomCameraMethodName.SetTweenDuration, value);
    }
    
    public TransitionType TweenTransition
    {
        get => (TransitionType)(int)Node.Call(PhantomCameraMethodName.GetTweenTransition);
        set => Node.Call(PhantomCameraMethodName.SetTweenTransition, (int)value);
    }
    
    public EaseType TweenEase
    {
        get => (EaseType)(int)Node.Call(PhantomCameraMethodName.GetTweenEase);
        set => Node.Call(PhantomCameraMethodName.SetTweenEase, (int)value);
    }

    public bool TweenOnLoad
    {
        get => (bool)Node.Call(PhantomCameraMethodName.GetTweenOnLoad);
        set => Node.Call(PhantomCameraMethodName.SetTweenOnLoad, value);
    }

    public InactiveUpdateMode InactiveUpdateMode
    {
        get => (InactiveUpdateMode)(int)Node.Call(PhantomCameraMethodName.GetInactiveUpdateMode);
        set => Node.Call(PhantomCameraMethodName.SetInactiveUpdateMode, (int)value);
    }
    
    public int HostLayers
    {
        get => (int)Node.Call(PhantomCameraMethodName.GetHostLayers);
        set => Node.Call(PhantomCameraMethodName.SetHostLayers, value);
    }
    
    public int NoiseEmitterLayer
    {
        get => (int)Node.Call(PhantomCameraMethodName.GetNoiseEmitterLayer);
        set => Node.Call(PhantomCameraMethodName.SetNoiseEmitterLayer, value);
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
        
        Node.Connect(PhantomCameraSignalName.BecameActive, _callableBecameActive);
        Node.Connect(PhantomCameraSignalName.BecameInactive, _callableBecameInactive);
        Node.Connect(PhantomCameraSignalName.FollowTargetChanged, _callableFollowTargetChanged);
        Node.Connect(PhantomCameraSignalName.DeadZoneChanged, _callableDeadZoneChanged);
        Node.Connect(PhantomCameraSignalName.TweenStarted, _callableTweenStarted);
        Node.Connect(PhantomCameraSignalName.IsTweening, _callableIsTweening);
        Node.Connect(PhantomCameraSignalName.TweenCompleted, _callableTweenCompleted);
    }

    ~PhantomCamera()
    {
        Node.Disconnect(PhantomCameraSignalName.BecameActive, _callableBecameActive);
        Node.Disconnect(PhantomCameraSignalName.BecameInactive, _callableBecameInactive);
        Node.Disconnect(PhantomCameraSignalName.FollowTargetChanged, _callableFollowTargetChanged);
        Node.Disconnect(PhantomCameraSignalName.DeadZoneChanged, _callableDeadZoneChanged);
        Node.Disconnect(PhantomCameraSignalName.TweenStarted, _callableTweenStarted);
        Node.Disconnect(PhantomCameraSignalName.IsTweening, _callableIsTweening);
        Node.Disconnect(PhantomCameraSignalName.TweenCompleted, _callableTweenCompleted);
    }
}

public static class PhantomCameraMethodName
{
    public const string GetFollowMode = "get_follow_mode";
    public const string IsActive = "is_active";

    public const string GetPriority = "get_priority";
    public const string SetPriority = "set_priority";

    public const string GetPCamHostOwner = "get_pcam_host_owner";
    public const string SetPCamHostOwner = "set_pcam_host_owner";

    public const string GetFollowTarget = "get_follow_target";
    public const string SetFollowTarget = "set_follow_target";

    public const string GetFollowTargets = "get_follow_targets";
    public const string SetFollowTargets = "set_follow_targets";

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

    public const string GetNoiseEmitterLayer = "get_noise_emitter_layer";
    public const string SetNoiseEmitterLayer = "set_noise_emitter_layer";
}

public static class PhantomCameraPropertyName
{
    public const string DeadZoneWidth = "dead_zone_width";
    public const string DeadZoneHeight = "dead_zone_height";
}

public static class PhantomCameraSignalName
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