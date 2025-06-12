using Godot;

#nullable enable

namespace PhantomCamera;

public enum InterpolationMode
{
    Auto,
    Idle,
    Physics
}

public static class PhantomCameraHostExtensions
{
    public static PhantomCameraHost AsPhantomCameraHost(this Node node)
    {
        return new PhantomCameraHost(node);
    }
}

public class PhantomCameraHost()
{
    public Node Node { get; } = null!;

    public PhantomCameraHost(Node node) : this()
    {
        Node = node;

        _callablePCamBecameActive = Callable.From<Node>(pCam => PCamBecameActive?.Invoke(pCam));
        _callablePCamBecameInactive = Callable.From<Node>(pCam => PCamBecameInactive?.Invoke(pCam));

        Node.Connect(SignalName.PCamBecameActive, _callablePCamBecameActive);
        Node.Connect(SignalName.PCamBecameInactive, _callablePCamBecameInactive);
    }

    ~PhantomCameraHost()
    {
        Node.Disconnect(SignalName.PCamBecameActive, _callablePCamBecameActive);
        Node.Disconnect(SignalName.PCamBecameInactive, _callablePCamBecameInactive);
    }

    public delegate void PCamBecameActiveEventHandler(Node pCam);
    public delegate void PCamBecameInactiveEventHandler(Node pCam);

    public event PCamBecameActiveEventHandler? PCamBecameActive;
    public event PCamBecameInactiveEventHandler? PCamBecameInactive;


    private readonly Callable _callablePCamBecameActive;
    private readonly Callable _callablePCamBecameInactive;
    // For when Godot becomes the minimum version
    // public InterpolationMode InterpolationMode
    // {
    //      get => (InterpolationMode)(int)Node.Call(MethodName.GetInterpolationMode);
    //      set => Node.Call(MethodName.SetInterpolationMode, (int)value);
    // }

    public int HostLayers
    {
        get => (int)Node.Call(PhantomCamera.MethodName.GetHostLayers);
        set => Node.Call(PhantomCamera.MethodName.SetHostLayers, value);
    }

    public void SetHostLayersValue(int layer, bool value) => Node.Call(MethodName.SetHostLayersValue, layer, value);

    public Camera2D? Camera2D => (Camera2D?)Node.Get(PropertyName.Camera2D);

    public Camera3D? Camera3D => (Camera3D?)Node.Get(PropertyName.Camera3D);

    public InterpolationMode InterpolationMode
    {
        get => (InterpolationMode)(int)Node.Call(MethodName.GetInterpolationMode);
        set => Node.Call(MethodName.SetInterpolationMode, (int)value);
    }

    public bool TriggerPhantomCameraTween => (bool)Node.Call(MethodName.GetTriggerPhantomCameraTween);

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

        public const string SetHostLayersValue = "set_host_layers_value";
    }

    public static class SignalName
    {
        public const string PCamBecameActive = "pcam_became_active";
        public const string PCamBecameInactive = "pcam_became_inactive";
    }
}

public class ActivePhantomCameraQueryResult(GodotObject godotObject)
{
    public bool Is2D => godotObject.IsClass("Node2D") || ((Node)godotObject).Name.ToString().Contains("PhantomCamera2D")
                                               || ((Node)godotObject).Name.ToString().Contains("PCam2D")
                                               || ((Node)godotObject).Name.ToString().Contains("2D");

    public bool Is3D => godotObject.IsClass("Node3D") || ((Node)godotObject).Name.ToString().Contains("PhantomCamera3D")
                                               || ((Node)godotObject).Name.ToString().Contains("PCam3D")
                                               || ((Node)godotObject).Name.ToString().Contains("3D");

    public PhantomCamera2D? AsPhantomCamera2D()
    {
        return Is2D ? new PhantomCamera2D(godotObject) : null;
    }

    public PhantomCamera3D? AsPhantomCamera3D()
    {
        return Is3D ? new PhantomCamera3D(godotObject) : null;
    }
}
