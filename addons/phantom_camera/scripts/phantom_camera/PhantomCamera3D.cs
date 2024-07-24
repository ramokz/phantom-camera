using Godot;
using PhantomCamera.Resources;

// TODO: missing shared properties
// - get/set follow_distance (3d only)
// - get/set auto_follow_distance (3d only)
// - get/set auto_follow_distance_min (3d only)
// - get/set auto_follow_distance_max (3d only)
// - get/set auto_follow_distance_divisor (3d only)
// - get/set look_at_target (3d only)
// - get/set look_at_targets (3d only)
// - get/set viewport_position (3d only)
// - get/set collision_mask (3d only)
// - get/set shape (3d only)
// - get/set margin (3d only)
// - get/set look_at_offset (3d only)
// - get/set look_at_damping (3d only)
// - get/set look_at_damping_value (3d only)

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
    }
}