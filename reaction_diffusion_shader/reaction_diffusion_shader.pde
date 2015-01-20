// This sketch isn't working.

float  feed=0.037, kill=0.06;
float delta = 1;

PShader grey_scott;
PGraphics grid, grid_copy;
PVector brush; //0..1

PGraphics init_graphics(int w, int h){
  PGraphics g = createGraphics(w,h, P2D);
  return g;
}

void setup(){
  size(640, 360, P2D);
  grey_scott = loadShader("grey_scott.frag.glsl");
  grey_scott.set("screenWidth", float(width));
  //.setTexture(image)
  grey_scott.set("screenHeight", float(height));
  grey_scott.set("brush", brush.x, brush.y);
  grid = init_graphics(width,height);
  grid_copy = init_graphics(width,height);
  brush = new PVector(0.5,0.5); //0..1
  
  //clear grid to black
  grid.beginDraw();
  grid.background(255,0,0);
  grid.endDraw();
}

void draw(){
  /*grey_scott.set ("delta", 0.8);
  grey_scott.set ("feed", feed);
  grey_scott.set ("kill", kill);*/
  PGraphics S = grid;
  PGraphics out = grid_copy;
  //shader (grey_scott);
  for (int i=0;i<8;++i){
    out.beginDraw();
    image (S, 0,0, width,height);
    out.endDraw();
    PGraphics tmp = S;
    S = out;
    out = tmp;
  }
  resetShader();
  S = grid;
  grid_copy = out;
  image(grid, 0, 0, width,height);
}
