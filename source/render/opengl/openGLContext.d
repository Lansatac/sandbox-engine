module render.opengl.openGLContext;

import derelict.opengl3.gl3;

@trusted
class OpenGLContext
{

	this()
	{
		DerelictGL3.load();
	}

	//Window CreateWindow(int width, int height, string title, Window parent)
	//{
	//	auto window = windowProvider.CreateWindow(width, height, title, parent);
	//	DerelictGL3.reload();
	//	return window;
	//}
}