module system.System;

import components.registry;

@safe
interface Initializing
{
	void Initialize();
	void Deinitialize();
}

@safe
interface Updating
{
	void Update(float deltaTime);
}

@safe
interface HandlesComponentCreation(TComponent) : Updating
{
	void HandleCreated(TComponent[] created)
	{

	}
}

@safe
interface HandlesComponentModifications(TComponent)
{
	void HandleModified(TComponent[] modified)
	{
		
	}
}