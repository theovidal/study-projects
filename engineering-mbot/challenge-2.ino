#include <MeMCore.h>

// ----- DEFINITIONS  -----
MeRGBLed led(0, 2);
MeUltrasonicSensor sensor(PORT_3);

// ----- PROPGRAM SETUP -----
void setup() {
  led.setpin(13);
}

// -----  PROGRAM LOOP  -----
void loop() {
  float distance = sensor.distanceCm();
  if (distance >= 50) {
    // Producing green light
    led.setColor(0, 255, 0);
  } else {
    // Producing a linear gradient from green to red
    float green = (255 * distance) / 50;
    led.setColor(255 - green, green, 0);
  }
  
  // Refresh the LEDs so we can get new colors
  led.show();
}
