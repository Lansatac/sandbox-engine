module assimp.AssImpMeshDataRepository;

import assimp.AssImpConversions;

import resources.mesh.Mesh;
import resources.mesh.MeshRepository;

alias MeshData = MeshRepository.MeshData;

@trusted
class AssImpMeshDataRepository : MeshRepository.Data
{
	import gl3n.linalg;
	import derelict.assimp3.assimp;
	
	import std.typecons;

	aiPropertyStore* importProperties;

	this()
	{
		import std.string;

		version(Windows)
		{
			DerelictASSIMP3.load("libs/assimp.dll");
		}
		else
		{
			DerelictASSIMP3.load();
		}
		importProperties = aiCreatePropertyStore();
		aiSetImportPropertyInteger(importProperties, AI_CONFIG_PP_FD_REMOVE.toStringz, 1);
	}

	~this()
	{
		aiReleasePropertyStore(importProperties);
	}

	MeshData Load(string path)
	{
		import std.parallelism : task, taskPool;

		auto id = nextID++;

		scenes[id] = new immutable Scene(new immutable (Mesh)[0]);

		alias loadMesh = function (Rebindable!(immutable Scene)[MeshData] scenes, aiPropertyStore* importProperties, string path, ulong id)
		{
			import std.string;
			import std.file;
			import std.path : extension;
		
			auto fileData = read(path);

			auto importFlags = aiProcess_Triangulate
				| aiProcess_SortByPType | aiProcess_JoinIdenticalVertices
				| aiProcess_GenNormals | aiProcess_GenSmoothNormals
				| aiProcess_GenUVCoords
				| aiProcess_SplitLargeMeshes
				| aiProcess_PreTransformVertices
				| aiProcess_FindDegenerates;

			auto scene = aiImportFileFromMemoryWithProperties( fileData.ptr,
																fileData.length,
																importFlags,
																path.extension.toStringz,
																importProperties
																);

			//Convert to engine representation
			scenes[id] = conv(*scene);
		
			aiReleaseImport(scene);
		};

		auto loadingTask = task!loadMesh(scenes, importProperties, path, id);
		taskPool.put(loadingTask);
		return id;
	}

	void Unload(MeshData data)
	in
	{
		assert((data in scenes) != null);
	}
	body
	{
		scenes.remove(data);
	}

	immutable(Scene) GetData(MeshData data) const
	{
		return scenes[data];
	}

private:
	MeshData nextID = cast(MeshData)1;

	Rebindable!(immutable Scene)[MeshData] scenes;

}

