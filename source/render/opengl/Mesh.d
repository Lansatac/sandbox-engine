module render.opengl.Mesh;

import derelict.opengl3.types;

class GLMesh
{
	this(
		immutable GLuint[] vertexbuffers,
		immutable GLuint[] colorbuffers,
		immutable GLuint[] normalbuffers,
		immutable GLuint[] uvbuffers,
		immutable uint[] triangleCounts)
	{
		this.vertexbuffers = vertexbuffers;
		this.colorbuffers = colorbuffers;
		this.normalbuffers = normalbuffers;
		this.uvbuffers = uvbuffers;
		this.triangleCounts = triangleCounts;
	}
	immutable GLuint[] vertexbuffers;
	immutable GLuint[] colorbuffers;
	immutable GLuint[] normalbuffers;
	immutable GLuint[] uvbuffers;

	immutable uint[] triangleCounts;
}

