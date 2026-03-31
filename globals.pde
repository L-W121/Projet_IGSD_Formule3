Track track;
CarState playerCar;
CarState opponentCar;

PShape carModel;
PImage skyTexture;
PImage groundTexture;
PGraphics minimapBuffer;

boolean accelerateHeld = false;
boolean brakeHeld = false;
boolean nightMode = false;
boolean fogMode = false;

final int MINIMAP_WIDTH = 320;
final int MINIMAP_HEIGHT = 220;
final float CAMERA_EYE_HEIGHT = 22.0;
final float CAMERA_EYE_FORWARD = 10.0;
final float CAMERA_LOOK_AHEAD = 7.0;
final float FOG_NEAR_DISTANCE = 260.0;
final float FOG_FAR_DISTANCE = 1550.0;

void initializeScene() {
  textureWrap(REPEAT);

  skyTexture = loadImage("cube.jpeg");
  groundTexture = loadImage("desert.png");
  carModel = loadShape("Car.obj");
  if (carModel != null) {
    // We disable the OBJ style so that each car can receive the scene lighting.
    carModel.disableStyle();
  }

  minimapBuffer = createGraphics(MINIMAP_WIDTH, MINIMAP_HEIGHT, P3D);
}

PVector lerpVector(PVector a, PVector b, float t) {
  return new PVector(
    lerp(a.x, b.x, t),
    lerp(a.y, b.y, t),
    lerp(a.z, b.z, t)
  );
}

float wrapValue(float value, float modulo) {
  if (modulo <= 0) {
    return 0;
  }

  while (value < 0) {
    value += modulo;
  }
  while (value >= modulo) {
    value -= modulo;
  }
  return value;
}

float snapToLane(float laneValue) {
  return round(laneValue * 2.0) / 2.0;
}

int getBackgroundColor() {
  return nightMode ? color(10, 14, 26) : color(168, 205, 234);
}

int getFogColor() {
  return nightMode ? color(16, 20, 28) : color(194, 203, 210);
}
