module window.window;

import scene.scene;

@safe
interface Window
{
	int width();
	int height();

	bool Closed();

	void Resize(int newWidth, int newHeight) nothrow;

	void RenderFrame(Scene scene);
}