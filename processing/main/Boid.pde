//class Boid {
//  PVector location;
//  PVector velocity;
//  PVector acceleration;
//  float r;
//  float maxforce;
//  float maxspeed;
//  float align_neighbordist = 50;
//  float cohesion_neighbordist = 50;
//  float desiredseparation = 0.0f;
  
//  Boid(float x, float y) {
//    location = new PVector(x, y);
//    velocity = new PVector(random(-1,1), random(-1,1));
//    acceleration = new PVector(0, 0);
//    r = 3.0;
//    maxforce = 0.03;
//    maxspeed = 3;
//  }
  
//  void run(ArrayList<Boid> boids) {
//    flock(boids);
//    update();
//    borders();
//    render();
//  }
  
//  void applyForce(PVector force) {
//    acceleration.add(force);
//  }
  
//  void flock(ArrayList<Boid> boids) {
//    PVector ali = align(boids);
//    PVector coh = cohesion(boids);
//    PVector sep = separate(boids);
//    ali.mult(1.0);
//    coh.mult(1.0);
//    sep.mult(1.5);
//    applyForce(ali);
//    applyForce(coh);
//    applyForce(sep);
//  }
  
//  void update() {
//    velocity.add(acceleration);
//    velocity.limit(maxspeed);
//    location.add(velocity);
//    acceleration.mult(0);
//  }
  
//  PVector seek(PVector target) {
//    PVector desired = PVector.sub(target, location);
//    desired.normalize();
//    desired.mult(maxspeed);
//    PVector steer = PVector.sub(desired, velocity);
//    steer.limit(maxforce);
//    return steer;
//  }
  
//  void render() {
//    float theta = velocity.heading2D() + radians(90);
//    fill(255);
//    stroke(0);
//    pushMatrix();
//    translate(location.x, location.y);
//    rotate(theta);
//    beginShape(TRIANGLES);
//    vertex(0, -r*2);
//    vertex(-r, r*2);
//    vertex(r, r*2);
//    endShape();
//    popMatrix();
//  }
  
//  void borders() {
//    if (location.x < -r) location.x = width + r;
//    if (location.y < -r) location.y = height + r;
//    if (location.x > width+r) location.x = -r;
//    if (location.y > height+r) location.y = -r;
//  }
  
//  // Alignment
//  // For every nearby boid in the system, calculate the average velocity
//  PVector align(ArrayList<Boid> boids) {
//    PVector sum = new PVector(0, 0);
//    int count = 0;
    
//    for (Boid other : boids) {
//      float d = PVector.dist(location, other.location);
      
//      if ((d > 0) && (d < align_neighbordist)) {
//        sum.add(other.velocity);
//        count++;
//      }
//    }
    
//    if (count > 0) {
//      sum.div((float)count);
//      sum.normalize();
//      sum.mult(maxspeed);
//      PVector steer = PVector.sub(sum,velocity);
//      steer.limit(maxforce);
//      return steer;
//    } else {
//      return new PVector(0,0);
//    }
//  }
  
//  // Cohesion
//  // For the average location (i.e. center) of all nearby boids, calculate steering vector towards that location
//  PVector cohesion (ArrayList<Boid> boids) {
//    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all locations
//    int count = 0;
//    for (Boid other : boids) {
//      float d = PVector.dist(location, other.location);
//      if ((d > 0) && (d < cohesion_neighbordist)) {
//        sum.add(other.location); // Add location
//        count++;
//      }
//    }
//    if (count > 0) {
//      sum.div(count);
//      return seek(sum);  // Steer towards the location
//    } else {
//      return new PVector(0,0);
//    }
//  }
  
//  // Separation
//  // Method checks for nearby boids and steers away
//  PVector separate (ArrayList<Boid> boids) {
//    //float desiredseparation = 25.0f;
//    PVector steer = new PVector(0, 0, 0);
//    int count = 0;
//    // For every boid in the system, check if it's too close
//    for (Boid other : boids) {
//      float d = PVector.dist(location, other.location);
//      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
//      if ((d > 0) && (d < desiredseparation)) {
//        // Calculate vector pointing away from neighbor
//        PVector diff = PVector.sub(location, other.location);
//        diff.normalize();
//        diff.div(d);        // Weight by distance
//        steer.add(diff);
//        count++;            // Keep track of how many
//      }
//    }
//    // Average -- divide by how many
//    if (count > 0) {
//      steer.div((float)count);
//    }

//    // As long as the vector is greater than 0
//    if (steer.mag() > 0) {
//      // Implement Reynolds: Steering = Desired - Velocity
//      steer.normalize();
//      steer.mult(maxspeed);
//      steer.sub(velocity);
//      steer.limit(maxforce);
//    }
//    return steer;
//  }
//}

class Boid {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;
  float maxspeed;
  
  Boid(PVector l, float ms, float mf) {
    position = l.get();
    r = 3;
    maxspeed = ms;
    maxforce = mf;
    acceleration = new PVector(0, 0);
    velocity = new PVector(maxspeed, 0);
  }
  
  void applyBehaviors(ArrayList boids, Flock path) {
    PVector f = follow(path);
    PVector s = separate(boids);
    f.mult(3);
    s.mult(1);
    applyForce(f);
    applyForce(s);
  }
  
  void applyForce(PVector force) {
    acceleration.add(force);
  }
  
  public void run(int r, int g, int b) {
    update();
    borders();
    render(r, g, b);
  }
  
  PVector follow(Flock p) {
    PVector predict = velocity.get();
    predict.normalize();
    predict.mult(25);
    PVector predictpos = PVector.add(position, predict);
    
    PVector normal = null;
    PVector target = null;
    float worldRecord = 1000000;
    
    for (int i=0; i<p.points.size(); i++) {
      PVector a = p.points.get(i);
      PVector b = p.points.get((i+1)%p.points.size());
      
      PVector normalPoint = getNormalPoint(predictpos, a, b);
      
      PVector dir = PVector.sub(b, a);
      
      if (normalPoint.x<min(a.x,b.x) || normalPoint.x>max(a.x,b.x) || normalPoint.y<min(a.y,b.y) || normalPoint.y>max(a.y,b.y)) {
        normalPoint = b.get();
        a = p.points.get((i+1)%p.points.size());
        b = p.points.get((i+2)%p.points.size());
        dir = PVector.sub(b, a);
      }
      
      float d = PVector.dist(predictpos, normalPoint);
      if (d < worldRecord) {
        worldRecord = d;
        normal = normalPoint;
        dir.normalize();
        dir.mult(25);
        target = normal.get();
        target.add(dir);
      }
    }
    
    if (worldRecord > p.radius) {
      return seek(target);
    }
    else {
      return new PVector(0,0);
    }
  }
  
  PVector getNormalPoint(PVector p, PVector a, PVector b) {
    PVector ap = PVector.sub(p, a);
    PVector ab = PVector.sub(b, a);
    ab.normalize();
    ab.mult(ap.dot(ab));
    PVector normalPoint = PVector.add(a, ab);
    return normalPoint;
  }
  
  PVector separate (ArrayList boids) {
    float desiredseparation = r*2;
    PVector steer = new PVector(0,0,0);
    int count = 0;
    for (int i=0; i<boids.size(); i++) {
      Boid other = (Boid) boids.get(i);
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < desiredseparation)) {
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);
        steer.add(diff);
        count++;
      }
    }
    
    if (count > 0) {
      steer.div((float)count);
    }
    
    if (steer.mag() > 0) {
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    
    return steer;
  }
  
  void update() {
    velocity.add(acceleration);
    velocity.limit(maxspeed);
    position.add(velocity);
    acceleration.mult(0);
  }
  
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);
    desired.normalize();
    desired.mult(maxspeed);
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);
    return steer;
  }
  
  void render(int red, int green, int blue) {
    fill(red, green, blue);
    stroke(0);
    pushMatrix();
    translate(position.x, position.y);
    ellipse(0, 0, r, r);
    popMatrix();
  }
  
  void borders() {
    if (position.x < -r) position.x = width + r;
    if (position.y < -r) position.y = height + r;
    if (position.x > width+r) position.x = -r;
    if (position.y > height+r) position.y = -r;
  }
}
