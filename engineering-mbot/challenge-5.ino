#include <MeMCore.h>

// ----- DEFINITIONS  -----
MeDCMotor motorLeft(M1);
MeDCMotor motorRight(M2);

MeLineFollower follower(PORT_2);

bool bp_new = false;
bool bp_old = false;
bool ordre = false;
int buttonValue = 0;
int buttonPin = 7;

// ----- PROPGRAM SETUP -----
void setup() { }

// -----  PROGRAM LOOP  -----
void loop() {
  buttonValue = analogRead(buttonPin);
  delay(100);
  
  if (buttonValue > 512)
    bp_new = false;
  else
    bp_new = true;

  if (bp_new && !bp_old)
    ordre = !ordre;

  if (ordre) {
    bool left = !follower.readSensor1();
    bool right = !follower.readSensor2();
  
    if (left && right) {
      motorLeft.run(-60);
      motorRight.run(60);
    } else if (right) {
      motorLeft.run(-60);
      motorRight.run(-60);
      delay(200);
    }
    else if (left) {
      motorLeft.run(60);
      motorRight.run(60);
      delay(200);                          
    }
  } else {
    motorLeft.stop();
    motorRight.stop();
  }

  bp_old = bp_new;
}