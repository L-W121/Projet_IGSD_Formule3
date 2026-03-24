class Track{
  float r=300;
  float roadWidth = 50; 
  int nb=200;
  ArrayList<PVector> centerPoints = new ArrayList<PVector>();
  
  void initTrack() {
    centerPoints.clear();

    for (int i = 0; i < nb; i++) {
      float a = TWO_PI * i / nb;
      float x = cos(a) * r;
      float z = sin(a) * r;
      float y = 0;
      centerPoints.add(new PVector(x, y, z));
    }
  }

  void displayTrack() {
    noStroke();
    fill(70);

    beginShape(QUAD_STRIP);
    for (int i = 0; i <= nb; i++) {
      int idx = i % nb;

      PVector center = centerPoints.get(idx);
      PVector dir = getDirection(idx);
      PVector side = new PVector(-dir.z, 0, dir.x); 
      side.normalize();

      PVector left = PVector.add(center, PVector.mult(side, -roadWidth * 0.5));
      PVector right = PVector.add(center, PVector.mult(side, roadWidth * 0.5));

      vertex(left.x, left.y, left.z);
      vertex(right.x, right.y, right.z);
    }
    endShape();
  }
  
  PVector getDirection(int i){
      i = i % (nb-1);
      PVector center = centerPoints.get(i);
      PVector center1 = centerPoints.get(i+1);
      PVector dir = PVector.sub(center1, center);
      dir.normalize();
      return dir;
  }
  
}
