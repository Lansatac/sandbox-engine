module components.updatingComponent;

import components.component;
import scene.scene;
import scene.gameObject;

@safe
class UpdatingComponent : Component
{
	void updateComponent(double deltaTime)
	{
		update(deltaTime);
	}

protected:
	this(Scene scene, objectID objID)
	{
		super(scene, objID);
	}

	abstract void update(double deltaTime);
}