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

		logf(LogLevel.trace, "GLFW Initialized");
	}

	~this()
	{
		glfwTerminate();
	}

	float GetTime()
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