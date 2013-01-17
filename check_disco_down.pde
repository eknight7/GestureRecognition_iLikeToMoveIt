import SimpleOpenNI.*;
SimpleOpenNI  kinect;

int last_time;

PVector[] right_fist = new PVector[0];
PVector[] current = new PVector[0];
PVector[] previous = new PVector[0];

int time_check = 5000;
boolean start = false;
boolean tracking = false;
boolean check2 = false;
boolean check3 = false;
boolean check_bad = false;

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
      /*
      PVector rightHand = new PVector();
      PVector rightElbow = new PVector();
      PVector rightShoulder = new PVector();

      kinect.getJointPositionSkeleton(userId,
                                      SimpleOpenNI.SKEL_RIGHT_HAND,
                                      rightHand);
      kinect.getJointPositionSkeleton(userId,
                                      SimpleOpenNI.SKEL_RIGHT_ELBOW,
                                      rightElbow);
      kinect.getJointPositionSkeleton(userId,
                                      SimpleOpenNI.SKEL_RIGHT_SHOULDER,
                                      rightShoulder);

      // right elbow above right shoulder
      // AND
      // right elbow right of right shoulder
      //
      if(rightElbow.y > rightShoulder.y &&
         rightElbow.x > rightShoulder.x) { 
        stroke(255); 
      } else {
        stroke(255,0,0); 
      }
      kinect.drawLimb(userId, 
                      SimpleOpenNI.SKEL_RIGHT_SHOULDER,
                      SimpleOpenNI.SKEL_RIGHT_ELBOW);

      // right hand above right elbow
      // AND
      // right hand right of right elbow
      //
      if(rightHand.y > rightElbow.y && rightHand.x > rightElbow.x) {
        stroke(255);
      } else {
        stroke(255,0,0);
      }

      kinect.drawLimb(userId,
                      SimpleOpenNI.SKEL_RIGHT_HAND,
                      SimpleOpenNI.SKEL_RIGHT_ELBOW);
      */
      
      PVector right_hand = new PVector();
      kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,right_hand);
      PVector right_elbow = new PVector();
      kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_ELBOW,right_elbow);
      PVector right_shoulder = new PVector();
      kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_SHOULDER,right_shoulder);
      PVector torso = new PVector();
      kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_TORSO, torso);
      
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
      
      if ((millis() - last_time) < 10000) println("NOT YET Checking gest");
      // disco_go_down
      else if (start){
        
        if (ch_thresh_less(right_hand.y, right_elbow.y) && (right_hand.x > right_elbow.x) 
          && ch_thresh_less(right_elbow.y, right_shoulder.y) && (right_elbow.x > right_shoulder.x)){
            stroke(255,165,0);
            kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
            kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
            //play();
            start = false;
            if (!tracking) {
              println("Now TRACKING" + millis());
              println("Checkpoint 1 achieved at " + millis());
            }
            tracking = true;
          }
        else{
          println("righthand : x = " + right_hand.x + " righthand : y = " + right_hand.y);
          println("rightelbow: x = " + right_hand.x + " righthand : y = " + right_hand.y);
        println("(right_hand.y > right_elbow.y) = " + (right_hand.y > right_elbow.y));
        println("(right_hand.x < right_elbow.x) = " + (right_hand.x > right_elbow.x));
        println("(right_elbow.y > right_shoulder.y) = " + (right_elbow.y > right_shoulder.y));
        println("(right_elbow.x < right_shoulder.x) = " + (right_elbow.x > right_shoulder.x));
        stroke(0,0,255);}
        
      }
      else{
        if ((tracking || check2 || check3) && !check_bad){
          stroke(255,165,0);
          kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
          kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
          stroke(0,0,255);
        }
        else { println("Not yet....");}
      }
      
      if (tracking && !((millis() - last_time) < 20000)){
        
        stroke(255,165,0);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
        
        
        // if the right hand's height is decreasing : y
        // if the right hand's horizontal is increasing : x
        // if the right elbow's height is decreasing : y
        // if the right elbow's horizontal is increasing : x
        if ( ch_thresh_great(current[0].y,previous[0].y) 
          && ch_thresh_great(current[0].x,previous[0].x)
          && ch_thresh_great(current[1].y,previous[1].y)
          && ch_thresh_great(current[1].x, previous[1].x)){
            // keep tracking
            tracking = true;
            if (!check2) { println("Checkpoint 2 achieved at " + millis());}
            check2 = true; //reached checkpoint 2
          }
          
        /*if ( (current[0].y < previous[0].y)
        && ( current[0].x < previous[0].x)
        && ( current[1].y < previous[1].y)
        && ( current[1].x < previous[1].x)){
          //keep tracking
          tracking = true;
        }*/
        else { 
          println("Stopped tracking as right hand is not moving correctly at " + millis());
          
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
          check_bad = true;
        }
        // if the right hand and elbow are coming below the shoulder
        /*if ((current[0].y < current[1].y) && (current[0].x < current[1].x)
          && (current[1].y < current[2].y) && (current[1].x < current[2].x) && !check_bad){
           if (!check2) { println("Checkpoint 3 achieved at " + millis());}
           check2 = true; //reached checkpoint 2
           
          } 
          */
        
        // if the right hand and elbow were below the shoulder and now are coming below the torso
        if (check2 && !check_bad
           && (current[0].y < current[1].y) && (current[0].x < current[1].x)
           && (current[1].y < current[3].y) && (current[1].x < current[3].x)){
       
             //BINGO
             //play_song = true; 
             //play();
             if (!check3){
               println("Checkpoint 3 achieved = " + millis());
               println("OOOLALA");
             }
             check3 = true;
           }
           
           if (check2 && !check3 &&
           !(ch_thresh_great(current[0].y, current[1].y) &&
             ch_thresh_great(current[0].x, current[1].x) &&
             ch_thresh_great(current[1].y, current[2].y) &&
             ch_thresh_great(current[1].x, current[2].x))){
               check2 = false;
               tracking = false;
               check_bad = true;
               println("Stopped tracking disturbed checkpoint 2 at " + millis());
             }
      }
      stroke(0,0,255);
         
      arrayCopy(temp, previous); // update the previous frame to the current frame
    }
  }
  
  String fname = "/Users/Phoenix/Documents/iLikeToMoveIt/disco_move_down/ddown-#####.png";
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
   if (check3) { stroke(255,165,0);}
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
    
    // Save the current positions of the joints
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
    
    current = (PVector[])append(current, right_hand); // [0] = right_hand
    current = (PVector[])append(current, right_elbow); // [1] = right_elbow
    current = (PVector[])append(current, right_shoulder); //[2] = right_shoulder
    current = (PVector[])append(current, torso); //[3] = torso
    
    previous = (PVector[])append(previous, right_hand); // [0] = right_hand
    previous = (PVector[])append(previous, right_elbow); // [1] = right_elbow
    previous = (PVector[])append(previous, right_shoulder); //[2] = right_shoulder
    previous = (PVector[])append(previous, torso); //[3] = torso

}

void onStartPose(String pose, int userId) {
  println("Started pose for user");
  kinect.stopPoseDetection(userId);
  kinect.requestCalibrationSkeleton(userId, true);
}
