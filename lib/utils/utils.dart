bool isPortrait = false;
double scaleWidth = 0.0;
double scaleHeight = 0.0;

setFontSize(double size) {
  return size * scaleWidth;
}

setScaleWidth(double width) {
  return width * scaleWidth;
}

setScaleHeight(double height) {
  return height * scaleHeight;
}
