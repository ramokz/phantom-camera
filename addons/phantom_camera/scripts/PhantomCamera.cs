using System.Linq;
using Godot;

#nullable enable

namespace PhantomCamera;

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

public enum ProjectionType
{
    Perspective,
    Orthogonal,
    Frustum
}

// TODO: For Godot 4.3
// public enum InterpolationMode
// {
//     Auto,
//     Idle,
//     Physics
// }

public static class PhantomCameraExtension
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

public class PhantomCameraTween
{
    public Resource Resource { get; }

    public float Duration
    {
        get => (float)Resource.Call(MethodName.GetTweenDuration);
        set => Resource.Call(MethodName.SetTweenDuration, value);
    }

    public TransitionType Transition
    {
        get => (TransitionType)(int)Resource.Call(MethodName.GetTweenTransition);
        set => Resource.Call(MethodName.SetTweenTransition, (int)value);
    }

    public EaseType Ease
    {
        get => (EaseType)(int)Resource.Call(MethodName.GetTweenEase);
        set => Resource.Call(MethodName.SetTweenEase, (int)value);
    }

    public PhantomCameraTween(Resource tweenResource) => Resource = tweenResource;

    public static class MethodName
    {
        public const string GetTweenDuration = "get_tween_durartion";
        public const string SetTweenDuration = "set_tween_durartion";
        
        public const string GetTweenTransition = "get_tween_transition";
        public const string SetTweenTransition = "set_tween_transition";
        
        public const string GetTweenEase = "get_tween_ease";
        public const string SetTweenEase = "set_tween_ease";
    }
}

public class Camera3DResource
{
    public readonly Resource Resource;

    public const float MinOffset = 0;
    public const float MaxOffset = 1;
    
    public const float MinFov = 1;
    public const float MaxFov = 179;

    public const float MinSize = 0.001f;
    public const float MaxSize = 100;

    public const float MinNear = 0.001f;
    public const float MaxNear = 10;
    
    public const float MinFar = 0.01f;
    public const float MaxFar = 4000;

    public int CullMask
    {
        get => (int)Resource.Call(MethodName.GetCullMask);
        set => Resource.Call(MethodName.SetCullMask, value);
    }
    
    public float HOffset
    {
        get => (float)Resource.Call(MethodName.GetHOffset);
        set => Resource.Call(MethodName.SetHOffset, Mathf.Clamp(value, MinOffset, MaxOffset));
    }

    public float VOffset
    {
        get => (float)Resource.Call(MethodName.GetVOffset);
        set => Resource.Call(MethodName.SetVOffset, Mathf.Clamp(value, MinOffset, MaxOffset));
    }

    public ProjectionType Projection
    {
        get => (ProjectionType)(int)Resource.Call(MethodName.GetProjection);
        set => Resource.Call(MethodName.SetProjection, (int)value);
    }

    public float Fov
    {
        get => (float)Resource.Call(MethodName.GetFov);
        set => Resource.Call(MethodName.SetFov, Mathf.Clamp(value, MinFov, MaxFov));
    }

    public float Size
    {
        get => (float)Resource.Call(MethodName.GetSize);
        set => Resource.Call(MethodName.SetSize, Mathf.Clamp(value, MinSize, MaxSize));
    }

    public Vector2 FrustumOffset
    {
        get => (Vector2)Resource.Call(MethodName.GetFrustumOffset);
        set => Resource.Call(MethodName.SetFrustumOffset, value);
    }
    
    public float Near
    {
        get => (float)Resource.Call(MethodName.GetNear);
        set => Resource.Call(MethodName.SetNear, Mathf.Clamp(value, MinNear, MaxNear));
    }
    
    public float Far
    {
        get => (float)Resource.Call(MethodName.GetFar);
        set => Resource.Call(MethodName.SetFar, Mathf.Clamp(value, MinFar, MaxFar));
    }
    
    public Camera3DResource(Resource resource) => Resource = resource;

    public void SetCullMaskValue(int layerNumber, bool value)
    {
        Resource.Call(MethodName.SetCullMaskValue, layerNumber, value);
    }

    public static class MethodName
    {
        public const string GetCullMask = "get_cull_mask";
        public const string SetCullMask = "set_cull_mask";
        public const string SetCullMaskValue = "set_cull_mask_value";
        
        public const string GetHOffset = "get_h_offset";
        public const string SetHOffset = "set_h_offset";
        
        public const string GetVOffset = "get_v_offset";
        public const string SetVOffset = "set_v_offset";
        
        public const string GetProjection = "get_projection";
        public const string SetProjection = "set_projection";
        
        public const string GetFov = "get_fov";
        public const string SetFov = "set_fov";
        
        public const string GetSize = "get_size";
        public const string SetSize = "set_size";
        
        public const string GetFrustumOffset = "get_frustum_offset";
        public const string SetFrustumOffset = "set_frustum_offset";
        
        public const string GetNear = "get_near";
        public const string SetNear = "set_near";
        
        public const string GetFar = "get_far";
        public const string SetFar = "set_far";
    }
}

public abstract class PhantomCamera
{
    protected readonly GodotObject Node;
    
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
        get => (int)Node.Call(MethodName.GetPriority);
        set => Node.Call(MethodName.SetPriority, value);
    }
    
    public FollowMode FollowMode => (FollowMode)(int)Node.Call(MethodName.GetFollowMode);
    
    public bool IsActive => (bool)Node.Call(MethodName.IsActive);

    public PhantomCameraTween TweenResource
    {
        get => new((Resource)Node.Call(MethodName.GetTweenResource));
        set => Node.Call(MethodName.SetTweenResource, value.Resource);
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
        _callableLookAtTargetChanged = Callable.From(() => LookAtTargetChanged?.Invoke());
        _callableDeadZoneChanged = Callable.From(() => DeadZoneChanged?.Invoke());
        _callableTweenStarted = Callable.From(() => TweenStarted?.Invoke());
        _callableIsTweening = Callable.From(() => IsTweening?.Invoke());
        _callableTweenCompleted = Callable.From(() => TweenCompleted?.Invoke());
        
        Node.Connect(SignalName.BecameActive, _callableBecameActive);
        Node.Connect(SignalName.BecameInactive, _callableBecameInactive);
        Node.Connect(SignalName.FollowTargetChanged, _callableFollowTargetChanged);
        Node.Connect(SignalName.LookAtTargetChanged, _callableLookAtTargetChanged);
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
        Node.Disconnect(SignalName.LookAtTargetChanged, _callableLookAtTargetChanged);
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

public class PhantomCamera2D : PhantomCamera
{
    public Node2D Node2D => (Node2D)Node;
    
    public delegate void TweenInterruptedEventHandler(Node2D pCam);
    
    public event TweenInterruptedEventHandler? TweenInterrupted;
    
    private readonly Callable _callableTweenInterrupted;

    public Vector2 Zoom
    {
        get => (Vector2)Node.Call(MethodName.GetZoom);
        set => Node.Call(MethodName.SetZoom, value);
    }

    public bool SnapToPixel
    {
        get => (bool)Node.Call(MethodName.GetSnapToPixel);
        set => Node.Call(MethodName.SetSnapToPixel, value);
    }

    public int LimitLeft
    {
        get => (int)Node.Call(MethodName.GetLimitLeft);
        set => Node.Call(MethodName.SetLimitLeft, value);
    }

    public int LimitTop
    {
        get => (int)Node.Call(MethodName.GetLimitTop);
        set => Node.Call(MethodName.SetLimitTop, value);
    }

    public int LimitRight
    {
        get => (int)Node.Call(MethodName.GetLimitRight);
        set => Node.Call(MethodName.SetLimitRight, value);
    }

    public int LimitBottom
    {
        get => (int)Node.Call(MethodName.GetLimitBottom);
        set => Node.Call(MethodName.SetLimitBottom, value);
    }

    public NodePath LimitTarget
    {
        get => (NodePath)Node.Call(MethodName.GetLimitTarget);
        set => Node.Call(MethodName.SetLimitTarget, value);
    }

    public Vector4I LimitMargin
    {
        get => (Vector4I)Node.Call(MethodName.GetLimitMargin);
        set => Node.Call(MethodName.SetLimitMargin, value);
    }
    
    public static PhantomCamera2D FromScript(string path) => new(GD.Load<GDScript>(path).New().AsGodotObject());
    public static PhantomCamera2D FromScript(GDScript script) => new(script.New().AsGodotObject());
    
    public PhantomCamera2D(GodotObject phantomCameraNode) : base(phantomCameraNode)
    {
        _callableTweenInterrupted = Callable.From<Node2D>(pCam => TweenInterrupted?.Invoke(pCam));
        Node.Connect(SignalName.TweenInterrupted, _callableTweenInterrupted);
    }

    ~PhantomCamera2D()
    {
        Node.Disconnect(SignalName.TweenInterrupted, _callableTweenInterrupted);
    }

    public void SetLimit(Side side, int value)
    {
        Node.Call(MethodName.SetLimit, (int)side, value);
    }

    public int GetLimit(Side side)
    {
        return (int)Node.Call(MethodName.GetLimit, (int)side);
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
    public Node3D Node3D => (Node3D)Node;
    
    public delegate void TweenInterruptedEventHandler(Node3D pCam);
    
    public event TweenInterruptedEventHandler? TweenInterrupted;
    
    private readonly Callable _callableTweenInterrupted;
    
    public LookAtMode LookAtMode => (LookAtMode)(int)Node.Call(MethodName.GetLookAtMode);

    public Camera3DResource Camera3DResource
    {
        get => new((Resource)Node.Call(MethodName.GetCamera3DResource));
        set => Node.Call(MethodName.SetCamera3DResource, value.Resource);
    }

    public Vector3 ThirdPersonRotation
    {
        get => (Vector3)Node.Call(MethodName.GetThirdPersonRotation);
        set => Node.Call(MethodName.SetThirdPersonRotation, value);
    }
    
    public Vector3 ThirdPersonRotationDegrees
    {
        get => (Vector3)Node.Call(MethodName.GetThirdPersonRotationDegrees);
        set => Node.Call(MethodName.SetThirdPersonRotationDegrees, value);
    }
    
    public Quaternion ThirdPersonQuaternion
    {
        get => (Quaternion)Node.Call(MethodName.GetThirdPersonQuaternion);
        set => Node.Call(MethodName.SetThirdPersonQuaternion, value);
    }

    public float SpringLength
    {
        get => (float)Node.Call(MethodName.GetSpringLength);
        set => Node.Call(MethodName.SetSpringLength, value);
    }
    
    public static PhantomCamera3D FromScript(string path) => new(GD.Load<GDScript>(path).New().AsGodotObject());
    public static PhantomCamera3D FromScript(GDScript script) => new(script.New().AsGodotObject());

    public PhantomCamera3D(GodotObject phantomCamera3DNode) : base(phantomCamera3DNode)
    {
        _callableTweenInterrupted = Callable.From<Node3D>(pCam => TweenInterrupted?.Invoke(pCam));
        Node.Connect(SignalName.TweenInterrupted, _callableTweenInterrupted);
    }
    
    ~PhantomCamera3D()
    {
        Node.Disconnect(SignalName.TweenInterrupted, _callableTweenInterrupted);
    }

    public new static class MethodName
    {
        public const string GetLookAtMode = "get_look_at_mode";

        public const string GetCamera3DResource = "get_camera_3d_resource";
        public const string SetCamera3DResource = "set_camera_3d_resource";
        
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

public class ActivePhantomCameraQueryResult
{
    private readonly GodotObject _obj;

    public bool Is2D => _obj.IsClass("Node2D");

    public bool Is3D => _obj.IsClass("Node3D");

    public ActivePhantomCameraQueryResult(GodotObject godotOject) => _obj = godotOject;

    public PhantomCamera2D? AsPhantomCamera2D()
    {
        return Is2D ? new PhantomCamera2D(_obj) : null;
    }

    public PhantomCamera3D? AsPhantomCamera3D()
    {
        return Is3D ? new PhantomCamera3D(_obj) : null;
    }
}

public class PhantomCameraHost
{
    public readonly Node Node;

    // TODO: For Godot 4.3
    // public InterpolationMode InterpolationMode
    // {
    //     get => (InterpolationMode)(int)Node.Call(MethodName.GetInterpolationMode);
    //     set => Node.Call(MethodName.SetInterpolationMode, (int)value);
    // }

    public Camera2D Camera2D => (Camera2D)Node.Call(MethodName.GetCamera2D);

    public Camera3D Camera3D => (Camera3D)Node.Call(MethodName.GetCamera3D);

    public bool TriggerPhantomCameraTween => (bool)Node.Call(MethodName.GetTriggerPhantomCameraTween);

    public PhantomCameraHost(Node node) => Node = node;

    public ActivePhantomCameraQueryResult? GetActivePhantomCamera()
    {
        var result = Node.Call(MethodName.GetActivePhantomCamera);
        return result.VariantType == Variant.Type.Nil ? null : new ActivePhantomCameraQueryResult(result.AsGodotObject());
    }
    
    public static class MethodName
    {
        public const string GetCamera2D = "get_camera_2d";
        public const string GetCamera3D = "get_camera_3d";
        
        public const string GetActivePhantomCamera = "get_active_pcam";
        public const string GetTriggerPhantomCameraTween = "get_trigger_pcam_tween";

        // TODO: For Godot 4.3
        // public const string GetInterpolationMode = "get_interpolation_mode";
        // public const string SetInterpolationMode = "set_interpolation_mode";
    }
}

public static class PhantomCameraManager
{
    private static GodotObject? _instance;
    
    private static GodotObject Instance => _instance ??= Engine.GetSingleton("PhantomCameraManager");

    public static PhantomCamera2D[] PhantomCamera2Ds =>
        Instance.Call(MethodName.GetPhantomCamera2Ds).AsGodotArray<Node2D>()
            .Select(node => new PhantomCamera2D(node)).ToArray();
    
    public static PhantomCamera3D[] PhantomCamera3Ds =>
        Instance.Call(MethodName.GetPhantomCamera3Ds).AsGodotArray<Node3D>()
            .Select(node => new PhantomCamera3D(node)).ToArray();
    
    public static PhantomCameraHost[] PhantomCameraHosts =>
        Instance.Call(MethodName.GetPhantomCameraHosts).AsGodotArray<Node>()
            .Select(node => new PhantomCameraHost(node)).ToArray();
    
    public static class MethodName
    {
        public const string GetPhantomCamera2Ds = "get_phantom_camera_2ds";
        public const string GetPhantomCamera3Ds = "get_phantom_camera_3ds";
        public const string GetPhantomCameraHosts = "get_phantom_camera_hosts";
    }
}