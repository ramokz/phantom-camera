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
    
    public const float MinFov = 1;
    public const float MaxFov = 179;

    public const float MinSize = 0.001f;

    public const float MinNear = 0.001f;
    
    public const float MinFar = 0.01f;

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
        set => Resource.Call(MethodName.SetFov, Mathf.Clamp(value, MinFov, MaxFov));
    }

    public float Size
    {
        get => (float)Resource.Call(MethodName.GetSize);
        set => Resource.Call(MethodName.SetSize, Mathf.Clamp(value, MinSize, 99999));
    }

    public Vector2 FrustumOffset
    {
        get => (Vector2)Resource.Call(MethodName.GetFrustumOffset);
        set => Resource.Call(MethodName.SetFrustumOffset, value);
    }
    
    public float Near
    {
        get => (float)Resource.Call(MethodName.GetNear);
        set => Resource.Call(MethodName.SetNear, Mathf.Clamp(value, MinNear, 99999));
    }
    
    public float Far
    {
        get => (float)Resource.Call(MethodName.GetFar);
        set => Resource.Call(MethodName.SetFar, Mathf.Clamp(value, MinFar, 99999));
    }

    public static class MethodName
    {
        public const string GetKeepAspect = "get_keep_aspect";
        public const string SetKeepAspect = "set_keep_aspect";
        
        public const string GetCullMask = "get_cull_mask";
        public const string SetCullMask = "set_cull_mask";
        public const string SetCullMaskValue = "set_cull_mask_value";
        
        public const string GetHOffset = "get_h_offset";
        public const string SetHOffset = "set_h_offset";
        
        public const string GetVOffset = "get_v_offset";
        public const string SetVOffset = "set_v_offset";
        
        public const string GetProjection = "get_projection";
        public const string SetProjection = "set_projection";
        
        public const string GetFov = "get_fov";
        public const string SetFov = "set_fov";
        
        public const string GetSize = "get_size";
        public const string SetSize = "set_size";
        
        public const string GetFrustumOffset = "get_frustum_offset";
        public const string SetFrustumOffset = "set_frustum_offset";
        
        public const string GetNear = "get_near";
        public const string SetNear = "set_near";
        
        public const string GetFar = "get_far";
        public const string SetFar = "set_far";
    }
}