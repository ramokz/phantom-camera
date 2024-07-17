using Godot;

namespace PhantomCamera;

public class PCam3D
{
    public delegate void PCam3DEventHandler();
    public delegate void PCam3DTweenInterruptedEventHandler(Variant pCam3D);

    public event PCam3DEventHandler BecameActive;
    public event PCam3DEventHandler BecameInactive;
    public event PCam3DEventHandler FollowTargetChanged;
    public event PCam3DEventHandler LookAtTargetChanged;
    public event PCam3DEventHandler DeadZoneChanged;
    public event PCam3DEventHandler TweenStarted;
    public event PCam3DEventHandler IsTweening;
    public event PCam3DEventHandler TweenCompleted;
    public event PCam3DTweenInterruptedEventHandler TweenInterrupted;
    
    private readonly GodotObject _godotObject;
    
    private readonly Callable _callableBecameActive;
    private readonly Callable _callableBecameInactive;
    private readonly Callable _callableFollowTargetChanged;
    private readonly Callable _callableLookAtTargetChanged;
    private readonly Callable _callableDeadZoneChanged;
    private readonly Callable _callableTweenStarted;
    private readonly Callable _callableIsTweening;
    private readonly Callable _callableTweenCompleted;
    private readonly Callable _callableTweenInterrupted;

    public FollowMode FollowMode => _godotObject.Call(MethodName.GetFollowMode).As<FollowMode>();

    public LookAtMode LookAtMode => _godotObject.Call(MethodName.GetLookAtMode).As<LookAtMode>();

    public bool IsActive => _godotObject.Call(MethodName.IsActive).As<bool>();

    public int Priority
    {
        get => _godotObject.Call(MethodName.GetPriority).As<int>();
        set => _godotObject.Call(MethodName.SetPriority, value);
    }

    public Vector3 ThirdPersonRotation
    {
        get => _godotObject.Call(MethodName.GetThirdPersonRotation).As<Vector3>();
        set => _godotObject.Call(MethodName.SetThirdPersonRotation, value);
    }
    
    public Vector3 ThirdPersonRotationDegrees
    {
        get => _godotObject.Call(MethodName.GetThirdPersonRotationDegrees).As<Vector3>();
        set => _godotObject.Call(MethodName.SetThirdPersonRotationDegrees, value);
    }
    
    public Quaternion ThirdPersonQuaternion
    {
        get => _godotObject.Call(MethodName.GetThirdPersonQuaternion).As<Quaternion>();
        set => _godotObject.Call(MethodName.SetThirdPersonQuaternion, value);
    }

    public float SpringLength
    {
        get => _godotObject.Call(MethodName.GetSpringLength).As<float>();
        set => _godotObject.Call(MethodName.SetSpringLength, value);
    }
    
    public static PCam3D FromScript(string path) => GD.Load<GDScript>(path).AsPCam3D();

    public PCam3D(GodotObject godotObject)
    {
        _godotObject = godotObject;
        
        _callableBecameActive = Callable.From(OnBecameActive);
        _callableBecameInactive = Callable.From(OnBecameInactive);
        _callableFollowTargetChanged = Callable.From(OnFollowTargetChanged);
        _callableLookAtTargetChanged = Callable.From(OnLookAtTargetChanged);
        _callableDeadZoneChanged = Callable.From(OnDeadZoneChanged);
        _callableTweenStarted = Callable.From(OnTweenStarted);
        _callableIsTweening = Callable.From(OnIsTweening);
        _callableTweenCompleted = Callable.From(OnTweenCompleted);
        _callableTweenInterrupted = Callable.From<Variant>(OnTweenInterrupted);
        
        _godotObject.Connect(SignalName.BecameActive, _callableBecameActive);
        _godotObject.Connect(SignalName.BecameInactive, _callableBecameInactive);
        _godotObject.Connect(SignalName.FollowTargetChanged, _callableFollowTargetChanged);
        _godotObject.Connect(SignalName.LookAtTargetChanged, _callableLookAtTargetChanged);
        _godotObject.Connect(SignalName.DeadZoneChanged, _callableDeadZoneChanged);
        _godotObject.Connect(SignalName.TweenStarted, _callableTweenStarted);
        _godotObject.Connect(SignalName.IsTweening, _callableIsTweening);
        _godotObject.Connect(SignalName.TweenCompleted, _callableTweenCompleted);
        _godotObject.Connect(SignalName.TweenInterrupted, _callableTweenInterrupted);
    }

    ~PCam3D()
    {
        _godotObject.Disconnect(SignalName.BecameActive, _callableBecameActive);
        _godotObject.Disconnect(SignalName.BecameInactive, _callableBecameInactive);
        _godotObject.Disconnect(SignalName.FollowTargetChanged, _callableFollowTargetChanged);
        _godotObject.Disconnect(SignalName.LookAtTargetChanged, _callableLookAtTargetChanged);
        _godotObject.Disconnect(SignalName.DeadZoneChanged, _callableDeadZoneChanged);
        _godotObject.Disconnect(SignalName.TweenStarted, _callableTweenStarted);
        _godotObject.Disconnect(SignalName.IsTweening, _callableIsTweening);
        _godotObject.Disconnect(SignalName.TweenCompleted, _callableTweenCompleted);
        _godotObject.Disconnect(SignalName.TweenInterrupted, _callableTweenInterrupted);
    }
    
    protected virtual void OnBecameActive()
    {
        BecameActive?.Invoke();
    }
    
    protected virtual void OnBecameInactive()
    {
        BecameInactive?.Invoke();
    }
    
    protected virtual void OnFollowTargetChanged()
    {
        FollowTargetChanged?.Invoke();
    }
    
    protected virtual void OnLookAtTargetChanged()
    {
        LookAtTargetChanged?.Invoke();
    }
    
    protected virtual void OnDeadZoneChanged()
    {
        DeadZoneChanged?.Invoke();
    }
    
    protected virtual void OnTweenStarted()
    {
        TweenStarted?.Invoke();
    }
    
    protected virtual void OnIsTweening()
    {
        IsTweening?.Invoke();
    }
    
    protected virtual void OnTweenInterrupted(Variant pCam3D)
    {
        TweenInterrupted?.Invoke(pCam3D);
    }
    
    protected virtual void OnTweenCompleted()
    {
        TweenCompleted?.Invoke();
    }
    

    public static class MethodName
    {
        public const string GetFollowMode = "get_follow_mode";
        public const string GetLookAtMode = "get_look_at_mode";
        public const string IsActive = "is_active";
        
        public const string GetPriority = "get_priority";
        public const string SetPriority = "set_priority";
        
        public const string GetThirdPersonRotation = "get_third_person_rotation";
        public const string SetThirdPersonRotation = "set_third_person_rotation";
        
        public const string GetThirdPersonRotationDegrees = "get_third_person_rotation_degrees";
        public const string SetThirdPersonRotationDegrees = "set_third_person_rotation_degrees";
        
        public const string GetThirdPersonQuaternion = "get_third_person_quaternion";
        public const string SetThirdPersonQuaternion = "set_third_person_quaternion";
        
        public const string GetSpringLength = "get_spring_length";
        public const string SetSpringLength = "set_spring_length";
    }

    public static class SignalName
    {
        public const string BecameActive = "became_active";
        public const string BecameInactive = "became_inactive";
        public const string FollowTargetChanged = "follow_target_changed";
        public const string LookAtTargetChanged = "look_at_target_changed";
        public const string DeadZoneChanged = "dead_zone_changed";
        public const string TweenStarted = "tween_started";
        public const string IsTweening = "is_tweening";
        public const string TweenInterrupted = "tween_interrupted";
        public const string TweenCompleted = "tween_completed";
    }
}