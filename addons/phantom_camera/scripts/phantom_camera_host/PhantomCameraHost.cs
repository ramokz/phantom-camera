using Godot;
using PhantomCamera;

#nullable enable

namespace PhantomCamera;

// public enum InterpolationMode
// {
//     Auto,
//     Idle,
//     Physics
// }


public partial class PhantomCameraHost(GodotObject node) : Node
{

    public Node Node { get; } = (Node)node;

    // For when Godot 4.3 becomes the minimum version
    // public InterpolationMode InterpolationMode
    // {
    //      get => (InterpolationMode)(int)Node.Call(MethodName.GetInterpolationMode);
    //      set => Node.Call(MethodName.SetInterpolationMode, (int)value);
    // }
    
    public int HostLayers
    {
        get => (int)Node.Call(PhantomCameraMethodName.GetHostLayers);
        set => Node.Call(PhantomCameraMethodName.SetHostLayers, value);
    }

    public void SetHostLayersValue(int layer, bool value) => Node.Call(PhantomCameraHostMethodName.SetHostLayersValue, layer, value);

    public Camera2D? Camera2D => (Camera2D?)Node.Get(PhantomCameraHostPropertyName.Camera2D);

    public Camera3D? Camera3D => (Camera3D?)Node.Get(PhantomCameraHostPropertyName.Camera3D);

    public bool TriggerPhantomCameraTween => (bool)Node.Call(PhantomCameraHostMethodName.GetTriggerPhantomCameraTween);

    public ActivePhantomCameraQueryResult? GetActivePhantomCamera()
    {
        var result = Node.Call(PhantomCameraHostMethodName.GetActivePhantomCamera);
        return result.VariantType == Variant.Type.Nil ? null : new ActivePhantomCameraQueryResult(result.AsGodotObject());
    }
}

public static class PhantomCameraHostPropertyName
{
    public const string Camera2D = "camera_2d";
    public const string Camera3D = "camera_3d";
}
    
public static class PhantomCameraHostMethodName
{
    public const string GetActivePhantomCamera = "get_active_pcam";
    public const string GetTriggerPhantomCameraTween = "get_trigger_pcam_tween";

    public const string GetInterpolationMode = "get_interpolation_mode";
    public const string SetInterpolationMode = "set_interpolation_mode";
        
    public const string SetHostLayersValue = "set_host_layers_value";
}

public partial class ActivePhantomCameraQueryResult(GodotObject godotObject) : GodotObject
{
    public bool Is2D => godotObject.IsClass("Node2D");

    public bool Is3D => godotObject.IsClass("Node3D");
}