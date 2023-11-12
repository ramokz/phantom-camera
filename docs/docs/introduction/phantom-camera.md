# Phantom Camera Node
Is the primary node type for this plugin and the one that needs to be actively used.

Its purpose is to contain the positional and rotational data that should be applied to a scene's Camera2D/Camera3D. Because multiple of these can exist in a given scene, it doesn't communicate directly to a Camera2D/Camera3D. Instead, it sends signals to the scene's PhantomCameraHost. The PhantomCameraHost then determines which PhantomCamera should be followed and relays that to the Camera2D/Camera3D.