﻿using Godot;
using PhantomCamera.Resources;

// TODO: missing shared properties
// - get/set pcam_host_owner
// - get/set follow_target
// - get/set follow_targets
// - get/set follow_path
// - get/set follow_offset
// - get/set follow_damping
// - get/set follow_damping_value
// - dead_zone_width
// - dead_zone_height

#nullable enable

namespace PhantomCamera.Cameras;

public enum FollowMode
{
    None,
    Glued,
    Simple,
    Group,
    Path,
    Framed,
    ThirdPerson
}

public enum LookAtMode
{
    None,
    Mimic,
    Simple,
    Group
}

public enum InactiveUpdateMode
{
    Always,
    Never
}

public abstract class PhantomCamera // TODO: FollowTarget, LookAtTarget
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
    
    public FollowMode FollowMode => (FollowMode)(int)Node.Call(MethodName.GetFollowMode);
    
    public bool IsActive => (bool)Node.Call(MethodName.IsActive);

    public PhantomCameraTween TweenResource
    {
        get => new((Resource)Node.Call(MethodName.GetTweenResource));
        set => Node.Call(MethodName.SetTweenResource, (GodotObject)value.Resource);
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

        public const string GetTweenResource = "get_tween_resource";
        public const string SetTweenResource = "set_tween_resource";

        public const string GetTweenOnLoad = "get_tween_on_load";
        public const string SetTweenOnLoad = "set_tween_on_load";

        public const string GetInactiveUpdateMode = "get_inactive_update_mode";
        public const string SetInactiveUpdateMode = "set_inactive_update_mode";
    }

    public static class SignalName
    {
        public const string BecameActive = "became_active";
        public const string BecameInactive = "became_inactive";
        public const string FollowTargetChanged = "follow_target_changed";
        public const string LookAtTargetChanged = "look_at_target_changed";
        public const string DeadZoneChanged = "dead_zone_changed";
        public const string TweenStarted = "tween_started";
        public const string IsTweening = "is_tweening";
        public const string TweenCompleted = "tween_completed";
        public const string TweenInterrupted = "tween_interrupted";
    }
}