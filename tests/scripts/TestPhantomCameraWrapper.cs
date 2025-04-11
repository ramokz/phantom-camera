using System.Diagnostics;
using System.Linq;
using Godot;
using PhantomCamera;
using PhantomCamera.Manager;

namespace PhantomCameraTests;

public partial class TestPhantomCameraWrapper : Node
{
    private PackedScene _scene2d;

    private PackedScene _scene3d;

    public override void _Ready()
    {
        // res://tests/scenes/test_scene_2d.tscn
        _scene2d = GD.Load<PackedScene>("uid://bx61t0ytiwtwm");
        // res://tests/scenes/test_scene_3d.tscn
        _scene3d = GD.Load<PackedScene>("uid://bry2ltsrujg02");
    }

    public void Test()
    {
        GD.Print("Testing in progress...");
        Test2D();
        Test3D();
        GD.Print("PhantomCameraWrapper tests complete");
    }

    private void Test2D()
    {
        var testScene = _scene2d.Instantiate();
        AddChild(testScene);
        
        // PhantomCameraManager tests
        Debug.Assert(PhantomCameraManager.Instance != null);
        Debug.Assert(PhantomCameraManager.PhantomCamera3Ds.Length == 0);
        Debug.Assert(PhantomCameraManager.PhantomCamera2Ds.Length == 1);
        Debug.Assert(PhantomCameraManager.PhantomCameraHosts.Length == 1);

        // PhantomCameraHost tests
        var cameraHost = testScene.GetNode<Node>("Camera2D/PhantomCameraHost").AsPhantomCameraHost();
        Debug.Assert(cameraHost.Node != null);
        Debug.Assert(cameraHost.Camera2D != null);
        Debug.Assert(cameraHost.Camera3D == null);
        Debug.Assert(!cameraHost.TriggerPhantomCameraTween);

        var cameraQuery = cameraHost.GetActivePhantomCamera();
        Debug.Assert(cameraQuery == null);
        Debug.Assert(cameraQuery.Is2D);
        Debug.Assert(!cameraQuery.Is3D);
        Debug.Assert(cameraQuery.AsPhantomCamera3D() == null);
        
        GD.Print("PhantomCameraHost tests successfully completed.");
        
        // PhantomCamera shared tests
        var camera = cameraQuery.AsPhantomCamera2D();
        Debug.Assert(camera != null);
        Debug.Assert(camera.Node2D != null);
        
        Debug.Assert(camera.FollowMode == FollowMode.None);
        Debug.Assert(camera.IsActive);

        var priority = camera.Priority;
        camera.Priority += 10;
        Debug.Assert(camera.Priority == priority + 10);

        var tweenOnLoad = camera.TweenOnLoad;
        camera.TweenOnLoad = !camera.TweenOnLoad;
        Debug.Assert(camera.TweenOnLoad != tweenOnLoad);
        
        Debug.Assert(camera.InactiveUpdateMode == InactiveUpdateMode.Always);
        camera.InactiveUpdateMode = InactiveUpdateMode.Never;
        Debug.Assert(camera.InactiveUpdateMode == InactiveUpdateMode.Never);
        
        GD.Print("Shader PhantomCamera tests successfully completed.");

        // TweenResource tests
        var tweenResource = camera.TweenResource;
        Debug.Assert(tweenResource.Resource != null);

        var tweenDuration = tweenResource.Duration;
        tweenResource.Duration += 1.0f;
        Debug.Assert((tweenResource.Duration - (tweenDuration + 1.0f)) <= float.Epsilon);

        tweenResource.Ease = EaseType.Out;
        Debug.Assert(tweenResource.Ease == EaseType.Out);

        tweenResource.Transition = TransitionType.Sine;
        Debug.Assert(tweenResource.Transition == TransitionType.Sine);

        var tweenResourceScript = GD.Load<GDScript>("res://addons/phantom_camera/scripts/resources/tween_resource.gd");
        var newTweenResource = new PhantomCameraTween(tweenResourceScript.New().As<Resource>())
        {
            Duration = 1.5f,
            Ease = EaseType.In,
            Transition = TransitionType.Cubic
        };
        camera.TweenResource = newTweenResource;

        Debug.Assert((camera.TweenResource.Duration - 1.5f) <= float.Epsilon);
        Debug.Assert(camera.TweenResource.Ease == EaseType.In);
        Debug.Assert(camera.TweenResource.Transition == TransitionType.Cubic);
        
        GD.Print("PhantomCameraTween tests successfully completed.");

        // PhantomCamera2D tests
        camera.Zoom = new Vector2(2, 2);
        Debug.Assert(camera.Zoom.Equals(new Vector2(2, 2)));

        var snapToPixel = camera.SnapToPixel;
        camera.SnapToPixel = !camera.SnapToPixel;
        Debug.Assert(camera.SnapToPixel != snapToPixel);
        
        camera.LimitLeft = 2;
        camera.LimitTop = 3;
        camera.LimitRight = 4;
        camera.LimitBottom = 5;
        Debug.Assert(camera.LimitLeft == camera.GetLimit(Side.Left));
        Debug.Assert(camera.LimitTop == camera.GetLimit(Side.Top));
        Debug.Assert(camera.LimitRight == camera.GetLimit(Side.Right));
        Debug.Assert(camera.LimitBottom == camera.GetLimit(Side.Bottom));
        
        camera.SetLimit(Side.Left, 5);
        camera.SetLimit(Side.Top, 4);
        camera.SetLimit(Side.Right, 3);
        camera.SetLimit(Side.Bottom, 2);
        Debug.Assert(camera.LimitLeft == camera.GetLimit(Side.Left));
        Debug.Assert(camera.LimitTop == camera.GetLimit(Side.Top));
        Debug.Assert(camera.LimitRight == camera.GetLimit(Side.Right));
        Debug.Assert(camera.LimitBottom == camera.GetLimit(Side.Bottom));

        Debug.Assert(camera.GetLimitTarget() == null);

        var tileMap = testScene.GetNode<TileMap>("TileMap");
        camera.SetLimitTarget(tileMap);
        var limitTarget = camera.GetLimitTarget();
        Debug.Assert(limitTarget != null);
        Debug.Assert(limitTarget.IsTileMap);
        Debug.Assert(limitTarget.AsTileMap() != null);
        
        var tileMapLayer = testScene.GetNode<TileMapLayer>("TileMapLayer");
        camera.SetLimitTarget(tileMapLayer);
        limitTarget = camera.GetLimitTarget();
        Debug.Assert(limitTarget != null);
        Debug.Assert(limitTarget.IsTileMapLayer);
        Debug.Assert(limitTarget.AsTileMapLayer() != null);

        var shape2D = testScene.GetNode<CollisionShape2D>("Area2D/CollisionShape2D");
        camera.SetLimitTarget(shape2D);
        limitTarget = camera.GetLimitTarget();
        Debug.Assert(limitTarget != null);
        Debug.Assert(limitTarget.IsCollisionShape2D);
        Debug.Assert(limitTarget.AsCollisionShape2D() != null);
        
        // TODO: test LimitMargin
        
        // TODO: test signals
        
        GD.Print("PhantomCamera2D tests successfully completed.");
        
        RemoveChild(testScene);
        
        GD.Print("2D Testing complete.");
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
        camera.Fov = 90;
        Debug.Assert(camera.Fov.Equals(90));

        Node3D followTarget1 = new Node3D()
        {
            Name = "FollowTarget1",
        };
        
        Node3D followTarget2 = new Node3D()
        {
            Name = "FollowTarget2",
        };
        
        AddChild(followTarget1);
        AddChild(followTarget2);
        
        camera.FollowTarget = GetNode<Node3D>("FollowTarget1");
        Debug.Assert(camera.FollowTarget != null);
        Debug.Assert(camera.FollowTarget.Name == "FollowTarget1");
        camera.FollowTarget = null;
        
        camera.AppendFollowTargetArray([followTarget1, followTarget2]);
        Debug.Assert(camera.FollowTargets.Contains(followTarget1));
        Debug.Assert(camera.FollowTargets.Contains(followTarget2));
        
        RemoveChild(followTarget1);
        RemoveChild(followTarget2);
        
        camera.ThirdPersonRotationDegrees = new Vector3(0, 2, 3);
        Debug.Assert(camera.ThirdPersonRotationDegrees.Equals(new Vector3(0, 2, 3)));
        
        RemoveChild(testScene);
        
        GD.Print("3D Testing complete.");
    }
}