module glfw.GlfwContext;

import std.experimental.logger;
import std.string;

import derelict.glfw3;

@trusted
class GlfwContext
{
	this()
	{
		version(Windows)
		{
			DerelictGLFW3.load("libs/glfw3.dll");
		}
		else
		{
			DerelictGLFW3.load();
		}

		logf(LogLevel.trace, "Initializing GLFW");
		// initialize glfw
		if (!glfwInit())
			throw new Exception("Failed to Initialize GLFW!");
		glfwSetErrorCallback(&error_callback);


	    glfwWindowHint(GLFW_SAMPLES, 4); // 4x antialiasing
		glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3); // We want OpenGL 3.3
		glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
		glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GLFW_TRUE); // To make MacOS happy; should not be needed
		glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE); //We don't want the old OpenGL 

		logf(LogLevel.trace, "GLFW Initialized");
	}

	~this()
	{
		glfwTerminate();
	}

	@trusted float GetTime()
	{
		return glfwGetTime();
	}
}


extern(C) void error_callback(int error, const (char)* description) nothrow
{
	try
	{
    	errorf("GLFW Error %s:\n%s", error, description.fromStringz);
	}
	catch(Throwable)
	{
		// Suppress any exceptions so the method may be nothrow
	}
}