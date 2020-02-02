/*
  This is the fifth and one of the final challenges we had to answer in our engineering class.
  The challenge is the following :
  "Your mBot robot has to follow and complete a circuit using its line follower.
  It must stop right behind the starting line using the integrated push button.
  You have to make your robot the fastest possible in order to beat other's.
  You can use whatever method you want, as long as it's the most efficient for you."

  Our robot integrates three separated modes :
  - Automatic piloting : the robot doesn't know the circuit and therefore has to check how the circuit is made in order to follow it;
  - Programmed piloting : the robot knows the circuit as it's defined in the code. It stupidly executes what we want;
  - Neutral : the robot is stopped and does nothing.
  The switching between modes is operated by the push button, on the top of the robot.

  Right below is the license (basically : do what you want with this script) and after that, the code.

  DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
  Version 2, December 2004

  Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>

  Everyone is permitted to copy and distribute verbatim or modified
  copies of this license document, and changing it is allowed as long
  as the name is changed.

              DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE

  TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. You just DO WHAT THE FUCK YOU WANT TO.
 */

#include <MeMCore.h>

// ------------------------
// ----- DEFINITIONS  -----
// ------------------------
MeRGBLed led(0, 2);

MeDCMotor motorLeft(M1);
MeDCMotor motorRight(M2);

MeLineFollower follower(PORT_2);

bool oldButtonState = false;
bool newButtonState = false;
bool order = false;
int buttonValue = 0;
int state = 0;

const int BUTTON_PIN = 7;
const int TURN_DELAY = 200;

// Our robot has a parralelism problem : the left motor is faster than the right one
// We have to set two different speeds for the two motors.
const int RIGHT_SPEED = 110;
const int LEFT_SPEED = -(RIGHT_SPEED - 15);

// The effective speed of the robot, in cm/s
const int REAL_SPEED = 14.0351;

// --------------------------
// ----- PROPGRAM SETUP -----
// --------------------------
void setup() {
  led.setpin(13);
}

// --------------------------
// -----  PROGRAM LOOP  -----
// --------------------------
void loop() {
  buttonValue = analogRead(BUTTON_PIN);
  delay(100);

  // Pass through the neutral state to stop motors between modes
  neutralState();
  
  if (buttonValue < 512)
    newButtonState = true;
  else
    newButtonState = false;

  if (newButtonState && !oldButtonState)
    order = !order;

  if (order) {
    state++;
    if (state == 3)
      state = 0;
    order = false;
  }

  /*!
   * States :
   * - 0 : neutral state
   * - 1 : automatic piloting
   * - 2 : programmed piloting
   */
  switch (state) {
    case 0:
      led.setColor(0, 0, 255);
      neutralState();
      break;
    case 1:
      led.setColor(0, 255, 0);
      automaticPiloting();
      break;
    case 2:
      led.setColor(255, 0, 0);
      programmedPiloting();
      break;
  }

  led.show();
  oldButtonState = newButtonState;
}

// ------------------------
// ----- ROBOT STATES -----
// ------------------------
void programmedPiloting() {
  //goForward(20);
  //stopRobot(3000);
}

void automaticPiloting() {
  bool left = !follower.readSensor1();
  bool right = !follower.readSensor2();

  if (left && right) {
    motorLeft.run(LEFT_SPEED);
    motorRight.run(RIGHT_SPEED);
  } else if (right) {
    motorLeft.run(LEFT_SPEED);
    motorRight.run(-RIGHT_SPEED);
    delay(TURN_DELAY);
  } else if (left) {
    motorLeft.run(-LEFT_SPEED);
    motorRight.run(RIGHT_SPEED);
    delay(TURN_DELAY);                          
  }
}

void neutralState() {
  motorLeft.stop();
  motorRight.stop();
}

// -----------------------------------------
// ----- PROGRAMMED PILOTING FUNCTIONS -----
// -----------------------------------------
void gotoLeft(float angle) {
  // TODO : affine function
}

void gotoRight(float angle) {
  // TODO : affine function
}

/*!
 * Make the robot go forward
 * 
 * @param distance The distance to travel, in centimeters
 */
void goForward(float distance) {
  motorLeft.run(LEFT_SPEED);
  motorRight.run(RIGHT_SPEED);

  // Time is obtained using the formula : t = d/v
  // We have to add 1.25 centimeters in order to have a realistic distance
  // The final result is in seconds, so we convert it in milliseconds for the delay function.
  float waitTime = ((distance + 1.25) / REAL_SPEED) * 1000;
  delay(waitTime);
}

/*!
 * Stop the robot
 * TODO : make the function stoppable if the button is pressed
 * 
 * @param waitTime Milliseconds to wait before the next action
 */
void stopRobot(int waitTime) {
  motorLeft.stop();
  motorRight.stop();
  delay(waitTime);
}
