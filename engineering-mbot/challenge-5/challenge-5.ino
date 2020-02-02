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
MeDCMotor motorLeft(M1);
MeDCMotor motorRight(M2);

MeLineFollower follower(PORT_2);

bool newButtonState = false;
bool oldButtonState = false;
bool order = false;
int buttonValue = 0;
int state = 1;

const int BUTTON_PIN = 7;
const int SPEED = 60;
const int TURN_DELAY = 200;

// --------------------------
// ----- PROPGRAM SETUP -----
// --------------------------
void setup() { }

// --------------------------
// -----  PROGRAM LOOP  -----
// --------------------------
void loop() {
  buttonValue = analogRead(BUTTON_PIN);
  delay(100);
  
  if (buttonValue < 512)
    newButtonState = true;
  else
    newButtonState = false;

  if (newButtonState && !oldButtonState)
    order = !order;

  if (order) {
    state++;
    if (state == 3)
      state = 1;
  }

  switch (state) {
    case 1: automaticPiloting();
    case 2: programmedPiloting();
    default: neutralState();
  }

  oldButtonState = newButtonState;
}

// ------------------------------
// ----- PILOTING FUNCTIONS -----
// ------------------------------
void programmedPiloting() {
  // TODO
}

void automaticPiloting() {
  bool left = !follower.readSensor1();
  bool right = !follower.readSensor2();

  if (left && right) {
    motorLeft.run(-SPEED);
    motorRight.run(SPEED);
  } else if (right) {
    motorLeft.run(-SPEED);
    motorRight.run(-SPEED);
    delay(TURN_DELAY);
  } else if (left) {
    motorLeft.run(SPEED);
    motorRight.run(SPEED);
    delay(TURN_DELAY);                          
  }
}

void neutralState() {
  motorLeft.stop();
  motorRight.stop();
}

// ---------------------
// ----- FUNCTIONS -----
// ---------------------
void gotoLeft(float angle) {
  // TODO : affine function
}

void gotoRight(float angle) {
  // TODO : affine function
}

void goForward(float distance) {
  // TODO : affine function
}
