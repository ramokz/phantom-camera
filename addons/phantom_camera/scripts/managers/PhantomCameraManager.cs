using System.Linq;
using Godot;

#nullable enable

namespace PhantomCamera.Manager;

public static class PhantomCameraManager
{
    private static GodotObject? _instance;

    public static GodotObject Instance => _instance ??= Engine.GetSingleton("PhantomCameraManager");

    public static PhantomCamera2D[] PhantomCamera2Ds =>
        Instance.Call(MethodName.GetPhantomCamera2Ds).AsGodotArray<Node2D>()
            .Select(node => new PhantomCamera2D(node)).ToArray();

    public static PhantomCamera3D[] PhantomCamera3Ds =>
        Instance.Call(MethodName.GetPhantomCamera3Ds).AsGodotArray<Node3D>()
            .Select(node => new PhantomCamera3D(node)).ToArray();

    public static PhantomCameraHost[] PhantomCameraHosts =>
        Instance.Call(MethodName.GetPhantomCameraHosts).AsGodotArray<Node>()
            .Select(node => new PhantomCameraHost(node)).ToArray();

    public static PhantomCamera2D[] GetPhantomCamera2Ds() => PhantomCamera2Ds;
    public static PhantomCamera3D[] GetPhantomCamera3Ds() => PhantomCamera3Ds;
    public static PhantomCameraHost[] GetPhantomCameraHosts() => PhantomCameraHosts;

    public static class MethodName
    {
        public static readonly StringName GetPhantomCamera2Ds = new("get_phantom_camera_2ds");
        public static readonly StringName GetPhantomCamera3Ds = new("get_phantom_camera_3ds");
        public static readonly StringName GetPhantomCameraHosts = new("get_phantom_camera_hosts");
    }
}
