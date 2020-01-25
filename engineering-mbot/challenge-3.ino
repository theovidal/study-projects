#include <MeMCore.h>

// ----- DEFINITIONS  -----
bool oldButtonState = false;
bool newButtonState = false;
bool order = false;
bool led = false;
int buttonValue = 0;

const int buttonPin = 7;

// ----- PROPGRAM SETUP -----
void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(buttonPin, INPUT);

  // Setting off the LED before the program loops
  digitalWrite(LED_BUILTIN, LOW);
}

// -----  PROGRAM LOOP  -----
void loop() {
  buttonValue = analogRead(buttonPin);
  delay(100);

  if (buttonValue < 512)
    newButtonState = true;
  else
    newButtonState = false;

  if (newButtonState && !oldButtonState)
    order = true;
  else
    order = false;

  if (order) {
    if (led) {
      digitalWrite(LED_BUILTIN, LOW);
      led = false;
    } else {
      digitalWrite(LED_BUILTIN, HIGH);
      led = true;
    }
    order = false;
  }
  
  oldButtonState = newButtonState;
}
