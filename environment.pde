PImage img;
void backGround(){
  translate(0, 256, 0);
  img = loadImage("cube.jpeg");
  noStroke();
  beginShape(QUADS);
  texture(img);
  vertex(-256, 256, 256, 512, 0);
  vertex(256, 256, 256, 1024, 0);
  vertex(256, 256, -256, 1024, 512);
  vertex(-256, 256, -256, 512, 512);
  
  vertex(256, 256, -256, 1024, 512);
  vertex(-256, 256, -256, 512, 512);
  vertex(-256, -256, -256, 512, 1024);
  vertex(256, -256, -256, 1024, 1024);
  
  endShape();
  translate(0, -256, 0);
}
