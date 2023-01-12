module ashen.ui;

import bindbc.glfw;
import bindbc.opengl;

public import ashen.ui.img;
public import ashen.ui.gfx.color;
public import ashen.ui.gfx.renderer;
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
		bool sizeUpdated;

	public:
	// Window Controls
		int getWidth() {return width;}
		int getHeight() {return height;}
        void setIcon(AshenImage icon) {
			if (icon.format == AshenFormat.Invalid) {
				ashenInternal_DispatchError(HResult.InvalidParameter, "ashen/ui","Invalid Image Format.");
				return;
			}
            GLFWimage[1] images;
    
            images[0].width = icon.width;
            images[0].height = icon.height;

            images[0].pixels = cast(ubyte*) icon.data;

            glfwSetWindowIcon(window, 1, images.ptr);
        }

		void defineInterval(int interval) {
			if (interval > 3 || interval < 0) {
				ashenInternal_DispatchError(HResult.InvalidParameter, "ashen/ui", "interval should be between 0 and 3.");
				return;
			}
			glfwSwapInterval(interval);
		}

		void useVSync(bool b) {
			glfwSwapInterval(b ? 1 : 0);
		}

		bool isVisible() {
			return !glfwWindowShouldClose(window);
		}

		void prepare(AshenColor* color) {
			ashenInternal_CheckGLErrors();
			glClear(GL_COLOR_BUFFER_BIT);
			glClearColor(color.r, color.g, color.b, color.a);

			glfwPollEvents();
		}

		void swapBuffers() {
			glfwSwapBuffers(window);
		}
	// end Window Controls
}

/**
	Initializes the Libraries used by AshenUI and creates a window.
*/
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

/**
	Creates a window, duh
*/
private HResult ashenCreateWindow(bstring title, int width, int height, out AshenWindow window) {
	AshenWindow aw = new AshenWindow();
	
	glfwWindowHint(GLFW_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_VERSION_MINOR, 3);

	aw.window = glfwCreateWindow(width, height, title, null, null);
	aw.width  = width;
	aw.height = height;
	aw.sizeUpdated = true;
	if (!aw.window)
		return ashenInternal_DispatchError(HResult.ObjCreationFailure, "ashen/ui", "Unable to create window.");

	glfwMakeContextCurrent(aw.window);

	GLSupport glRet = loadOpenGL();

	glfwAshenWindowCallback(null, width, height);
	glfwSetFramebufferSizeCallback(aw.window, &glfwAshenWindowCallback);

	if (glRet <  GLSupport.gl33) {
		return HResult.OkayWarnings;
	}

	ashenInternal_InitRenderer();

	window = aw;
	createdWindow = aw;

	return HResult.Okay;
}

/**
	Releases Objects allocated by the library.
*/
void ashenTerminate() {
	ashenInternal_ReleaseRenderer();

	glfwDestroyWindow(createdWindow.window);
	glfwTerminate();
}

/**
	I tried to mimic Win32's HRESULT thing, 
	only used for stuff that may break everything if fail or
	when dealing with communication with the operating system.
*/
enum HResult {
	InvalidFormat,
	ExceptionCatched,

	BadLibraryLoad,
	MissingLibrary,
	LibInitFailure,

	InvalidParameter,

	ObjCreationFailure,

	OkayWarnings,
	Okay
}

auto Succeeded(HResult res) {return res == HResult.Okay || res == HResult.OkayWarnings;}

//// GLFW events area

extern(C)
void glfwAshenWindowCallback(GLFWwindow* wnd, int w, int h) nothrow {
	if (createdWindow !is null) {
		createdWindow.width = w;
		createdWindow.height = h;
		createdWindow.sizeUpdated = true;
	}
	glViewport(0, 0, w, h);
}

