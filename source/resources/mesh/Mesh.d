module resources.mesh.Mesh;

align(1) struct Color
{
    immutable float r, g, b, a;
}

struct Face
{
    immutable uint[] Indicies;
}

struct VertexWeight
{
    immutable uint VertexId;
    immutable float Weight;
}

struct Bone
{
    import gl3n.linalg;

    immutable string Name;
    immutable VertexWeight[] Weights;
    immutable mat4 OffsetMatrix;
}

//class Node {
//    string Name;
//    mat4 Transformation;
//    Node Parent;
//    Node[] Children;
//    uint[] Meshes;
//}

align(1) struct Texel {
    ubyte b, g, r, a;
}

struct Texture {
    uint Width;
    uint Height;
    Texel[] Texels;
}

struct TexCoordSet
{
    import gl3n.linalg;

    enum ComponentsUsed
    {
        One = 1,
        Two,
        Three
    }

    immutable vec3[] UVs;
    immutable ComponentsUsed Components;
}

class Scene
{
	this(immutable Mesh[] Meshes) immutable pure
	{
		this.Meshes = Meshes;
	}
    immutable Mesh[] Meshes;

    //Node RootNode;
    //Material[] Materials;
    //Animation[] Animations;
    Texture[] Textures;
    //Light[] Lights;
    //Camera[] Cameras;
}

struct Mesh
{
    import gl3n.linalg;
    
    immutable string Name;

    immutable vec3[] Vertices;
    immutable vec3[] Normals;
    immutable vec3[] Tangents;
    immutable vec3[] Bitangents;
    immutable Face[] Faces;

    immutable Color[][] Colors;

    immutable TexCoordSet[] TextureCoords;
    immutable Bone[] Bones;

    immutable uint MaterialIndex;
}