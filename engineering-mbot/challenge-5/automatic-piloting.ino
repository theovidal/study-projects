#include <MeMCore.h>

const int SPEED = 60;
const int TURN_DELAY = 200;

void automaticPiloting(MeLineFollower follower, MeDCMotor motorLeft, MeDCMotor motorRight) {
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
