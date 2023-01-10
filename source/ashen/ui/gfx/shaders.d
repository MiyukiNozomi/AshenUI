module ashen.ui.gfx.shaders;

/**
		This module is for internal usage only.
	Please refer to only using the functions exported by
	the ashen.ui module;
	Also, you should not use functions that have "ashenInternal"
	as a prefix. unless you're modifying the library.
*/

import bindbc.opengl;

import core.memory:GC;
import core.stdc.string : strlen;

import ashen.ui.gfx.color;
import ashen.ui.utils.dispatch;
import ashen.ui : HResult, bstring, Succeeded;

public abstract class AshenShader {
	private:
		GLuint vertex, fragment, program;
		GLint[bstring] uniforms;

	public:
		this(bstring vS, bstring fS, bstring[] uniforms) {
			this.vertex = ashenInternal_CreateShader(GL_VERTEX_SHADER, vS);
			this.fragment = ashenInternal_CreateShader(GL_FRAGMENT_SHADER, fS);
			this.program = glCreateProgram();

			glAttachShader(this.program, this.vertex);
			glAttachShader(this.program, this.fragment);
			glLinkProgram(this.program);
			glValidateProgram(this.program);

			GLint param;
			glGetProgramiv(this.program, GL_LINK_STATUS, &param);
			if (param != GL_TRUE) {
				char[1024] infoLog;

				// why does OpenGL even return this in this function???
				GLsizei lengthUseless;
				glGetProgramInfoLog(this.program, 1024, &lengthUseless, infoLog.ptr);
				import std.format : format;
				throw new AshenPoorImplementationException(format("Incapable of Linking Program: %s", infoLog));
			}

			foreach (bstring s ; uniforms) {
				this.uniforms[s] = glGetUniformLocation(this.program, s);

				if (this.uniforms[s] == -1) {
					import std.format : format;
					throw new AshenPoorImplementationException(format("Uniform not found: %s", s));
				}
			}
		}

		void SetColor(bstring uniform, AshenColor* color) {
			if ((uniform in uniforms) is null) {
				throw new AshenPoorImplementationException("Unknown uniform");
			}
			glUniform4f(uniforms[uniform], color.r, color.g, color.b, color.a);
		}

		void Bind()   {glUseProgram(program);}
		void Unbind() {glUseProgram(0);}

		void Release() {
			glDeleteShader(vertex);
			glDeleteShader(fragment);
			glDeleteProgram(program);
		}
}

public GLuint ashenInternal_CreateShader(GLenum type, bstring src) {
	GLuint shader = glCreateShader(type);

	glShaderSource(shader, 1, &src, null);
	glCompileShader(shader);
	ashenInternal_CheckGLErrors();

	GLint param;
	glGetShaderiv(shader, GL_COMPILE_STATUS, &param);

	if (param != GL_TRUE) {
		char[1024] infoLog;

		// why does OpenGL even return this in this function???
		GLsizei lengthUseless;
		glGetShaderInfoLog(shader, 1024, &lengthUseless, infoLog.ptr);
		import std.format : format;
		throw new AshenPoorImplementationException(format("Incapable of Compiling Shader: %s", infoLog));
	}
	return shader;
}