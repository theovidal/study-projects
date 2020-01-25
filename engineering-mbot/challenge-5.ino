#include <MeMCore.h>

// ----- DEFINITIONS  -----
MeDCMotor motorLeft(M1);
MeDCMotor motorRight(M2);

MeLineFollower follower(PORT_2);

bool newButtonState = false;
bool oldButtonState = false;
bool order = false;
int buttonValue = 0;

const int buttonPin = 7;
const int speed = 60;
const int turnDelay = 200;

// ----- PROPGRAM SETUP -----
void setup() { }

// -----  PROGRAM LOOP  -----
void loop() {
  buttonValue = analogRead(buttonPin);
  delay(100);
  
  if (buttonValue < 512)
    newButtonState = true;
  else
    newButtonState = false;

  if (newButtonState && !oldButtonState)
    order = !order;

  if (order) {
    bool left = !follower.readSensor1();
    bool right = !follower.readSensor2();
  
    if (left && right) {
      motorLeft.run(-speed);
      motorRight.run(speed);
    } else if (right) {
      motorLeft.run(-speed);
      motorRight.run(-speed);
      delay(turnDelay);
    }
    else if (left) {
      motorLeft.run(speed);
      motorRight.run(speed);
      delay(turnDelay);                          
    }
  } else {
    motorLeft.stop();
    motorRight.stop();
  }

  oldButtonState = newButtonState;
}
