void displayCars(PGraphics pg, boolean includePlayerCar, PVector referencePoint, boolean useFog) {
  if (includePlayerCar) {
    displaySingleCar(pg, playerCar, referencePoint, useFog);
  }
  displaySingleCar(pg, opponentCar, referencePoint, useFog);
}

void displaySingleCar(PGraphics pg, CarState car, PVector referencePoint, boolean useFog) {
  if (car == null) {
    return;
  }

  TrackPose pose = track.samplePose(car.progress, car.lane);
  float yaw = atan2(pose.forward.x, pose.forward.z);

  pg.pushMatrix();
  pg.pushStyle();
  pg.translate(pose.position.x, pose.position.y, pose.position.z);
  pg.rotateY(yaw + PI);

  float fogAmount = useFog ? computeFogAmount(pose.position, referencePoint) : 0.0;
  int shadedColor = lerpColor(car.bodyColor, getFogColor(), fogAmount * 0.7);
  if (nightMode) {
    shadedColor = lerpColor(shadedColor, color(70, 78, 88), 0.28);
  }

  pg.noStroke();
  pg.fill(shadedColor);
  pg.ambient(70);
  pg.specular(180);
  pg.shininess(18.0);

  if (carModel != null) {
    pg.scale(28.0);
    pg.shape(carModel);
  } else {
    pg.box(50, 18, 95);
  }

  pg.popStyle();
  pg.popMatrix();
}
