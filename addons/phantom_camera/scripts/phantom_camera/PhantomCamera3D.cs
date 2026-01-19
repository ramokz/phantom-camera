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

    public static void SetThirdPersonRotationDegrees(this PhantomCamera3D pCam3D, Vector3 rotation) =>
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

    public Vector3 Up
    {
        get => (Vector3)Node3D.Call(MethodName.GetUp);
        set => Node3D.Call(MethodName.SetUp, value);
    }

    public Node3D UpTarget
    {
        get => (Node3D)Node3D.Call(MethodName.GetUpTarget);
        set => Node3D.Call(MethodName.SetUpTarget, value);
    }

    public int KeepAspect
    {
        get => (int)Node3D.Call(MethodName.GetKeepAspect);
        set => Node3D.Call(MethodName.SetKeepAspect, value);
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

    public PhantomCamera3D(GodotObject phantomCamera3DNode) : base(phantomCamera3DNode)
    {
        var callableLookAtTargetChanged = Callable.From(() => LookAtTargetChanged?.Invoke());
        var callableDeadZoneReached = Callable.From(() => DeadZoneReached?.Invoke());
        var callableCamera3DResourceChanged = Callable.From(() => Camera3DResourceChanged?.Invoke());
        var callableCamera3DResourcePropertyChanged = Callable.From((StringName property, Variant value) =>
            Camera3DResourcePropertyChanged?.Invoke(property, value));
        var callableTweenInterrupted = Callable.From<Node3D>(pCam => TweenInterrupted?.Invoke(pCam));
        var callableNoiseEmitted = Callable.From((Transform3D output) => NoiseEmitted?.Invoke(output));

        Node3D.Connect(SignalName.LookAtTargetChanged, callableLookAtTargetChanged);
        Node3D.Connect(PhantomCamera.SignalName.DeadZoneReached, callableDeadZoneReached);
        Node3D.Connect(SignalName.Camera3DResourceChanged, callableCamera3DResourceChanged);
        Node3D.Connect(SignalName.Camera3DResourcePropertyChanged, callableCamera3DResourcePropertyChanged);
        Node3D.Connect(PhantomCamera.SignalName.TweenInterrupted, callableTweenInterrupted);
        Node3D.Connect(PhantomCamera.SignalName.NoiseEmitted, callableNoiseEmitted);
    }

    public new static class MethodName
    {
        public static readonly StringName GetLookAtMode = new("get_look_at_mode");

        public static readonly StringName GetCamera3DResource = new("get_camera_3d_resource");
        public static readonly StringName SetCamera3DResource = new("set_camera_3d_resource");

        public static readonly StringName GetThirdPersonRotation = new("get_third_person_rotation");
        public static readonly StringName SetThirdPersonRotation = new("set_third_person_rotation");

        public static readonly StringName GetThirdPersonRotationDegrees = new("get_third_person_rotation_degrees");
        public static readonly StringName SetThirdPersonRotationDegrees = new("set_third_person_rotation_degrees");

        public static readonly StringName GetThirdPersonQuaternion = new("get_third_person_quaternion");
        public static readonly StringName SetThirdPersonQuaternion = new("set_third_person_quaternion");

        public static readonly StringName GetVerticalRotationOffset = new("get_vertical_rotation_offset");
        public static readonly StringName SetVerticalRotationOffset = new("set_vertical_rotation_offset");

        public static readonly StringName GetHorizontalRotationOffset = new("get_horizontal_rotation_offset");
        public static readonly StringName SetHorizontalRotationOffset = new("set_horizontal_rotation_offset");

        public static readonly StringName GetSpringLength = new("get_spring_length");
        public static readonly StringName SetSpringLength = new("set_spring_length");

        public static readonly StringName GetFollowDistance = new("get_follow_distance");
        public static readonly StringName SetFollowDistance = new("set_follow_distance");

        public static readonly StringName GetAutoFollowDistance = new("get_auto_follow_distance");
        public static readonly StringName SetAutoFollowDistance = new("set_auto_follow_distance");

        public static readonly StringName GetAutoFollowDistanceMin = new("get_auto_follow_distance_min");
        public static readonly StringName SetAutoFollowDistanceMin = new("set_auto_follow_distance_min");

        public static readonly StringName GetAutoFollowDistanceMax = new("get_auto_follow_distance_max");
        public static readonly StringName SetAutoFollowDistanceMax = new("set_auto_follow_distance_max");

        public static readonly StringName GetAutoFollowDistanceDivisor = new("get_auto_follow_distance_divisor");
        public static readonly StringName SetAutoFollowDistanceDivisor = new("set_auto_follow_distance_divisor");

        public static readonly StringName GetLookAtTarget = new("get_look_at_target");
        public static readonly StringName SetLookAtTarget = new("set_look_at_target");

        public static readonly StringName GetLookAtTargets = new("get_look_at_targets");
        public static readonly StringName SetLookAtTargets = new("set_look_at_targets");

        public static readonly StringName IsLooking = new("is_looking");

        public static readonly StringName GetUp = new("get_up");
        public static readonly StringName SetUp = new("set_up");

        public static readonly StringName GetUpTarget = new("get_up_target");
        public static readonly StringName SetUpTarget = new("set_up_target");

        public static readonly StringName GetCollisionMask = new("get_collision_mask");
        public static readonly StringName SetCollisionMask = new("set_collision_mask");

        public static readonly StringName SetCollisionMaskValue = new("set_collision_mask_value");

        public static readonly StringName GetShape = new("get_shape");
        public static readonly StringName SetShape = new("set_shape");

        public static readonly StringName GetMargin = new("get_margin");
        public static readonly StringName SetMargin = new("set_margin");

        public static readonly StringName GetLookAtOffset = new("get_look_at_offset");
        public static readonly StringName SetLookAtOffset = new("set_look_at_offset");

        public static readonly StringName GetLookAtDamping = new("get_look_at_damping");
        public static readonly StringName SetLookAtDamping = new("set_look_at_damping");

        public static readonly StringName GetLookAtDampingValue = new("get_look_at_damping_value");
        public static readonly StringName SetLookAtDampingValue = new("set_look_at_damping_value");

        public static readonly StringName GetKeepAspect = new("get_keep_aspect");
        public static readonly StringName SetKeepAspect = new("set_keep_aspect");

        public static readonly StringName GetCullMask = new("get_cull_mask");
        public static readonly StringName SetCullMask = new("set_cull_mask");

        public static readonly StringName GetHOffset = new("get_h_offset");
        public static readonly StringName SetHOffset = new("set_h_offset");

        public static readonly StringName GetVOffset = new("get_v_offset");
        public static readonly StringName SetVOffset = new("set_v_offset");

        public static readonly StringName GetProjection = new("get_projection");
        public static readonly StringName SetProjection = new("set_projection");

        public static readonly StringName GetFov = new("get_fov");
        public static readonly StringName SetFov = new("set_fov");

        public static readonly StringName GetSize = new("get_size");
        public static readonly StringName SetSize = new("set_size");

        public static readonly StringName GetFrustumOffset = new("get_frustum_offset");
        public static readonly StringName SetFrustumOffset = new("set_frustum_offset");

        public static readonly StringName GetFar = new("get_far");
        public static readonly StringName SetFar = new("set_far");

        public static readonly StringName GetNear = new("get_near");
        public static readonly StringName SetNear = new("set_near");

        public static readonly StringName GetEnvironment = new("get_environment");
        public static readonly StringName SetEnvironment = new("set_environment");

        public static readonly StringName GetAttributes = new("get_attributes");
        public static readonly StringName SetAttributes = new("set_attributes");

        public static readonly StringName GetNoise = new("get_noise");
        public static readonly StringName SetNoise = new("set_noise");
    }

    public new static class SignalName
    {
        public static readonly StringName LookAtTargetChanged = new("look_at_target_changed");
        public static readonly StringName Camera3DResourceChanged = new("camera_3d_resource_changed");
        public static readonly StringName Camera3DResourcePropertyChanged = new("camera_3d_resource_property_changed");
    }
}
