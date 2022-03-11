class Flock {
  ArrayList<PVector> points;
  float radius;
  
  Flock() {
    radius = 10;
    points = new ArrayList<PVector>();
  }
  
  void addPoint(float x, float y) {
    PVector point = new PVector(x, y);
    points.add(point);
  }
}
