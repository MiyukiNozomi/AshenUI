module ashen.ui.img;

/**
    Yes, ashenui has its own image format;
    screw compressed image formats, its not like you're 
    going to be browsing a website anyway? are you?

    the actual reason is that uncompressed formats are
    just easier to deal with and faster to load.
    Also, its designed to be a simpler format; since 
    BMP has a stupid 40 char header in 24 bit and 108 char header
    in 32 bit, who the hell had that idea?

    since, the only way for you to know if its 32 or 24 bit is by reading that 
    same header!!!!!

    Either way, fell free to take a look at AshenBitmap/ on the
    main folder of the repository, there's an explanation there
    of the format.
*/

import bindbc.opengl : GLuint;

import std.conv;
import std.stdio;
import std.array;
import std.bitmanip;
import core.memory : GC;

import ashen.ui : HResult, bstring;
import ashen.ui.utils.dispatch;

import ashen.ui.gfx.renderer;

enum AshenFormat {
    RGBA = 4,
    RGB = 3,

    GPUSide = -3,
    Invalid = -1
}

class AshenImage {
    AshenFormat format;
    uint width;
    uint height;
    ubyte[] data;

    GLuint texId;

    /**
        Just a warning,
        calling this function will make it unusable in the CPU
        side for obvious reasons.

    */
    void pushToGPU() {
        texId = ashenInternal_SendImageToGPU(this);

        format = AshenFormat.GPUSide;
        data = null;
        width = 0;
        height = 0;
    }

    void release() {
        if (format == AshenFormat.GPUSide) {
            ashenInternal_ReleaseTexture(this);
            return;
        }
        // ok ok,you may say "wtf! isn't this a memory leak?!?!??!?!"
        // if it was C or C++, of course; however: D has a GC
        // so, lets leave it to the GC to clean it up.
        data = null;

        width = 0;
        height = 0;
        format = AshenFormat.Invalid; 
    }
}

HResult ashenLoadImage(string filename,
                       out AshenImage outImage) {
    try {
        File f = File(filename, "rb");   
        ubyte[12] AMPHeader = [
            0, 0, 0,    // margic 3 characters: 'AMP'
            0, 0, 0, 0, // width
            0, 0, 0, 0, // height
            0,         // format, 3 for RGB and 4 for RGBA.
        ];

        f.rawRead(AMPHeader);

        if (AMPHeader[0] != 'A' || AMPHeader[1] != 'M' || AMPHeader[2] != 'P') {
            return ashenInternal_DispatchError(HResult.InvalidFormat, "ashen/ui/img", "Not a Ashen Bitmap.");
        }

        // bitwise our way back to the original size
        int width  = (AMPHeader[3]) | (AMPHeader[4] <<  8) | (AMPHeader[5] << 16) | (AMPHeader[6]  << 24);   
        int height = (AMPHeader[7]) | (AMPHeader[8] <<  8) | (AMPHeader[9] << 16) | (AMPHeader[10] << 24);   

        int format = AMPHeader[11];

        // AshenBitmap can only be either RGBA or RGB.
        if (format != 3 && format != 4) {
            return ashenInternal_DispatchError(HResult.InvalidFormat, "ashen/ui/img", "Invalid Image Format");
        }

        ubyte[] data = new ubyte[width * height * format];
        f.rawRead(data);

        f.close();

        AshenImage image = new AshenImage();
        image.data = data;
        image.width = width;
        image.height = height;
        
        // 3 == RGB; 4 == RGBA
        image.format = cast(AshenFormat) format;
        outImage = image;

        return HResult.Okay;
    } catch(Exception e) {
        return ashenInternal_DispatchError(HResult.ExceptionCatched, "ashen/ui/img",
        "Exception Catched: %s(%d) > %s", e.file, e.line, e.msg);
    }
}