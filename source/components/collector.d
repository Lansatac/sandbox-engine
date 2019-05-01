module components.collector;

class Collector(TComponent)
{
	public void Add(TComponent component)
	{
		set ~= component;
	}

	public TComponent[] Get()
	{
		return set;
	}

	public void Clear()
	{
		set.length = 0;
	}

	private TComponent[] set;
}