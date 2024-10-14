using System.Linq;
using Godot;
using PhantomCamera.Resources;

#nullable enable

namespace PhantomCamera.Cameras;

public class PhantomCamera3D : PhantomCamera
{
    public Node3D Node3D => (Node3D)Node;
    
    public delegate void LookAtTargetChangedEventHandler();
    public delegate void TweenInterruptedEventHandler(Node3D pCam);
    
    public event LookAtTargetChangedEventHandler? LookAtTargetChanged;
    public event TweenInterruptedEventHandler? TweenInterrupted;
    
    private readonly Callable _callableLookAtTargetChanged;
    private readonly Callable _callableTweenInterrupted;

    public Node3D FollowTarget
    {
        get => (Node3D)Node3D.Call(PhantomCamera.MethodName.GetFollowTarget);
        set => Node3D.Call(PhantomCamera.MethodName.SetFollowTarget, value);
    }
    
    public Node3D[] FollowTargets
    {
        get => Node3D.Call(PhantomCamera.MethodName.GetFollowTargets).AsGodotArray<Node3D>().ToArray();
        set => Node3D.Call(PhantomCamera.MethodName.SetFollowTargets, value);
    }
    
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
        set => Node3D.Call(MethodName.SetLookAtTargets, value);
    }
        
    public Vector2 ViewportPosition
    {
        get => (Vector2)Node3D.Call(MethodName.GetViewportPosition);
        set => Node3D.Call(MethodName.SetViewportPosition, value);
    }
        
    public int CollisionMask
    {
        get => (int)Node3D.Call(MethodName.GetCollisionMask);
        set => Node3D.Call(MethodName.SetCollisionMask, value);
    }
        
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
    
    public int CullMask
    {
        get => (int)Node.Call(MethodName.GetCullMask);
        set => Node.Call(MethodName.SetCullMask, value);
    }
    
    public float HOffset
    {
        get => (float)Node.Call(MethodName.GetHOffset);
        set => Node.Call(MethodName.SetHOffset, value);
    }
    
    public float VOffset
    {
        get => (float)Node.Call(MethodName.GetVOffset);
        set => Node.Call(MethodName.SetVOffset, value);
    }
    
    public ProjectionType Projection
    {
        get => (ProjectionType)(int)Node.Call(MethodName.GetProjection);
        set => Node.Call(MethodName.SetProjection, (int)value);
    }
    
    public float Fov
    {
        get => (float)Node.Call(MethodName.GetFov);
        set => Node.Call(MethodName.SetFov, value);
    }
    
    public float Size
    {
        get => (float)Node.Call(MethodName.GetSize);
        set => Node.Call(MethodName.SetSize, value);
    }
    
    public Vector2 FrustumOffset
    {
        get => (Vector2)Node.Call(MethodName.GetFrustumOffset);
        set => Node.Call(MethodName.SetFrustumOffset, value);
    }
    
    public float Far
    {
        get => (float)Node.Call(MethodName.GetFar);
        set => Node.Call(MethodName.SetFar, value);
    }
    
    public float Near
    {
        get => (float)Node.Call(MethodName.GetNear);
        set => Node.Call(MethodName.SetNear, value);
    }
    
    public Environment Environment
    {
        get => (Environment)Node.Call(MethodName.GetEnvironment);
        set => Node.Call(MethodName.SetEnvironment, value);
    }
    
    public CameraAttributes Attributes
    {
        get => (CameraAttributes)Node.Call(MethodName.GetAttributes);
        set => Node.Call(MethodName.SetAttributes, value);
    }
    
    
    public static PhantomCamera3D FromScript(string path) => new(GD.Load<GDScript>(path).New().AsGodotObject());
    public static PhantomCamera3D FromScript(GDScript script) => new(script.New().AsGodotObject());

    public PhantomCamera3D(GodotObject phantomCamera3DNode) : base(phantomCamera3DNode)
    {
        _callableLookAtTargetChanged = Callable.From(() => LookAtTargetChanged?.Invoke());
        _callableTweenInterrupted = Callable.From<Node3D>(pCam => TweenInterrupted?.Invoke(pCam));
        
        Node.Connect(SignalName.LookAtTargetChanged, _callableLookAtTargetChanged);
        Node.Connect(SignalName.TweenInterrupted, _callableTweenInterrupted);
    }
    
    ~PhantomCamera3D()
    {
        Node.Disconnect(SignalName.LookAtTargetChanged, _callableLookAtTargetChanged);
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
        
        public const string GetViewportPosition = "get_viewport_position";
        public const string SetViewportPosition = "set_viewport_position";
        
        public const string GetCollisionMask = "get_collision_mask";
        public const string SetCollisionMask = "set_collision_mask";
        
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
    }
}