PShape voiture;
void displayCar(int x, int y, float w, float h){
  rotateY(PI);
  voiture = loadShape("Car.obj");
  shape(voiture, x, y, w, h);
  rotateY(-PI);
}
