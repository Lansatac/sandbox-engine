
module resources.InstanceRepository;

template InstanceRepository(alias string Type, TData)
{
	private enum string InstanceIDName = Type ~ "Instance";
	private enum string DataIDName = Type ~ "Data";

	mixin("alias " ~ InstanceIDName ~ " = ulong;");
	mixin("alias " ~ DataIDName ~ " = ulong;");

	interface Instances
	{
		mixin(InstanceIDName ~ " AquireInstance(" ~ DataIDName ~ " data);");
		mixin("void ReleaseInstance(" ~ DataIDName ~ " data);");
	}


	interface Data
	{
		mixin(DataIDName ~ " Load(string path);");
		mixin("void Unload(" ~ DataIDName ~ " data);");

		mixin("immutable(TData) GetData(" ~ DataIDName ~ " data) const;");
	}
}