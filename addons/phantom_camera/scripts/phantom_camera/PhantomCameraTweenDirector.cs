using Godot;

namespace PhantomCamera.TweenDirector;

public class PhantomCameraTweenDirector(GodotObject node)
{
    public Node Node = (Node)node;

    public TweenDirectorResource TweenDirector
    {
        get => new((Resource)Node.Call(MethodName.GetTweenDirector));
        set => Node.Call(MethodName.SetTweenDirector, (GodotObject)value.Resource);
    }

    public static class MethodName
    {
        public static readonly StringName SetTweenDirector = new("set_tween_director");
        public static readonly StringName GetTweenDirector = new("get_tween_director");
    }
}
