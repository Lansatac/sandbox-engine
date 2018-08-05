module render.opengl.OpenGLMeshRepository;

import derelict.opengl3.gl3;
import derelict.assimp3.types;

import gl3n.linalg;

import resources.MeshRepository;
import resources.Mesh;

import render.opengl.Mesh;;

alias MeshInstance = MeshRepository.MeshInstance;
alias MeshData = MeshRepository.MeshData;

@trusted
class OpenGLMeshRepository : MeshRepository.Instances
{
	this(MeshRepository.Data dataRepository)
	{
		this.dataRepository = dataRepository;
	}

	MeshInstance AquireInstance(MeshData data)
	{
		auto scene = dataRepository.GetData(data);
		GLuint[] VertexArrayIDs;
		
		int numMeshes = cast(int)scene.Meshes.length;
		GLuint[] vertexbuffers;
		GLuint[] colorbuffers;
		GLuint[] normalbuffers;
		GLuint[] uvbuffers;
		uint[] triangleCounts;
		VertexArrayIDs.length = numMeshes;
		triangleCounts.length = numMeshes;
		vertexbuffers.length = numMeshes;
 		colorbuffers.length = numMeshes;
		normalbuffers.length = numMeshes;
		uvbuffers.length = numMeshes;
		
		glGenVertexArrays(numMeshes, VertexArrayIDs.ptr);

		// Generate 1 buffer, put the resulting identifier in vertexbuffer
		glGenBuffers(numMeshes, vertexbuffers.ptr);
		glGenBuffers(numMeshes, colorbuffers.ptr);
 		glGenBuffers(numMeshes, normalbuffers.ptr);
 		glGenBuffers(numMeshes, uvbuffers.ptr);

		for(int i = 0; i < vertexbuffers.length; ++i)
		{
			import std.algorithm;
			import std.range;

			glBindVertexArray(VertexArrayIDs[i]);
			auto mesh = scene.Meshes[i];

			glBindBuffer(GL_ARRAY_BUFFER, vertexbuffers[i]);
			glBufferData(GL_ARRAY_BUFFER, mesh.Vertices.length * vec3.sizeof, cast(void*)mesh.Vertices, GL_STATIC_DRAW);

			glBindBuffer(GL_ARRAY_BUFFER, uvbuffers[i]);
			auto texCoords = mesh.TextureCoords.map!(x=>x.UVs).array;
			glBufferData(GL_ARRAY_BUFFER, texCoords.length * vec3.sizeof, cast(void*)texCoords, GL_STATIC_DRAW);

			glBindBuffer(GL_ARRAY_BUFFER, normalbuffers[i]);
			glBufferData(GL_ARRAY_BUFFER, mesh.Normals.length * vec3.sizeof, cast(void*)mesh.Normals, GL_STATIC_DRAW);

			glBindBuffer(GL_ARRAY_BUFFER, colorbuffers[i]);
			if(mesh.Colors.length > 0)
			{
				glBufferData(GL_ARRAY_BUFFER, mesh.Colors.length * Color.sizeof, cast(void*)mesh.Colors, GL_STATIC_DRAW);
			}
			else
			{
				float[] white = array(repeat(1f).take(mesh.Vertices.length * 4));
				glBufferData(GL_ARRAY_BUFFER, white.length * float.sizeof, cast(void*)white, GL_STATIC_DRAW);
			}

			triangleCounts[i] = cast(uint)mesh.Faces.length * 3;
		}
		auto instanceID = next++;
		meshMap[instanceID] = new GLMesh(vertexbuffers.idup, colorbuffers.idup, normalbuffers.idup, uvbuffers.idup, triangleCounts.idup);
		return instanceID;
	}

	void ReleaseInstance(MeshData data)
	{
		//meshMap.remove(data);
	}

	GLMesh GetMesh(MeshInstance mesh)
	{
		return meshMap[mesh];
	}

	private:
		const MeshRepository.Data dataRepository;

		GLMesh[MeshInstance] meshMap;
		//MeshInstance[MeshData] instanceMap
		MeshInstance next = cast(MeshInstance)1;
}
