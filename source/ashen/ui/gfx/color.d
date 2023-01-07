module ashen.ui.gfx.color;

struct AshenColor {
	float r;
	float g;
	float b;
	float a;

	this(int r, int g, int b, int a = 255) {
		this.r = r / 255;
		this.g = g / 255;
		this.b = b / 255;
		this.a = a / 255;
	}

	this(string hex) {
    		import std.conv : to;
   		ulong color = hex.to!ulong(16);
        	this.r = ((color >> 16) & 0xFF) / 255;  // Extract the RR byte
        	this.g = ((color >> 8) & 0xFF) / 255;   // Extract the GG byte
        	this.b = ((color) & 0xFF) / 255;         // Extract the BB byte
		this.a = 1;
	}

	static:
		auto White = AshenColor();
		auto Black = AshenColor(0,0,0);
		auto Red   = AshenColor(255, 0, 0);
		auto Green = AshenColor(0, 255, 0);
		auto Blue  = AshenColor(0, 0, 255);

		auto Magenta = AshenColor(255, 0, 255);
}
