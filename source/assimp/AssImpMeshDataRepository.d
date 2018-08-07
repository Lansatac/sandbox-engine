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

	this()
	{
		version(Windows)
		{
			DerelictASSIMP3.load("libs/assimp.dll");
		}
		else
		{
			DerelictASSIMP3.load();
		}
	}

	MeshData Load(string path)
	{
		import std.string;

		auto scene = aiImportFile( path.toStringz, aiProcess_GenSmoothNormals | aiProcess_GenUVCoords );
		auto id = nextID++;

		//Convert to engine representation
		scenes[id] = conv(*scene);

		aiReleaseImport(scene);
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

