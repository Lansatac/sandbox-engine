module render.opengl.OpenGLRenderSystem;

import std.experimental.logger;
import std.range;

import gl3n.linalg;
import gl3n.math;
import derelict.opengl3.gl3;
import glfw.GlfwContext;

import derelict.glfw3;

import glfw.GlfwWindow;

import scene.scene;
import scene.gameObject;

import system.System;

import components.component;
import components.registry;
import components.camera;
import components.transform;
import components.meshRenderer;

import render.opengl.OpenGLMeshRepository;
import render.opengl.Mesh;

@safe
class OpenGLRenderSystem(TRegistry) : Updating
{
	TRegistry registry;
	OpenGLMeshRepository repository;
	GlfwWindow window;

	this(TRegistry registry, OpenGLMeshRepository repository, GlfwWindow window)
	{
		this.registry = registry;
		this.repository = repository;
		this.window = window;
	}

	void Update(float deltaTime)
	{
		auto cameras = registry.getComponentsOfType!Camera;
		renderFrame(cameras);
	}

	mat4 viewMatrix(Transform transform)
	{
		return mat4.look_at(transform.position, transform.position + transform.forward, transform.up);
	}

	@trusted
	private void renderFrame(TCameraRange)(TCameraRange cameras)
	{

	    glfwMakeContextCurrent(window.windowHandle);
		glClearColor(0.2,0.4,0.4,1);

		foreach(camera; cameras)
		{
			renderCamera(camera);
		}

		glfwSwapBuffers(window.windowHandle);
	}

	@trusted
	private void renderCamera(Camera camera)
	{
		import derelict.glfw3.glfw3;

		auto cameraTransform = registry.getComponent!Transform(camera.ObjectID);

		double time = glfwGetTime();
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		mat4 Projection = mat4.perspective(
			window.width, window.height,
			camera.fov, camera.nearClip, camera.farClip
			);


		mat4 View = viewMatrix(cameraTransform);

		mat4 vp = Projection * View;

		auto renderers = registry.getComponentsOfType!(MeshRenderer);

		foreach(renderer; renderers)
		{
			auto glMesh = repository.GetMesh(renderer.Mesh);
			glEnable(GL_DEPTH_TEST);
			glDepthFunc(GL_LESS);

			auto transform = registry.getComponent!Transform(renderer.ObjectID);
			//// Model matrix : an identity matrix (model will be at the origin)
			mat4 Model = mat4.identity
			.scale(transform.scale.x, transform.scale.y, transform.scale.z)
			.rotate(transform.rotation.w, vec3(transform.rotation.x, transform.rotation.y, transform.rotation.z))
			.translate(transform.position)
			;

			//// Our ModelViewProjection : multiplication of our 3 matrices
			mat4 mvp = vp * Model;
			mvp.transpose;

			foreach(
				mesh, normals, colors, shader, faceCount;
			 	zip(glMesh.vertexbuffers, glMesh.normalbuffers, glMesh.colorbuffers, renderer.shaders.chain(renderer.shaders.back.repeat), glMesh.triangleCounts))
			{

				glUseProgram(shader);
				GLuint MatrixID = glGetUniformLocation(shader, "MVP");
			  	glUniformMatrix4fv(MatrixID, 1, GL_FALSE, mvp.value_ptr);
				MatrixID = glGetUniformLocation(shader, "M");
			  	glUniformMatrix4fv(MatrixID, 1, GL_FALSE, Model.value_ptr);
				MatrixID = glGetUniformLocation(shader, "V");
			  	glUniformMatrix4fv(MatrixID, 1, GL_FALSE, View.value_ptr);

			  	GLuint vectorID = glGetUniformLocation(shader, "LightPosition_worldspace");
			  	glUniform3f(vectorID, sin(time) * 10,20,10);

				glEnableVertexAttribArray(0);
				glCullFace(GL_BACK);
				glEnable(GL_CULL_FACE);
				glBindBuffer(GL_ARRAY_BUFFER, mesh);

				glVertexAttribPointer(
				   0,                  // attribute 0. No particular reason for 0, but must match the layout in the shader.
				   3,                  // size
				   GL_FLOAT,           // type
				   GL_FALSE,           // normalized?
				   0,                  // stride
				   cast(void*)0        // array buffer offset
				);
				glEnableVertexAttribArray(1);
				glBindBuffer(GL_ARRAY_BUFFER, colors);
				glVertexAttribPointer(
				    1,                                // attribute. No particular reason for 1, but must match the layout in the shader.
				    4,                                // size
				    GL_FLOAT,                         // type
				    GL_FALSE,                         // normalized?
				    0,                                // stride
				    cast(void*)0                          // array buffer offset
				);
				glEnableVertexAttribArray(2);
				glBindBuffer(GL_ARRAY_BUFFER, normals);
				glVertexAttribPointer(
					2,                                // attribute
					3,                                // size
					GL_FLOAT,                         // type
					GL_FALSE,                         // normalized?
					0,                                // stride
					cast(void*)0                          // array buffer offset
				);

				// Draw the triangle !
				glDrawArrays(GL_TRIANGLES, 0, faceCount); // Starting from vertex 0; 3 vertices total -> 1 triangle
				glDisableVertexAttribArray(0);
			}
		}
	}
}