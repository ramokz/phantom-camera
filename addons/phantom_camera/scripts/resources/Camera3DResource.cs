using Godot;

namespace PhantomCamera;

public enum KeepAspect
{
    KeepWidth,
    KeepHeight
}

public enum ProjectionType
{
    Perspective,
    Orthogonal,
    Frustum
}

public class Camera3DResource(Resource resource)
{
    public readonly Resource Resource = resource;

    public KeepAspect KeepAspect
    {
        get => (KeepAspect)(int)Resource.Get(PropertyName.KeepAspect);
        set => Resource.Set(PropertyName.KeepAspect, (int)value);
    }

    public int CullMask
    {
        get => (int)Resource.Get(PropertyName.CullMask);
        set => Resource.Set(PropertyName.CullMask, value);
    }


    public float HOffset
    {
        get => (float)Resource.Get(PropertyName.HOffset);
        set => Resource.Set(PropertyName.HOffset, value);
    }

    public float VOffset
    {
        get => (float)Resource.Get(PropertyName.VOffset);
        set => Resource.Set(PropertyName.VOffset, value);
    }

    public ProjectionType Projection
    {
        get => (ProjectionType)(int)Resource.Get(PropertyName.Projection);
        set => Resource.Set(PropertyName.Projection, (int)value);
    }

    public float Fov
    {
        get => (float)Resource.Get(PropertyName.Fov);
        set => Resource.Set(PropertyName.Fov, Mathf.Clamp(value, 1, 179));
    }

    public float Size
    {
        get => (float)Resource.Get(PropertyName.Size);
        set => Resource.Set(PropertyName.Size, Mathf.Clamp(value, 0.001f, float.PositiveInfinity));
    }

    public Vector2 FrustumOffset
    {
        get => (Vector2)Resource.Get(PropertyName.FrustumOffset);
        set => Resource.Set(PropertyName.FrustumOffset, value);
    }

    public float Near
    {
        get => (float)Resource.Get(PropertyName.Near);
        set => Resource.Set(PropertyName.Near, Mathf.Clamp(value, 0.001f, float.PositiveInfinity));
    }

    public float Far
    {
        get => (float)Resource.Get(PropertyName.Far);
        set => Resource.Set(PropertyName.Far, Mathf.Clamp(value, 0.01f, float.PositiveInfinity));
    }
    
    public static Camera3DResource New()
    {
        Resource resource = new();
#if GODOT4_4_OR_GREATER
        resource.SetScript(GD.Load<GDScript>("uid://b8hhnqsugykly"));
#else
        resource.SetScript(GD.Load<GDScript>("res://addons/phantom_camera/scripts/resources/camera_3d_resource.gd"));
#endif
        return new Camera3DResource(resource);
    }

    public static class PropertyName
    {
        public static readonly StringName KeepAspect = new("keep_aspect");

        public static readonly StringName CullMask = new("cull_mask");

        public static readonly StringName HOffset = new("h_offset");

        public static readonly StringName VOffset = new("v_offset");

        public static readonly StringName Projection = new("projection");

        public static readonly StringName Fov = new("fov");

        public static readonly StringName Size = new("size");

        public static readonly StringName FrustumOffset = new("frustum_offset");

        public static readonly StringName Near = new("near");

        public static readonly StringName Far = new("far");
    }
}
