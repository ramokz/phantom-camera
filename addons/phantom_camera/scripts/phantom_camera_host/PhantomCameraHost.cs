using Godot;
using PhantomCamera;

#nullable enable

namespace PhantomCamera;

public enum InterpolationMode
{
    Auto,
    Idle,
    Physics
}

public class PhantomCameraHost
{
    public Node Node { get; }

    // TODO: Multiple PCamHosts
    
    public InterpolationMode InterpolationMode
    {
         get => (InterpolationMode)(int)Node.Call(MethodName.GetInterpolationMode);
         set => Node.Call(MethodName.SetInterpolationMode, (int)value);
    }

    public Camera2D? Camera2D => (Camera2D?)Node.Get(PropertyName.Camera2D);

    public Camera3D? Camera3D => (Camera3D?)Node.Get(PropertyName.Camera3D);

    public bool TriggerPhantomCameraTween => (bool)Node.Call(MethodName.GetTriggerPhantomCameraTween);

    public PhantomCameraHost(Node node) => Node = node;

    public ActivePhantomCameraQueryResult? GetActivePhantomCamera()
    {
        var result = Node.Call(MethodName.GetActivePhantomCamera);
        return result.VariantType == Variant.Type.Nil ? null : new ActivePhantomCameraQueryResult(result.AsGodotObject());
    }

    public static class PropertyName
    {
        public const string Camera2D = "camera_2d";
        public const string Camera3D = "camera_3d";
    }
    
    public static class MethodName
    {
        public const string GetActivePhantomCamera = "get_active_pcam";
        public const string GetTriggerPhantomCameraTween = "get_trigger_pcam_tween";

        public const string GetInterpolationMode = "get_interpolation_mode";
        public const string SetInterpolationMode = "set_interpolation_mode";
    }
}

public class ActivePhantomCameraQueryResult
{
    private readonly GodotObject _obj;

    public bool Is2D => _obj.IsClass("Node2D");

    public bool Is3D => _obj.IsClass("Node3D");

    public ActivePhantomCameraQueryResult(GodotObject godotObject) => _obj = godotObject;

    public PhantomCamera2D? AsPhantomCamera2D()
    {
        return Is2D ? new PhantomCamera2D(_obj) : null;
    }

    public PhantomCamera3D? AsPhantomCamera3D()
    {
        return Is3D ? new PhantomCamera3D(_obj) : null;
    }
}