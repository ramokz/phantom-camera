using Godot;
using PhantomCamera.Cameras;
using PhantomCamera.Hosts;

namespace PhantomCamera;

public static class PhantomCameraExtension
{
    public static PhantomCamera3D AsPhantomCamera3D(this Node3D node3D)
    {
        return new PhantomCamera3D(node3D);
    }

    public static PhantomCamera2D AsPhantomCamera2D(this Node2D node2D)
    {
        return new PhantomCamera2D(node2D);
    }

    public static PhantomCameraHost AsPhantomCameraHost(this Node node)
    {
        return new PhantomCameraHost(node);
    }
}





