module scene.scene;

import std.container;
import std.algorithm;
import std.range;
import std.string;
import std.experimental.logger;

import derelict.glfw3.glfw3;

import components.registry;
import components.camera;
import components.cameraControl;
import window;
import scene.gameObject;

class Scene
{
	alias registry this;

	this(Window window)
	{
		objects = make!(Array!objectID)();
		_registry = new Registry(this);
	}

	@property Registry registry()
	{
		return _registry;
	}
	objectID createObject()
	{
		auto newObject = nextID++;
		objects.insertBack(newObject);
		return newObject;
	}

	objectID createObject(C...)()
	{
		auto newObject = nextID++;
		objects.insertBack(newObject);
		foreach(t; C)
		{
			_registry.createComponent!(t)(newObject);
		}
		return newObject;
	}

	void update()
	{
		double current = glfwGetTime();
		double delta = current - lastTime;
		lastTime = current;

		auto toUpdate = _registry.getComponentsOfType!CameraControl();
		foreach(updatee; toUpdate)
		{
			try
			{
				updatee.updateComponent(lastTime);
			}
			catch(Exception e)
			{
				error(format("Exception in update:\n%s", e));
			}
		}
	}

	void render(Window window)
	{
		update();

		auto cameras = _registry.getComponentsOfType!Camera().array;
		//cameras.sort();
		foreach(camera; cameras)
		{
			camera.render(window);
		}
	}

private:
	Array!objectID objects;
	Registry _registry;
	objectID nextID;

	double lastTime;
}