module scene.scene;

import std.container;
import std.algorithm;
import std.range;
import std.string;
import std.experimental.logger;

import components.registry;
import scene.gameObject;

@safe
class Scene(TComponents...)
{
	alias registry this;

	@trusted
	this()
	{
		objects = make!(Array!objectID)();
		_registry = new Registry!(TComponents)();
	}

	@property Registry!(TComponents) registry()
	{
		return _registry;
	}

	@trusted
	objectID createObject()
	{
		auto newObject = nextID++;
		objects.insertBack(newObject);
		return newObject;
	}

	//@trusted
	//objectID createObject(C...)()
	//{
	//	auto newObject = nextID++;
	//	objects.insertBack(newObject);
	//	foreach(t; C)
	//	{
	//		_registry.addComponent!(t)(newObject);
	//	}
	//	return newObject;
	//}

private:
	Array!objectID objects;
	Registry!(TComponents) _registry;
	objectID nextID;
}