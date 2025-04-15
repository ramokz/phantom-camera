using Godot;

namespace PhantomCamera;

public enum ProjectionType
{
    Perspective,
    Orthogonal,
    Frustum
}

public partial class Camera3DResource(Resource resource) : Resource
{
    public readonly Resource Resource = resource;

    public const float MinOffset = 0;
    public const float MaxOffset = 1;
    
    public const float MinFov = 1;
    public const float MaxFov = 179;

    public const float MinSize = 0.001f;
    public const float MaxSize = 100;

    public const float MinNear = 0.001f;
    public const float MaxNear = 10;
    
    public const float MinFar = 0.01f;
    public const float MaxFar = 4000;

    public int CullMask
    {
        get => (int)Resource.Call(Camera3DResourceMethodName.GetCullMask);
        set => Resource.Call(Camera3DResourceMethodName.SetCullMask, value);
    }
    
    public void SetCullMaskValue(int layer, bool value) => Resource.Call(Camera3DResourceMethodName.SetCullMaskValue, layer, value);
    
    public float HOffset
    {
        get => (float)Resource.Call(Camera3DResourceMethodName.GetHOffset);
        set => Resource.Call(Camera3DResourceMethodName.SetHOffset, Mathf.Clamp(value, MinOffset, MaxOffset));
    }

    public float VOffset
    {
        get => (float)Resource.Call(Camera3DResourceMethodName.GetVOffset);
        set => Resource.Call(Camera3DResourceMethodName.SetVOffset, Mathf.Clamp(value, MinOffset, MaxOffset));
    }

    public ProjectionType Projection
    {
        get => (ProjectionType)(int)Resource.Call(Camera3DResourceMethodName.GetProjection);
        set => Resource.Call(Camera3DResourceMethodName.SetProjection, (int)value);
    }

    public float Fov
    {
        get => (float)Resource.Call(Camera3DResourceMethodName.GetFov);
        set => Resource.Call(Camera3DResourceMethodName.SetFov, Mathf.Clamp(value, MinFov, MaxFov));
    }

    public float Size
    {
        get => (float)Resource.Call(Camera3DResourceMethodName.GetSize);
        set => Resource.Call(Camera3DResourceMethodName.SetSize, Mathf.Clamp(value, MinSize, MaxSize));
    }

    public Vector2 FrustumOffset
    {
        get => (Vector2)Resource.Call(Camera3DResourceMethodName.GetFrustumOffset);
        set => Resource.Call(Camera3DResourceMethodName.SetFrustumOffset, value);
    }
    
    public float Near
    {
        get => (float)Resource.Call(Camera3DResourceMethodName.GetNear);
        set => Resource.Call(Camera3DResourceMethodName.SetNear, Mathf.Clamp(value, MinNear, MaxNear));
    }
    
    public float Far
    {
        get => (float)Resource.Call(Camera3DResourceMethodName.GetFar);
        set => Resource.Call(Camera3DResourceMethodName.SetFar, Mathf.Clamp(value, MinFar, MaxFar));
    }

    public static class Camera3DResourceMethodName
    {
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