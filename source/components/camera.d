module components.camera;

import scene.scene;
import scene.gameObject;
import components.component;

@safe
class Camera : Component
{
	this()
	{
	}

	int depth = 0;
	float fov = 70f;
	float nearClip = 0.1f;
	float farClip = 1000f;
}