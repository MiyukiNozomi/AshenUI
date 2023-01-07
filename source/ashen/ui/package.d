module ashen.ui;

import bindbc.glfw;
import bindbc.opengl;

public import ashen.ui.img;
public import ashen.ui.gfx.color;
public import ashen.ui.utils.dispatch;

import ashen.ui.gfx.shaders;
import ashen.ui.gfx.rectshader;

// "binding" string
alias bstring = const(char)*;

package AshenWindow createdWindow;

auto GetWidth() {return createdWindow.width;}
auto GetHeight() {return createdWindow.height;}

class AshenWindow {
	package:
		GLFWwindow* window;
		int width;
		int height;

		AshenColorRectShader colorRectShader;

	public:
        void setIcon(AshenImage icon) {
            GLFWimage[1] images;
    
            images[0].width = icon.width;
            images[0].height = icon.height;

            images[0].pixels = cast(ubyte*) icon.data;

            glfwSetWindowIcon(window, 1, images.ptr);
        }

		void defineInterval(int interval) {
			glfwSwapInterval(interval);
		}

		void useVSync(bool b) {
			glfwSwapInterval(b ? 1 : 0);
		}

		bool isVisible() {
			return !glfwWindowShouldClose(window);
		}

		void prepare(AshenColor* color) {
			glClear(GL_COLOR_BUFFER_BIT);
			glClearColor(color.r, color.g, color.b, color.a);

			glfwPollEvents();
		}

		void swapBuffers() {
			glfwSwapBuffers(window);
		}
}

HResult ashenInit(bstring title, int width, int height, out AshenWindow window) {
	GLFWSupport glfwRet = loadGLFW();
	if (glfwRet != glfwSupport) {
		if (glfwRet == GLFWSupport.badLibrary) {
			return HResult.BadLibraryLoad;
		} else if (GLFWSupport.noLibrary) {
			return HResult.MissingLibrary;
		}
		// should never fall in here
		return HResult.LibInitFailure;
	}

	if (!glfwInit())
		return HResult.LibInitFailure;
	return ashenCreateWindow(title, width, height, window);
}

private HResult ashenCreateWindow(bstring title, int width, int height, out AshenWindow window) {
	AshenWindow aw = new AshenWindow();
	
	aw.window = glfwCreateWindow(width, height, title, null, null);
	if (!aw.window)
		return HResult.ObjCreationFailure;

	glfwMakeContextCurrent(aw.window);

	GLSupport glRet = loadOpenGL();

	glfwAshenWindowCallback(null, width, height);
	glfwSetFramebufferSizeCallback(aw.window, &glfwAshenWindowCallback);

	if (glRet <  GLSupport.gl33) {
		return HResult.OkayWarnings;
	}

	aw.colorRectShader = new AshenColorRectShader();

	window = aw;

	return HResult.Okay;
}

void ashenTerminate() {
	glfwTerminate();
}

enum HResult {
	BadLibraryLoad,
	MissingLibrary,
	
	OutOfMemory,

	LibInitFailure,

	ObjCreationFailure,
	
	ShaderCompileFailure,
	ShaderProgramCreationFailure,
	
	ExceptionCatched,
	
	FileNotFound,
	InvalidFormat,
	UnsupportedBitsPerPixel,
	
	Errors,

	OkayWarnings,
	Okay
}

auto Succeeded(HResult res) {return res == HResult.Okay || res == HResult.OkayWarnings;}

HResult CheckGLErrors() {
	GLenum err = glGetError();
	
	if (err == GL_NO_ERROR)
		return HResult.Okay;
	
	//TODO : Implement DispatchError and TransmitError functions
	switch(err) {
		default: break;
	}
	return HResult.Errors;
}

extern(C)
void glfwAshenWindowCallback(GLFWwindow* wnd, int w, int h) nothrow {
	if (createdWindow !is null) {
		createdWindow.width = w;
		createdWindow.height = h;
	}
	glViewport(0, 0, w, h);
}

