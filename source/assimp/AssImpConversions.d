module assimp.AssImpConversions;

import derelict.assimp3.assimp;
import gl3n.linalg;

import resources.mesh.Mesh;

import std.algorithm;
import std.range;

const (T[]) toArray(T)(const T* ptr, uint length) pure nothrow
{
	return ptr == null ? [] : ptr[0..length];
}

string conv(const aiString impString) pure nothrow
{
	return impString.data[0..impString.length].idup;
}

immutable(vec3[]) conv(const aiVector3D* ptr, uint length) pure nothrow
{
	return ptr.toArray(length).map!conv.array;
}

immutable(vec3) conv(const aiVector3D vector) pure nothrow
{
	return vec3(vector.x,vector.y,vector.z);
}

immutable(Scene) conv(const aiScene scene) pure
{
	return new immutable Scene(scene.mMeshes.conv(scene.mNumMeshes));
}

immutable (Mesh[]) conv(const aiMesh** ptr, const uint length) pure
{
	return ptr.toArray(length).map!(mesh=>conv(*mesh)).array;
}

immutable (Mesh) conv(const aiMesh mesh) pure
{
	with(mesh)
	{
		return Mesh(
			mName.conv,
			conv(mVertices, mNumVertices),
			conv(mNormals, mNumVertices),
			conv(mTangents, mNumVertices),
			conv(mBitangents, mNumVertices),
			mFaces.conv(mNumFaces),
			mColors.conv(mNumVertices),
			conv(mTextureCoords, mNumVertices, mNumUVComponents),
			mBones.conv(mNumBones),
			mMaterialIndex
		    );
	}
}

immutable (Face[]) conv(const aiFace* ptr, const uint length) pure nothrow
{
	return ptr.toArray(length).map!conv.array;
}

immutable (Face) conv(const aiFace face) pure nothrow
{
	return Face(face.mIndices.toArray(face.mNumIndices).idup);
}

immutable (Color[][]) conv(const aiColor4D*[] ptrArray, const uint length) pure nothrow
{
	immutable (Color[])[] colors;
	foreach(colorArray; ptrArray)
	{
		colors ~= colorArray.conv(length);
	}
	return colors.idup;
}

immutable (Color[]) conv(const aiColor4D* ptr, const uint length) pure nothrow
{
	return ptr.toArray(length).map!conv.array;
}

immutable (Color) conv(aiColor4D color) pure nothrow @nogc
{
	return Color(color.r, color.g, color.b, color.a);
}

TexCoordSet[] conv(const aiVector3D*[] ptrArray, const uint length, const uint[] numComponents) pure
{
	auto uvs = ptrArray.map!(set=>set.toArray(length));

	return zip(uvs, numComponents)
			.map!((set)=>conv(set[0], set[1]))
			.array;
}

TexCoordSet conv(const aiVector3D[] uvSet, uint componentCount) pure nothrow
{
	return TexCoordSet(uvSet.map!(conv).array, cast(TexCoordSet.ComponentsUsed)componentCount);
}

immutable (Bone[]) conv(const aiBone** impBones, uint boneCount) pure nothrow
{
	return impBones.toArray(boneCount).map!(bone=>conv(*bone)).array;
}

immutable (Bone) conv(const aiBone impBone) pure nothrow
{
	return Bone(impBone.mName.conv, impBone.mWeights.toArray(impBone.mNumWeights).conv);
}

immutable(VertexWeight[]) conv(const aiVertexWeight[] impWeights) pure nothrow
{
	return impWeights.map!(conv).array;
}

immutable(VertexWeight) conv(const aiVertexWeight impWeight) pure nothrow @nogc
{
	return VertexWeight(impWeight.mVertexId, impWeight.mWeight);
}

immutable(mat4) conv(aiMatrix4x4 impMatrix) pure nothrow @nogc
{
	return mat4(
		impMatrix.a1, impMatrix.a2, impMatrix.a3, impMatrix.a4,
		impMatrix.b1, impMatrix.b2, impMatrix.b3, impMatrix.b4,
		impMatrix.c1, impMatrix.c2, impMatrix.c3, impMatrix.c4,
		impMatrix.d1, impMatrix.d2, impMatrix.d3, impMatrix.d4,
		);
}