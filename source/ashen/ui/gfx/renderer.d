module ashen.ui.gfx.renderer;

import bindbc.opengl;

import ashen.ui;

import ashen.ui.gfx.color;
import ashen.ui.gfx.shaders;
import ashen.ui.gfx.rectshader;
import ashen.ui.utils.dispatch;

public:
/**
    Initializes the renderer
*/
void ashenInternal_InitRenderer() {
    rectangle = ashenMakeDrawable([
        -1, -1,
        -1,  1,
         1, -1,
         1, -1,
        -1,  1,
         1,  1
    ], 2, true);
    colorRectShader = new AshenColorRectShader();

    glEnable(GL_BLEND);
}

void ashenDrawRectangle(AshenColor* color) {
    colorRectShader.Bind();
    colorRectShader.SetColor("color", color);

    rectangle.bind();
    glDrawArrays(GL_TRIANGLES, 0, rectangle.vertexCount);
    rectangle.unbind();
    ashenInternal_CheckGLErrors();

    colorRectShader.Unbind();
}

private: 
AshenColorRectShader colorRectShader;
Drawable rectangle;

// VertexArray, wharever;
// declaration of a "Drawable Thing"
struct Drawable {
    GLuint vao;
    GLuint vbo;
    int vertexCount;

    void bind() {
        glBindVertexArray(vao);
    }

    void unbind() {
        glBindVertexArray(0);
    }

    void release() {
        glDeleteVertexArrays(1, &vao);
        glDeleteBuffers(1, &vbo);
    }
}

/**
    Sends some stuff to the GPU
*/
Drawable ashenMakeDrawable(float[] inputVertices, int dimensions, GLboolean normalized) {
    ashenInternal_CheckGLErrors();
    size_t verticesSize;
    void* verticesPtr = ashenToCArray!float(inputVertices, verticesSize);

    GLuint vao, vbo;
    int vertexCount = cast(int)inputVertices.length / dimensions;

    glGenVertexArrays(1, &vao);
    glBindVertexArray(vao);

    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);

    glBufferData(GL_ARRAY_BUFFER, verticesSize, verticesPtr, GL_STATIC_DRAW);

    glVertexAttribPointer(0, dimensions, GL_FLOAT, normalized, 0, cast(void*) 0);
    glEnableVertexAttribArray(0);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);

    ashenInternal_CheckGLErrors();

    return Drawable(vao, vbo, vertexCount);
}

// C APIs don't really recognize dynamic
// D arrays very well for some reason.
// so, i wrote a template to make a conversion.

import core.memory:GC;

template ashenToCArray(T) {
    void* ashenToCArray(T[] thing, out size_t oSize) {
        size_t size = thing.length * T.sizeof;
        T* ptr = cast(T*) GC.malloc(size);
        for (size_t i = 0; i < thing.length; i++) {
            ptr[i] = thing[i];
        }
        oSize = size;
        return ptr;
    }
}