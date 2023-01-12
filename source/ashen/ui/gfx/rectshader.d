module ashen.ui.gfx.rectshader;

import ashen.ui : bstring;
import ashen.ui.gfx.shaders;

public class AshenColorRectShader : AshenShader {

    public this() {
        super(ashenInternal_Rectvertexsource, ashenInternal_RectColorfragmentsource, [
            "projection","transformation","color"
        ]);
    }

}

public class AshenTexturedRectShader : AshenShader {

    public this() {
        super(ashenInternal_Rectvertexsource, ashenInternal_RectImagefragmentsource, [
            "projection","transformation","color","isGrayScale"
        ]);
    }

}


public const bstring ashenInternal_Rectvertexsource = "
#version 330 core

layout (location = 0) in vec2 vertex;

uniform mat4 projection;
uniform mat4 transformation;

out vec2 uvCoords;

void main()
{
    gl_Position = projection * transformation * vec4(vertex.xy, 0, 1.0);
    uvCoords = vec2(vertex.x, (vertex.y - 1.0) * -1);
}
";
public const bstring ashenInternal_RectColorfragmentsource = "
#version 330 core

in vec2 uvCoords;

out vec4 out_Color;

uniform vec4 color;

void main() {
    out_Color = color;
}";
public const bstring ashenInternal_RectImagefragmentsource = "
#version 330 core

in vec2 uvCoords;

out vec4 out_Color;

uniform vec4 color;
uniform sampler2D tex;
uniform float isGrayScale;

void main() {
    vec4 txd = texture(tex, uvCoords);

    if (isGrayScale > 0.5) {
        float alpha = txd.a;
        out_Color = vec4(
            alpha * color.r,
            alpha * color.g,
            alpha * color.b,
            alpha
        );
    } else {
        out_Color = txd;
    }
}";