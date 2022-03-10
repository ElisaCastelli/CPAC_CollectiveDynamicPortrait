//class Flock {
//  ArrayList<Boid> boids;
  
//  Flock() {
//    boids = new ArrayList<Boid>();
//  }
  
//  void run() {
//    for (Boid b : boids) {
//      b.run(boids);
//    }
//  }
  
//  void addBoid(Boid b) {
//    boids.add(b);
//  }
//}

class Flock {
  ArrayList<PVector> points;
  float radius;
  
  Flock() {
    radius = 20;
    points = new ArrayList<PVector>();
  }
  
  void addPoint(float x, float y) {
    PVector point = new PVector(x, y);
    points.add(point);
  }
}
