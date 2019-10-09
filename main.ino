/*
 * Todo :
 * - Re-activate the potentiometer to control lights' speed
 */

// Including the TinkerKit library
#include <TinkerKit.h>

// ----- VARIABLES -----
TKLed greenFirelight(O0);
TKLed redFirelight(O1);
TKLed yellowFirelight(O2);

TKLed greenPedestrian(O4);
TKLed redPedestrian(O5);
TKButton pedestrianButton(I0);

int speed = 10000;

// ----- SETUP -----
void setup()
{
  Serial.begin(9600);
}

// ----- LOOP -----
void loop()
{
  // Red light
  redFirelight.on();
  delay(2500);

  // Pedestrian lights
  redPedestrian.off();
  greenPedestrian.on();
  delay(speed);
  greenPedestrian.off();
  redPedestrian.on();

  delay(2500);
  redFirelight.off();

  // Green light
  greenFirelight.on();
  int checkRate = 20;
  for (int actualDelay = 0; actualDelay < speed; actualDelay += checkRate)
  {
    delay(checkRate);
    if (pedestrianButton.pressed() == true)
    {
      break;
    }
  }
  greenFirelight.off();

  // Yellow light
  yellowFirelight.on();
  delay(2500);
  yellowFirelight.off();
}

// Useless : we no longer have a potentiometer
/*int getSpeed() {
  int speed = slider.read();
  Serial.println(speed);
  return speed;
}*/