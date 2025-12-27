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

        var callableBecameActive = Callable.From(() => BecameActive?.Invoke());
        var callableBecameInactive = Callable.From(() => BecameInactive?.Invoke());
        var callableFollowTargetChanged = Callable.From(() => FollowTargetChanged?.Invoke());
        var callableDeadZoneChanged = Callable.From(() => DeadZoneChanged?.Invoke());
        var callableTweenStarted = Callable.From(() => TweenStarted?.Invoke());
        var callableIsTweening = Callable.From(() => IsTweening?.Invoke());
        var callableTweenCompleted = Callable.From(() => TweenCompleted?.Invoke());

        Node.Connect(SignalName.BecameActive, callableBecameActive);
        Node.Connect(SignalName.BecameInactive, callableBecameInactive);
        Node.Connect(SignalName.FollowTargetChanged, callableFollowTargetChanged);
        Node.Connect(SignalName.DeadZoneChanged, callableDeadZoneChanged);
        Node.Connect(SignalName.TweenStarted, callableTweenStarted);
        Node.Connect(SignalName.IsTweening, callableIsTweening);
        Node.Connect(SignalName.TweenCompleted, callableTweenCompleted);
    }

    public static class MethodName
    {
        public static readonly StringName GetFollowMode = new("get_follow_mode");
        public static readonly StringName IsActive = new("is_active");

        public static readonly StringName GetPriority = new("get_priority");
        public static readonly StringName SetPriority = new("set_priority");

        public static readonly StringName IsFollowing = new("is_following");

        public static readonly StringName GetFollowTarget = new("get_follow_target");
        public static readonly StringName SetFollowTarget = new("set_follow_target");

        public static readonly StringName GetFollowTargets = new("get_follow_targets");
        public static readonly StringName SetFollowTargets = new("set_follow_targets");

        public static readonly StringName TeleportPosition = new("teleport_position");

        public static readonly StringName AppendFollowTargets = new("append_follow_targets");
        public static readonly StringName AppendFollowTargetsArray = new("append_follow_targets_array");
        public static readonly StringName EraseFollowTargets = new("erase_follow_targets");

        public static readonly StringName GetFollowPath = new("get_follow_path");
        public static readonly StringName SetFollowPath = new("set_follow_path");

        public static readonly StringName GetFollowOffset = new("get_follow_offset");
        public static readonly StringName SetFollowOffset = new("set_follow_offset");

        public static readonly StringName GetFollowDamping = new("get_follow_damping");
        public static readonly StringName SetFollowDamping = new("set_follow_damping");

        public static readonly StringName GetFollowDampingValue = new("get_follow_damping_value");
        public static readonly StringName SetFollowDampingValue = new("set_follow_damping_value");

        public static readonly StringName GetFollowAxisLock = new("get_follow_axis_lock");
        public static readonly StringName SetFollowAxisLock = new("set_follow_axis_lock");

        public static readonly StringName GetTweenResource = new("get_tween_resource");
        public static readonly StringName SetTweenResource = new("set_tween_resource");

        public static readonly StringName GetTweenSkip = new("get_tween_skip");
        public static readonly StringName SetTweenSkip = new("set_tween_skip");

        public static readonly StringName GetTweenDuration = new("get_tween_duration");
        public static readonly StringName SetTweenDuration = new("set_tween_duration");

        public static readonly StringName GetTweenTransition = new("get_tween_transition");
        public static readonly StringName SetTweenTransition = new("set_tween_transition");

        public static readonly StringName GetTweenEase = new("get_tween_ease");
        public static readonly StringName SetTweenEase = new("set_tween_ease");

        public static readonly StringName GetTweenOnLoad = new("get_tween_on_load");
        public static readonly StringName SetTweenOnLoad = new("set_tween_on_load");

        public static readonly StringName GetInactiveUpdateMode = new("get_inactive_update_mode");
        public static readonly StringName SetInactiveUpdateMode = new("set_inactive_update_mode");

        public static readonly StringName GetHostLayers = new("get_host_layers");
        public static readonly StringName SetHostLayers = new("set_host_layers");
        public static readonly StringName SetHostLayersValue = new("set_host_layers_value");

        public static readonly StringName GetNoiseEmitterLayer = new("get_noise_emitter_layer");
        public static readonly StringName SetNoiseEmitterLayer = new("set_noise_emitter_layer");

        public static readonly StringName EmitNoise = new("emit_noise");
    }

    public static class PropertyName
    {
        public static readonly StringName DeadZoneWidth = new("dead_zone_width");
        public static readonly StringName DeadZoneHeight = new("dead_zone_height");
    }

    public static class SignalName
    {
        public static readonly StringName BecameActive = new("became_active");
        public static readonly StringName BecameInactive = new("became_inactive");
        public static readonly StringName FollowTargetChanged = new("follow_target_changed");
        public static readonly StringName DeadZoneChanged = new("dead_zone_changed");
        public static readonly StringName DeadZoneReached = new("dead_zone_reached");
        public static readonly StringName TweenStarted = new("tween_started");
        public static readonly StringName IsTweening = new("is_tweening");
        public static readonly StringName TweenCompleted = new("tween_completed");
        public static readonly StringName TweenInterrupted = new("tween_interrupted");
        public static readonly StringName NoiseEmitted = new("noise_emitted");
    }
}
