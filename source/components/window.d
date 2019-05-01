module components.window;

import scene.scene;
import scene.gameObject;
import components.component;
import components.registry;

@safe
class Window : Component
{
	int width;
	int height;
	string title;
}