module decoder;

// Example of a decoder,
// It works. i hope.

import std.stdio;

ubyte[] DecodeAMP(string filename, out int outWidth, out int outHeight, out int outFormat) {
    File f = File(filename, "rb");   
    
	ubyte[12] AMPHeader = [
        0, 0, 0,
		0, 0, 0, 0, // width
		0, 0, 0, 0, // height
		0,         // format, 3 for RGB and 4 for RGBA.
	];

    f.rawRead(AMPHeader);

    if (AMPHeader[0] != 'A' || AMPHeader[1] != 'M' || AMPHeader[2] != 'P') {
        // error should be thrown, not a AMP file.
    }

    int width  = (AMPHeader[3]) | (AMPHeader[4] <<  8) | (AMPHeader[5] << 16) | (AMPHeader[6]  << 24);   
    int height = (AMPHeader[7]) | (AMPHeader[8] <<  8) | (AMPHeader[9] << 16) | (AMPHeader[10] << 24);   
    int format = AMPHeader[11];

    if (format != 3 && format != 4) {
        // you should throw an error here.
        // the file is invalid.
    }

    ubyte[] data = new ubyte[width * height * format];
    f.rawRead(data);

    f.close();

    outWidth  = width;
    outHeight = height;
    outFormat = format;
    return data;
}