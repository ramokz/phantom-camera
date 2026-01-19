using System.Linq;
using Godot;
using Godot.Collections;

namespace PhantomCamera.TweenDirector;

public enum Type {
    PhantomCameras  = 0,
    TweenResources  = 1,
    Any             = 2,
}

public class TweenDirectorResource(Resource resource)
{
    public readonly Resource Resource = resource;

    public PhantomCameraTween TweenResource
    {
        get => new((Resource)Resource.Call(MethodName.GetTweenResource));
        set => Resource.Call(MethodName.SetTweenResource, (GodotObject)value.Resource);
    }

    public Type FromType
    {
        get => (Type)(int)Resource.Call(MethodName.GetFromType);
        set => Resource.Call(MethodName.SetFromType, (int)value);
    }

    public NodePath[] FromPhantomCameras
    {
        get => Resource.Call(MethodName.GetFromPhantomCameras).AsGodotArray<NodePath>().ToArray();
        set => Resource.Call(MethodName.SetFromPhantomCameras, new Array<NodePath>(value));
    }

    public Resource[] FromTweenResources
    {
        get => Resource.Call(MethodName.GetFromTweenResources).AsGodotArray<Resource>().ToArray();
        set => Resource.Call(MethodName.SetFromTweenResources, new Array<Resource>(value));
    }

    public Type ToType
    {
        get => (Type)(int)Resource.Call(MethodName.GetToType);
        set => Resource.Call(MethodName.SetToType, (int)value);
    }

    public NodePath[] ToPhantomCameras
    {
        get => (NodePath[])Resource.Call(MethodName.GetToPhantomCameras);
        set => Resource.Call(MethodName.SetToPhantomCameras, value);
    }

    public Resource[] ToTweenResources
    {
        get => Resource.Call(MethodName.GetToTweenResources).AsGodotArray<Resource>().ToArray();
        set => Resource.Call(MethodName.SetToTweenResources, new Array<Resource>(value));
    }

    public static TweenDirectorResource New()
    {
        Resource resource = new();
        resource.SetScript(GD.Load<GDScript>("uid://2au3qse3jc5t"));
        return new TweenDirectorResource(resource);
    }

    public static class MethodName
    {
        public static readonly StringName GetTweenResource = new("get_tween_resource");
        public static readonly StringName SetTweenResource = new("set_tween_resource");

        public static readonly StringName GetFromType = new("get_from_type");
        public static readonly StringName SetFromType = new("set_from_type");

        public static readonly StringName GetFromPhantomCameras = new("get_from_phantom_cameras");
        public static readonly StringName SetFromPhantomCameras = new("set_from_phantom_cameras");

        public static readonly StringName GetFromTweenResources = new("get_from_tween_resources");
        public static readonly StringName SetFromTweenResources = new("set_from_tween_resources");

        public static readonly StringName GetToType = new("get_to_type");
        public static readonly StringName SetToType = new("set_to_type");

        public static readonly StringName GetToPhantomCameras = new("get_to_phantom_cameras");
        public static readonly StringName SetToPhantomCameras = new("set_to_phantom_cameras");

        public static readonly StringName GetToTweenResources = new("get_to_tween_resources");
        public static readonly StringName SetToTweenResources = new("set_to_tween_resources");
    }
}
