void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      accelerateHeld = true;
    } else if (keyCode == DOWN) {
      brakeHeld = true;
    } else if (keyCode == LEFT) {
      // Lane changes are snapped so the car clearly moves from one side to the other.
      playerCar.shiftLane(-0.5);
    } else if (keyCode == RIGHT) {
      playerCar.shiftLane(0.5);
    }
    return;
  }

  if (key == 'w' || key == 'W') {
    accelerateHeld = true;
  } else if (key == 's' || key == 'S') {
    brakeHeld = true;
  } else if (key == 'a' || key == 'A') {
    playerCar.shiftLane(-0.5);
  } else if (key == 'd' || key == 'D') {
    playerCar.shiftLane(0.5);
  } else if (key == 'n' || key == 'N') {
    nightMode = !nightMode;
  } else if (key == 'f' || key == 'F') {
    fogMode = !fogMode;
  } else if (key == 'r' || key == 'R') {
    resetRace();
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == UP) {
      accelerateHeld = false;
    } else if (keyCode == DOWN) {
      brakeHeld = false;
    }
    return;
  }

  if (key == 'w' || key == 'W') {
    accelerateHeld = false;
  } else if (key == 's' || key == 'S') {
    brakeHeld = false;
  }
}
