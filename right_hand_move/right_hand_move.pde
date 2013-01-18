import SimpleOpenNI.*;
import ddf.minim.*;

Minim minim;
AudioPlayer song;


SimpleOpenNI context; // global context object to access the camera
boolean start_save = false;
boolean play_song = false;
int last_time;

PVector[] right_fist = new PVector[0];
PVector[] current = new PVector[0];
PVector[] previous = new PVector[0];

int time_check = 5000;
boolean start = false;
boolean tracking = true;
boolean check2 = false;

// setup() is called only once in the beginning
void setup(){
  
  //instantiate a new context
  context = new SimpleOpenNI(this);
  
  // enable depth image generation
  // i.e. collecting of depth data
  context.enableDepth();
  
  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  
  // since we want to draw the skeleton with lines
  // so we set the background, stroke, stroke color and stroke weight
  background(200,0,0);
  stroke(0,0,255);
  strokeWeight(3);
  smooth();
  
  // create a window that is the same size as the depth image info
  size(context.depthWidth(), context.depthHeight());
  println("depthwidth = " + context.depthWidth());
  println("depthHeight = " + context.depthHeight());
  
  // load in audio file
  minim = new Minim(this);
  song = minim.loadFile("/Users/Phoenix/Documents/iLikeToMoveIt/01 Circle of Life (performed by C.mp3");
  last_time = millis();
  
}

// draw() is called repeatedly
void draw(){
  //update the camera
  context.update();
  
  // draw the depth image
  //if (!(millis() - start > 20000)){
    
  image(context.depthImage(),0,0);
  //}
  //background(0);
  // DRAW DEPTH IMAGE FIRST AND THEN THE SKELETON ON TOP OF THE IMAGE
  
  // check if skeleton if users 1 to 10 is being tracked
  // for all users from 1 to 10
  for (int i = 1; i < 4; i++){
    // check if their skeleton is being tracked
    if (context.isTrackingSkeleton(i)){
     
      drawSkeleton(i); // draw their skeleton
      PVector right_hand = new PVector();
      context.getJointPositionSkeleton(i,SimpleOpenNI.SKEL_LEFT_HAND,right_hand);
      PVector right_elbow = new PVector();
      context.getJointPositionSkeleton(i,SimpleOpenNI.SKEL_LEFT_ELBOW,right_elbow);
      PVector right_shoulder = new PVector();
      context.getJointPositionSkeleton(i,SimpleOpenNI.SKEL_LEFT_SHOULDER,right_shoulder);
      PVector torso = new PVector();
      context.getJointPositionSkeleton(i,SimpleOpenNI.SKEL_TORSO, torso);
      
      PVector[] temp = new PVector[0];
      temp = (PVector[])append(temp, current[0]); // [0] = right_hand
      temp = (PVector[])append(temp, current[1]); // [1] = right_elbow
      temp = (PVector[])append(temp, current[2]); //[2] = right_shoulder
      temp = (PVector[])append(temp, current[3]); //[3] = torso
      
      current = new PVector[0];
      current = (PVector[])append(current, right_hand); // [0] = right_hand
      current = (PVector[])append(current, right_elbow); // [1] = right_elbow
      current = (PVector[])append(current, right_shoulder); //[2] = right_shoulder
      current = (PVector[])append(current, torso); //[3] = torso
      
      // disco_up
      if (start && !((millis() - last_time) < 10000)){
        if ((right_hand.y > right_elbow.y) && (right_hand.x < right_elbow.x) 
          && (right_elbow.y > right_shoulder.y) && (right_elbow.x < right_shoulder.x)){
            stroke(255,165,0);
            context.drawLimb(i, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
            context.drawLimb(i, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
            //play();
          }
        stroke(0,0,255);
        start = false;
        tracking = true;
      }
      
      if (tracking && !((millis() - last_time) < 10000)){
        
        stroke(255,165,0);
        context.drawLimb(i, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
        context.drawLimb(i, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
        
        // if the right hand's height is decreasing : y
        // if the right hand's horizontal is increasing : x
        // if the right elbow's height is decreasing : y
        // if the right elbow's horizontal is increasing : x
        if ( ch_thresh_great(current[0].y,previous[0].y) 
          && ch_thresh_less(current[0].x,previous[0].x)
          && ch_thresh_great(current[1].y,previous[1].y)
          && ch_thresh_less(current[1].x, previous[1].x)){
            // keep tracking
            tracking = true;
          }
        else { 
          println("Stopped tracking as right hand is not moving correctly");
          
          println ("cur rhand y = " + current[0].y + " : cur rhand x = " + current[0].x);
          println ("cur relbow y = " + current[1].y + " : cur relbow x = " + current[1].y);
          println ("prev rhand y = " + previous[0].y + " : prev rhand x = " + previous[0].x);
          println ("prev relbow y = " + previous[1].y + " : prev relbow x = " + previous[1].y);
          println ("ch_thresh_great(cur rhand y, prev rhand y) = " + ch_thresh_great(current[0].y,previous[0].y));
          println ("ch_thresh_less(cur rhand x, prev rhand x) = " + ch_thresh_great(current[0].x,previous[0].x));
          println ("ch_thresh_great(cur relbow y, prev relbow y) = " + ch_thresh_great(current[1].y,previous[1].y));
          println ("ch_thresh_less(cur relbow x, prev relbow x) = " + ch_thresh_great(current[1].x,previous[1].x));
          
          tracking = false;
          check2 = false;
        }
        // if the right hand and elbow are coming below the shoulder
        if ((current[0].y < current[1].y) && (current[0].x > current[1].x)
          && (current[1].y < current[2].y) && (current[1].x > current[2].x)){
           check2 = true; //reached checkpoint 2
          } 
          
        if (check2 &&
           !(ch_thresh_great(current[0].y, current[1].y) &&
             ch_thresh_less(current[0].x, current[1].x) &&
             ch_thresh_great(current[1].y, current[2].y) &&
             ch_thresh_less(current[1].x, current[2].x))){
               check2 = false;
               tracking = false;
               println("Stopped tracking disturbed checkpoint 2");
             }
        // if the right hand and elbow were below the shoulder and now are coming below the torso
        if (check2 
           && (current[0].y < current[1].y) && (current[0].x > current[1].x)
           && (current[1].y < current[3].y) && (current[1].x > current[3].x)){
       
             //BINGO
             play_song = true; 
             play();
             
             println("OOOLALA");
           }
      }
      stroke(0,0,255);
         
      arrayCopy(temp, previous); // update the previous frame to the current frame
       
        
      /*if (play_song){
        play();
      }*/
  
      /* 
      if (start_save){
        save_user_right(i);
        
        int t = millis() - last_time;
        if (t > time_check){
          right_fist_moved(i);
          last_time = millis();
        }
         
      }
      */
    }
  }
  
  //last_time = millis();
  
  if(start_save){
    //println("HI!");
    String fname = "/Users/Phoenix/Documents/iLikeToMoveIt/right_hand_test/rh_coord-#####.png";
    saveFrame(fname);
  }
  
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
   // context.drawLimb(userId, joint to draw line from, joint to draw a line to)
   
   // Head to neck
   context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
   
   // neck to left hand
   context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
   context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
   context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
   
   
   // neck to right hand
   context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
   context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
   context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
   
   // shoulders to torso
   context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
   context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
   
   // torso to left foot
   context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
   context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
   context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
   
   // torso to right foot
   context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
   context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
   context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
   
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

void save_user_right(int userId){
  
  // get 3D position of USER'S RIGHT HAND
   PVector jointPos = new PVector();
   context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,jointPos);
   //println("rightfist x = " + jointPos.x);
   //println("rightfist y = " + jointPos.y);
   //println("rightfist z = " + jointPos.z);
   right_fist = (PVector[])append(right_fist, jointPos);
  
}
void drawJoint(int userId, int jointID) {
  PVector joint = new PVector();
  float confidence = context.getJointPositionSkeleton(userId, jointID, joint);
  if (confidence < 0.5) {
    return;
  }
  PVector convertedJoint = new PVector();
  context.convertRealWorldToProjective(joint, convertedJoint);
  ellipse(convertedJoint.x, convertedJoint.y, 5, 5);
}

// when a newUser enters the field of view
void onNewUser(int userId){
  println("New User detected : userId = " + userId);
  
  // start pose detection (ESSENTIAL KEY)
  context.startPoseDetection("Psi", userId);
}

// when a user leaves the field of view
void onLoseUser(int userId){
  println("Lost user : userId = " + userId);
}

// when the user is beginning a calibration pose
void onStartPose(String pose, int userId){
  println("Start of pose detected, userId : " + userId + " , pose: " + pose);
  
  // stop pose detection
  context.stopPoseDetection(userId);
  
  // start attempting to calibrate the skeleton (recognize the joints of the pose of the user)
  context.requestCalibrationSkeleton(userId, true);
}

// when calibration begins
void onStartCalibration(int userId){
  println("Beginning calibration , userId : " + userId);
}

// when calibration ends
void onEndCalibration(int userId, boolean successful){
  println("Calibration of userId : " + userId + " , successful : " + successful);
  
  if (successful){
    println(" User calibrated !");
    
    //begin skeleton tracking
    context.startTrackingSkeleton(userId);
    start_save = true;
    start = true;
    last_time = millis();
    
    println("started tracking at " + last_time);
    PVector right_hand = new PVector();
    context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,right_hand);
    PVector right_elbow = new PVector();
    context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_ELBOW,right_elbow);
    PVector right_shoulder = new PVector();
    context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_SHOULDER,right_shoulder);
    PVector torso = new PVector();
    context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_TORSO, torso);
    current = (PVector[])append(current, right_hand); // [0] = right_hand
    current = (PVector[])append(current, right_elbow); // [1] = right_elbow
    current = (PVector[])append(current, right_shoulder); //[2] = right_shoulder
    current = (PVector[])append(current, torso); //[3] = torso
    
    previous = (PVector[])append(previous, right_hand); // [0] = right_hand
    previous = (PVector[])append(previous, right_elbow); // [1] = right_elbow
    previous = (PVector[])append(previous, right_shoulder); //[2] = right_shoulder
    previous = (PVector[])append(previous, torso); //[3] = torso
    
    //play_song = true;
    // play our song or sound effect
    //song.play();
  }
  else{
    println ("Failed to calibrate user!");
    
    // start pose detection
    context.startPoseDetection("Psi", userId);
    
  }
  
}

void keyPressed() { // Press a key to save the data
  if ( key == 's') { 
    String[] lines = new String[right_fist.length];
    for (int i = 0; i < right_fist.length; i++) {
      lines[i] = "x = " + right_fist[i].x + " : y = " + right_fist[i].y;
    }
    String filename = "/Users/Phoenix/Documents/iLikeToMoveIt/gesture_saves/lines_disco-" + millis() + ".txt";
    saveStrings(filename, lines);
    String fname = "/Users/Phoenix/Documents/iLikeToMoveIt/gesture_saves/rh_coord_disco-" + millis() + ".png";
    saveFrame(fname);
    right_fist = new PVector[0];
  }
  else{  
    exit(); // Stop the program
  }
}

void right_fist_moved(int userId){
  // in the y direction up and down facing the Kinect
  float threshold = 300;
  // Find the maximum consecutive difference in the sequence
  float min = right_fist[0].y;
  float max = right_fist[0].y;
  float max_diff = 0;
  for (int i = 0; i < right_fist.length; i++){
    float yval = right_fist[i].y;
    if (yval < min)
      min = yval;
    if (yval > max)
      max = yval;
    //float diff = abs(yval - min);
    float diff = abs(max - min);
    if (diff > max_diff)
      max_diff = diff;
    if (max_diff > threshold)
      break;
  }
  
  print("min val = " + min);
  print("max val = " + max);
  println("maxdiff = " + max_diff);
  if (max_diff > threshold){
    right_fist = new PVector[0];
    println("\t\t\tYESS!!");
    play_song = true;
    play();
  }
}  

void play()
{
   if(play_song){
     while(song.position() < 5000){
       song.play();
     }
     song.pause();
     play_song = false;
     song.rewind();
   }
}   

void stop()
{
  // the AudioPlayer you got from Minim.loadFile()
  song.close();
  minim.stop();
 
  // this calls the stop method that 
  // you are overriding by defining your own
  // it must be called so that your application 
  // can do all the cleanup it would normally do
  super.stop();
}


  
