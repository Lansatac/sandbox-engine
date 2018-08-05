import std.stdio;
import std.string;
import std.conv;

import std.experimental.logger;

import core.time;

import derelict.assimp3.assimp;
import derelict.opengl3.gl3;
import gl3n.linalg;
import gl3n.math;

import assimp.AssImpMeshDataRepository;
import glfw.GlfwContext;
import glfw.GlfwWindow;
import render.opengl.OpenGLMeshRepository;

import timeAccumulator;
import window;
import shader;
import scene.scene;
import components.transform;
import components.cameraControl;
import components.camera;
import components.meshRenderer;

int main()
{
	version(Windows)
	{
		DerelictASSIMP3.load("libs/assimp.dll");
	}
	else
	{
		DerelictASSIMP3.load();
	}

	DerelictGL3.load();

	GlfwContext glfw = new GlfwContext();


	auto window = new GlfwWindow(glfw, 1024, 768, "Hi!", null);
	

	DerelictGL3.reload();
	logf(LogLevel.info, "OpenGL Version: %s", glGetString(GL_VERSION).fromStringz);

    bool glLoggingEnabled = true;
    version(linux)
    {
        glLoggingEnabled = false;
    }
    version(OSX)
    {
        glLoggingEnabled = false;
    }
	version(Linux)
	{
		if(glLoggingEnabled)
		{
			glEnable(GL_DEBUG_OUTPUT);
			glDebugMessageCallback(&loggingCallbackOpenGL, null);
		}
	}

    auto meshDataRepo = new AssImpMeshDataRepository();
    auto meshRepo = new OpenGLMeshRepository(meshDataRepo);


	Scene scene = new Scene(window);
	auto camera = scene.createObject!(Transform, Camera, CameraControl);
	auto gameObject = scene.createObject!(Transform, MeshRenderer);
	scene.getComponent!(MeshRenderer)(gameObject).Mesh = meshRepo.AquireInstance(meshDataRepo.Load("assets/dragon_recon/dragon_vrip_res4.ply"));
	scene.getComponent!(Camera)(camera).SetRepo(meshRepo);

	window.SetActiveScene(scene);

	scene.getComponent!(CameraControl)(camera).window = window.window;

	auto gameObjectMesh = scene.getComponent!(MeshRenderer)(gameObject);
	
	gameObjectMesh.loadMaterial("shaders/simpleLit.vshader", "shaders/simpleLit.fshader");

	auto gameObjectTransform = scene.getComponent!(Transform)(gameObject);
	gameObjectTransform.position = vec3(0f, -10f, -10f);
	gameObjectTransform.scale = vec3(200f, 200f, 200f);

	glClearColor(0.2,0.4,0.4,1);

	auto camTransform = scene.getComponent!Transform(camera);
	camTransform.position = vec3(0,0,5);
	camTransform.rotation = quat.euler_rotation(0,PI,0);

	double lastTime = glfw.GetTime();
	double speed = 2f;

	auto fps = TimeAccumulator();

	// Compute time difference between current and last frame
	while(!window.Closed)
	{
		double currentTime = glfw.GetTime();
		double deltaTime = double(currentTime - lastTime);
		scope(exit)lastTime = currentTime;

		fps.addTime(deltaTime);
		if(fps.trackedWindow() > 1f)
		{
			//writefln("fps: %s", fps.averageRate);
			fps.reset;
		}

		window.RenderFrame();
	}

	return 0;
}

extern (C) nothrow void loggingCallbackOpenGL( GLenum source, GLenum type, GLuint id, GLenum severity,
                                               GLsizei length, const(GLchar)* message, GLvoid* userParam )
{
    try
    {
    	switch(type)
    	{
	    case GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR:
    	case GL_DEBUG_TYPE_ERROR:
    		errorf("GL Error %s", message.fromStringz);
    		break;
	    case GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR:
	    case GL_DEBUG_TYPE_PORTABILITY:
	    case GL_DEBUG_TYPE_PERFORMANCE:
    		warningf("GL Warning %s", message.fromStringz);
    		break;
	    case GL_DEBUG_TYPE_MARKER:
	    case GL_DEBUG_TYPE_PUSH_GROUP:
	    case GL_DEBUG_TYPE_POP_GROUP:
	    case GL_DEBUG_TYPE_OTHER:
    	default:
        	logf("GL Info: %s", message.fromStringz);
    	}


    }
    catch(Throwable){}
}

void logError()
{
	auto errorCode = glGetError();
	//if(errorCode != GL_NO_ERROR)
		writefln("%s", glGetError());
}
