module ashen.ui.img;

import std.conv;
import std.stdio;
import std.array;
import std.bitmanip;
import core.memory : GC;

import ashen.ui : HResult, bstring;
import ashen.ui.utils.dispatch;

enum AshenFormat {
    RGBA = 4,
    RGB = 3,

    Invalid = -1
}

class AshenImage {
    AshenFormat format;
    uint width;
    uint height;
    ubyte[] data;

    void Release() {
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
            0, 0, 0,
            0, 0, 0, 0, // width
            0, 0, 0, 0, // height
            0,         // format, 3 for RGB and 4 for RGBA.
        ];

        f.rawRead(AMPHeader);

        if (AMPHeader[0] != 'A' || AMPHeader[1] != 'M' || AMPHeader[2] != 'P') {
            return ashenInternal_DispatchError(HResult.InvalidFormat, "ashen/ui/img", "Not a Ashen Bitmap.");
        }

        int width  = (AMPHeader[3]) | (AMPHeader[4] <<  8) | (AMPHeader[5] << 16) | (AMPHeader[6]  << 24);   
        int height = (AMPHeader[7]) | (AMPHeader[8] <<  8) | (AMPHeader[9] << 16) | (AMPHeader[10] << 24);   
        int format = AMPHeader[11];

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
        image.format = cast(AshenFormat) format;
        outImage = image;

        return HResult.Okay;
    } catch(Exception e) {
        return ashenInternal_DispatchError(HResult.ExceptionCatched, "ashen/ui/img",
        "Exception Catched: %s(%d) > %s", e.file, e.line, e.msg);
    }
}