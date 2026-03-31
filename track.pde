class TrackSample {
  PVector center;
  PVector forward;
  PVector right;
  float travelledDistance;

  TrackSample(PVector center, PVector forward, PVector right, float travelledDistance) {
    this.center = center;
    this.forward = forward;
    this.right = right;
    this.travelledDistance = travelledDistance;
  }
}

class TrackPose {
  PVector center;
  PVector position;
  PVector forward;
  PVector right;
  float progress;

  TrackPose(PVector center, PVector position, PVector forward, PVector right, float progress) {
    this.center = center;
    this.position = position;
    this.forward = forward;
    this.right = right;
    this.progress = progress;
  }
}

class Track {
  ArrayList<PVector> controlPoints = new ArrayList<PVector>();
  ArrayList<TrackSample> samples = new ArrayList<TrackSample>();
  PImage roadTexture;

  float roadWidth = 150.0;
  int curveSubdivisions = 28;

  void initTrack() {
    buildControlPoints();
    roadTexture = buildRoadTexture();
    buildSamples();
  }

  // These control points define the main layout of the circuit.
  // Their Y value can be changed to create hills and dips in the road.
  void buildControlPoints() {
    controlPoints.clear();
    controlPoints.add(new PVector(-440, 0, -70));
    controlPoints.add(new PVector(-250, -55, -330));
    controlPoints.add(new PVector(80, -25, -360));
    controlPoints.add(new PVector(330, 0, -190));
    controlPoints.add(new PVector(390, -95, 120));
    controlPoints.add(new PVector(160, -35, 360));
    controlPoints.add(new PVector(-120, -110, 300));
    controlPoints.add(new PVector(-360, -40, 160));
  }

  void buildSamples() {
    samples.clear();

    float travelledDistance = 0.0;
    int pointCount = controlPoints.size();

    for (int i = 0; i < pointCount; i++) {
      PVector p0 = controlPoints.get((i - 1 + pointCount) % pointCount);
      PVector p1 = controlPoints.get(i);
      PVector p2 = controlPoints.get((i + 1) % pointCount);
      PVector p3 = controlPoints.get((i + 2) % pointCount);

      // Catmull-Rom to Bezier conversion lets the curve pass through each control point.
      PVector c1 = PVector.add(p1, PVector.mult(PVector.sub(p2, p0), 1.0 / 6.0));
      PVector c2 = PVector.sub(p2, PVector.mult(PVector.sub(p3, p1), 1.0 / 6.0));

      for (int step = 0; step < curveSubdivisions; step++) {
        float t = step / (float) curveSubdivisions;
        PVector center = bezierPoint3D(p1, c1, c2, p2, t);
        PVector forward = bezierTangent3D(p1, c1, c2, p2, t);
        forward.normalize();

        // The right vector is kept horizontal so lane switching remains stable on hills.
        PVector right = new PVector(-forward.z, 0, forward.x);
        right.normalize();

        if (!samples.isEmpty()) {
          travelledDistance += PVector.dist(samples.get(samples.size() - 1).center, center);
        }

        samples.add(new TrackSample(center, forward, right, travelledDistance));
      }
    }
  }

  PImage buildRoadTexture() {
    PImage textureImage = createImage(256, 512, RGB);
    textureImage.loadPixels();

    for (int y = 0; y < textureImage.height; y++) {
      for (int x = 0; x < textureImage.width; x++) {
        float edgeDistance = min(x, textureImage.width - 1 - x);
        boolean shoulder = edgeDistance < 22;
        boolean middleLine = abs(x - textureImage.width * 0.5) < 6 && ((y / 34) % 2 == 0);

        int asphalt = color(56 + (y % 18), 58 + (x % 7), 63 + (y % 13));
        int shoulderColor = color(188, 154, 92);
        int lineColor = color(242, 240, 208);

        int pixelColor = asphalt;
        if (shoulder) {
          pixelColor = shoulderColor;
        }
        if (middleLine) {
          pixelColor = lineColor;
        }

        textureImage.pixels[y * textureImage.width + x] = pixelColor;
      }
    }

    textureImage.updatePixels();
    return textureImage;
  }

  void displayTrack(PGraphics pg, PVector referencePoint, boolean useFog) {
    if (samples.isEmpty() || roadTexture == null) {
      return;
    }

    pg.pushStyle();
    pg.noStroke();
    pg.textureMode(NORMAL);

    for (int i = 0; i < samples.size(); i++) {
      TrackSample current = samples.get(i);
      TrackSample next = samples.get((i + 1) % samples.size());

      PVector currentLeft = PVector.sub(current.center, PVector.mult(current.right, roadWidth * 0.5));
      PVector currentRight = PVector.add(current.center, PVector.mult(current.right, roadWidth * 0.5));
      PVector nextLeft = PVector.sub(next.center, PVector.mult(next.right, roadWidth * 0.5));
      PVector nextRight = PVector.add(next.center, PVector.mult(next.right, roadWidth * 0.5));

      PVector quadCenter = lerpVector(current.center, next.center, 0.5);
      float fogAmount = useFog ? computeFogAmount(quadCenter, referencePoint) : 0.0;
      int tintColor = lerpColor(color(255), getFogColor(), fogAmount * 0.85);
      if (nightMode) {
        tintColor = lerpColor(tintColor, color(82, 88, 106), 0.38);
      }

      pg.tint(tintColor);
      pg.beginShape(QUADS);
      pg.texture(roadTexture);
      pg.vertex(currentLeft.x, currentLeft.y, currentLeft.z, 0.0, 0.0);
      pg.vertex(currentRight.x, currentRight.y, currentRight.z, 1.0, 0.0);
      pg.vertex(nextRight.x, nextRight.y, nextRight.z, 1.0, 1.0);
      pg.vertex(nextLeft.x, nextLeft.y, nextLeft.z, 0.0, 1.0);
      pg.endShape();
    }

    pg.noTint();
    pg.popStyle();
  }

  TrackPose samplePose(float progress, float lane) {
    if (samples.isEmpty()) {
      return new TrackPose(new PVector(), new PVector(), new PVector(0, 0, 1), new PVector(1, 0, 0), 0);
    }

    float wrappedProgress = wrapProgress(progress);
    int baseIndex = floor(wrappedProgress);
    int nextIndex = (baseIndex + 1) % samples.size();
    float t = wrappedProgress - baseIndex;

    TrackSample a = samples.get(baseIndex);
    TrackSample b = samples.get(nextIndex);

    PVector center = lerpVector(a.center, b.center, t);
    PVector forward = lerpVector(a.forward, b.forward, t);
    forward.normalize();

    PVector right = lerpVector(a.right, b.right, t);
    right.y = 0;
    right.normalize();

    PVector position = PVector.add(center, PVector.mult(right, lane * roadWidth * 0.42));
    return new TrackPose(center, position, forward, right, wrappedProgress);
  }

  float wrapProgress(float progress) {
    return wrapValue(progress, samples.size());
  }

  PVector bezierPoint3D(PVector p0, PVector p1, PVector p2, PVector p3, float t) {
    return new PVector(
      bezierPoint(p0.x, p1.x, p2.x, p3.x, t),
      bezierPoint(p0.y, p1.y, p2.y, p3.y, t),
      bezierPoint(p0.z, p1.z, p2.z, p3.z, t)
    );
  }

  PVector bezierTangent3D(PVector p0, PVector p1, PVector p2, PVector p3, float t) {
    return new PVector(
      bezierTangent(p0.x, p1.x, p2.x, p3.x, t),
      bezierTangent(p0.y, p1.y, p2.y, p3.y, t),
      bezierTangent(p0.z, p1.z, p2.z, p3.z, t)
    );
  }
}
