import SimpleOpenNI.*;
SimpleOpenNI  kinect;

int last_time;

PVector[] right_fist = new PVector[0];
PVector[] current_right_arm_torso = new PVector[0]; // [0] = right_hand; [1] = right_elbow; [2] = right_shoulder; [3] = torso
PVector[] previous_right_arm_torso = new PVector[0]; // [0] = right_hand; [1] = right_elbow; [2] = right_shoulder; [3] = torso

int time_check = 5000;
boolean start = false; // IMPORTANT : SKELETON HAS BEEN TRACKED
int tracking = 0;

int gesture = 0;
boolean check2_disco = false;
boolean check3_disco = false;
boolean check4_disco = false;

void setup() {
  size(640, 480);
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  kinect.setMirror(true); // reflect the image so that it is in the user's perspective
  strokeWeight(5);
}

void draw() {
  background(0);
  kinect.update();
  image(kinect.depthImage(), 0, 0);

  IntVector userList = new IntVector();
  kinect.getUsers(userList);
  if (userList.size() > 0) {

    int userId = userList.get(0);
    if ( kinect.isTrackingSkeleton(userId)) {
      drawSkeleton(userId);
      
      
      
      if ((millis() - last_time) < 10000) println("NOT YET Checking gest");
      
      
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
      
      if (start && tracking == 0 && !((millis() - last_time) < 10000)){
        
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
  
  String fname = "/Users/Phoenix/Documents/iLikeToMoveIt/disco_move_down_changing/ddown_" + millis() + "_#####.png";
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
    
    // if the right hand is below the right elbow
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
           && (current_right_arm_torso[1].y < current_right_arm_torso[3].y) && (current_right_arm_torso[1].x < current_right_arm_torso[3].x)){

               //BINGO && !check_bad
               //play_song = true; 
               //play();
               if (!check4_disco){
                   println("Checkpoint 4 achieved = " + millis());
                   println("OOOLALA");
                   gesture = 1;
                   println("Gesture = " + gesture);
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
