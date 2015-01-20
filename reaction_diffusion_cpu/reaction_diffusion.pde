/*
** Press any key to bring up GUI to change feed and kill rate.
** Click and drag to spawn "chemical B".
** CPU port of https://pmneila.github.io/jsexp/grayscott/
*/

import controlP5.*;

boolean show_gui = false;

float  feed=0.037, kill=0.06;
float delta = 1;
int brush_size = 10;
int iterations_per_frame = 8;

float[][][] grid;
float[][][] grid_copy;
//[0,0]=left, [1,0]=right, [0,1]=up, [1,1]=down
float[] current; 
float[][][] selection; 

final int A = 0;
final int B = 1;

float[] lapl, dst;

int grid_w, grid_h;

/* GUI stuff */
ControlP5 cp5;
Slider feed_slider, kill_slider;

void setup(){
  randomSeed(second()*year()*month()*minute());
  size (300,300);
  grid_w = width;
  grid_h = height;
  grid = init_grid();
  grid_copy = init_grid();
  selection = new float[4][4][2];
  current = new float[2];
  lapl = new float[2];
  dst = new float[2];
  
  colorMode(HSB,255);
  
  /* GUI */
  cp5 = new ControlP5(this);
  kill_slider = cp5.addSlider("Kill")
     .setRange(0.0,0.1)
     .setValue(kill)
     .setPosition(0,0)
     .setSize(3*width/4,10)
     ;
   kill_slider.addCallback(new CallbackListener(){
     public void controlEvent(CallbackEvent theEvent) {
      if (theEvent.getAction()==ControlP5.ACTION_BROADCAST) {
        kill = kill_slider.getValue();
    }
  }
   });
  
  feed_slider = cp5.addSlider("Feed")
     .setRange(0.0,0.1)
     .setValue(feed)
     .setPosition(0,15)
     .setSize(3*width/4,10);
     
   feed_slider.addCallback(new CallbackListener(){
     public void controlEvent(CallbackEvent theEvent) {
      if (theEvent.getAction()==ControlP5.ACTION_BROADCAST) {
        feed = feed_slider.getValue();
    }
  }
   });
     
  set_gui_visible(show_gui);
}

void draw(){
  noStroke();
  background(0);
  
  grid = solve(iterations_per_frame, grid, grid_copy);
  loadPixels();
  for (int x=0;x<grid.length;++x){
      float[][] row = grid[x];
      for (int y=0;y<row.length;++y){
        float cell = grid[x][y][A];
        //stroke(255*cell);
        pixels[y*width+x] = color(255*cell,200,200);
      }
  }
  updatePixels();
  
}

float[][][] init_grid(){
  float[][][] g = new float[grid_w][grid_h][2];
  float d, a, b;
  for (int x=0;x<g.length;++x){
    float[][] row = g[x];
    for (int y=0;y<row.length;++y){
      d = 1.0*random(100)/10000.0;
      a = y>grid_w/2?1.0-d:d;//d;
      b = y>grid_h/2?d:1.0-d;//1-d;
      row[y][A]= a;
      row[y][B]= b;
    }
  }
  return g;
}

void copy_cell(float[] S, float[] out){
  out[A] =  S[A];
  out[B] =  S[B];
}

void get_cell (float[][][] S, int x, int y, float[] output){
  float[][] sx;
  if (x >= S.length){
    x = 0;
  }else if (x<0){
    x = S.length-1;
  }
  sx = S[A];
  if (y >= sx.length){
    y = 0;
  }else if (y<0){
    y = sx.length-1;
  }
  copy_cell(S[x][y], output);
}

void get_surrounding(float[][][] S, int x, int y){
  get_cell(S, x-1,y, selection[A][A]); //left
  get_cell(S, x+1,y, selection[B][A]); //right
  get_cell(S, x,y+1, selection[A][B]); //up
  get_cell(S, x,y-1, selection[B][B]); //down
}

float[][][] solve(int iterations, float[][][] source, float[][][] out){
  float[][][] S = source;
  while (iterations-- > 0){
    for (int x=0;x<S.length;++x){
      float[][] row = S[x];
      for (int y=0;y<row.length;++y){
        get_cell (S, x,y, current);
        get_surrounding (S, x, y);
        for(int i=0;i<2;++i){
          lapl[i] = selection[A][A][i] + 
                    selection[A][B][i] +
                    selection[B][A][i] +
                    selection[B][B][i] -
                    current[i]*4.0;
        }
        float da = 0.2097f *lapl[A] - 
                current[A]*current[B]*current[B] +
                feed*(1.0 - current[A]);
        float db = 0.105f *lapl[B] + 
                current[A]*current[B]*current[B] -
                (feed + kill)*current[B];
        
        dst[A] = current[A] + delta * da;
        dst[B] = current[B] + delta * db;
        if(mousePressed && dist(mouseX,mouseY,x,y)<brush_size){
          dst[B] = 0.9;
        }
        copy_cell (dst, out[x][y]);
      }
    }
    float[][][] tmp = out;
    out = S;
    S = out;
  }
  return S;
}

void slider(float val) {
  kill = cp5.getController("Kill").getValue();
  feed = cp5.getController("Feed").getValue();
  println("kill: "+kill+"\nfeed: "+feed);
}

void set_gui_visible(boolean show_gui){
  if (show_gui){
     cp5.show();
   }else{
     cp5.hide();
   }
}

void keyPressed(){
  show_gui = !show_gui;
  set_gui_visible(show_gui);
}
