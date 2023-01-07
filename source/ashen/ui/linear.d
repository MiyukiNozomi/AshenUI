module ashen.ui.linear;

import std.math;

alias AshenFloat2 = float2;
alias AshenMatrix4f = Matrix4f;

struct float2 {
    float x;
    float y;

    float magnetude() {
        return sqrt(x * x + y * y);
    }

    float2 normalized() {
        return this / magnetude();
    }

    void normalize() {
        float len = magnetude();
        this.x /= len;
        this.y /= len;
    }

    float2 opUnary(string s)() if (s == "-") {
        return float2(-this.x, -this.y);
    }
    
    float2 opBinary(string op)(float f) {
             static if (op == "+") return float2(this.x + f, this.y + f);
        else static if (op == "-") return float2(this.x - f, this.y - f);
        else static if (op == "*") return float2(this.x * f, this.y * f);
        else static if (op == "/") return float2(this.x / f, this.y / f);
        else static assert(0, "Operator "~op~" not implemented");
    }

    float2 opBinary(string op)(float2 f) {
             static if (op == "+") return float2(this.x + f.x, this.y + f.y);
        else static if (op == "-") return float2(this.x - f.x, this.y - f.y);
        else static if (op == "*") return float2(this.x * f.x, this.y * f.y);
        else static assert(0, "Operator "~op~" not implemented");
    }
}

struct Matrix4f {
    float[4][4] matrix;

    void clear(float v) {
        for (int i = 0; i < 4; i++) {
            for (int j = 0; j < 4; j++) {
                matrix[i][j] = v;
            }
        }
    }

    void identity() {
        clear(0);
        for (int j = 0; j < 4; j++) {
            matrix[j][j] = 1;
        }
    }
}

void ashenOrthographic(ref AshenMatrix4f ret, float left, float right, float top,
                       float bottom, float far, float near) {
    ret.clear(0);
    ret.matrix[0][0] = 2 / (right - left);
    ret.matrix[0][3] = -(right + left) / (right - left);
    ret.matrix[1][1] = 2 / (top - bottom);
    ret.matrix[1][3] = -(top + bottom) / (top - bottom);
    ret.matrix[2][2] = -2 / (far - near);
    ret.matrix[2][3] = -(far + near) / (far - near);
    ret.matrix[3][3] = 1;
}

AshenMatrix4f ashenOrthographic(float left, float right, float top,
                                float bottom, float far, float near) {
    AshenMatrix4f ret;
    ashenOrthographic(ret, left, right, top, bottom, far, near);
    return ret;
}

void ashenTranslate(ref AshenMatrix4f ret, ref float2 position) {
    ret.matrix[0][3] = position.x;
    ret.matrix[1][3] = position.y;
}

void ashenRotate(ref AshenMatrix4f ret, ref float alpha) {
    float cosamt = cos(alpha);
    float sinamt = sin(alpha);

    ret.matrix[1][1] = cosamt;
    ret.matrix[1][2] = -sinamt;
    ret.matrix[2][1] = sinamt;
    ret.matrix[2][2] = cosamt;
}


void ashenScale(ref AshenMatrix4f ret, float2 scale) {
    ret.matrix[0][0] = scale.x;
    ret.matrix[1][1] = scale.y;
}