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
import render.opengl.OpenGLMeshRepository;

import timeAccumulator;
import window.window;
import shader;
import scene.scene;
import components.transform;
import components.cameraControl;
import components.camera;
import components.meshRenderer;

@safe
int main()
{
	

	GlfwContext glfw = new GlfwContext();
	OpenGLContext gl = new OpenGLContext(glfw);
	auto window = gl.CreateWindow(1024, 768, "Hi!", null);

    auto meshDataRepo = new AssImpMeshDataRepository();
    auto meshRepo = new OpenGLMeshRepository(meshDataRepo);


	Scene scene = new Scene(window);
	auto camera = scene.createObject!(Transform, Camera, CameraControl);
	auto gameObject = scene.createObject!(Transform, MeshRenderer);
	scene.getComponent!(MeshRenderer)(gameObject).Mesh = meshRepo.AquireInstance(meshDataRepo.Load("assets/dragon_recon/dragon_vrip_res4.ply"));
	scene.getComponent!(Camera)(camera).SetRepo(meshRepo);

	//scene.getComponent!(CameraControl)(camera).window = window.window;

	auto gameObjectMesh = scene.getComponent!(MeshRenderer)(gameObject);
	
	gameObjectMesh.loadMaterial("shaders/simpleLit.vshader", "shaders/simpleLit.fshader");

	auto gameObjectTransform = scene.getComponent!(Transform)(gameObject);
	gameObjectTransform.position = vec3(0f, -10f, -10f);
	gameObjectTransform.scale = vec3(200f, 200f, 200f);


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

		window.RenderFrame(scene);
	}

	return 0;
}
