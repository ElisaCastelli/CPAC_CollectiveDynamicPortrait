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
    for(int j=0; j<soundtrack_player.bufferSize()-1; j++){
      strokeWeight(abs(1+soundtrack_player.right.get(j)*100));
    }
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
