void drawEnvironment(PGraphics pg, PVector referencePoint) {
  drawSkybox(pg, referencePoint);
  drawGround(pg, referencePoint);
}

// The skybox stays centered on the camera so the horizon always feels infinitely far away.
void drawSkybox(PGraphics pg, PVector referencePoint) {
  if (skyTexture == null) {
    return;
  }

  float boxSize = 5200.0;
  float half = boxSize * 0.5;

  pg.pushMatrix();
  pg.pushStyle();
  pg.translate(referencePoint.x, referencePoint.y - 120.0, referencePoint.z);
  pg.noStroke();
  pg.textureMode(NORMAL);
  pg.tint(nightMode ? color(120, 130, 170) : color(255));

  drawTexturedQuad(pg, skyTexture,
    new PVector(-half, -half, -half),
    new PVector(half, -half, -half),
    new PVector(half, half, -half),
    new PVector(-half, half, -half));

  drawTexturedQuad(pg, skyTexture,
    new PVector(half, -half, half),
    new PVector(-half, -half, half),
    new PVector(-half, half, half),
    new PVector(half, half, half));

  drawTexturedQuad(pg, skyTexture,
    new PVector(-half, -half, half),
    new PVector(-half, -half, -half),
    new PVector(-half, half, -half),
    new PVector(-half, half, half));

  drawTexturedQuad(pg, skyTexture,
    new PVector(half, -half, -half),
    new PVector(half, -half, half),
    new PVector(half, half, half),
    new PVector(half, half, -half));

  drawTexturedQuad(pg, skyTexture,
    new PVector(-half, -half, half),
    new PVector(half, -half, half),
    new PVector(half, -half, -half),
    new PVector(-half, -half, -half));

  pg.noTint();
  pg.popStyle();
  pg.popMatrix();
}

// A large textured ground plane follows the camera to hide the hard edge below the horizon.
void drawGround(PGraphics pg, PVector referencePoint) {
  if (groundTexture == null) {
    return;
  }

  float half = 3400.0;
  float y = 60.0;

  pg.pushStyle();
  pg.noStroke();
  pg.textureMode(NORMAL);
  pg.tint(nightMode ? color(95, 102, 115) : color(255));
  pg.beginShape(QUADS);
  pg.texture(groundTexture);
  pg.vertex(referencePoint.x - half, y, referencePoint.z - half, 0.0, 0.0);
  pg.vertex(referencePoint.x + half, y, referencePoint.z - half, 8.0, 0.0);
  pg.vertex(referencePoint.x + half, y, referencePoint.z + half, 8.0, 8.0);
  pg.vertex(referencePoint.x - half, y, referencePoint.z + half, 0.0, 8.0);
  pg.endShape();
  pg.noTint();
  pg.popStyle();
}

void drawTexturedQuad(PGraphics pg, PImage textureImage, PVector a, PVector b, PVector c, PVector d) {
  pg.beginShape(QUADS);
  pg.texture(textureImage);
  pg.vertex(a.x, a.y, a.z, 0.0, 0.0);
  pg.vertex(b.x, b.y, b.z, 1.0, 0.0);
  pg.vertex(c.x, c.y, c.z, 1.0, 1.0);
  pg.vertex(d.x, d.y, d.z, 0.0, 1.0);
  pg.endShape();
}
