void setup() {
  size(1280, 720, P3D);
  smooth(8);
  frameRate(60);

  initializeScene();

  track = new Track();
  track.initTrack();
  initCars();
}

void draw() {
  updateCars();

  TrackPose playerPose = track.samplePose(playerCar.progress, playerCar.lane);
  PVector cameraEye = getCameraEye(playerPose);
  PVector cameraTarget = getCameraTarget();
  PVector cameraForward = PVector.sub(cameraTarget, cameraEye);
  cameraForward.normalize();

  background(getBackgroundColor());
  applyMainCamera((PGraphics) g, cameraEye, cameraTarget);
  renderWorld((PGraphics) g, cameraEye, true, false, fogMode);

  if (fogMode) {
    drawFogVolumes((PGraphics) g, cameraEye, cameraForward);
  }

  drawMiniMap();
  drawHud();
}

// Shared renderer used by the main camera and the minimap camera.
void renderWorld(PGraphics pg, PVector referencePoint, boolean drawEnvironmentScene, boolean includePlayerCar, boolean useFog) {
  if (drawEnvironmentScene) {
    drawEnvironment(pg, referencePoint);
  }

  applySceneLights(pg);
  track.displayTrack(pg, referencePoint, useFog);
  displayCars(pg, includePlayerCar, referencePoint, useFog);
}
