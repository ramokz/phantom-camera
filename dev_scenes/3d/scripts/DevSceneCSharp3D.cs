using Godot;
using PhantomCamera;

public partial class DevSceneCSharp3D : Node3D
{
    public override void _Ready()
    {
        var pCam = GetNode<Node3D>("Player/PlayerCam").AsPhantomCamera3D();
        
        GD.Print(pCam.Node3D);
    }
}
