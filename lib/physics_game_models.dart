import 'dart:math' as math;

const gravity = 9.8;

double projectileHeightAt(double distance, double speed, double angleDegrees) {
  final angle = angleDegrees * math.pi / 180;
  final horizontalSpeed = speed * math.cos(angle);
  if (horizontalSpeed <= 0) return double.negativeInfinity;
  final time = distance / horizontalSpeed;
  return speed * math.sin(angle) * time - gravity * time * time / 2;
}

double projectileRange(double speed, double angleDegrees) {
  final angle = angleDegrees * math.pi / 180;
  return speed * speed * math.sin(2 * angle) / gravity;
}

bool projectileHits({
  required double distance,
  required double height,
  required double speed,
  required double angle,
  double tolerance = 1.7,
}) {
  return projectileRange(speed, angle) >= distance &&
      (projectileHeightAt(distance, speed, angle) - height).abs() <= tolerance;
}

double lensImageDistance(double objectDistance, double focalLength) {
  if (objectDistance <= focalLength) return double.infinity;
  return objectDistance * focalLength / (objectDistance - focalLength);
}

double energyAtFinish({
  required double mass,
  required double height,
  required double springCompression,
  required double friction,
  double trackLength = 5,
}) {
  final initial =
      mass * gravity * height + .5 * 40 * springCompression * springCompression;
  final lost = friction * mass * gravity * trackLength;
  return math.max(0, initial - lost);
}

double finishSpeed({
  required double mass,
  required double height,
  required double springCompression,
  required double friction,
  double trackLength = 5,
}) {
  final kinetic = energyAtFinish(
    mass: mass,
    height: height,
    springCompression: springCompression,
    friction: friction,
    trackLength: trackLength,
  );
  return math.sqrt(2 * kinetic / mass);
}
