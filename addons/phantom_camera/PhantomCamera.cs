using Godot;

#nullable enable

namespace PhantomCamera;

public static class GodotExtension
{
    public static PhantomCamera3D AsPhantomCamera3D(this Node3D node3D)
    {
        return new PhantomCamera3D(node3D);
    }

    public static PhantomCamera2D AsPhantomCamera2D(this Node2D node2D)
    {
        return new PhantomCamera2D(node2D);
    }
}

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

public abstract class PhantomCamera
{
    protected GodotObject Pcam;
    
    public delegate void BecameActiveEventHandler();
    public delegate void BecameInactiveEventHandler();
    public delegate void FollowTargetChangedEventHandler();
    public delegate void LookAtTargetChangedEventHandler();
    public delegate void DeadZoneChangedEventHandler();
    public delegate void TweenStartedEventHandler();
    public delegate void IsTweeningEventHandler();
    public delegate void TweenCompletedEventHandler();
    
    public event BecameActiveEventHandler? BecameActive;
    public event BecameInactiveEventHandler? BecameInactive;
    public event FollowTargetChangedEventHandler? FollowTargetChanged;
    public event LookAtTargetChangedEventHandler? LookAtTargetChanged;
    public event DeadZoneChangedEventHandler? DeadZoneChanged;
    public event TweenStartedEventHandler? TweenStarted;
    public event IsTweeningEventHandler? IsTweening;
    public event TweenCompletedEventHandler? TweenCompleted;

    private readonly Callable _callableBecameActive;
    private readonly Callable _callableBecameInactive;
    private readonly Callable _callableFollowTargetChanged;
    private readonly Callable _callableLookAtTargetChanged;
    private readonly Callable _callableDeadZoneChanged;
    private readonly Callable _callableTweenStarted;
    private readonly Callable _callableIsTweening;
    private readonly Callable _callableTweenCompleted;
    
    public int Priority
    {
        get => (int)Pcam.Call(MethodName.GetPriority);
        set => Pcam.Call(MethodName.SetPriority, value);
    }
    
    public FollowMode FollowMode => Pcam.Call(MethodName.GetFollowMode).As<FollowMode>();
    
    // TODO: Tween resource property (PhantomCameraTween type)
    
    public bool IsActive => (bool)Pcam.Call(MethodName.IsActive);

    public bool TweenOnLoad
    {
        get => (bool)Pcam.Call(MethodName.GetTweenOnLoad);
        set => Pcam.Call(MethodName.SetTweenOnLoad, value);
    }

    public InactiveUpdateMode InactiveUpdateMode
    {
        get => Pcam.Call(MethodName.GetInactiveUpdateMode).As<InactiveUpdateMode>();
        set => Pcam.Call(MethodName.SetInactiveUpdateMode, (int)value);
    }

    protected PhantomCamera(GodotObject phantomCameraNode)
    {
        Pcam = phantomCameraNode;
        
        _callableBecameActive = Callable.From(() => BecameActive?.Invoke());
        _callableBecameInactive = Callable.From(() => BecameInactive?.Invoke());
        _callableFollowTargetChanged = Callable.From(() => FollowTargetChanged?.Invoke());
        _callableLookAtTargetChanged = Callable.From(() => LookAtTargetChanged?.Invoke());
        _callableDeadZoneChanged = Callable.From(() => DeadZoneChanged?.Invoke());
        _callableTweenStarted = Callable.From(() => TweenStarted?.Invoke());
        _callableIsTweening = Callable.From(() => IsTweening?.Invoke());
        _callableTweenCompleted = Callable.From(() => TweenCompleted?.Invoke());
        
        Pcam.Connect(SignalName.BecameActive, _callableBecameActive);
        Pcam.Connect(SignalName.BecameInactive, _callableBecameInactive);
        Pcam.Connect(SignalName.FollowTargetChanged, _callableFollowTargetChanged);
        Pcam.Connect(SignalName.LookAtTargetChanged, _callableLookAtTargetChanged);
        Pcam.Connect(SignalName.DeadZoneChanged, _callableDeadZoneChanged);
        Pcam.Connect(SignalName.TweenStarted, _callableTweenStarted);
        Pcam.Connect(SignalName.IsTweening, _callableIsTweening);
        Pcam.Connect(SignalName.TweenCompleted, _callableTweenCompleted);
    }

    ~PhantomCamera()
    {
        Pcam.Disconnect(SignalName.BecameActive, _callableBecameActive);
        Pcam.Disconnect(SignalName.BecameInactive, _callableBecameInactive);
        Pcam.Disconnect(SignalName.FollowTargetChanged, _callableFollowTargetChanged);
        Pcam.Disconnect(SignalName.LookAtTargetChanged, _callableLookAtTargetChanged);
        Pcam.Disconnect(SignalName.DeadZoneChanged, _callableDeadZoneChanged);
        Pcam.Disconnect(SignalName.TweenStarted, _callableTweenStarted);
        Pcam.Disconnect(SignalName.IsTweening, _callableIsTweening);
        Pcam.Disconnect(SignalName.TweenCompleted, _callableTweenCompleted);
    }
    
    public static class MethodName
    {
        public const string GetFollowMode = "get_follow_mode";
        public const string IsActive = "is_active";
        
        public const string GetPriority = "get_priority";
        public const string SetPriority = "set_priority";

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

public class PhantomCamera2D : PhantomCamera
{
    public delegate void TweenInterruptedEventHandler(Node2D pCam);
    
    public event TweenInterruptedEventHandler? TweenInterrupted;
    
    private readonly Callable _callableTweenInterrupted;

    public Vector2 Zoom
    {
        get => (Vector2)Pcam.Call(MethodName.GetZoom);
        set => Pcam.Call(MethodName.SetZoom, value);
    }

    public bool SnapToPixel
    {
        get => (bool)Pcam.Call(MethodName.GetSnapToPixel);
        set => Pcam.Call(MethodName.SetSnapToPixel, value);
    }

    public int LimitLeft
    {
        get => (int)Pcam.Call(MethodName.GetLimitLeft);
        set => Pcam.Call(MethodName.SetLimitLeft, value);
    }

    public int LimitTop
    {
        get => (int)Pcam.Call(MethodName.GetLimitTop);
        set => Pcam.Call(MethodName.SetLimitTop, value);
    }

    public int LimitRight
    {
        get => (int)Pcam.Call(MethodName.GetLimitRight);
        set => Pcam.Call(MethodName.SetLimitRight, value);
    }

    public int LimitBottom
    {
        get => (int)Pcam.Call(MethodName.GetLimitBottom);
        set => Pcam.Call(MethodName.SetLimitBottom, value);
    }

    public NodePath LimitTarget
    {
        get => (NodePath)Pcam.Call(MethodName.GetLimitTarget);
        set => Pcam.Call(MethodName.SetLimitTarget, value);
    }

    public Vector4I LimitMargin
    {
        get => (Vector4I)Pcam.Call(MethodName.GetLimitMargin);
        set => Pcam.Call(MethodName.SetLimitMargin, value);
    }
    
    public static PhantomCamera2D FromScript(string path) => new(GD.Load<GDScript>(path).New().AsGodotObject());
    public static PhantomCamera2D FromScript(GDScript script) => new(script.New().AsGodotObject());
    
    public PhantomCamera2D(GodotObject phantomCameraNode) : base(phantomCameraNode)
    {
        _callableTweenInterrupted = Callable.From<Node2D>(pCam => TweenInterrupted?.Invoke(pCam));
        Pcam.Connect(SignalName.TweenInterrupted, _callableTweenInterrupted);
    }

    ~PhantomCamera2D()
    {
        Pcam.Disconnect(SignalName.TweenInterrupted, _callableTweenInterrupted);
    }

    public void SetLimit(Side side, int value)
    {
        Pcam.Call(MethodName.SetLimit, (int)side, value);
    }

    public int GetLimit(Side side)
    {
        return (int)Pcam.Call(MethodName.GetLimit, (int)side);
    }

    public new static class MethodName
    {
        public const string GetZoom = "get_zoom";
        public const string SetZoom = "set_zoom";
        
        public const string GetSnapToPixel = "get_snap_to_pixel";
        public const string SetSnapToPixel = "set_snap_to_pixel";

        public const string GetLimit = "get_limit";
        public const string SetLimit = "set_limit";
        
        public const string GetLimitLeft = "get_limit_left";
        public const string SetLimitLeft = "set_limit_left";
        
        public const string GetLimitTop = "get_limit_top";
        public const string SetLimitTop = "set_limit_top";
        
        public const string GetLimitRight = "get_limit_right";
        public const string SetLimitRight = "set_limit_right";
        
        public const string GetLimitBottom = "get_limit_bottom";
        public const string SetLimitBottom = "set_limit_bottom";

        public const string GetLimitTarget = "get_limit_target";
        public const string SetLimitTarget = "set_limit_target";

        public const string GetLimitMargin = "get_limit_margin";
        public const string SetLimitMargin = "set_limit_margin";
    }
}

public class PhantomCamera3D : PhantomCamera
{
    public delegate void TweenInterruptedEventHandler(Node3D pCam);
    
    public event TweenInterruptedEventHandler? TweenInterrupted;
    
    private readonly Callable _callableTweenInterrupted;
    
    public new LookAtMode LookAtMode => Pcam.Call(MethodName.GetLookAtMode).As<LookAtMode>();
    
    // TODO: Camera3DResource

    public Vector3 ThirdPersonRotation
    {
        get => Pcam.Call(MethodName.GetThirdPersonRotation).As<Vector3>();
        set => Pcam.Call(MethodName.SetThirdPersonRotation, value);
    }
    
    public Vector3 ThirdPersonRotationDegrees
    {
        get => Pcam.Call(MethodName.GetThirdPersonRotationDegrees).As<Vector3>();
        set => Pcam.Call(MethodName.SetThirdPersonRotationDegrees, value);
    }
    
    public Quaternion ThirdPersonQuaternion
    {
        get => Pcam.Call(MethodName.GetThirdPersonQuaternion).As<Quaternion>();
        set => Pcam.Call(MethodName.SetThirdPersonQuaternion, value);
    }

    public float SpringLength
    {
        get => Pcam.Call(MethodName.GetSpringLength).As<float>();
        set => Pcam.Call(MethodName.SetSpringLength, value);
    }
    
    public static PhantomCamera3D FromScript(string path) => new(GD.Load<GDScript>(path).New().AsGodotObject());
    public static PhantomCamera3D FromScript(GDScript script) => new(script.New().AsGodotObject());

    public PhantomCamera3D(GodotObject phantomCamera3DNode) : base(phantomCamera3DNode)
    {
        _callableTweenInterrupted = Callable.From<Node3D>(pCam => TweenInterrupted?.Invoke(pCam));
        Pcam.Connect(SignalName.TweenInterrupted, _callableTweenInterrupted);
    }
    
    ~PhantomCamera3D()
    {
        Pcam.Disconnect(SignalName.TweenInterrupted, _callableTweenInterrupted);
    }

    public new static class MethodName
    {
        public const string GetLookAtMode = "get_look_at_mode";
        
        public const string GetThirdPersonRotation = "get_third_person_rotation";
        public const string SetThirdPersonRotation = "set_third_person_rotation";
        
        public const string GetThirdPersonRotationDegrees = "get_third_person_rotation_degrees";
        public const string SetThirdPersonRotationDegrees = "set_third_person_rotation_degrees";
        
        public const string GetThirdPersonQuaternion = "get_third_person_quaternion";
        public const string SetThirdPersonQuaternion = "set_third_person_quaternion";
        
        public const string GetSpringLength = "get_spring_length";
        public const string SetSpringLength = "set_spring_length";
    }
}