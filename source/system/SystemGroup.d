module system.SystemGroup;

import system.System;

@safe
final class SystemGroup : Initializing, Updating
{
	Initializing[] intitializingSystems;
	Updating[] updatingSystems;

	SystemGroup Add(TSystem)(TSystem system)
	{
		import std.traits;

		static if(isAssignable!(Initializing, TSystem))
		{
			intitializingSystems ~= system;
		}
		static if(isAssignable!(Updating, TSystem))
		{
			updatingSystems ~= system;
		}

		return this;
	}

	void Initialize()
	{
		foreach(system; intitializingSystems)
		{
			system.Initialize();
		}
	}

	void Deinitialize()
	{
		foreach(system; intitializingSystems)
		{
			system.Deinitialize();
		}
	}


	void Update(float deltaTime)
	{
		foreach(system; updatingSystems)
		{
			system.Update(deltaTime);
		}
	}
}