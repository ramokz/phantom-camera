using System.Diagnostics;
using Godot;
using PhantomCamera;

namespace PhantomCameraTests;

public partial class TestPhantomCameraWrapper: Node
{
    private PackedScene _scene2d;

    private PackedScene _scene3d;

    public override void _Ready()
    {
        _scene2d = GD.Load<PackedScene>("res://tests/scenes/test_scene_2d.tscn");
        _scene3d = GD.Load<PackedScene>("res://tests/scenes/test_scene_3d.tscn");
    }

    public void Test()
    {
        Test2D();
        Test3D();
        GD.Print("PhantomCameraWrapper tests complete");
    }

    private void Test2D()
    {
        var testScene = _scene2d.Instantiate();
        AddChild(testScene);
        
        // PhantomCameraManager Tests
        Debug.Assert(PhantomCameraManager.Instance != null);
        Debug.Assert(PhantomCameraManager.PhantomCamera3Ds.Length == 0);
        Debug.Assert(PhantomCameraManager.PhantomCamera2Ds.Length == 1);
        Debug.Assert(PhantomCameraManager.PhantomCameraHosts.Length == 1);

        // PhantomCameraHost Tests
        var cameraHost = testScene.GetNode<Node>("Camera2D/PhantomCameraHost").AsPhantomCameraHost();
        Debug.Assert(cameraHost.Node != null);
        Debug.Assert(cameraHost.Camera2D != null);
        Debug.Assert(cameraHost.Camera3D == null);
        Debug.Assert(cameraHost.TriggerPhantomCameraTween);

        var cameraQuery = cameraHost.GetActivePhantomCamera();
        Debug.Assert(cameraQuery != null);
        Debug.Assert(cameraQuery.Is2D);
        Debug.Assert(!cameraQuery.Is3D);
        Debug.Assert(cameraQuery.AsPhantomCamera3D() == null);
        
        // PhantomCamera2D Tests
        var camera = cameraQuery.AsPhantomCamera2D();
        Debug.Assert(camera != null);
        GD.Print(camera.Node2D);
        // TODO: finish implementing 2d tests
        
        RemoveChild(testScene);
    }

    private void Test3D()
    {
        var testScene = _scene3d.Instantiate();
        AddChild(testScene);
        
        // PhantomCameraManager Tests
        Debug.Assert(PhantomCameraManager.Instance != null);
        Debug.Assert(PhantomCameraManager.PhantomCamera2Ds.Length == 0);
        Debug.Assert(PhantomCameraManager.PhantomCamera3Ds.Length == 1);
        Debug.Assert(PhantomCameraManager.PhantomCameraHosts.Length == 1);
        
        // PhantomCameraHost Tests
        var cameraHost = testScene.GetNode<Node>("Camera3D/PhantomCameraHost").AsPhantomCameraHost();
        Debug.Assert(cameraHost.Node != null);
        Debug.Assert(cameraHost.Camera2D == null);
        Debug.Assert(cameraHost.Camera3D != null);
        Debug.Assert(cameraHost.TriggerPhantomCameraTween);

        var cameraQuery = cameraHost.GetActivePhantomCamera();
        Debug.Assert(cameraQuery != null);
        Debug.Assert(!cameraQuery.Is2D);
        Debug.Assert(cameraQuery.Is3D);
        Debug.Assert(cameraQuery.AsPhantomCamera2D() == null);
        
        // PhantomCamera3D Tests
        var camera = cameraQuery.AsPhantomCamera3D();
        Debug.Assert(camera != null);
        GD.Print(camera.Node3D);
        // TODO: finish implementing 3d tests
        
        RemoveChild(testScene);
    }
}