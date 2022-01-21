import Runtime


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
//Process p = exec("python ." + sep +"test.py");
Process p = Runtime.getRuntime().exec("python style_transfer_demo.py 1 1");
 try {
   int result = p.waitFor();
   println("the process returned " + result);
 } catch (InterruptedException e) { }
}
