module ashen.ui.gfx.renderer;

import bindbc.opengl;

import ashen.ui.utils.dispatch;

/**
    Initializes the renderer
*/
package void ashenInitRenderer() {


    
}

// VertexArray, wharever;
// declaration of a "Drawable Thing"
struct Drawable {
    GLuint vao;
    GLuint vbo;

    void release() {
        glDeleteVertexArrays(1, &vao);
        glDeleteBuffers(1, &vbo);
    }
}

/**
    Sends some stuff to the GPU
*/