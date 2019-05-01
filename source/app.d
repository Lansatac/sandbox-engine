import std.stdio;
import std.string;
import std.conv;

import std.experimental.logger;

import core.time;

import gl3n.linalg;
import gl3n.math;

import assimp.AssImpMeshDataRepository;
import render.opengl.openGLContext;
import glfw.GlfwContext;
import glfw.GlfwWindow;

import render.opengl.OpenGLRenderSystem;
import render.opengl.OpenGLMeshRepository;

import timeAccumulator;
import shader;
import scene.scene;

import system.SystemGroup;

import components.transform;
import components.camera;
import components.meshRenderer;

@safe
int main()
{
	GlfwContext glfw = new GlfwContext();
	OpenGLContext gl = new OpenGLContext();
	//auto window = gl.CreateWindow(1024, 768, "Hi!", null);

    auto meshDataRepo = new AssImpMeshDataRepository();
    auto meshRepo = new OpenGLMeshRepository(meshDataRepo);


	auto scene = new Scene!(Transform, Camera, MeshRenderer);
	auto camera = scene.createObject();
	scene.add(camera, new Transform());
	scene.add(camera, new Camera());
	auto gameObject = scene.createObject();
	scene.add(gameObject, new Transform());
	scene.add(gameObject, new MeshRenderer());
	scene.getMeshRenderer(gameObject).Mesh = meshRepo.AquireInstance(meshDataRepo.Load("assets/car/BMW27GE.fbx"));

	//scene.getComponent!(CameraControl)(camera).window = window.window;

	auto gameObjectMesh = scene.getMeshRenderer(gameObject);
	
	gameObjectMesh.loadMaterial("shaders/simpleLit.vshader", "shaders/simpleLit.fshader");

	auto gameObjectTransform = scene.getTransform(gameObject);
	gameObjectTransform.position = vec3(0f, 0f, 0f);
	gameObjectTransform.scale = vec3(1f, 1f, 1f);


	auto camTransform = scene.getTransform(camera);
	camTransform.position = vec3(0,0,15);
	camTransform.rotation = quat.euler_rotation(0,PI,0);


	//SystemGroup systems = new SystemGroup()
	//						.Add(new OpenGLRenderSystem(scene.registry, meshRepo, cast(GlfwWindow)window))
	//						;

	double lastTime = glfw.GetTime();
	double speed = 2f;

	auto fps = TimeAccumulator();

	// Compute time difference between current and last frame
	//while(!window.Closed)
	//{
	//	double currentTime = glfw.GetTime();
	//	double deltaTime = double(currentTime - lastTime);
	//	scope(exit)lastTime = currentTime;

	//	fps.addTime(deltaTime);
	//	if(fps.trackedWindow() > 1f)
	//	{
	//		//writefln("fps: %s", fps.averageRate);
	//		fps.reset;
	//	}

	//	systems.Update(deltaTime);

	//}

	return 0;
}
