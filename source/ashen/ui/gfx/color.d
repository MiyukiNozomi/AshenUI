module ashen.ui.gfx.color;

class AshenColor {
	float r;
	float g;
	float b;
	float a;

	this(int r, int g, int b, int a = 255) {
		this.r = cast(float)r / 255.0f;
		this.g = cast(float)g / 255.0f;
		this.b = cast(float)b / 255.0f;
		this.a = cast(float)a / 255.0f;
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
		AshenColor White, Black,
				  Red, Green, Blue,
				  Orange, Magenta;

		void makeDefaultColors() {
			White = new AshenColor(255,255,255);
			Black = new AshenColor(0,0,0);

		 	Red   = new AshenColor(255, 0, 0);
		 	Green = new AshenColor(0, 255, 0);
		 	Blue  = new AshenColor(0, 0, 255);

		 	Orange  = new AshenColor(245, 117, 19);
		 	Magenta = new AshenColor(255, 0, 255);
		}
}