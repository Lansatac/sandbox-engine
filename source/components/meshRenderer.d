module components.meshRenderer;

import std.range;
import std.array;
import std.experimental.logger;

import derelict.opengl3.gl3;

import scene.scene;
import scene.gameObject;
import components.component;
import shader;
import resources.mesh.MeshRepository;

@safe
class MeshRenderer : Component
{
	this(Scene scene, objectID objID)
	{
		super(scene, objID);
	}

	@property MeshRepository.MeshInstance Mesh()
	{
		return mesh;
	}
	@property void Mesh(MeshRepository.MeshInstance mesh)
	{
		this.mesh = mesh;
	}

	@property GLuint[] shaders()
	{
		return programIDs;
	}


	void loadMaterial(string vertexPath, string fragmentPath)
	{
		programIDs = [LoadShader( vertexPath, fragmentPath )];
	}


private:
	MeshRepository.MeshInstance mesh;
	GLuint[] programIDs;
}