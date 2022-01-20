void setup() {
  size(800, 1000);
  background(235,235,235);
  frameRate(30);
}

void draw() {
  fill(255);
  rect(80, 80, 640, 840);
}

void mousePressed(){
  doExec();
}

String sep = System.getProperty("file.separator");

void doExec(){
Process p = exec("python test.py");
 try {
   int result = p.waitFor();
   println("the process returned " + result);
 } catch (InterruptedException e) { }
}
