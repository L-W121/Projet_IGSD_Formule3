PVector getCameraEye(TrackPose playerPose) {
  // The eye sits slightly above and ahead of the car center to imitate a cockpit view.
  PVector eye = playerPose.position.copy();
  eye.add(PVector.mult(playerPose.forward, CAMERA_EYE_FORWARD));
  eye.add(0, -CAMERA_EYE_HEIGHT, 0);
  return eye;
}

PVector getCameraTarget() {
  // Looking a few samples ahead keeps the first-person view aligned with the road direction.
  TrackPose aheadPose = track.samplePose(playerCar.progress + CAMERA_LOOK_AHEAD, playerCar.lane);
  PVector target = aheadPose.position.copy();
  target.add(0, -10, 0);
  return target;
}

void applyMainCamera(PGraphics pg, PVector eye, PVector target) {
  pg.perspective(PI / 3.0, width / (float) height, 10.0, 9000.0);
  pg.camera(eye.x, eye.y, eye.z, target.x, target.y, target.z, 0.0, 1.0, 0.0);
}
