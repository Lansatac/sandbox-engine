module render.opengl.openGLContext;

import derelict.opengl3.gl3;
import window.window;
import window.windowProvider;

@trusted
class OpenGLContext : WindowProvider
{
	WindowProvider windowProvider;

	this(WindowProvider windowProvider)
	{
		DerelictGL3.load();
		this.windowProvider = windowProvider;
	}

	Window CreateWindow(int width, int height, string title, Window parent)
	{
		auto window = windowProvider.CreateWindow(width, height, title, parent);
		DerelictGL3.reload();
		return window;
	}
}