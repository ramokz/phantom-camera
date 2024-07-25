using System.Linq;
using Godot;

#nullable enable

namespace PhantomCamera.Cameras;

public class PhantomCamera2D : PhantomCamera
{
    public Node2D Node2D => (Node2D)Node;
    
    public delegate void TweenInterruptedEventHandler(Node2D pCam);
    
    public event TweenInterruptedEventHandler? TweenInterrupted;
    
    private readonly Callable _callableTweenInterrupted;

    public Node2D FollowTarget
    {
        get => (Node2D)Node2D.Call(PhantomCamera.MethodName.GetFollowTarget);
        set => Node2D.Call(PhantomCamera.MethodName.SetFollowTarget, value);
    }
    
    public Node2D[] FollowTargets
    {
        get => Node2D.Call(PhantomCamera.MethodName.GetFollowTargets).AsGodotArray<Node2D>().ToArray();
        set => Node2D.Call(PhantomCamera.MethodName.SetFollowTargets, value);
    }
    
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
    
    public Vector2 Zoom
    {
        get => (Vector2)Node.Call(MethodName.GetZoom);
        set => Node.Call(MethodName.SetZoom, value);
    }

    public bool SnapToPixel
    {
        get => (bool)Node.Call(MethodName.GetSnapToPixel);
        set => Node.Call(MethodName.SetSnapToPixel, value);
    }

    public int LimitLeft
    {
        get => (int)Node.Call(MethodName.GetLimitLeft);
        set => Node.Call(MethodName.SetLimitLeft, value);
    }

    public int LimitTop
    {
        get => (int)Node.Call(MethodName.GetLimitTop);
        set => Node.Call(MethodName.SetLimitTop, value);
    }

    public int LimitRight
    {
        get => (int)Node.Call(MethodName.GetLimitRight);
        set => Node.Call(MethodName.SetLimitRight, value);
    }

    public int LimitBottom
    {
        get => (int)Node.Call(MethodName.GetLimitBottom);
        set => Node.Call(MethodName.SetLimitBottom, value);
    }
    
    public Vector4I LimitMargin
    {
        get => (Vector4I)Node.Call(MethodName.GetLimitMargin);
        set => Node.Call(MethodName.SetLimitMargin, value);
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
    
    public static PhantomCamera2D FromScript(string path) => new(GD.Load<GDScript>(path).New().AsGodotObject());
    public static PhantomCamera2D FromScript(GDScript script) => new(script.New().AsGodotObject());
    
    public PhantomCamera2D(GodotObject phantomCameraNode) : base(phantomCameraNode)
    {
        _callableTweenInterrupted = Callable.From<Node2D>(pCam => TweenInterrupted?.Invoke(pCam));
        Node.Connect(SignalName.TweenInterrupted, _callableTweenInterrupted);
    }

    ~PhantomCamera2D()
    {
        Node.Disconnect(SignalName.TweenInterrupted, _callableTweenInterrupted);
    }

    public void SetLimitTarget(TileMap tileMap)
    {
        Node.Call(MethodName.SetLimitTarget, tileMap.GetPath());
    }

    public void SetLimitTarget(CollisionShape2D shape2D)
    {
        Node.Call(MethodName.SetLimitTarget, shape2D.GetPath());
    }

    public LimitTargetQueryResult? GetLimitTarget()
    {
        var result = (NodePath)Node.Call(MethodName.GetLimitTarget);
        return result.IsEmpty ? null : new LimitTargetQueryResult(Node2D.GetNode(result));
    }

    public void SetLimit(Side side, int value)
    {
        Node.Call(MethodName.SetLimit, (int)side, value);
    }

    public int GetLimit(Side side)
    {
        return (int)Node.Call(MethodName.GetLimit, (int)side);
    }

    public new static class MethodName
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
    }

    public new static class PropertyName
    {
        public const string DrawLimits = "draw_limits";
    }
}

public class LimitTargetQueryResult
{
    private readonly GodotObject _obj;

    public bool IsTileMap => _obj.IsClass("TileMap");

    public bool IsCollisionShape2D => _obj.IsClass("CollisionShape2D");

    public LimitTargetQueryResult(GodotObject godotObject) => _obj = godotObject;
    
    public TileMap? AsTileMap()
    {
        return IsTileMap ? (TileMap)_obj : null;
    }

    public CollisionShape2D? AsCollisionShape2D()
    {
        return IsCollisionShape2D ? (CollisionShape2D)_obj : null;
    }
}