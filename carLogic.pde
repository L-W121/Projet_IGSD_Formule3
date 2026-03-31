class CarState {
  float progress;
  float lane;
  float targetLane;
  float speed;
  float cruiseSpeed;
  int bodyColor;
  boolean playerControlled;

  CarState(float progress, float lane, float speed, float cruiseSpeed, int bodyColor, boolean playerControlled) {
    this.progress = progress;
    this.lane = lane;
    this.targetLane = lane;
    this.speed = speed;
    this.cruiseSpeed = cruiseSpeed;
    this.bodyColor = bodyColor;
    this.playerControlled = playerControlled;
  }

  void shiftLane(float delta) {
    targetLane = constrain(snapToLane(targetLane + delta), -1.0, 1.0);
  }
}

void initCars() {
  playerCar = new CarState(6.0, 0.0, 0.30, 0.22, color(212, 70, 66), true);
  opponentCar = new CarState(38.0, 0.45, 0.24, 0.24, color(72, 145, 232), false);
}

void updateCars() {
  if (track == null || track.samples.isEmpty()) {
    return;
  }

  updatePlayerCar();
  updateOpponentCar();
}

void updatePlayerCar() {
  // The player controls the speed continuously and changes lane in discrete steps.
  if (accelerateHeld) {
    playerCar.speed += 0.010;
  }
  if (brakeHeld) {
    playerCar.speed -= 0.015;
  }

  playerCar.speed = constrain(playerCar.speed, 0.05, 1.10);
  playerCar.speed = lerp(playerCar.speed, playerCar.cruiseSpeed, 0.02);
  playerCar.lane = lerp(playerCar.lane, playerCar.targetLane, 0.16);
  playerCar.progress = track.wrapProgress(playerCar.progress + playerCar.speed);
}

void updateOpponentCar() {
  // The opponent keeps moving to make the scene feel alive even without full racing AI.
  opponentCar.targetLane = 0.72 * sin(frameCount * 0.017);
  opponentCar.lane = lerp(opponentCar.lane, opponentCar.targetLane, 0.05);
  opponentCar.speed = opponentCar.cruiseSpeed + 0.03 * sin(frameCount * 0.013 + 1.5);
  opponentCar.progress = track.wrapProgress(opponentCar.progress + opponentCar.speed);
}

void resetRace() {
  if (playerCar != null) {
    playerCar.progress = 6.0;
    playerCar.lane = 0.0;
    playerCar.targetLane = 0.0;
    playerCar.speed = 0.30;
  }

  if (opponentCar != null) {
    opponentCar.progress = 38.0;
    opponentCar.lane = 0.45;
    opponentCar.targetLane = 0.45;
    opponentCar.speed = 0.24;
  }
}
