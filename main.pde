void setup() {
  size(1280, 720, P3D);
  track = new Track();
  track.initTrack();
}

void draw() {
  lights();
  camera(0,-400,600,0,0,0,0,1,0);
  
  track.displayTrack();

} 
