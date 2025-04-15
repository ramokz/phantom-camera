using System.Linq;
using Godot;
using Godot.Collections;
using PhantomCamera;

#nullable enable

namespace PhantomCamera.Manager;

public static class PhantomCameraManager
{
    private static GodotObject? _instance;

    public static GodotObject Instance => _instance ??= Engine.GetSingleton("PhantomCameraManager");

    public static Array<PhantomCamera2D> PhantomCamera2Ds =>
        Instance.Call(MethodName.GetPhantomCamera2Ds).AsGodotArray<PhantomCamera2D>();
    
    public static Array<PhantomCamera3D> PhantomCamera3Ds =>
        Instance.Call(MethodName.GetPhantomCamera3Ds).AsGodotArray<PhantomCamera3D>();

    public static Array<PhantomCameraHost> PhantomCameraHosts =>
        Instance.Call(MethodName.GetPhantomCameraHosts).AsGodotArray<PhantomCameraHost>();
    
    public static class MethodName
    {
        public const string GetPhantomCamera2Ds = "get_phantom_camera_2ds";
        public const string GetPhantomCamera3Ds = "get_phantom_camera_3ds";
        public const string GetPhantomCameraHosts = "get_phantom_camera_hosts";
    }
}