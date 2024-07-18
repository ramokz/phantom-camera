using Godot;
using PhantomCamera;

public partial class DevSceneCSharp3D : Node3D
{
    public override void _Ready()
    {
        var pCamNode = GetNode<Node3D>("Player/PlayerCam");
        var pCam = pCamNode.AsPhantomCamera3D();
        
        GD.Print(pCam);
    }
}
