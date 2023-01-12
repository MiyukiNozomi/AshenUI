module ashen.ui.gfx.renderer;

import bindbc.opengl;

import ashen.ui;

import ashen.ui.math.matrix;

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
         0,  0,
         0,  1,
         1,  0,
         1,  0,
         0,  1,
         1,  1
    ], 2, true);
    colorRectShader = new AshenColorRectShader();
    texRectShader = new AshenTexturedRectShader();

    glEnable(GL_BLEND);
}

void ashenDrawRectangle(AshenColor color, float x, float y,
                                           float w, float h,
                                           float r = 0) {
    colorRectShader.Bind();
    colorRectShader.SetColor("color", color);
    
    ashenInternal_SendProjection(colorRectShader);

    colorRectShader.SetMatrix("transformation", ashenTransform(x, y, w, h, r));

    rectangle.bind();
    glDrawArrays(GL_TRIANGLES, 0, rectangle.vertexCount);
    rectangle.unbind();
    ashenInternal_CheckGLErrors();

    colorRectShader.Unbind();
}

void ashenDrawRectangle(AshenImage image, float x, float y,
                                          float w, float h,
                                          AshenColor tint = null,
                                          float r = 0) {
    if (image.format != AshenFormat.GPUSide) {
        ashenInternal_SendImageToGPU(image);
    }
    texRectShader.Bind();

    if (tint !is null) {
        texRectShader.SetFloat("isGrayScale", 1);
        texRectShader.SetColor("color", tint);
    } else {
        texRectShader.SetFloat("isGrayScale", 0);
    }

    ashenInternal_SendProjection(texRectShader);

    texRectShader.SetMatrix("transformation", ashenTransform(x, y, w, h, r));

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, image.texId);

    rectangle.bind();
    glDrawArrays(GL_TRIANGLES, 0, rectangle.vertexCount);
    rectangle.unbind();
    ashenInternal_CheckGLErrors();

    texRectShader.Unbind();
}

void ashenInternal_ReleaseTexture(AshenImage image) {
    glDeleteTextures(1, &image.texId);
}

void ashenInternal_ReleaseRenderer() {
    colorRectShader.Release();
    texRectShader.Release();
}

private: 
/**
    The logic is simple: 
        if size updated, redo projection.
    then send it to shader
*/
void ashenInternal_SendProjection(AshenShader shader) {
    if (createdWindow.sizeUpdated) {
        if (!projection) projection = ashenCreateMatrix();
        projection = ashenOrthographic(projection, createdWindow.width, createdWindow.height);
        createdWindow.sizeUpdated = false;
    }
    shader.SetMatrix("projection", projection);
}

AshenMat4 projection;
AshenColorRectShader colorRectShader;
AshenTexturedRectShader texRectShader;
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

    GC.free(verticesPtr);
    return Drawable(vao, vbo, vertexCount);
}

/**
    Just a warning,
    calling this function will make the image unusable in
    the CPU side for obvious reasons.
*/
public void ashenInternal_SendImageToGPU(AshenImage image) {
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

    // size is useless in this context
    size_t size;

    void* pixels = ashenToCArray!ubyte(image.data, size);
    GLenum format = image.format == AshenFormat.RGB ? GL_RGB : GL_RGBA;

    glTexImage2D(GL_TEXTURE_2D, 0, format, image.width, image.height, 0, format,
                 GL_UNSIGNED_BYTE, pixels);
    glGenerateMipmap(GL_TEXTURE_2D);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

    glBindTexture(GL_TEXTURE_2D, 0);
    ashenInternal_CheckGLErrors();

    GC.free(pixels);
    image.texId = texture;
    image.format = AshenFormat.GPUSide;
    image.data = null;
    image.width = 0;
    image.height = 0;
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