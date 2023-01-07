# Ashen Bitmap (AMP)
The first 3 bytes should be 'AMP'. 
The following 4 bytes should be the Image's Width. the next 4 bytes should contain the image's height
The next byte is simply the image's format, this format can be `04` for `RGBA` and `03` for `RGB`.

the rest of the file should only contain the pixel data in one of the formats specified.

Notes: A file can be deemed "invalid" if the format is neither 4 or 3.