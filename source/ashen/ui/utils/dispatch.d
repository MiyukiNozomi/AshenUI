module ashen.ui.utils.dispatch;

import ashen.ui : HResult;
import std.format : format;

public struct AshenError {
	string source;
	string msg;
}

private AshenError[] errors;
private bool hadErrors = true;

/**
	Internal Usage Only!
	DO NOT CALL THIS FUNCTION!
	unless you're modifying the library itself.
	but never, never call this from within your program that is
	using this library
*/
public HResult ashenInternal_DispatchError(HResult, string, Char, Args...)
		  (HResult code, string file,
		  in Char[] fmt, Args args)  {
	auto msg = format(fmt, args);
	errors ~= AshenError(file, format("HRESULT %s, %s", code,msg));
	hadErrors = true;
	return code;
}

public bool ashenHadError() {
	return hadErrors;
}

public AshenError* ashenGetErrors(out size_t count) {
	count = errors.length;
	return errors.ptr;
}


import bindbc.opengl;

public void ashenInternal_CheckGLErrors() {
	GLuint err = glGetError();
	
	if (err == GL_NO_ERROR) 
		return;

	// can we have pattern matching in D?

	string msg = "";
	switch(err) {
		case GL_INVALID_VALUE:     msg = "Invalid Value!"; break;
		case GL_INVALID_OPERATION: msg = "Invalid Operation!"; break;
		case GL_INVALID_FRAMEBUFFER_OPERATION: msg = "Invalid FrameBuffer Operation!"; break;
		case GL_OUT_OF_MEMORY: msg = "wtf Out of memory? that probably isn't a problem with"~
				"the API but rather with your project."; break;
		default: msg = "Invalid Enum!"; break;
	}

	throw new AshenPoorImplementationException("GL Error: " ~ msg);
}

/*

        Personally i'm not a big fan of Exceptions,
    however, this exception won't really be thrown unless
    i broke something. (aka if an error happens in an
    internal usage only function).

        As you can except, this is to stop everything.
*/

class AshenPoorImplementationException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__,
            Throwable nextInChain = null) pure nothrow @nogc @safe {
        super(msg, file, line, nextInChain);
    }
}