/*
 * Todo :
 * - Make helper classes (Light, Button, Slider)
 */

// ----- DEFINITIONS  -----
#define O0 11
#define O1 10
#define O2 9
#define O3 6
#define O4 5
#define O5 3
#define I0 A0
#define I1 A1
#define I2 A2
#define I3 A3
#define I4 A4
#define I5 A5

int greenCarLight = O0;
int yellowCarLight = O1;
int redCarLight = O2;

int greenPedestrianLight = O4;
int redPedestrianLight = O5;

int pedestrianButton = I0;
int lightSensor = I2;
int speedSlider = I5;

// ----- PROPGRAM SETUP -----
void setup()
{
  pinMode(redCarLight, OUTPUT);
  pinMode(yellowCarLight, OUTPUT);
  pinMode(greenCarLight, OUTPUT);

  pinMode(redPedestrianLight, OUTPUT);
  pinMode(greenPedestrianLight, OUTPUT);
  pinMode(pedestrianButton, INPUT);

  Serial.begin(9600);
}

// -----  PROGRAM LOOP  -----
void loop()
{
  // Red light
  analogWrite(redCarLight, lightIntensity());
  delay(2500);

  // Pedestrian lights
  analogWrite(redPedestrianLight, LOW);
  analogWrite(greenPedestrianLight, lightIntensity());
  delay(lightDuration());
  analogWrite(greenPedestrianLight, LOW);
  analogWrite(redPedestrianLight, lightIntensity());

  delay(2500);
  analogWrite(redCarLight, LOW);

  // Green light
  analogWrite(greenCarLight, HIGH);
  int refreshRate = 20;
  for (int elapsedTime = 0; elapsedTime < lightDuration(); elapsedTime += refreshRate)
  {
    if (digitalRead(pedestrianButton) == HIGH)
    {
      break;
    }
    else
    {
      analogWrite(greenCarLight, lightIntensity())
    }
    delay(refreshRate);
  }
  analogWrite(greenCarLight, LOW);

  // Yellow light
  analogWrite(yellowCarLight, lightIntensity());
  delay(2500);
  analogWrite(yellowCarLight, LOW);
}

// lightDuration fetches the duration of the light according to the slider.
int lightDuration()
{
  // Affine function : (8000/1023)x + 2000
  // We want a value between 2000ms and 10000ms, and we have the slider value from 0 to 1023.
  int duration = 7.8 * analogRead(speedSlider) + 2000;
  return duration;
}

// lightInsensity returns the intensity of the light depending on the natural light.
// The higher it is, the lower traffic lights need to be powered (visibility is enough)
int lightIntensity()
{
  // Affine function : -(204/900)x + 255
  // We want a decreasing value between 51 and 255 (20% - 100%), and we have the light sensor value from 0 to 900
  int intensity = -0.2267 * analogRead(lightSensor) + 255;
  return intensity;
}