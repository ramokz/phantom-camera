using Godot;

namespace PhantomCamera;

public static class GodotExtension
{
    public static PCam3D AsPCam3D(this GodotObject godotObject)
    {
        return new PCam3D(godotObject);
    }

    public static PCam3D AsPCam3D(this GDScript godotScript)
    {
        return new PCam3D(godotScript.New().AsGodotObject());
    }
}

public enum FollowMode
{
    None,
    Glued,
    Simple,
    Group,
    Path,
    Framed,
    ThirdPerson
}

public enum LookAtMode
{
    None,
    Mimic,
    Simple,
    Group
}