module components.registry;

import std.container;
import std.algorithm;

import scene.scene;
import scene.gameObject;
import components;

@safe
class Registry(TComponent...)
{
	this()
	{
	}

	static foreach(ComponentType; TComponent)
	{
		mixin(
			ComponentType.stringof ~ " add(objectID objID, " ~ ComponentType.stringof ~ " component)" ~
			"{" ~
				ComponentType.stringof ~ "registry[objID] = component;" ~
				"return component;" ~
			"}"
		);
	}

	static foreach(ComponentType; TComponent)
	{
		mixin(
			ComponentType.stringof ~ " get" ~ ComponentType.stringof ~ "(objectID objID)" ~
			"{" ~
				"return " ~ ComponentType.stringof ~ "registry[objID];" ~
			"}"
		);
	}

	static foreach(ComponentType; TComponent)
	{
		mixin(
			ComponentType.stringof ~ "[] getAll" ~ ComponentType.stringof ~ "(objectID objID)\n" ~
			"{" ~
				"import std.range;" ~
				"return " ~ ComponentType.stringof ~ "registry.byValue().array;" ~
			"}"
		);
	}

private:

	static foreach(ComponentType; TComponent)
	{
		mixin(ComponentType.stringof ~ "[objectID] " ~ ComponentType.stringof ~ "registry;");
	}
}