module glfw.GlfwWindow;

import std.string;
import std.experimental.logger;

import glfw.GlfwContext;

import derelict.glfw3;
import derelict.opengl3.gl3;

import scene.scene;
import scene.gameObject;

@trusted
class GlfwWindow
{
	int width()
	{
		return _width;
	}

	int height()
	{
		return _height;
	}

	this (GlfwContext context, int width, int height, string title)
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
	    windowHandle = glfwCreateWindow(_width, _height, _title.toStringz, null, null);
	    if (!windowHandle)
	    {
	        throw new Exception("Failed to create window");
	    }

	    glfwSetWindowSizeCallback(windowHandle, &onResize);

	    /* Make the window's context current */
	    glfwMakeContextCurrent(windowHandle);

	    registry[windowHandle] = this;
	}

	@trusted
	void RenderFrame()
	in
	{
		assert(!Closed);
	}
	body
	{
		glfwPollEvents();

		if (glfwGetKey(windowHandle, GLFW_KEY_ESCAPE ) == GLFW_PRESS)
		{
			glfwSetWindowShouldClose(windowHandle, 1);	    
		}

		if(glfwWindowShouldClose(windowHandle) == GLFW_TRUE)
		{
			Close();
		}

    }

	void Close()
	{
		registry.remove(windowHandle);
		glfwDestroyWindow(windowHandle);
		windowHandle = null;
	}

    bool Closed()
    {
	    return windowHandle == null || glfwWindowShouldClose(windowHandle) == GLFW_TRUE;
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
	public GLFWwindow* windowHandle;

	int _width;
	int _height;
	string _title;
}


private:
	GlfwWindow[GLFWwindow*] registry;

	extern (C) void onResize(GLFWwindow* window, int width, int height) nothrow
	{
		try
		{
			auto win = registry[window];
			win.Resize(width, height);
		}
		catch(Throwable){}
	}