using Godot;

#nullable enable

namespace PhantomCamera;

public enum InterpolationMode
{
    Auto,
    Idle,
    Physics,
    Manual,
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

    public PhantomCameraHost(GodotObject node) : this()
    {
        Node = node as Node;

        var callablePCamBecameActive = Callable.From<Node>(pCam => PCamBecameActive?.Invoke(pCam));
        var callablePCamBecameInactive = Callable.From<Node>(pCam => PCamBecameInactive?.Invoke(pCam));

        Node.Connect(SignalName.PCamBecameActive, callablePCamBecameActive);
        Node.Connect(SignalName.PCamBecameInactive, callablePCamBecameInactive);
    }

    public delegate void PCamBecameActiveEventHandler(Node pCam);
    public delegate void PCamBecameInactiveEventHandler(Node pCam);

    public event PCamBecameActiveEventHandler? PCamBecameActive;
    public event PCamBecameInactiveEventHandler? PCamBecameInactive;


    private readonly Callable _callablePCamBecameActive;
    private readonly Callable _callablePCamBecameInactive;

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

    public void Process() => Node.Call(MethodName.Process);

    public PhantomCamera? GetActivePhantomCamera()
    {
        var result = Node.Call(MethodName.GetActivePhantomCamera);

        if (result.Obj is Node2D node2D)
        {
            return new PhantomCamera2D(node2D);
        }

        if (result.Obj is Node3D node3D)
        {
            return new PhantomCamera3D(node3D);
        }

        return null;
    }

    public static class PropertyName
    {
        public static readonly StringName Camera2D = new("camera_2d");
        public static readonly StringName Camera3D = new("camera_3d");
    }

    public static class MethodName
    {
        public static readonly StringName GetActivePhantomCamera = new("get_active_pcam");
        public static readonly StringName GetTriggerPhantomCameraTween = new("get_trigger_pcam_tween");

        public static readonly StringName GetInterpolationMode = new("get_interpolation_mode");
        public static readonly StringName SetInterpolationMode = new("set_interpolation_mode");

        public static readonly StringName SetHostLayersValue = new("set_host_layers_value");

        public static readonly StringName Process = new("process");
    }

    public static class SignalName
    {
        public static readonly StringName PCamBecameActive = new("pcam_became_active");
        public static readonly StringName PCamBecameInactive = new("pcam_became_inactive");
    }
}
