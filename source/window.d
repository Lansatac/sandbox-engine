module window;

interface Window
{
	int width();
	int height();

	void Resize(int newWidth, int newHeight) nothrow;
}