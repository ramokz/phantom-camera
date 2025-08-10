using System.Linq;
using Godot;
using Godot.Collections;
using PhantomCamera.Noise;

#nullable enable

namespace PhantomCamera;

public enum FollowMode2D
{
    None,
    Glued,
    Simple,
    Group,
    Path,
    Framed
}

public enum FollowLockAxis2D
{
    None,
    X,
    Y,
    XY
}

public static class PhantomCamera2DExtensions
{
    public static PhantomCamera2D AsPhantomCamera2D(this Node2D node2D)
    {
        return new PhantomCamera2D(node2D);
    }

    public static PhantomCameraNoiseEmitter2D AsPhantomCameraNoiseEmitter2D(this Node2D node2D)
    {
        return new PhantomCameraNoiseEmitter2D(node2D);
    }

    public static PhantomCameraNoise2D AsPhantomCameraNoise2D(this Resource resource)
    {
        return new PhantomCameraNoise2D(resource);
    }
}

public class PhantomCamera2D : PhantomCamera
{
    public Node2D Node2D => (Node2D)Node;

    public delegate void TweenInterruptedEventHandler(Node2D pCam);
    public delegate void DeadZoneReachedEventHandler(Vector2 side);
    public delegate void NoiseEmittedEventHandler(Transform2D output);

    public event TweenInterruptedEventHandler? TweenInterrupted;
    public event DeadZoneReachedEventHandler? DeadZoneReached;
    public event NoiseEmittedEventHandler? NoiseEmitted;

    private readonly Callable _callableTweenInterrupted;
    private readonly Callable _callableDeadZoneReached;
    private readonly Callable _callableNoiseEmitted;

    public Node2D FollowTarget
    {
        get => (Node2D)Node2D.Call(PhantomCamera.MethodName.GetFollowTarget);
        set => Node2D.Call(PhantomCamera.MethodName.SetFollowTarget, value);
    }

    public Node2D[] FollowTargets
    {
        get => Node2D.Call(PhantomCamera.MethodName.GetFollowTargets).AsGodotArray<Node2D>().ToArray();
        set => Node2D.Call(PhantomCamera.MethodName.SetFollowTargets, new Array<Node2D>(value));
    }

    public void AppendFollowTargets(Node2D target) => Node2D.Call(PhantomCamera.MethodName.AppendFollowTargets, target);
    public void AppendFollowTargetsArray(Node2D[] targets) => Node2D.Call(PhantomCamera.MethodName.AppendFollowTargetsArray, targets);
    public void EraseFollowTargets(Node2D target) => Node2D.Call(PhantomCamera.MethodName.EraseFollowTargets, target);

    public FollowMode2D FollowMode => (FollowMode2D)(int)Node.Call(PhantomCamera.MethodName.GetFollowMode);

    public Path2D FollowPath
    {
        get => (Path2D)Node2D.Call(PhantomCamera.MethodName.GetFollowPath);
        set => Node2D.Call(PhantomCamera.MethodName.SetFollowPath, value);
    }

    public Vector2 FollowOffset
    {
        get => (Vector2)Node2D.Call(PhantomCamera.MethodName.GetFollowOffset);
        set => Node2D.Call(PhantomCamera.MethodName.SetFollowOffset, value);
    }

    public Vector2 FollowDampingValue
    {
        get => (Vector2)Node2D.Call(PhantomCamera.MethodName.GetFollowDampingValue);
        set => Node2D.Call(PhantomCamera.MethodName.SetFollowDampingValue, value);
    }

    public FollowLockAxis2D FollowAxisLock
    {
        get => (FollowLockAxis2D)(int)Node2D.Call(PhantomCamera.MethodName.GetFollowAxisLock);
        set => Node2D.Call(PhantomCamera.MethodName.SetFollowAxisLock, (int)value);
    }

    public Vector2 Zoom
    {
        get => (Vector2)Node2D.Call(MethodName.GetZoom);
        set => Node2D.Call(MethodName.SetZoom, value);
    }

    public bool SnapToPixel
    {
        get => (bool)Node2D.Call(MethodName.GetSnapToPixel);
        set => Node2D.Call(MethodName.SetSnapToPixel, value);
    }

    public bool RotateWithTarget
    {
        get => (bool)Node2D.Call(MethodName.GetRotateWithTarget);
        set => Node2D.Call(MethodName.SetRotateWithTarget, value);
    }

    public float RotationOffset
    {
        get => (float)Node2D.Call(MethodName.GetRotationOffset);
        set => Node2D.Call(MethodName.SetRotationOffset, value);
    }

    public bool RotationDamping
    {
        get => (bool)Node2D.Call(MethodName.GetRotationDamping);
        set  => Node2D.Call(MethodName.SetRotationDamping, value);
    }

    public float RotationDampingValue
    {
        get => (float)Node2D.Call(MethodName.GetRotationDampingValue);
        set => Node2D.Call(MethodName.SetRotationDampingValue, value);
    }

    public int LimitLeft
    {
        get => (int)Node2D.Call(MethodName.GetLimitLeft);
        set => Node2D.Call(MethodName.SetLimitLeft, value);
    }

    public int LimitTop
    {
        get => (int)Node2D.Call(MethodName.GetLimitTop);
        set => Node2D.Call(MethodName.SetLimitTop, value);
    }

    public int LimitRight
    {
        get => (int)Node2D.Call(MethodName.GetLimitRight);
        set => Node2D.Call(MethodName.SetLimitRight, value);
    }

    public int LimitBottom
    {
        get => (int)Node2D.Call(MethodName.GetLimitBottom);
        set => Node2D.Call(MethodName.SetLimitBottom, value);
    }

    public Vector4I LimitMargin
    {
        get => (Vector4I)Node2D.Call(MethodName.GetLimitMargin);
        set => Node2D.Call(MethodName.SetLimitMargin, value);
    }

    public bool AutoZoom
    {
        get => (bool)Node2D.Call(MethodName.GetAutoZoom);
        set => Node2D.Call(MethodName.SetAutoZoom, value);
    }

    public float AutoZoomMin
    {
        get => (float)Node2D.Call(MethodName.GetAutoZoomMin);
        set => Node2D.Call(MethodName.SetAutoZoomMin, value);
    }

    public float AutoZoomMax
    {
        get => (float)Node2D.Call(MethodName.GetAutoZoomMax);
        set => Node2D.Call(MethodName.SetAutoZoomMax, value);
    }

    public Vector4 AutoZoomMargin
    {
        get => (Vector4)Node2D.Call(MethodName.GetAutoZoomMargin);
        set => Node2D.Call(MethodName.SetAutoZoomMargin, value);
    }

    public bool DrawLimits
    {
        get => (bool)Node2D.Get(PropertyName.DrawLimits);
        set => Node2D.Set(PropertyName.DrawLimits, value);
    }

    public PhantomCameraNoise2D Noise
    {
        get => new((Resource)Node2D.Call(MethodName.GetNoise));
        set => Node2D.Call(MethodName.SetNoise, (GodotObject)value.Resource);
    }

    public void EmitNoise(Transform2D transform) => Node2D.Call(PhantomCamera.MethodName.EmitNoise, transform);

    public NodePath LimitTarget
    {
        get => (NodePath)Node2D.Call(MethodName.GetLimitTarget);
        set => Node2D.Call(MethodName.SetLimitTarget, value);
    }

    public static PhantomCamera2D FromScript(string path) => new(GD.Load<GDScript>(path).New().AsGodotObject());
    public static PhantomCamera2D FromScript(GDScript script) => new(script.New().AsGodotObject());

    public PhantomCamera2D(GodotObject phantomCameraNode) : base(phantomCameraNode)
    {
        _callableTweenInterrupted = Callable.From<Node2D>(pCam => TweenInterrupted?.Invoke(pCam));
        _callableDeadZoneReached = Callable.From((Vector2 side) => DeadZoneReached?.Invoke(side));
        _callableNoiseEmitted = Callable.From((Transform2D output) => NoiseEmitted?.Invoke(output));

        Node2D.Connect(SignalName.TweenInterrupted, _callableTweenInterrupted);
        Node2D.Connect(SignalName.DeadZoneReached, _callableDeadZoneReached);
        Node2D.Connect(SignalName.NoiseEmitted, _callableNoiseEmitted);
    }

    ~PhantomCamera2D()
    {
        Node2D.Disconnect(SignalName.TweenInterrupted, _callableTweenInterrupted);
        Node2D.Disconnect(SignalName.DeadZoneReached, _callableDeadZoneReached);
        Node2D.Disconnect(SignalName.NoiseEmitted, _callableNoiseEmitted);
    }

    public void SetLimitTarget(TileMap tileMap)
    {
        Node2D.Call(MethodName.SetLimitTarget, tileMap.GetPath());
    }

    public void SetLimitTarget(TileMapLayer tileMapLayer)
    {
        Node2D.Call(MethodName.SetLimitTarget, tileMapLayer.GetPath());
    }

    public void SetLimitTarget(CollisionShape2D shape2D)
    {
        Node2D.Call(MethodName.SetLimitTarget, shape2D.GetPath());
    }

    public LimitTargetQueryResult? GetLimitTarget()
    {
        var result = (NodePath)Node2D.Call(MethodName.GetLimitTarget);
        return result.IsEmpty ? null : new LimitTargetQueryResult(Node2D.GetNode(result));
    }

    public void SetLimit(Side side, int value)
    {
        Node2D.Call(MethodName.SetLimit, (int)side, value);
    }

    public int GetLimit(Side side)
    {
        return (int)Node2D.Call(MethodName.GetLimit, (int)side);
    }

    public new static class MethodName
    {
        public const string GetZoom = "get_zoom";
        public const string SetZoom = "set_zoom";

        public const string GetSnapToPixel = "get_snap_to_pixel";
        public const string SetSnapToPixel = "set_snap_to_pixel";

        public const string GetRotateWithTarget = "get_rotate_with_target";
        public const string SetRotateWithTarget = "set_rotate_with_target";

        public const string GetRotationOffset = "get_rotation_offset";
        public const string SetRotationOffset = "set_rotation_offset";

        public const string GetRotationDamping = "get_rotation_damping";
        public const string SetRotationDamping = "set_rotation_damping";

        public const string GetRotationDampingValue = "get_rotation_damping_value";
        public const string SetRotationDampingValue = "set_rotation_damping_value";

        public const string GetLimit = "get_limit";
        public const string SetLimit = "set_limit";

        public const string GetLimitLeft = "get_limit_left";
        public const string SetLimitLeft = "set_limit_left";

        public const string GetLimitTop = "get_limit_top";
        public const string SetLimitTop = "set_limit_top";

        public const string GetLimitRight = "get_limit_right";
        public const string SetLimitRight = "set_limit_right";

        public const string GetLimitBottom = "get_limit_bottom";
        public const string SetLimitBottom = "set_limit_bottom";

        public const string GetLimitTarget = "get_limit_target";
        public const string SetLimitTarget = "set_limit_target";

        public const string GetLimitMargin = "get_limit_margin";
        public const string SetLimitMargin = "set_limit_margin";

        public const string GetAutoZoom = "get_auto_zoom";
        public const string SetAutoZoom = "set_auto_zoom";

        public const string GetAutoZoomMin = "get_auto_zoom_min";
        public const string SetAutoZoomMin = "set_auto_zoom_min";

        public const string GetAutoZoomMax = "get_auto_zoom_max";
        public const string SetAutoZoomMax = "set_auto_zoom_max";

        public const string GetAutoZoomMargin = "get_auto_zoom_margin";
        public const string SetAutoZoomMargin = "set_auto_zoom_margin";

        public const string GetNoise = "get_noise";
        public const string SetNoise = "set_noise";
    }

    public new static class PropertyName
    {
        public const string DrawLimits = "draw_limits";
    }
}

public class LimitTargetQueryResult(GodotObject godotObject)
{
    public bool IsTileMap => godotObject.IsClass("TileMap");

    public bool IsTileMapLayer => godotObject.IsClass("TileMapLayer");

    public bool IsCollisionShape2D => godotObject.IsClass("CollisionShape2D");

    public TileMap? AsTileMap()
    {
        return IsTileMap ? (TileMap)godotObject : null;
    }

    public TileMapLayer? AsTileMapLayer()
    {
        return IsTileMapLayer ? (TileMapLayer)godotObject : null;
    }

    public CollisionShape2D? AsCollisionShape2D()
    {
        return IsCollisionShape2D ? (CollisionShape2D)godotObject : null;
    }
}
