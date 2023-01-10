module ashen.ui.gfx.rectshader;

import ashen.ui : bstring;
import ashen.ui.gfx.shaders;

public class AshenColorRectShader : AshenShader {

    public this() {
        super(ashenInternal_Rectvertexsource, ashenInternal_Rectfragmentsource, ["color"]);
    }

}

public const bstring ashenInternal_Rectvertexsource = "
#version 330 core

layout (location = 0) in vec2 vertex;

out vec2 uvCoords;

void main()
{
    gl_Position = vec4(vertex.xy, 0.0, 1.0);
    uvCoords = vec2(vertex.x/2.0 + 0.5, vertex.y/2.0 + 0.5);
}
";
public const bstring ashenInternal_Rectfragmentsource = "
#version 330 core

in vec2 uvCoords;

out vec4 out_Color;

uniform vec4 color;

void main() {
    out_Color = color;
}";