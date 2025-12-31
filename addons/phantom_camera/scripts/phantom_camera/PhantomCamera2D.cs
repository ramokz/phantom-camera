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

    public PhantomCamera2D(GodotObject phantomCameraNode) : base(phantomCameraNode)
    {
        var callableTweenInterrupted = Callable.From<Node2D>(pCam => TweenInterrupted?.Invoke(pCam));
        var callableDeadZoneReached = Callable.From((Vector2 side) => DeadZoneReached?.Invoke(side));
        var callableNoiseEmitted = Callable.From((Transform2D output) => NoiseEmitted?.Invoke(output));

        Node2D.Connect(SignalName.TweenInterrupted, callableTweenInterrupted);
        Node2D.Connect(SignalName.DeadZoneReached, callableDeadZoneReached);
        Node2D.Connect(SignalName.NoiseEmitted, callableNoiseEmitted);
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
        public static readonly StringName GetZoom = new("get_zoom");
        public static readonly StringName SetZoom = new("set_zoom");

        public static readonly StringName GetSnapToPixel = new("get_snap_to_pixel");
        public static readonly StringName SetSnapToPixel = new("set_snap_to_pixel");

        public static readonly StringName GetRotateWithTarget = new("get_rotate_with_target");
        public static readonly StringName SetRotateWithTarget = new("set_rotate_with_target");

        public static readonly StringName GetRotationOffset = new("get_rotation_offset");
        public static readonly StringName SetRotationOffset = new("set_rotation_offset");

        public static readonly StringName GetRotationDamping = new("get_rotation_damping");
        public static readonly StringName SetRotationDamping = new("set_rotation_damping");

        public static readonly StringName GetRotationDampingValue = new("get_rotation_damping_value");
        public static readonly StringName SetRotationDampingValue = new("set_rotation_damping_value");

        public static readonly StringName GetLimit = new("get_limit");
        public static readonly StringName SetLimit = new("set_limit");

        public static readonly StringName GetLimitLeft = new("get_limit_left");
        public static readonly StringName SetLimitLeft = new("set_limit_left");

        public static readonly StringName GetLimitTop = new("get_limit_top");
        public static readonly StringName SetLimitTop = new("set_limit_top");

        public static readonly StringName GetLimitRight = new("get_limit_right");
        public static readonly StringName SetLimitRight = new("set_limit_right");

        public static readonly StringName GetLimitBottom = new("get_limit_bottom");
        public static readonly StringName SetLimitBottom = new("set_limit_bottom");

        public static readonly StringName GetLimitTarget = new("get_limit_target");
        public static readonly StringName SetLimitTarget = new("set_limit_target");

        public static readonly StringName GetLimitMargin = new("get_limit_margin");
        public static readonly StringName SetLimitMargin = new("set_limit_margin");

        public static readonly StringName GetAutoZoom = new("get_auto_zoom");
        public static readonly StringName SetAutoZoom = new("set_auto_zoom");

        public static readonly StringName GetAutoZoomMin = new("get_auto_zoom_min");
        public static readonly StringName SetAutoZoomMin = new("set_auto_zoom_min");

        public static readonly StringName GetAutoZoomMax = new("get_auto_zoom_max");
        public static readonly StringName SetAutoZoomMax = new("set_auto_zoom_max");

        public static readonly StringName GetAutoZoomMargin = new("get_auto_zoom_margin");
        public static readonly StringName SetAutoZoomMargin = new("set_auto_zoom_margin");

        public static readonly StringName GetNoise = new("get_noise");
        public static readonly StringName SetNoise = new("set_noise");
    }

    public new static class PropertyName
    {
        public static readonly StringName DrawLimits = new("draw_limits");
    }
}

public class LimitTargetQueryResult(GodotObject godotObject)
{
    public bool IsTileMapLayer => godotObject.IsClass("TileMapLayer");

    public bool IsCollisionShape2D => godotObject.IsClass("CollisionShape2D");


    public TileMapLayer? AsTileMapLayer()
    {
        return IsTileMapLayer ? (TileMapLayer)godotObject : null;
    }

    public CollisionShape2D? AsCollisionShape2D()
    {
        return IsCollisionShape2D ? (CollisionShape2D)godotObject : null;
    }
}
