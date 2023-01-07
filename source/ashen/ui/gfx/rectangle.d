module ashen.ui.gfx.rectangle;

import ashen.ui : bstring;
import ashen.ui.gfx.shaders;

public class AshenColorRectShader : AshenShader {

    public this() {
        super(ashenInternal_Rectvertexsource, ashenInternal_Rectfragmentsource,
                [
                    "transformation", "projection", "color"
                ]);
    }

}

public const bstring ashenInternal_Rectvertexsource = "
#version 330 core
layout (location = 0) in vec4 vertex;

uniform mat4 transformation;
uniform mat4 projection;

void main()
{
    gl_Position = projection * transformation * vec4(vertex.xy, 0.0, 1.0);
}
";
public const bstring ashenInternal_Rectfragmentsource = "
#version 330 core

out vec4 out_Color;

uniform vec4 color;

void main() {
    out_Color = color;
}";