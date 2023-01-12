module ashen.ui.math.matrix;

import std.math;
import core.memory : GC;

import ashen.ui.utils.dispatch;

alias AshenMat4 = float*;

AshenMat4 ashenCreateMatrix() {
    return cast(AshenMat4) GC.malloc(4 * 4 * float.sizeof);
}

AshenMat4 ashenOrthographic(AshenMat4 mat, float width, float height) {
    AshenMat4 result = mat;
    ashenIdentity(result);

    float w2 = 2.0f / width;
    float h2 = 2.0f / height;

    result[ 0] = w2;
    result[5u] = h2;
    result[12] = -1.0f;
    result[13] = -1.0f;

    return result;
}

AshenMat4 ashenTransform(float x, float y, float width, float height, float rotation) {
    AshenMat4 transformation;

    transformation = ashenScale(width, height);
    transformation = ashenRotate(transformation, rotation);
    transformation = ashenTranslate(transformation, x, y);

    return transformation;
}

// Rotation in Z axis ¯\_(ツ)_/¯
AshenMat4 ashenRotate(AshenMat4 mat4, float r) {
    auto m = ashenCreateMatrix();
    ashenIdentity(m);

    float cosinedAmmount = cast(float)cos(r);
    float sinedAmmount   = cast(float)sin(r);

    m[0u] =  cosinedAmmount;
    m[4u] = -sinedAmmount;
    m[1u] =  sinedAmmount;
    m[5u] =  cosinedAmmount;

    return ashenMultiply(m, mat4);
}

AshenMat4 ashenTranslate(AshenMat4 mat4, float x, float y) {
    auto m = ashenCreateMatrix();
    ashenIdentity(m);

    m[12u] = x;
    m[13u] = y;

    return ashenMultiply(m, mat4);
}

AshenMat4 ashenScale(float width, float height) {
    AshenMat4 m = ashenCreateMatrix();
    ashenIdentity(m);

    m[0u] = width;
    m[5u] = height;

    return m;
}

void ashenIdentity(AshenMat4 matrix) {
    for (int i = 0; i < 4; i++) {
        matrix[i + i * 4u] = 1;
    }
}

AshenMat4 ashenMultiply(AshenMat4 left, AshenMat4 right) {
    auto result = ashenCreateMatrix();

    for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
            result[r + c * 4u] = 0;
            for (int c2 = 0; c2 < 4; c2++) {
                result[r + c * 4u] += left[r + c2 * 4u] * right[c2 + c * 4u];
            }
        }
    }
    return result;
}