// Fluid Simulation
// Daniel Shiffman
// https://thecodingtrain.com/CodingChallenges/132-fluid-simulation.html
// https://youtu.be/alhpH6ECFvQ

// This would not be possible without:
// Real-Time Fluid Dynamics for Games by Jos Stam
// http://www.dgp.toronto.edu/people/stam/reality/Research/pdf/GDC03.pdf
// Fluid Simulation for Dummies by Mike Ash
// https://mikeash.com/pyblog/fluid-simulation-for-dummies.html

final int N = 1920;
final int M = 1080;
final int iter = 16;
final int SCALE = 3;
float t = 0;

Fluid fluid;

void settings() {
  size(N*SCALE, M*SCALE);
  println(displayWidth);
    println(displayHeight);
  
}

void setup() {
  fluid = new Fluid(0.2, 0, 0.0000001);
}

//void mouseDragged() {
//}

void draw() {
  background(0);
  //cambia la posizione del coso in mezzo che genera il fluido 
  int cx = int(0.5*width/SCALE);
  int cy = int(0.5*height/SCALE);
  for (int i = -1; i <= 1; i++) {
    for (int j = -1; j <= 1; j++) {
      fluid.addDensity(cx+i, cy+j, random(50, 100));//densità del fluido, se diminuisco il range, viene più effetto fumo (initial one: 50, 150);
    }
  }
  
  //CHANGE TIMING 
  for (int i = 0; i < 5; i++) {
    float angle = noise(t) * TWO_PI * 2;
    PVector v = PVector.fromAngle(angle);
    v.mult(0.09);
    t += 0.01;
    fluid.addVelocity(cx, cy, v.x, v.y );
  }


  fluid.step();
  fluid.renderD();
  //fluid.renderV();
  //fluid.fadeD();
}
