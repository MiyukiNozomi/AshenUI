import ashen.ui;
import std.stdio;

void PrintOutErrors() {
    if (!ashenHadError()) {
        return;
    }
    size_t errCount;
    AshenError* errors = ashenGetErrors(errCount);

    for (size_t i = 0; i < errCount; i++) {
        writeln(errors[i]);
    }
}

void main() {
	AshenWindow window;
	if (!Succeeded(ashenInit("AshenUI!", 600, 400, window))) {
		writeln("Unable to initialize window!");
        return;
    }

    version(BigEndian)  {
        writeln("BE");
    } 
    version(LittleEndian) {
        writeln("LE");
    }

    AshenImage icon;
    if (!Succeeded(ashenLoadImage("sampleicon.amp", icon))) {
        writeln("Failed to load icon!");
        PrintOutErrors();
    }    
    window.setIcon(icon);

    icon.release();

	window.defineInterval(2);

    AshenImage doritos;
    ashenLoadImage("test-pictures/hahhaa.amp", doritos);

    AshenImage sniper;
    if (!Succeeded(ashenLoadImage("test-pictures/sniper.amp", sniper))) {
        writeln("idiot");
    }


	while (window.isVisible()) {
		window.prepare(&AshenColor.White);

        ashenDrawRectangle(doritos, 12, 12, 138, 256);
       // ashenDrawRectangle(sniper, window.getWidth() - sniper.width, 0, sniper.width, sniper.height);

       // ashenDrawRectangle(&AshenColor.Black, 0, 0, 120, 120);
       // ashenDrawRectangle(&AshenColor.Magenta, 12, 12, 120, 120);

		window.swapBuffers();
	}

    doritos.release();
    sniper.release();
    
	ashenTerminate();
}