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
        get => (KeepAspect)(int)Resource.Call(MethodName.GetKeepAspect);
        set => Resource.Call(MethodName.SetKeepAspect, (int)value);
    }

    public int CullMask
    {
        get => (int)Resource.Call(MethodName.GetCullMask);
        set => Resource.Call(MethodName.SetCullMask, value);
    }

    public void SetCullMaskValue(int layer, bool value) => Resource.Call(MethodName.SetCullMaskValue, layer, value);

    public float HOffset
    {
        get => (float)Resource.Call(MethodName.GetHOffset);
        set => Resource.Call(MethodName.SetHOffset, value);
    }

    public float VOffset
    {
        get => (float)Resource.Call(MethodName.GetVOffset);
        set => Resource.Call(MethodName.SetVOffset, value);
    }

    public ProjectionType Projection
    {
        get => (ProjectionType)(int)Resource.Call(MethodName.GetProjection);
        set => Resource.Call(MethodName.SetProjection, (int)value);
    }

    public float Fov
    {
        get => (float)Resource.Call(MethodName.GetFov);
        set => Resource.Call(MethodName.SetFov, Mathf.Clamp(value, 1, 179));
    }

    public float Size
    {
        get => (float)Resource.Call(MethodName.GetSize);
        set => Resource.Call(MethodName.SetSize, Mathf.Clamp(value, 0.001f, float.PositiveInfinity));
    }

    public Vector2 FrustumOffset
    {
        get => (Vector2)Resource.Call(MethodName.GetFrustumOffset);
        set => Resource.Call(MethodName.SetFrustumOffset, value);
    }

    public float Near
    {
        get => (float)Resource.Call(MethodName.GetNear);
        set => Resource.Call(MethodName.SetNear, Mathf.Clamp(value, 0.001f, float.PositiveInfinity));
    }

    public float Far
    {
        get => (float)Resource.Call(MethodName.GetFar);
        set => Resource.Call(MethodName.SetFar, Mathf.Clamp(value, 0.01f, float.PositiveInfinity));
    }

    public static class MethodName
    {
        public static readonly StringName GetKeepAspect = new("get_keep_aspect");
        public static readonly StringName SetKeepAspect = new("set_keep_aspect");

        public static readonly StringName GetCullMask = new("get_cull_mask");
        public static readonly StringName SetCullMask = new("set_cull_mask");
        public static readonly StringName SetCullMaskValue = new("set_cull_mask_value");

        public static readonly StringName GetHOffset = new("get_h_offset");
        public static readonly StringName SetHOffset = new("set_h_offset");

        public static readonly StringName GetVOffset = new("get_v_offset");
        public static readonly StringName SetVOffset = new("set_v_offset");

        public static readonly StringName GetProjection = new("get_projection");
        public static readonly StringName SetProjection = new("set_projection");

        public static readonly StringName GetFov = new("get_fov");
        public static readonly StringName SetFov = new("set_fov");

        public static readonly StringName GetSize = new("get_size");
        public static readonly StringName SetSize = new("set_size");

        public static readonly StringName GetFrustumOffset = new("get_frustum_offset");
        public static readonly StringName SetFrustumOffset = new("set_frustum_offset");

        public static readonly StringName GetNear = new("get_near");
        public static readonly StringName SetNear = new("set_near");

        public static readonly StringName GetFar = new("get_far");
        public static readonly StringName SetFar = new("set_far");
    }
}
