using System.Diagnostics;
using Godot;
using PhantomCamera;
using PhantomCamera.Cameras;
using PhantomCamera.Managers;
using PhantomCamera.Resources;

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
        Debug.Assert(cameraHost.TriggerPhantomCameraTween);

        var cameraQuery = cameraHost.GetActivePhantomCamera();
        Debug.Assert(cameraQuery != null);
        Debug.Assert(cameraQuery.Is2D);
        Debug.Assert(!cameraQuery.Is3D);
        Debug.Assert(cameraQuery.AsPhantomCamera3D() == null);
        
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

        var shape2D = testScene.GetNode<CollisionShape2D>("Area2D/CollisionShape2D");
        camera.SetLimitTarget(shape2D);
        limitTarget = camera.GetLimitTarget();
        Debug.Assert(limitTarget != null);
        Debug.Assert(limitTarget.IsCollisionShape2D);
        Debug.Assert(limitTarget.AsCollisionShape2D() != null);
        
        // TODO: test LimitMargin
        
        // TODO: test signals
        
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
        
        RemoveChild(testScene);
    }
}