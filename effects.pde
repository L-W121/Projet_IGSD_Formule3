void applySceneLights(PGraphics pg) {
  if (nightMode) {
    pg.ambientLight(28, 30, 42);
    pg.directionalLight(26, 28, 38, -0.2, 0.7, -0.3);
    addHeadlights(pg, playerCar, color(255, 245, 220));
    addHeadlights(pg, opponentCar, color(184, 220, 255));
  } else {
    pg.ambientLight(120, 120, 126);
    pg.directionalLight(208, 204, 194, -0.25, 0.7, -0.32);
    pg.directionalLight(92, 110, 138, 0.32, 0.18, 0.28);
  }
}

void addHeadlights(PGraphics pg, CarState car, int headlightColor) {
  if (car == null) {
    return;
  }

  TrackPose pose = track.samplePose(car.progress, car.lane);
  PVector front = PVector.add(pose.position, PVector.mult(pose.forward, 32.0));
  front.add(0, -8.0, 0);

  PVector beamDirection = pose.forward.copy();
  beamDirection.add(0, 0.16, 0);
  beamDirection.normalize();

  pg.spotLight(
    red(headlightColor),
    green(headlightColor),
    blue(headlightColor),
    front.x, front.y, front.z,
    beamDirection.x, beamDirection.y, beamDirection.z,
    PI / 3.0,
    38.0
  );
}

float computeFogAmount(PVector position, PVector referencePoint) {
  float distanceToCamera = PVector.dist(position, referencePoint);
  return constrain(map(distanceToCamera, FOG_NEAR_DISTANCE, FOG_FAR_DISTANCE, 0.0, 1.0), 0.0, 1.0);
}

// Stacked translucent quads create a simple distance fog without needing a custom shader.
void drawFogVolumes(PGraphics pg, PVector eye, PVector forward) {
  PVector up = new PVector(0, -1, 0);
  PVector right = PVector.cross(forward, up, null);
  if (right.magSq() < 0.0001) {
    right = new PVector(1, 0, 0);
  }
  right.normalize();
  up = PVector.cross(right, forward, null);
  up.normalize();

  int fogColor = getFogColor();
  pg.pushStyle();
  pg.hint(DISABLE_DEPTH_MASK);
  pg.noStroke();

  for (int i = 0; i < 12; i++) {
    float ratio = i / 11.0;
    float distanceFromCamera = lerp(180.0, 1700.0, ratio);
    float halfWidth = lerp(160.0, 2200.0, ratio);
    float halfHeight = lerp(100.0, 1200.0, ratio);
    float alpha = nightMode ? lerp(12.0, 56.0, ratio) : lerp(8.0, 44.0, ratio);

    PVector planeCenter = PVector.add(eye, PVector.mult(forward, distanceFromCamera));
    PVector rightOffset = PVector.mult(right, halfWidth);
    PVector upOffset = PVector.mult(up, halfHeight);

    PVector a = PVector.add(PVector.sub(planeCenter, rightOffset), upOffset);
    PVector b = PVector.add(PVector.add(planeCenter, rightOffset), upOffset);
    PVector c = PVector.sub(PVector.add(planeCenter, rightOffset), upOffset);
    PVector d = PVector.sub(PVector.sub(planeCenter, rightOffset), upOffset);

    pg.fill(red(fogColor), green(fogColor), blue(fogColor), alpha);
    pg.beginShape(QUADS);
    pg.vertex(a.x, a.y, a.z);
    pg.vertex(b.x, b.y, b.z);
    pg.vertex(c.x, c.y, c.z);
    pg.vertex(d.x, d.y, d.z);
    pg.endShape();
  }

  pg.hint(ENABLE_DEPTH_MASK);
  pg.popStyle();
}

void drawMiniMap() {
  if (minimapBuffer == null) {
    return;
  }

  TrackPose playerPose = track.samplePose(playerCar.progress, playerCar.lane);

  minimapBuffer.beginDraw();
  minimapBuffer.background(18, 22, 28);
  minimapBuffer.perspective(PI / 3.0, MINIMAP_WIDTH / (float) MINIMAP_HEIGHT, 10.0, 5000.0);
  minimapBuffer.camera(
    playerPose.position.x, -900.0, playerPose.position.z,
    playerPose.position.x, 0.0, playerPose.position.z,
    0.0, 0.0, -1.0
  );
  renderWorld(minimapBuffer, playerPose.position, false, true, false);
  minimapBuffer.endDraw();

  hint(DISABLE_DEPTH_TEST);
  camera();
  noLights();
  image(minimapBuffer, 22, 22);
  stroke(255, 220);
  noFill();
  rect(22, 22, MINIMAP_WIDTH, MINIMAP_HEIGHT, 10);
  hint(ENABLE_DEPTH_TEST);
}

void drawHud() {
  hint(DISABLE_DEPTH_TEST);
  camera();
  noLights();

  fill(0, 120);
  noStroke();
  rect(18, height - 86, 460, 60, 12);
  rect(width - 230, 18, 200, 54, 12);

  fill(255);
  textAlign(LEFT, TOP);
  textSize(15);
  text("W/S or Up/Down: speed    A/D or Left/Right: lane", 32, height - 74);
  text("N: night mode    F: fog    R: reset", 32, height - 48);

  textAlign(RIGHT, TOP);
  String modeLabel = nightMode ? "Night" : "Day";
  String fogLabel = fogMode ? "Fog on" : "Fog off";
  text("Speed: " + nf(playerCar.speed * 120.0, 0, 1), width - 44, 28);
  text(modeLabel + " | " + fogLabel, width - 44, 50);

  hint(ENABLE_DEPTH_TEST);
}
