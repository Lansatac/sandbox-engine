module glfw.GlfwWindow;

import std.string;
import std.experimental.logger;

import glfw.GlfwContext;

import derelict.glfw3;
import derelict.opengl3.gl3;

import scene.scene;
import scene.gameObject;

import window.window;

@trusted
class GlfwWindow : Window
{
	int width()
	{
		return _width;
	}

	int height()
	{
		return _height;
	}

	this (GlfwContext context, int width, int height, string title, Window parent)
	{
		_height = height;
		_width = width;
		_title = title;

	    glfwWindowHint(GLFW_SAMPLES, 4); // 4x antialiasing
		glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3); // We want OpenGL 3.3
		glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
		glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GLFW_TRUE); // To make MacOS happy; should not be needed
		glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE); //We don't want the old OpenGL 

	    /* Create a windowed mode window and its OpenGL context */
	    window = glfwCreateWindow(_width, _height, _title.toStringz, null, null);
	    if (!window)
	    {
	        throw new Exception("Failed to create window");
	    }

	    glfwSetWindowSizeCallback(window, &onResize);

	    /* Make the window's context current */
	    glfwMakeContextCurrent(window);

	    registry[window] = this;
	}

	@trusted
	void RenderFrame(Scene scene)
	in
	{
		assert(!Closed);
		assert(scene);
	}
	body
	{
	    glfwMakeContextCurrent(window);
		glClearColor(0.2,0.4,0.4,1);

		scene.render(this);

		glfwSwapBuffers(window);

		glfwPollEvents();

		if (glfwGetKey(window, GLFW_KEY_ESCAPE ) == GLFW_PRESS)
		{
			glfwSetWindowShouldClose(window, 1);	    
		}

		if(glfwWindowShouldClose(window) == GLFW_TRUE)
		{
			Close();
		}

    }

	void Close()
	{
		registry.remove(window);
		glfwDestroyWindow(window);
		window = null;
	}

    bool Closed()
    {
	    return window == null || glfwWindowShouldClose(window) == GLFW_TRUE;
    }

	void Resize(int newWidth, int newHeight) nothrow
	{
		_width = newWidth;
		_height = newHeight;
		try{
			glViewport(0,0, width, height);
		}
		catch(Throwable){}
	}

private:
	public GLFWwindow* window;

	Scene _scene;

	int _width;
	int _height;
	string _title;
}


private:
	Window[GLFWwindow*] registry;

	extern (C) void onResize(GLFWwindow* window, int width, int height) nothrow
	{
		try
		{
			auto win = registry[window];
			win.Resize(width, height);
		}
		catch(Throwable){}
	}