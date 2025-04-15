using System.Linq;
using Godot;
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
    Z,
    // ReSharper disable once InconsistentNaming
    XY
}

public partial class PhantomCamera2D : PhantomCamera
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
        get => (Node2D)Node2D.Call(PhantomCameraMethodName.GetFollowTarget);
        set => Node2D.Call(PhantomCameraMethodName.SetFollowTarget, value);
    }
    
    public Node2D[] FollowTargets
    {
        get => Node2D.Call(PhantomCameraMethodName.GetFollowTargets).AsGodotArray<Node2D>().ToArray();
        set => Node2D.Call(PhantomCameraMethodName.SetFollowTargets, value);
    }
    
    public void AppendFollowTargets(Node2D target) => Node2D.Call(PhantomCameraMethodName.AppendFollowTargets, target);
    public void AppendFollowTargetsArray(Node2D[] targets) => Node2D.Call(PhantomCameraMethodName.AppendFollowTargetsArray, targets);
    public void EraseFollowTargets(Node2D target) => Node2D.Call(PhantomCameraMethodName.EraseFollowTargets, target);
    
    public FollowMode2D FollowMode => (FollowMode2D)(int)Node.Call(PhantomCameraMethodName.GetFollowMode);
    
    public Path2D FollowPath
    {
        get => (Path2D)Node2D.Call(PhantomCameraMethodName.GetFollowPath);
        set => Node2D.Call(PhantomCameraMethodName.SetFollowPath, value);
    }
    
    public Vector2 FollowOffset
    {
        get => (Vector2)Node2D.Call(PhantomCameraMethodName.GetFollowOffset);
        set => Node2D.Call(PhantomCameraMethodName.SetFollowOffset, value);
    }
    
    public Vector2 FollowDampingValue
    {
        get => (Vector2)Node2D.Call(PhantomCameraMethodName.GetFollowDampingValue);
        set => Node2D.Call(PhantomCameraMethodName.SetFollowDampingValue, value);
    }
    
    public FollowLockAxis2D FollowAxisLock
    {
        get => (FollowLockAxis2D)(int)Node2D.Call(PhantomCameraMethodName.GetFollowAxisLock);
        set => Node2D.Call(PhantomCameraMethodName.SetFollowAxisLock, (int)value);
    }
    
    public Vector2 Zoom
    {
        get => (Vector2)Node2D.Call(PhantomCamera2DMethodName.GetZoom);
        set => Node2D.Call(PhantomCamera2DMethodName.SetZoom, value);
    }

    public bool SnapToPixel
    {
        get => (bool)Node2D.Call(PhantomCamera2DMethodName.GetSnapToPixel);
        set => Node2D.Call(PhantomCamera2DMethodName.SetSnapToPixel, value);
    }

    public int LimitLeft
    {
        get => (int)Node2D.Call(PhantomCamera2DMethodName.GetLimitLeft);
        set => Node2D.Call(PhantomCamera2DMethodName.SetLimitLeft, value);
    }

    public int LimitTop
    {
        get => (int)Node2D.Call(PhantomCamera2DMethodName.GetLimitTop);
        set => Node2D.Call(PhantomCamera2DMethodName.SetLimitTop, value);
    }

    public int LimitRight
    {
        get => (int)Node2D.Call(PhantomCamera2DMethodName.GetLimitRight);
        set => Node2D.Call(PhantomCamera2DMethodName.SetLimitRight, value);
    }

    public int LimitBottom
    {
        get => (int)Node2D.Call(PhantomCamera2DMethodName.GetLimitBottom);
        set => Node2D.Call(PhantomCamera2DMethodName.SetLimitBottom, value);
    }
    
    public Vector4I LimitMargin
    {
        get => (Vector4I)Node2D.Call(PhantomCamera2DMethodName.GetLimitMargin);
        set => Node2D.Call(PhantomCamera2DMethodName.SetLimitMargin, value);
    }
    
    public bool AutoZoom
    {
        get => (bool)Node2D.Call(PhantomCamera2DMethodName.GetAutoZoom);
        set => Node2D.Call(PhantomCamera2DMethodName.SetAutoZoom, value);
    }

    public float AutoZoomMin
    {
        get => (float)Node2D.Call(PhantomCamera2DMethodName.GetAutoZoomMin);
        set => Node2D.Call(PhantomCamera2DMethodName.SetAutoZoomMin, value);
    }

    public float AutoZoomMax
    {
        get => (float)Node2D.Call(PhantomCamera2DMethodName.GetAutoZoomMax);
        set => Node2D.Call(PhantomCamera2DMethodName.SetAutoZoomMax, value);
    }

    public Vector4 AutoZoomMargin
    {
        get => (Vector4)Node2D.Call(PhantomCamera2DMethodName.GetAutoZoomMargin);
        set => Node2D.Call(PhantomCamera2DMethodName.SetAutoZoomMargin, value);
    }

    public bool DrawLimits
    {
        get => (bool)Node2D.Get(PhantomCamera2DPropertyName.DrawLimits);
        set => Node2D.Set(PhantomCamera2DPropertyName.DrawLimits, value);
    }

    public PhantomCameraNoise2D Noise
    {
        get => new((Resource)Node2D.Call(PhantomCamera2DMethodName.GetNoise));
        set => Node2D.Call(PhantomCamera2DMethodName.SetNoise, (GodotObject)value.Resource);
    }
    
    public static PhantomCamera2D FromScript(string path) => new(GD.Load<GDScript>(path).New().AsGodotObject());
    public static PhantomCamera2D FromScript(GDScript script) => new(script.New().AsGodotObject());
    
    public PhantomCamera2D(GodotObject phantomCameraNode) : base(phantomCameraNode)
    {
        _callableTweenInterrupted = Callable.From<Node2D>(pCam => TweenInterrupted?.Invoke(pCam));
        _callableDeadZoneReached = Callable.From((Vector2 side) => DeadZoneReached?.Invoke(side));
        _callableNoiseEmitted = Callable.From((Transform2D output) => NoiseEmitted?.Invoke(output));
        
        Node2D.Connect(PhantomCameraSignalName.TweenInterrupted, _callableTweenInterrupted);
        Node2D.Connect(PhantomCameraSignalName.DeadZoneReached, _callableDeadZoneReached);
        Node2D.Connect(PhantomCameraSignalName.NoiseEmitted, _callableNoiseEmitted);
    }

    ~PhantomCamera2D()
    {
        Node2D.Disconnect(PhantomCameraSignalName.TweenInterrupted, _callableTweenInterrupted);
        Node2D.Disconnect(PhantomCameraSignalName.DeadZoneReached, _callableDeadZoneReached);
        Node2D.Disconnect(PhantomCameraSignalName.NoiseEmitted, _callableNoiseEmitted);
    }

    public void SetLimitTarget(TileMap tileMap)
    {
        Node2D.Call(PhantomCamera2DMethodName.SetLimitTarget, tileMap.GetPath());
    }

    public void SetLimitTarget(TileMapLayer tileMapLayer)
    {
        Node2D.Call(PhantomCamera2DMethodName.SetLimitTarget, tileMapLayer.GetPath());
    }

    public void SetLimitTarget(CollisionShape2D shape2D)
    {
        Node2D.Call(PhantomCamera2DMethodName.SetLimitTarget, shape2D.GetPath());
    }

    public LimitTargetQueryResult? GetLimitTarget()
    {
        var result = (NodePath)Node2D.Call(PhantomCamera2DMethodName.GetLimitTarget);
        return result.IsEmpty ? null : new LimitTargetQueryResult(Node2D.GetNode(result));
    }

    public void SetLimit(Side side, int value)
    {
        Node2D.Call(PhantomCamera2DMethodName.SetLimit, (int)side, value);
    }

    public int GetLimit(Side side)
    {
        return (int)Node2D.Call(PhantomCamera2DMethodName.GetLimit, (int)side);
    }

    public new static class PhantomCamera2DMethodName
    {
        public const string GetZoom = "get_zoom";
        public const string SetZoom = "set_zoom";
        
        public const string GetSnapToPixel = "get_snap_to_pixel";
        public const string SetSnapToPixel = "set_snap_to_pixel";

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

    public new static class PhantomCamera2DPropertyName
    {
        public const string DrawLimits = "draw_limits";
    }
}

public partial class LimitTargetQueryResult(GodotObject godotObject) : GodotObject
{
    public bool IsTileMap => godotObject.IsClass("TileMap");

    public bool IsTileMapLayer => godotObject.IsClass("TileMapLayer");

    public bool IsCollisionShape2D => godotObject.IsClass("CollisionShape2D");
}