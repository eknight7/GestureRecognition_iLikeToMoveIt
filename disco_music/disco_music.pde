import SimpleOpenNI.*;
SimpleOpenNI  kinect;

import ddf.minim.*;

/* Music player */
Minim minim;
int numSongs = 2;
AudioPlayer[] player = new AudioPlayer[numSongs];
int buffSize = 2048;
String song1 = new String("Don't Stop Believing.wav");
String song2 = new String("Code Monkey.wav");
PFont font;
int time1, time2, time3;


/* Kinect */
PVector[] right_fist = new PVector[0];
PVector[] current_right_arm_torso = new PVector[0]; // [0] = right_hand; [1] = right_elbow; [2] = right_shoulder; [3] = torso
PVector[] previous_right_arm_torso = new PVector[0]; // [0] = right_hand; [1] = right_elbow; [2] = right_shoulder; [3] = torso

int time_check = 5000;
boolean start = false; // IMPORTANT : SKELETON HAS BEEN TRACKED
int tracking = 0;
int last_time;
int gesture = 0; // for music player and kinect

// DISCO gesture
boolean check2_disco = false;
boolean check3_disco = false;
boolean check4_disco = false;

// window height, width
int windowW = 1280;
int windowH = 530;
int pgstart = 650;

void setup() {
  size(windowW,windowH);
  

  /* Kinect */
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  kinect.setMirror(true); // reflect the image so that it is in the user's perspective
  strokeWeight(5);

  /* Music player */
  fill(255);
  textAlign(CENTER);
  font = loadFont("Centaur-48.vlw");
  textFont(font);
  
  minim = new Minim(this);
  player[0] = minim.loadFile(song1, buffSize);
  player[1] = minim.loadFile(song2, buffSize);
  
}

void draw() {
  
  background(0);
  kinect.update();
  draw_music();
  strokeWeight(5);
  stroke(0,0,255);
  image(kinect.depthImage(), 0, 0,640,480);
  fill(255,0,0);
  text("DISCO : ", 100, 510);
  
  IntVector userList = new IntVector();
  kinect.getUsers(userList);
  if (userList.size() > 0) {

    int userId = userList.get(0);
    if ( kinect.isTrackingSkeleton(userId)) {
      drawSkeleton(userId);
      
      /*if (check4_disco){
        while(millis() - last_time < 30000){ // play for 30 seconds
          //playing music
          fill(0,255,0);
          text("YES", 300, 510);
        }
        check4_disco = false;
        pauseAll();
      }*/
      
      if ((millis() - last_time) < 5000) println("NOT YET Checking gest");
      
      
      PVector right_hand = new PVector();
      kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,right_hand);
      PVector right_elbow = new PVector();
      kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_ELBOW,right_elbow);
      PVector right_shoulder = new PVector();
      kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_SHOULDER,right_shoulder);
      PVector torso = new PVector();
      kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_TORSO, torso);
      
      PVector[] temp = new PVector[0];
      temp = (PVector[])append(temp, current_right_arm_torso[0]); // [0] = right_hand
      temp = (PVector[])append(temp, current_right_arm_torso[1]); // [1] = right_elbow
      temp = (PVector[])append(temp, current_right_arm_torso[2]); //[2] = right_shoulder
      temp = (PVector[])append(temp, current_right_arm_torso[3]); //[3] = torso
      
      current_right_arm_torso = new PVector[0];
      current_right_arm_torso = (PVector[])append(current_right_arm_torso, right_hand); // [0] = right_hand
      current_right_arm_torso = (PVector[])append(current_right_arm_torso, right_elbow); // [1] = right_elbow
      current_right_arm_torso = (PVector[])append(current_right_arm_torso, right_shoulder); //[2] = right_shoulder
      current_right_arm_torso = (PVector[])append(current_right_arm_torso, torso); //[3] = torso
      
      if (start && tracking == 0 && !((millis() - last_time) < 5000)){
        
        // disco_go_down
        if (ch_thresh_less(right_hand.y, right_elbow.y) && (right_hand.x > right_elbow.x) 
          && ch_thresh_less(right_elbow.y, right_shoulder.y) && (right_elbow.x > right_shoulder.x)){
            
            stroke(255,165,0);
            kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
            kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

            println("Now TRACKING" + millis());
            println("Checkpoint 1 achieved at " + millis());

            tracking = 1;
          }
          
        else{
          println("start = " + start);
          println("tracking = " + tracking);
          println("righthand : x = " + right_hand.x + " righthand : y = " + right_hand.y);
          println("rightelbow: x = " + right_hand.x + " righthand : y = " + right_hand.y);
          println("(right_hand.y > right_elbow.y) = " + (right_hand.y > right_elbow.y));
          println("(right_hand.x < right_elbow.x) = " + (right_hand.x > right_elbow.x));
          println("(right_elbow.y > right_shoulder.y) = " + (right_elbow.y > right_shoulder.y));
          println("(right_elbow.x < right_shoulder.x) = " + (right_elbow.x > right_shoulder.x));
          stroke(0,0,255);
          kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
          kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
        }
        
        
      }
      else{
        if ((tracking == 1 || check2_disco || check3_disco || check4_disco)) { 
          stroke(255,165,0);
          kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
          kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
          stroke(0,0,255);
         
        }
        else { println("No....");}
      }
      
      if(tracking == 1){
        boolean check = test_disco_fsm(userId);
        
      }
      else { 
        println("tracking = " + tracking);
      }
      stroke(0,0,255);
         
      arrayCopy(temp, previous_right_arm_torso); // update the previous_right_arm_torso frame to the current_right_arm_torso frame
    }
  }
  
  String fname = "/Users/Phoenix/Documents/iLikeToMoveIt/disco_track_music/ddown_#####.png";
  saveFrame(fname);
}

boolean ch_thresh_less(float cur, float prev){
  int threshold = 60;
  if ( ((prev - threshold) <= cur) ){
    return true;
  }
  return false;
}

boolean ch_thresh_great(float cur, float prev){
  int threshold = 60;
  if ( ((prev + threshold) >= cur) ){
    return true;
  }
  return false;
}

// draw skeleton with selected joints
void drawSkeleton(int userId)
{
   // Draw each of the 15 joints
   /*
    SimpleOpenNI.SKEL_HEAD
    SimpleOpenNI.SKEL_NECK  
    SimpleOpenNI.SKEL_LEFT_SHOULDER
    SimpleOpenNI.SKEL_LEFT_ELBOW
    SimpleOpenNI.SKEL_LEFT_HAND
    SimpleOpenNI.SKEL_RIGHT_SHOULDER
    SimpleOpenNI.SKEL_RIGHT_ELBOW
    SimpleOpenNI.SKEL_RIGHT_HAND
    SimpleOpenNI.SKEL_TORSO
    SimpleOpenNI.SKEL_LEFT_HIP
    SimpleOpenNI.SKEL_LEFT_KNEE
    SimpleOpenNI.SKEL_LEFT_FOOT
    SimpleOpenNI.SKEL_RIGHT_HIP
    SimpleOpenNI.SKEL_RIGHT_KNEE
    SimpleOpenNI.SKEL_RIGHT_FOOT
   */
   
   //println ("drawing !");
   // SimpleOpenNI function to draw a line between two joints
   // kinect.drawLimb(userId, joint to draw line from, joint to draw a line to)
   
   // Head to neck
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
   
   // neck to left hand
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
   
   
   // neck to right hand
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
   if (check3_disco) { stroke(255,165,0);}
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
   stroke(0,0,255);
   // shoulders to torso
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
   
   // torso to left foot
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
   
   // torso to right foot
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
   
   fill(255, 0, 0);
   drawJoint(userId, SimpleOpenNI.SKEL_HEAD);
   drawJoint(userId, SimpleOpenNI.SKEL_NECK);
   drawJoint(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER);
   drawJoint(userId, SimpleOpenNI.SKEL_LEFT_ELBOW);
   drawJoint(userId, SimpleOpenNI.SKEL_NECK);
   drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
   drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW);
   drawJoint(userId, SimpleOpenNI.SKEL_TORSO);
   drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP);
   drawJoint(userId, SimpleOpenNI.SKEL_LEFT_KNEE);
   drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HIP);
   drawJoint(userId, SimpleOpenNI.SKEL_LEFT_FOOT);
   drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_KNEE);
   drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP);
   drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_FOOT);
   drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
   drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HAND);
   
}

void drawJoint(int userId, int jointID) {
  PVector joint = new PVector();
  float confidence = kinect.getJointPositionSkeleton(userId, jointID, joint);
  if (confidence < 0.5) {
    return;
  }
  PVector convertedJoint = new PVector();
  kinect.convertRealWorldToProjective(joint, convertedJoint);
  ellipse(convertedJoint.x, convertedJoint.y, 5, 5);
}

// user-tracking callbacks!
void onNewUser(int userId) {
  println("start pose detection");
  kinect.startPoseDetection("Psi", userId);
}

void onEndCalibration(int userId, boolean successful) {
  if (successful) {
    println("  User calibrated !!!");
    kinect.startTrackingSkeleton(userId);
    
    // Save the current_right_arm_torso positions of the joints
    save_joint_pos(userId);
    
  }
  else {
    println("  Failed to calibrate user !!!");
    kinect.startPoseDetection("Psi", userId);
  }
}

void save_joint_pos(int userId){
    start = true;
    last_time = millis();
    
    println("started tracking at " + last_time + "start = " + start);
    
    PVector right_hand = new PVector();
    kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,right_hand);
    PVector right_elbow = new PVector();
    kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_ELBOW,right_elbow);
    PVector right_shoulder = new PVector();
    kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_SHOULDER,right_shoulder);
    PVector torso = new PVector();
    kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_TORSO, torso);
    
    current_right_arm_torso = (PVector[])append(current_right_arm_torso, right_hand); // [0] = right_hand
    current_right_arm_torso = (PVector[])append(current_right_arm_torso, right_elbow); // [1] = right_elbow
    current_right_arm_torso = (PVector[])append(current_right_arm_torso, right_shoulder); //[2] = right_shoulder
    current_right_arm_torso = (PVector[])append(current_right_arm_torso, torso); //[3] = torso
    
    previous_right_arm_torso = (PVector[])append(previous_right_arm_torso, right_hand); // [0] = right_hand
    previous_right_arm_torso = (PVector[])append(previous_right_arm_torso, right_elbow); // [1] = right_elbow
    previous_right_arm_torso = (PVector[])append(previous_right_arm_torso, right_shoulder); //[2] = right_shoulder
    previous_right_arm_torso = (PVector[])append(previous_right_arm_torso, torso); //[3] = torso

}

void onStartPose(String pose, int userId) {
  println("Started pose for user");
  kinect.stopPoseDetection(userId);
  kinect.requestCalibrationSkeleton(userId, true);
}

boolean test_disco_fsm(int userId){
  
  if (tracking == 1){ 
        
    stroke(255,165,0);
    kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
    kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
      
      
    // if the right hand's height is decreasing : y
    // if the right hand's horizontal is decreasing : x
    // if the right elbow's height is decreasing : y
    // if the right elbow's horizontal is decreasing : x
    if ( ch_thresh_great(current_right_arm_torso[0].y,previous_right_arm_torso[0].y) 
      && ch_thresh_great(current_right_arm_torso[0].x,previous_right_arm_torso[0].x)
      && ch_thresh_great(current_right_arm_torso[1].y,previous_right_arm_torso[1].y)
      && ch_thresh_great(current_right_arm_torso[1].x, previous_right_arm_torso[1].x)){
        // keep tracking
        tracking = 1;
        if (!check2_disco) { println("Checkpoint 2 achieved at " + millis());}
        check2_disco = true; //reached checkpoint 2
      }
      
    else { 
      println("Stopped tracking as right hand is not moving correctly at " + millis());
      
      /*println ("cur rhand y = " + current_right_arm_torso[0].y + " : cur rhand x = " + current_right_arm_torso[0].x);
      println ("cur relbow y = " + current_right_arm_torso[1].y + " : cur relbow x = " + current_right_arm_torso[1].y);
      println ("prev rhand y = " + previous_right_arm_torso[0].y + " : prev rhand x = " + previous_right_arm_torso[0].x);
      println ("prev relbow y = " + previous_right_arm_torso[1].y + " : prev relbow x = " + previous_right_arm_torso[1].y);
      println ("ch_thresh_great(cur rhand y, prev rhand y) = " + ch_thresh_great(current_right_arm_torso[0].y,previous_right_arm_torso[0].y));
      println ("ch_thresh_great(cur rhand x, prev rhand x) = " + ch_thresh_great(current_right_arm_torso[0].x,previous_right_arm_torso[0].x));
      println ("ch_thresh_great(cur relbow y, prev relbow y) = " + ch_thresh_great(current_right_arm_torso[1].y,previous_right_arm_torso[1].y));
      println ("ch_thresh_great(cur relbow x, prev relbow x) = " + ch_thresh_great(current_right_arm_torso[1].x,previous_right_arm_torso[1].x));
      */
      tracking = 0;
      check2_disco = false;
      return false;
    }
    
    // if the right hand is below the right elbow and the right shoulder
    if (check2_disco){ 
      if( ch_thresh_great(current_right_arm_torso[0].y, current_right_arm_torso[1].y) &&
          ch_thresh_great(current_right_arm_torso[0].x, current_right_arm_torso[1].x) &&
          ch_thresh_great(current_right_arm_torso[1].y, current_right_arm_torso[2].y) &&
          ch_thresh_great(current_right_arm_torso[1].x, current_right_arm_torso[2].x)){

             if (!check3_disco){
                 println("Checkpoint 3 achieved = " + millis());
             }
             check3_disco = true;
       }
 
      
       else if (!( ch_thresh_great(current_right_arm_torso[0].y,previous_right_arm_torso[0].y) 
                    && ch_thresh_great(current_right_arm_torso[0].x,previous_right_arm_torso[0].x)
                    && ch_thresh_great(current_right_arm_torso[1].y,previous_right_arm_torso[1].y)
                    && ch_thresh_great(current_right_arm_torso[1].x, previous_right_arm_torso[1].x))) {
             check2_disco = false;
             tracking = 0;
             println("Stopped tracking broken checkpoint 2 at " + millis());
             return false;
       }
       
       else{
             println("Checkpoint 2 continuing");
       }
    }  
    
    // if the right hand and elbow were below the shoulder and now are coming below the torso
    if (check3_disco){ 
        if( (current_right_arm_torso[0].y < current_right_arm_torso[1].y) && (current_right_arm_torso[0].x < current_right_arm_torso[1].x)
           && (current_right_arm_torso[0].y < current_right_arm_torso[3].y) && (current_right_arm_torso[0].x < current_right_arm_torso[3].x)){

               //BINGO && !check_bad
               //play_song = true; 
               //play();
               if (!check4_disco){
                   println("Checkpoint 4 achieved = " + millis());
                   println("OOOLALA");
                   gesture = 1;
                   println("Gesture = " + gesture);
                   fill(0,255,0);
                   text("YES", 300, 510);
                   check4_disco = true;
                   last_time = millis();
               }
               //check4_disco = true;
               check2_disco = false;
               check3_disco = false;
               
         }
   
        
         else if (!( ch_thresh_great(current_right_arm_torso[0].y,previous_right_arm_torso[0].y) 
                      && ch_thresh_great(current_right_arm_torso[0].x,previous_right_arm_torso[0].x)
                      && ch_thresh_great(current_right_arm_torso[1].y,previous_right_arm_torso[2].y)
                      && ch_thresh_great(current_right_arm_torso[1].x, previous_right_arm_torso[2].x))) {
               check2_disco = false;
               check3_disco = false;
               tracking = 0;
               println("Stopped tracking broken checkpoint 3 at " + millis());
               return false;
         }
         
         else{
               println("Checkpoint 3 continuing");
         }
    } 

    return true;
  }

  return false;
}


// ****  MUSIC FUNCTIONS **** //
void draw_music()
{
  //super.draw();
  background(0);
  textSize(40);
  text("Now playing:", (windowW-pgstart)/2 + pgstart, height/2);
  stroke(255);
  
  
  if (gesture == 1) {
    play1();
  }
  if (gesture == 2) {
    play2();
  }
  
  time1 = player[0].position()/1000;
  time2 = player[1].position()/1000;
  
  if (player[0].isPlaying()) {
    text("Don't Stop Believing by Journey", (windowW-pgstart)/2 + pgstart, height/2 + 50);
    waveform(0);
    time(0);
  }
  else if (player[1].isPlaying()) {
    text("Code Monkey by Jonathan Coulton", (windowW-pgstart)/2 + pgstart, height/2 + 50);
    waveform(1);
    time(1);
  }
  else {
    background(0);
    fill(255);
    text("Playback is paused.", (windowW-pgstart)/2 + pgstart, height/2);
  }
}

void keyPressed()
{
  switch(key)
  {
    case 'p':
      pauseAll();
      break;
    case 'q':
      stop();
    default:
      break;
  }
  
}

void play1()
{
  player[1].pause();
  player[0].play();
}

void play2()
{
  player[0].pause();
  player[1].play();
  
}


void pauseAll()
{
  player[0].pause();
  player[1].pause();
}

void stop()
{
  player[0].close();
  player[1].close();
  minim.stop();
  super.stop();
  exit();
}

void waveform(int p)
{
  strokeWeight(1);
  for(int i = 0; i < player[p].bufferSize() - 1; i++)
  {
    stroke(255);
    float x1 = map( i, 0, player[p].bufferSize(), 0, width );
    float x2 = map( i+1, 0, player[p].bufferSize(), 0, width );
    line( x1+pgstart, 100 + player[p].left.get(i)*100, x2+pgstart, 100 + player[p].left.get(i+1)*100 );
  }
}

void time(int p)
{
  textSize(25);
  float current = player[p].position()/1000;
  int currMin = floor(current/60);
  int currSec = round(current % 60);
  text(nf(currMin,2) + ":" + nf(currSec,2), pgstart+100, height - 90);
  float total = player[p].length()/1000;
  int minLeft = floor((total - current)/60);
  int secLeft = round(total - current - minLeft*60);
  text(nf(minLeft,2) + ":" + nf(secLeft,2), pgstart+width - 100, height - 90);
  float percent = current/total;
  strokeWeight(10);
  line(150+pgstart, height - 100, width - 150, height - 100);
  stroke(0,255,0);
  line(150+pgstart, height - 100, pgstart + 150 + ((width -pgstart - 300)*percent), height - 100);
  stroke(255);
  ellipse(150 + (width-pgstart - 300)*percent+pgstart, height - 100, 5, 5);
}



