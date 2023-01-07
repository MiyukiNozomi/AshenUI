import std.string;
import std.format;
import std.stdint;
import core.stdc.stdio;
import core.memory : GC;

import bindbc.sdl;
import bindbc.sdl.image;

import decoder;

void main(string[] args) {
	/*int w, h, fr;
	ubyte[] dat = DecodeAMP("test.amp", w, h, fr);

	Printf("%d %d %d\n", w, h, fr);
	Printf("%s\n", dat);*/

	if (!LoadLibraries()) {
		Printf("Error! Unable to load libraries.\n");
		return;
	}

	if (args.length == 1) {
		Printf("Usage: [input] /o[filename]\n");
		Printf("Where [input] is the input file.\n");
		Printf("Where /o[name] is the output file.\n");
		Printf("There's an optional argument of /rgb, which discards the alpha channel.\n");
		Printf("\n\nDeveloped by Miyuki.");
		return;
	}

	string inputFile;
	string outputFile;
	bool discardAlpha = false;

	for (int i = 1; i < args.length; i++) {
		auto arg = args[i];
		if (arg.startsWith("/o")) {
			outputFile = arg[2 .. arg.length];
		} else if (arg.endsWith(".png")||arg.endsWith(".jpg")||arg.endsWith(".bmp")) {
			inputFile = arg;
		} else if (arg == "/rgb") {
			discardAlpha = true;
		} else {
			Printf("Unrecognized Parameter: %s\n", arg);
		}
	}

	if (inputFile == "") {Printf("Missing input file.\n"); return;}
	if (outputFile == "") {Printf("Missing output file.\n"); return;}

	if (!outputFile.endsWith(".amp"))
		outputFile ~= ".amp";

	Printf("Defined InputFile as %s, and output file as %s\n", inputFile, outputFile);

	// i did not code loadSurface.
	// it ensures that the image will always have an alpha channel.
	SDL_Surface* surface = loadSurface(inputFile);
	if(!surface) {
		return;
	}
    uint32_t* pixels = cast(uint32_t*) surface.pixels;

	size_t cpLength = surface.w * surface.h * (discardAlpha ? 3 : 4);
    ubyte* convertedPixels = cast(ubyte*)GC.malloc(cpLength);

	Printf("Image Size: %dx%d\n", surface.w, surface.h);

	int ip = 0;

    for (size_t y = 0; y < surface.h; y++) {
    	for (size_t x = 0; x < surface.w; x++) {
            size_t i = (y * surface.w) + x;
			uint32_t color = pixels[i];
			
			ubyte r, g, b, a;
			SDL_GetRGBA(color, surface.format, &r, &g, &b, &a);
	
			convertedPixels[ip++] = r;
			convertedPixels[ip++] = g;
			convertedPixels[ip++] = b;

			if (!discardAlpha)
				convertedPixels[ip++] = a;
		}
    }
	SDL_FreeSurface(surface);

	ubyte[12] AMPHeader = [
		'A','M','P',
		0, 0, 0, 0, // width
		0, 0, 0, 0, // height
		0,         // format, 3 for RGB and 4 for RGBA.
	];

	int width = surface.w;
	int height = surface.h;
    AMPHeader[3] = (width      ) & 0xFF;
    AMPHeader[4] = (width >>  8) & 0xFF;
    AMPHeader[5] = (width >> 16) & 0xFF;
    AMPHeader[6] = (width >> 24) & 0xFF;

    AMPHeader[7]  = (height      ) & 0xFF;
    AMPHeader[8]  = (height >>  8) & 0xFF;
    AMPHeader[9]  = (height >> 16) & 0xFF;
    AMPHeader[10] = (height >> 24) & 0xFF;

	AMPHeader[11] = discardAlpha ? 3 : 4;

	FILE* f = fopen(outputFile.toStringz(), "wb");
	fwrite(AMPHeader.ptr, AMPHeader.sizeof,  1, f);
	fwrite(convertedPixels, cpLength, 1, f);
	fclose(f);

	Printf("Successfully Converted to AMP File!\n");
}

bool LoadLibraries() {
	SDLSupport sp = loadSDL();
	SDLImageSupport spi = loadSDLImage();
	if (sp != sdlSupport) {
		if (sp == SDLSupport.badLibrary)
			printf("Bad SDL Library.\n");
		else if (sp == SDLSupport.noLibrary) 
			Printf("Missing SDL library.");
		return false;
	}
	if (spi != sdlImageSupport){
		if (spi == SDLImageSupport.badLibrary)
			printf("Bad SDL Image Library.\n");
		else if (spi == SDLImageSupport.noLibrary) 
			Printf("Missing SDL Image library.");
		return false;
	}	
	return true;
}

void Printf(Char, Args...)(in Char[] fmt, Args args) {
	printf(format(fmt, args).toStringz());
}


//below this there's only hell;

import bindbc.sdl;
import bindbc.sdl.image;

// sdl functions thing //
string getSDLError() {
    import std.string : fromStringz;
	return cast(string) fromStringz(SDL_GetError());
}

/**more chaos*/
bool isSurfaceRGBA8888(const SDL_Surface* surface) {
	return (surface.format.Rmask == 0xFF000000 &&
			surface.format.Gmask == 0x00FF0000 &&
			surface.format.Bmask == 0x0000FF00 &&
			surface.format.Amask == 0x000000FF);
}

/**does something*/
SDL_Surface* ensureSurfaceRGBA8888(SDL_Surface* surface) {
	import std.string : format;

	// Just return if it is already RGBA8888
	if (isSurfaceRGBA8888(surface)) {
		return surface;
	}

	// Convert the surface into a new one that is RGBA8888
	SDL_Surface* new_surface = SDL_ConvertSurfaceFormat(surface, SDL_PIXELFORMAT_RGBA8888, 0);
	if (new_surface == null) {
		throw new Exception("Failed to convert surface to RGBA8888 format: %s".format(getSDLError()));
	}
	SDL_FreeSurface(surface);

	// Make sure the new surface is RGBA8888
	if (!isSurfaceRGBA8888(new_surface)) {
		throw new Exception("Failed to convert surface to RGBA8888 format: %s".format(getSDLError()));
	}
	return new_surface;
}

/** function from https://github.com/WorkhorsyTest/d_glfw/blob/master/dlang_glfw/source/helpers.d line 188 */
SDL_Surface* loadSurface(const string file_name) {
	import std.file : exists;
	import std.string : toStringz, format;

	if (! exists(file_name)) {
		Printf("The File %s does not exist.", file_name);
		return null;
	}

	SDL_Surface* surface = IMG_Load(file_name.toStringz);
	if (surface == null) {
		throw new Exception("Failed to load surface \"%s\": %s".format(file_name, getSDLError()));
	}
/*
	if (surface.format.BitsPerPixel < 32) {
		throw new Exception("Image has no alpha channel \"%s\"".format(file_name));
	}
*/
	surface = ensureSurfaceRGBA8888(surface);

	return surface;
}