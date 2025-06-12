using System.Linq;
using Godot;
using Godot.Collections;
using PhantomCamera.Noise;

#nullable enable

namespace PhantomCamera;

public enum LookAtMode
{
    None,
    Mimic,
    Simple,
    Group
}

public enum FollowMode3D
{
    None,
    Glued,
    Simple,
    Group,
    Path,
    Framed,
    ThirdPerson
}

public enum FollowLockAxis3D
{
    None,
    X,
    Y,
    Z,
    XY,
    XZ,
    YZ,
    XYZ
}

public static class PhantomCamera3DExtensions
{
    public static PhantomCamera3D AsPhantomCamera3D(this Node3D node3D)
    {
        return new PhantomCamera3D(node3D);
    }

    public static PhantomCameraNoiseEmitter3D AsPhantomCameraNoiseEmitter3D(this Node3D node3D)
    {
        return new PhantomCameraNoiseEmitter3D(node3D);
    }

    public static PhantomCameraNoise3D AsPhantomCameraNoise3D(this Resource resource)
    {
        return new PhantomCameraNoise3D(resource);
    }

    public static Camera3DResource AsCamera3DResource(this Resource resource)
    {
        return new Camera3DResource(resource);
    }

    public static Vector3 GetThirdPersonRotation(this PhantomCamera3D pCam3D) =>
        (Vector3)pCam3D.Node3D.Call(PhantomCamera3D.MethodName.GetThirdPersonRotation);

    public static void SetThirdPersonRotation(this PhantomCamera3D pCam3D, Vector3 rotation) =>
        pCam3D.Node3D.Call(PhantomCamera3D.MethodName.SetThirdPersonRotation, rotation);

    public static Vector3 GetThirdPersonRotationDegrees(this PhantomCamera3D pCam3D) =>
        (Vector3)pCam3D.Node3D.Call(PhantomCamera3D.MethodName.GetThirdPersonRotationDegrees);

    public static void SetThirdPersonDegrees(this PhantomCamera3D pCam3D, Vector3 rotation) =>
        pCam3D.Node3D.Call(PhantomCamera3D.MethodName.SetThirdPersonRotationDegrees, rotation);

    public static Quaternion GetThirdPersonQuaternion(this PhantomCamera3D pCam3D) =>
        (Quaternion)pCam3D.Node3D.Call(PhantomCamera3D.MethodName.GetThirdPersonQuaternion);

    public static void SetThirdPersonQuaternion(this PhantomCamera3D pCam3D, Quaternion quaternion) =>
        pCam3D.Node3D.Call(PhantomCamera3D.MethodName.SetThirdPersonQuaternion, quaternion);

}

public class PhantomCamera3D : PhantomCamera
{
    public Node3D Node3D => (Node3D)Node;

    public delegate void LookAtTargetChangedEventHandler();
    public delegate void DeadZoneReachedEventHandler();
    public delegate void Camera3DResourceChangedEventHandler();
    public delegate void Camera3DResourcePropertyChangedEventHandler(StringName property, Variant value);
    public delegate void TweenInterruptedEventHandler(Node3D pCam);
    public delegate void NoiseEmittedEventHandler(Transform3D output);

    public event LookAtTargetChangedEventHandler? LookAtTargetChanged;
    public event DeadZoneReachedEventHandler? DeadZoneReached;
    public event Camera3DResourceChangedEventHandler? Camera3DResourceChanged;
    public event Camera3DResourcePropertyChangedEventHandler? Camera3DResourcePropertyChanged;
    public event TweenInterruptedEventHandler? TweenInterrupted;
    public event NoiseEmittedEventHandler? NoiseEmitted;

    private readonly Callable _callableLookAtTargetChanged;
    private readonly Callable _callableDeadZoneReached;
    private readonly Callable _callableCamera3DResourceChanged;
    private readonly Callable _callableCamera3DResourcePropertyChanged;
    private readonly Callable _callableTweenInterrupted;
    private readonly Callable _callableNoiseEmitted;

    public Node3D FollowTarget
    {
        get => (Node3D)Node3D.Call(PhantomCamera.MethodName.GetFollowTarget);
        set => Node3D.Call(PhantomCamera.MethodName.SetFollowTarget, value);
    }

    public Node3D[] FollowTargets
    {
        get => Node3D.Call(PhantomCamera.MethodName.GetFollowTargets).AsGodotArray<Node3D>().ToArray();
        set => Node3D.Call(PhantomCamera.MethodName.SetFollowTargets, new Array<Node3D>(value));
    }

    public void AppendFollowTarget(Node3D target) => Node3D.Call(PhantomCamera.MethodName.AppendFollowTargets, target);
    public void AppendFollowTargetArray(Node3D[] targets) => Node3D.Call(PhantomCamera.MethodName.AppendFollowTargetsArray, targets);
    public void EraseFollowTarget(Node3D target) => Node3D.Call(PhantomCamera.MethodName.EraseFollowTargets, target);

    public FollowMode3D FollowMode => (FollowMode3D)(int)Node.Call(PhantomCamera.MethodName.GetFollowMode);

    public Path3D FollowPath
    {
        get => (Path3D)Node3D.Call(PhantomCamera.MethodName.GetFollowPath);
        set => Node3D.Call(PhantomCamera.MethodName.SetFollowPath, value);
    }

    public Vector3 FollowOffset
    {
        get => (Vector3)Node3D.Call(PhantomCamera.MethodName.GetFollowOffset);
        set => Node3D.Call(PhantomCamera.MethodName.SetFollowOffset, value);
    }

    public Vector3 FollowDampingValue
    {
        get => (Vector3)Node3D.Call(PhantomCamera.MethodName.GetFollowDampingValue);
        set => Node3D.Call(PhantomCamera.MethodName.SetFollowDampingValue, value);
    }

    public FollowLockAxis3D FollowAxisLock
    {
        get => (FollowLockAxis3D)(int)Node3D.Call(PhantomCamera.MethodName.GetFollowAxisLock);
        set => Node3D.Call(PhantomCamera.MethodName.SetFollowAxisLock, (int)value);
    }

    public LookAtMode LookAtMode => (LookAtMode)(int)Node3D.Call(MethodName.GetLookAtMode);

    public Camera3DResource Camera3DResource
    {
        get => new((Resource)Node3D.Call(MethodName.GetCamera3DResource));
        set => Node3D.Call(MethodName.SetCamera3DResource, value.Resource);
    }

    public float SpringLength
    {
        get => (float)Node3D.Call(MethodName.GetSpringLength);
        set => Node3D.Call(MethodName.SetSpringLength, value);
    }

    public float VerticalRotationOffset
    {
        get => (float)Node3D.Call(MethodName.GetVerticalRotationOffset);
        set => Node3D.Call(MethodName.SetVerticalRotationOffset, value);
    }

    public float HorizontalRotationOffset
    {
        get => (float)Node3D.Call(MethodName.GetHorizontalRotationOffset);
        set => Node3D.Call(MethodName.SetHorizontalRotationOffset, value);
    }

    public float FollowDistance
    {
        get => (float)Node3D.Call(MethodName.GetFollowDistance);
        set => Node3D.Call(MethodName.SetFollowDistance, value);
    }

    public bool AutoFollowDistance
    {
        get => (bool)Node3D.Call(MethodName.GetAutoFollowDistance);
        set => Node3D.Call(MethodName.SetAutoFollowDistance, value);
    }

    public float AutoFollowDistanceMin
    {
        get => (float)Node3D.Call(MethodName.GetAutoFollowDistanceMin);
        set => Node3D.Call(MethodName.SetAutoFollowDistanceMin, value);
    }

    public float AutoFollowDistanceMax
    {
        get => (float)Node3D.Call(MethodName.GetAutoFollowDistanceMax);
        set => Node3D.Call(MethodName.SetAutoFollowDistanceMax, value);
    }

    public float AutoFollowDistanceDivisor
    {
        get => (float)Node3D.Call(MethodName.GetAutoFollowDistanceDivisor);
        set => Node3D.Call(MethodName.SetAutoFollowDistanceDivisor, value);
    }

    public Node3D LookAtTarget
    {
        get => (Node3D)Node3D.Call(MethodName.GetLookAtTarget);
        set => Node3D.Call(MethodName.SetLookAtTarget, value);
    }

    public Node3D[] LookAtTargets
    {
        get => Node3D.Call(MethodName.GetLookAtTargets).AsGodotArray<Node3D>().ToArray();
        set => Node3D.Call(MethodName.SetLookAtTargets, new Array<Node3D>(value));
    }

    public bool IsLooking => (bool)Node3D.Call(MethodName.IsLooking);

    public int CollisionMask
    {
        get => (int)Node3D.Call(MethodName.GetCollisionMask);
        set => Node3D.Call(MethodName.SetCollisionMask, value);
    }

    public void SetCollisionMaskValue(int maskLayer, bool enable) =>
        Node3D.Call(MethodName.SetCollisionMaskValue, maskLayer, enable);

    public Shape3D Shape
    {
        get => (Shape3D)Node3D.Call(MethodName.GetShape);
        set => Node3D.Call(MethodName.SetShape, value);
    }

    public float Margin
    {
        get => (float)Node3D.Call(MethodName.GetMargin);
        set => Node3D.Call(MethodName.SetMargin, value);
    }

    public Vector3 LookAtOffset
    {
        get => (Vector3)Node3D.Call(MethodName.GetLookAtOffset);
        set => Node3D.Call(MethodName.SetLookAtOffset, value);
    }

    public bool LookAtDamping
    {
        get => (bool)Node3D.Call(MethodName.GetLookAtDamping);
        set => Node3D.Call(MethodName.SetLookAtDamping, value);
    }

    public float LookAtDampingValue
    {
        get => (float)Node3D.Call(MethodName.GetLookAtDampingValue);
        set => Node3D.Call(MethodName.SetLookAtDampingValue, value);
    }

    public Node3D Up
    {
        get => (Node3D)Node3D.Call(MethodName.GetUp);
        set => Node3D.Call(MethodName.SetUp, value);
    }

    public Vector3 UpTarget
    {
        get => (Vector3)Node3D.Call(MethodName.GetUpTarget);
        set => Node3D.Call(MethodName.SetUpTarget, value);
    }

    public int CullMask
    {
        get => (int)Node3D.Call(MethodName.GetCullMask);
        set => Node3D.Call(MethodName.SetCullMask, value);
    }

    public float HOffset
    {
        get => (float)Node3D.Call(MethodName.GetHOffset);
        set => Node3D.Call(MethodName.SetHOffset, value);
    }

    public float VOffset
    {
        get => (float)Node3D.Call(MethodName.GetVOffset);
        set => Node3D.Call(MethodName.SetVOffset, value);
    }

    public ProjectionType Projection
    {
        get => (ProjectionType)(int)Node3D.Call(MethodName.GetProjection);
        set => Node3D.Call(MethodName.SetProjection, (int)value);
    }

    public float Fov
    {
        get => (float)Node3D.Call(MethodName.GetFov);
        set => Node3D.Call(MethodName.SetFov, value);
    }

    public float Size
    {
        get => (float)Node3D.Call(MethodName.GetSize);
        set => Node3D.Call(MethodName.SetSize, value);
    }

    public Vector2 FrustumOffset
    {
        get => (Vector2)Node3D.Call(MethodName.GetFrustumOffset);
        set => Node3D.Call(MethodName.SetFrustumOffset, value);
    }

    public float Far
    {
        get => (float)Node3D.Call(MethodName.GetFar);
        set => Node3D.Call(MethodName.SetFar, value);
    }

    public float Near
    {
        get => (float)Node3D.Call(MethodName.GetNear);
        set => Node3D.Call(MethodName.SetNear, value);
    }

    public Environment Environment
    {
        get => (Environment)Node3D.Call(MethodName.GetEnvironment);
        set => Node3D.Call(MethodName.SetEnvironment, value);
    }

    public CameraAttributes Attributes
    {
        get => (CameraAttributes)Node3D.Call(MethodName.GetAttributes);
        set => Node3D.Call(MethodName.SetAttributes, value);
    }

    public PhantomCameraNoise3D Noise
    {
        get => new((Resource)Node3D.Call(MethodName.GetNoise));
        set => Node3D.Call(MethodName.SetNoise, (GodotObject)value.Resource);
    }

    public void EmitNoise(Transform3D transform) => Node3D.Call(PhantomCamera.MethodName.EmitNoise, transform);

    public static PhantomCamera3D FromScript(string path) => new(GD.Load<GDScript>(path).New().AsGodotObject());
    public static PhantomCamera3D FromScript(GDScript script) => new(script.New().AsGodotObject());

    public PhantomCamera3D(GodotObject phantomCamera3DNode) : base(phantomCamera3DNode)
    {
        _callableLookAtTargetChanged = Callable.From(() => LookAtTargetChanged?.Invoke());
        _callableDeadZoneReached = Callable.From(() => DeadZoneReached?.Invoke());
        _callableCamera3DResourceChanged = Callable.From(() => Camera3DResourceChanged?.Invoke());
        _callableCamera3DResourcePropertyChanged = Callable.From((StringName property, Variant value) =>
        Camera3DResourcePropertyChanged?.Invoke(property, value));
        _callableTweenInterrupted = Callable.From<Node3D>(pCam => TweenInterrupted?.Invoke(pCam));
        _callableNoiseEmitted = Callable.From((Transform3D output) => NoiseEmitted?.Invoke(output));

        Node3D.Connect(SignalName.LookAtTargetChanged, _callableLookAtTargetChanged);
        Node3D.Connect(PhantomCamera.SignalName.DeadZoneReached, _callableDeadZoneReached);
        Node3D.Connect(SignalName.Camera3DResourceChanged, _callableCamera3DResourceChanged);
        Node3D.Connect(SignalName.Camera3DResourcePropertyChanged, _callableCamera3DResourcePropertyChanged);
        Node3D.Connect(PhantomCamera.SignalName.TweenInterrupted, _callableTweenInterrupted);
        Node3D.Connect(PhantomCamera.SignalName.NoiseEmitted, _callableNoiseEmitted);
    }

    ~PhantomCamera3D()
    {
        Node3D.Disconnect(SignalName.LookAtTargetChanged, _callableLookAtTargetChanged);
        Node3D.Disconnect(PhantomCamera.SignalName.DeadZoneReached, _callableDeadZoneReached);
        Node3D.Disconnect(SignalName.Camera3DResourceChanged, _callableCamera3DResourceChanged);
        Node3D.Disconnect(SignalName.Camera3DResourcePropertyChanged, _callableCamera3DResourcePropertyChanged);
        Node3D.Disconnect(PhantomCamera.SignalName.TweenInterrupted, _callableTweenInterrupted);
        Node3D.Disconnect(PhantomCamera.SignalName.NoiseEmitted, _callableNoiseEmitted);
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

        public const string GetVerticalRotationOffset = "get_vertical_rotation_offset";
        public const string SetVerticalRotationOffset = "set_vertical_rotation_offset";

        public const string GetHorizontalRotationOffset = "get_horizontal_rotation_offset";
        public const string SetHorizontalRotationOffset = "set_horizontal_rotation_offset";

        public const string GetSpringLength = "get_spring_length";
        public const string SetSpringLength = "set_spring_length";

        public const string GetFollowDistance = "get_follow_distance";
        public const string SetFollowDistance = "set_follow_distance";

        public const string GetAutoFollowDistance = "get_auto_follow_distance";
        public const string SetAutoFollowDistance = "set_auto_follow_distance";

        public const string GetAutoFollowDistanceMin = "get_auto_follow_distance_min";
        public const string SetAutoFollowDistanceMin = "set_auto_follow_distance_min";

        public const string GetAutoFollowDistanceMax = "get_auto_follow_distance_max";
        public const string SetAutoFollowDistanceMax = "set_auto_follow_distance_max";

        public const string GetAutoFollowDistanceDivisor = "get_auto_follow_distance_divisor";
        public const string SetAutoFollowDistanceDivisor = "set_auto_follow_distance_divisor";

        public const string GetLookAtTarget = "get_look_at_target";
        public const string SetLookAtTarget = "set_look_at_target";

        public const string GetLookAtTargets = "get_look_at_targets";
        public const string SetLookAtTargets = "set_look_at_targets";

        public const string IsLooking = "is_looking";

        public const string GetUp = "get_up";
        public const string SetUp = "set_up";

        public const string GetUpTarget = "get_up_target";
        public const string SetUpTarget = "set_up_target";

        public const string GetCollisionMask = "get_collision_mask";
        public const string SetCollisionMask = "set_collision_mask";

        public const string SetCollisionMaskValue = "set_collision_mask_value";

        public const string GetShape = "get_shape";
        public const string SetShape = "set_shape";

        public const string GetMargin = "get_margin";
        public const string SetMargin = "set_margin";

        public const string GetLookAtOffset = "get_look_at_offset";
        public const string SetLookAtOffset = "set_look_at_offset";

        public const string GetLookAtDamping = "get_look_at_damping";
        public const string SetLookAtDamping = "set_look_at_damping";

        public const string GetLookAtDampingValue = "get_look_at_damping_value";
        public const string SetLookAtDampingValue = "set_look_at_damping_value";

        public const string GetCullMask = "get_cull_mask";
        public const string SetCullMask = "set_cull_mask";

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

        public const string GetFar = "get_far";
        public const string SetFar = "set_far";

        public const string GetNear = "get_near";
        public const string SetNear = "set_near";

        public const string GetEnvironment = "get_environment";
        public const string SetEnvironment = "set_environment";

        public const string GetAttributes = "get_attributes";
        public const string SetAttributes = "set_attributes";

        public const string GetNoise = "get_noise";
        public const string SetNoise = "set_noise";
    }

    public new static class SignalName
    {
        public const string LookAtTargetChanged = "look_at_target_changed";
        public const string Camera3DResourceChanged = "camera_3d_resource_changed";
        public const string Camera3DResourcePropertyChanged = "camera_3d_resource_property_changed";
    }
}
