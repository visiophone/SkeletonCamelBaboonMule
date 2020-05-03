/* //<>//
Experiments with Skeleton Tracing by Lingdong Huang (2020).
Capturing in realtime the skeleton of three diferent animals and exploring abstract movement visualizations.
The animal motion is taken from Eadweard Muybridge Animal Locomotion Studies (1887) 
.
Made with Processing using TraceSkeleton by Lingdong Huang 
https://github.com/LingDong-/skeleton-tracing
And Mesh Library by Lee Byron
http://leebyron.com/mesh/
.
Rodrigo Carvalho / Visiophone / 2020
www.visiophone-lab.com
*/


import java.io.*; //<>// //<>//
import java.lang.reflect.*;
import java.lang.*;
import java.awt.geom.AffineTransform;
import java.util.*;

import traceskeleton.*;
import processing.video.*;
import megamu.mesh.*;

float scl = 4;

PGraphics pg;
ArrayList<ArrayList<int[]>>  c;
ArrayList<int[]> rects = new ArrayList<int[]>();
boolean[]  im;
int W = 300;
int H = 169;
PImage img;

// videos, the original, and the back pic
Movie movA1;
Movie movA2;

Movie movB1;
Movie movB2;

Movie movC1;
Movie movC2;

// BOOLEANS FOR KEYS ON/OFF, MODES, ...
boolean gui=true;
boolean backPic=true;
boolean originalVid=true;
boolean rectss=false; // rects matrix On Off
boolean skeleton=true;

int nr = 250;
float [] skelX = new float [nr]; // arrays to copy the skel pos
float [] skelY = new float [nr];

float [] slowX = new float [nr]; // smoother version skel pos
float [] slowY = new float [nr];


int mode=0; // vizz mode

int animal = 1; // change animal

/// MESHH
float[][] points = new float[nr][2]; // VORONOI POINTS

// Array of Pvectors to store and draw repetitions of the contour HULL
PVector[][] countor = new PVector[20][50];

void setup() {
  size(1280, 720);

  movA1 = new Movie(this, "cammel_BW.mp4");
  movA1.loop();

  movA2 = new Movie(this, "cammel_original.mp4");
  movA2.loop();

  movB1 = new Movie(this, "baboon_BW.mp4");
  movB1.loop();

  movB2 = new Movie(this, "baboon_original.mp4");
  movB2.loop();

  movC1 = new Movie(this, "mule_BW.mp4");
  movC1.loop();

  movC2 = new Movie(this, "mule_original.mp4");
  movC2.loop();

  pg = createGraphics(W, H);
  pg.beginDraw();
  pg.background(0);
  pg.image(movA1, 0, 0);
  pg.endDraw();

  im = new boolean[W*H];

  // Initiate points
  for (int i=0; i<points.length; i++) {
    points[i][0]=width/2;
    points[i][1]=height/2;
  }

  // Initiate Countor Pvectors Array
  for (int i=0; i<20; i++) {

    for (int j=0; j<50; j++) {
      countor[i][j] = new PVector(width/2, height/2);
    }
  }
}
void draw() {
  background(0);

  // Image that will be checked to trace the Skeleton
  pg.beginDraw();
  pg.noFill();
  pg.strokeWeight(10);
  pg.stroke(255);
  //pg.line(pmouseX/scl, pmouseY/scl, mouseX/scl,mouseY/scl);
  if (animal==1) pg.image(movA1, 0, 0);
  else if (animal==2)  pg.image(movB1, 0, 0);
  else pg.image(movC1, 0, 0);

  pg.loadPixels();

  // CHECKS Image Pixels. Checks for wite pixels. And TraceSkeleton on white Areas  
  for (int i = 0; i < im.length; i++) {
    im[i] = (pg.pixels[i]>>16&0xFF)>128;
  }
  TraceSkeleton.thinningZS(im, W, H);
  pg.endDraw();
  pg.updatePixels(); // only need this on videos. Not with still images

  // Rect Areas withting the sketleton
  rects.clear();
  c = TraceSkeleton.traceSkeleton(im, W, H, 0, 0, W, H, 10, 999, rects);

  //// Show Skeletized image under the skeleton
  pushMatrix();
  scale(scl);
  tint(255, 100);
  if (backPic) image(pg, 0, 0);
  popMatrix();
  ////// 

  // RECTS 
  if (rectss) {
    noFill(); 
    for (int i = 0; i < rects.size(); i++) {
      stroke(255, 0, 0);
      rect(rects.get(i)[0]*scl, rects.get(i)[1]*scl, rects.get(i)[2]*scl, rects.get(i)[3]*scl);
    }
  } 

  strokeWeight(1);
  noFill();
  int counter=0; // counting the nr of points on each skeleton

  for (int i = 0; i < c.size(); i++) {
    stroke(255, 0, 0);
    beginShape();
    for (int j = 0; j < c.get(i).size(); j++) {

      if (skeleton) {
        //Draw Skeleton
        stroke(255);
        noFill();
        vertex(c.get(i).get(j)[0]*scl, c.get(i).get(j)[1]*scl);   // AQUI ESTÃO OS PONTOS
        rect(c.get(i).get(j)[0]*scl-2, c.get(i).get(j)[1]*scl-2, 4, 4);
      }

      float x= c.get(i).get(j)[0]*scl-2;
      float y= c.get(i).get(j)[1]*scl-2;

      skelX[counter]=x; // arrays to store skel X Y
      skelY[counter]=y;

      slowX[counter]+=(skelX[counter]-slowX[counter])*0.1;
      slowY[counter]+=(skelY[counter]-slowY[counter])*0.1;

      points[counter][0]=skelX[counter];
      points[counter][1]=skelY[counter];

      counter++; // counts the number of points
    }
    endShape();
  }


  ////////////////// MODE 1
  if (mode==1) {

    stroke(255);

    Voronoi myVoronoi = new Voronoi(points);
    MPolygon[] myRegions = myVoronoi.getRegions();

    for (int i=0; i<counter; i++)
    {

      // if(i<30)println(i+" "+points[i][0]+" , "+points[i][0]);

      //stroke(255);
      noStroke();
      fill(i, 100);
      //noFill();
      float[][] regionCoordinates = myRegions[i].getCoords();
      // myRegions[i].draw(this); // draw this shape
    }

    float[][] myEdges = myVoronoi.getEdges();
    for (int i=0; i<myEdges.length; i++)

    {
      float startX = myEdges[i][0];
      float startY = myEdges[i][1];
      float endX = myEdges[i][2];
      float endY = myEdges[i][3];
      stroke(255, 120);
      line( startX, startY, endX, endY );
    }



    Delaunay myDelaunay = new Delaunay( points );

    float[][] myEdges2 = myDelaunay.getEdges();

    stroke(255, 200);

    for (int i=0; i<counter; i++)
    {
      float startX = myEdges2[i][0];
      float startY = myEdges2[i][1];
      float endX = myEdges2[i][2];
      float endY = myEdges2[i][3];
      line( startX, startY, endX, endY );
    }
  }

  ////////////////// MODE 2

  if (mode==2) {

    Delaunay myDelaunay = new Delaunay( points );

    float[][] myEdges = myDelaunay.getEdges();
    stroke(255, 200);

    for (int i=0; i<myEdges.length; i++)
    {
      float startX = myEdges[i][0];
      float startY = myEdges[i][1];
      float endX = myEdges[i][2];
      float endY = myEdges[i][3];
      line( startX, startY, endX, endY );
    }
  }

  ////////////////// MODE 3

  if (mode==3) {

    Hull myHull = new Hull( points );

    MPolygon myRegion = myHull.getRegion();
    //fill(255,0,0,100);
    noFill();
    stroke(255);
    myRegion.draw(this);

    int[] extrema = myHull.getExtrema();

    pushMatrix();
    translate(width/2, height/2);

    for (int i=0; i<extrema.length; i++) {

      countor[i][0].x=map(points[extrema[i]][0], 0, width, -(width/2), (width/2));
      countor[i][0].y=map(points[extrema[i]][1], 0, height, -(height/2), (height/2));

      fill(255);
      ellipse(countor[i][0].x, countor[i][0].y, 2, 2);



      // Interior countor repetitions
      for (int j=1; j<30; j++) {

        countor[i][j].x = countor[i][j-1].x*0.93;
        countor[i][j].y = countor[i][j-1].y*0.93;

        int colorr=int(map(j, 0, 20, 255, 0));
        colorr=constrain(colorr, 0, 255);
        stroke(colorr,170);
        fill(colorr,170);
        //println(j+" "+colorr);
        ellipse(countor[i][j].x, countor[i][j].y, 2, 2); 

        if (i!=0) line(countor[i][j].x, countor[i][j].y, countor[i-1][j].x, countor[i-1][j].y);
      }


      // External countor repetitions
      countor[i][30].x=countor[i][0].x;
      countor[i][30].y=countor[i][0].y;
     
      for (int j=31; j<50; j++) {

        countor[i][j].x = countor[i][j-1].x*1.07;
        countor[i][j].y = countor[i][j-1].y*1.07;


        int colorr=int(map(j, 30, 40, 255, 0));
        colorr=constrain(colorr, 0, 255);
        stroke(colorr,170);
        fill(colorr,170);
        //println(j+" "+colorr);
        ellipse(countor[i][j].x, countor[i][j].y, 2, 2); 

        if (i!=0) line(countor[i][j].x, countor[i][j].y, countor[i-1][j].x, countor[i-1][j].y);
      }
    }

    popMatrix();
  }


  ////////////////// MODE 4

  if (mode==4) {
    stroke(255);
    for (int i=0; i<counter; i++) {     
      line (skelX[i], skelY[i], skelX[i], height/2);
    }
  }

  ////////////////// MODE 5
  if (mode==5) {    
    for (int i=0; i<counter; i++) { 
      // fill(255);
      stroke(255);
      if (skelY[i]<height/2) line(skelX[i], skelY[i], skelX[i], skelY[i]-100);   
      else line(skelX[i], skelY[i], skelX[i], skelY[i]+100);
    }
  }

  ////////////////// MODE 6
  if (mode==6) {
    stroke(255);
    for (int i=0; i<counter; i++) { 
      if (skelY[i]<=height/2)line (skelX[i], skelY[i], skelX[i], 0);
      else line (skelX[i], skelY[i], skelX[i], height);
    }
  }


  //////////////////// Original Video
  if (originalVid) {
    tint(255, 255);
    if (animal==1) image(movA2, width-width/4, 0, width/4, height/4);
    else if (animal==2) image(movB2, width-width/4, 0, width/4, height/4);
    else image(movC2, width-width/4, 0, width/4, height/4);
  }

  //////////////////// GUI

  if (gui) {
    noStroke();
    fill(0, 20);
    rect(0, 0, 100, 200);

    fill(255);
    text("FPS :"+int(frameRate), 10, 20);
    fill(255);
    text("NrPoints: "+counter, 10, 40); // number points in the skeleton

    text("KEYS ON/OFF:", 10, 70);
    text("[G] GUI", 10, 90);
    text("[B] BACK.PIC ", 10, 110);
    text("[V] VID ", 10, 130);
    text("[R] RECTS ", 10, 150);
    text("[S] SKELETON ", 10, 170);

    text("[0 - 6] MODE", 10, 210);
    text("MODE: "+mode, 10, 230);

    text("[Q] [W] [E] ANIMAL", 10, 250);
  }
}

////////////////////////////////////////////////////////////

void keyPressed() {

  if (key=='g' || key=='G') gui=!gui;
  if (key=='b' || key=='B') backPic=!backPic;
  if (key=='v' || key=='V') originalVid=!originalVid;
  if (key=='r' || key=='R') rectss=!rectss;
  if (key=='s' || key=='S') skeleton=!skeleton;

  if (key=='Q' || key=='q') animal=1;
  if (key=='W' || key=='w') animal=2;
  if (key=='E' || key=='e') animal=3;


  if (key=='0') {
    mode=0;
    gui=true;
    backPic=true;
    skeleton=true;
  }
  if (key=='1') mode=1;
  if (key=='2') mode=2;
  if (key=='3') mode=3;
  if (key=='4') mode=4;
  if (key=='5') {
    mode=5;
  }
  if (key=='6') {
    mode=6;
  }
  if (key=='7') {
    mode=7;
  }
}


//
void movieEvent(Movie m) {
  m.read();
}
