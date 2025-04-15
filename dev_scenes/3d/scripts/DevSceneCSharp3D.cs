using Godot;
using PhantomCamera;

public partial class DevSceneCSharp3D : Node3D
{
    private PhantomCamera3D _pCam3D1;
    private PhantomCamera3D _pCam3D2;
    
    public override void _Ready()
    {
        _pCam3D1 = GetNode<PhantomCamera3D>("Cam1");
        _pCam3D2 = GetNode<PhantomCamera3D>("Cam2");

        GD.Print(_pCam3D1.Node3D.Name);
        GD.Print(_pCam3D2.Node3D.Name);
        
    }

    public override void _Input(InputEvent @event)
    {
        if (@event is InputEventMouseMotion or InputEventMouseButton) return;
        
        var eventKey = (InputEventKey)@event;
        
        if (!eventKey.Pressed) return;
        
        if (eventKey.Keycode == Key.Space)
        {
            if (_pCam3D1.Priority < 30)
            {
                _pCam3D1.Priority = 30;
            }
            else
            {
                _pCam3D1.Priority = 0;
            }
        }
    }
}
