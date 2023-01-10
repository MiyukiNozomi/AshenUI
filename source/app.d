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

    AshenImage logo;
    if (!Succeeded(ashenLoadImage("logo.amp", logo))) {
        PrintOutErrors();
        return;
    }
    
    window.setIcon(icon);

    icon.release();

	window.defineInterval(2);

	while (window.isVisible()) {
		window.prepare(&AshenColor.Blue);

        ashenDrawRectangle(logo);

		window.swapBuffers();
	}

    logo.release();
    
	ashenTerminate();
}