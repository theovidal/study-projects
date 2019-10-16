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

int lightDuration = 10000;

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
  digitalWrite(redCarLight, HIGH);
  delay(2500);

  // Pedestrian lights
  digitalWrite(redPedestrianLight, LOW);
  digitalWrite(greenPedestrianLight, HIGH);
  delay(lightDuration);
  digitalWrite(greenPedestrianLight, LOW);
  digitalWrite(redPedestrianLight, HIGH);

  delay(2500);
  digitalWrite(redCarLight, LOW);

  // Green light
  digitalWrite(greenCarLight, HIGH);
  int refreshRate = 20;
  for (int elapsedTime = 0; elapsedTime < lightDuration; elapsedTime += refreshRate)
  {
    delay(refreshRate);
    if (digitalRead(pedestrianButton) == HIGH)
    {
      break;
    }
  }
  digitalWrite(greenCarLight, LOW);

  // Yellow light
  digitalWrite(yellowCarLight, HIGH);
  delay(2500);
  digitalWrite(yellowCarLight, LOW);
}

// Useless : we no longer have a potentiometer
/*int getDuration() {
  int lightDuration = slider.read();
  Serial.println(speed);
  return speed;
}*/