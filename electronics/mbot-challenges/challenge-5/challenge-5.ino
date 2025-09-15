/*
  This is the fifth and one of the final challenges we had to answer in our engineering class.
  The challenge is the following :
  "Your mBot robot has to follow and complete a circuit using its line follower.
  It must start just before and stop after the starting line using the method of your choice.
  You have to make your robot the fastest possible in order to beat other's.
  You can use whatever method you want, as long as it's the most efficient for you."

  Our robot integrates two separated modes :
  - Execution : the robot doesn't know the circuit and therefore has to check how the circuit is made in order to follow it;
  - Neutral : the robot is stopped and does nothing.
  The switching between modes is operated by the push button, on the top of the robot.

  Right below is the license (basically : credit me if you use the script) and after that, the code.

  MIT License

  Copyright (c) 2020 Exybore

  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#include <MeMCore.h>

// ------------------------
// ----- DEFINITIONS  -----
// ------------------------

// Hardware
MeRGBLed led(0, 2);
MeDCMotor motorLeft(M1);
MeDCMotor motorRight(M2);
MeLineFollower follower(PORT_2);

bool order = false;
int buttonValue = 0;
int state = 0;
int tours = 0;

unsigned long startTime = millis();
unsigned long tourTime = 13.00 * 1000;

// Previous follower states
bool oldRight = true;
bool oldLeft = true;

// Previous button states
bool oldButtonState = false;
bool newButtonState = false;

// Constants
const int BUTTON_PIN = 7;
// Our robot has a parralelism problem : the left motor is faster than the right one
// We have to set two different speeds for the two motors.
const int RIGHT_SPEED = 255;
const int LEFT_SPEED = -RIGHT_SPEED;

// --------------------------
// ----- PROPGRAM SETUP -----
// --------------------------
void setup() {
  led.setpin(13);
  Serial.begin(9600);
}

// --------------------------
// -----  PROGRAM LOOP  -----
// --------------------------
void loop() {
  buttonValue = analogRead(BUTTON_PIN);

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
    if (state == 1)
      startTime = millis();
    if (state == 3)
      state = 0;
    order = false;
  }

  if (state == 1 && millis() - startTime > tourTime)
    state = 2;

  /*!
   * States :
   * - 0 : start state (neutral)
   * - 1 : execution
   * - 2 : end state (neutral)
   */
  switch (state) {
    case 0:
      led.setColor(0, 0, 255);
      neutralState();
      break;
    case 1:
      led.setColor(0, 255, 0);
      executionState();
      break;
    case 2:
      led.setColor(255, 0, 0);
      neutralState();
      break;
  }

  led.show();
  oldButtonState = newButtonState;
}

// ------------------------
// ----- ROBOT STATES -----
// ------------------------
void executionState() {
  bool left = !follower.readSensor1();
  bool right = !follower.readSensor2();

  if (left && right) {
    motorLeft.run(LEFT_SPEED);
    motorRight.run(RIGHT_SPEED);
  // Left is out : go to the right
  } else if (right) {
    gotoRight(2.5);
    tours++;
    Serial.println(tours);
  // Right is out : go to the left
  } else if (left) {
    gotoLeft(6.75);                     
  } else {
    if (oldRight) {
      gotoRight(3);
    } else {
      gotoLeft(8.25);
    }
  }

  oldRight = right;
  oldLeft = left;
}

void neutralState() {
  motorLeft.stop();
  motorRight.stop();
}

// ------------------------------
// ----- PILOTING FUNCTIONS -----
// ------------------------------

// Makes the robot going to the left. The coefficient divides inner wheel's speed, so the robot can turn.
void gotoLeft(float coefficient) {
  while (follower.readSensor2()) {
    motorLeft.run(LEFT_SPEED / coefficient);
    motorRight.run(RIGHT_SPEED);
  }
}

// Makes the robot going to the right. The coefficient divides inner wheel's speed, so the robot can turn.
void gotoRight(float coefficient) {
  while (follower.readSensor1()) {
    motorLeft.run(LEFT_SPEED);
    motorRight.run(RIGHT_SPEED / coefficient);
  }
}
