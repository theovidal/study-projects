// ------------- DEFINITIONS -------------

#define O0 11
#define O1 10
#define O2 9
#define O3 6
#define O4 5
#define O9 3
#define I0 A0

int button = I0;
int currentMode = 0;

void switchMode() {
  ++currentMode;
  if (currentMode == 3) {
    currentMode = 0;
  }
  digitalWrite(O0, LOW);
  digitalWrite(O1, LOW);
  digitalWrite(O2, LOW);
  digitalWrite(O3, LOW);
  digitalWrite(O4, LOW);
  delay(200);
}

// ------------- CLASS DECLARATION -------------

class Mode {
  public:
  Mode(int leds[10], int states[10], int times[10]) {
    for (int i = 0; i < 10; i++) {
      _leds[i] = leds[i];
      _states[i] = states[i];
      _times[i] = times[i];
    }
  }

  void activateState(int index) {
    digitalWrite(_leds[index], _states[index]);
    for (int elapsedTime = 0; elapsedTime < _times[index]; elapsedTime += 20) {
      if (digitalRead(button) == HIGH) {
        switchMode();
        break;
      }
      delay(20);
    }
  }

  int getSize() {
    return sizeof(_leds) / sizeof(*_leds);
  }

  private:
  int _leds[10];
  int _states[10];
  int _times[10];
};

// ------------- MODES DEFINITION -------------

int modeAPins[] =   { O0,   O1,   O2,   O3,   O4,   O0,  O1,  O2,  O3,  O4   };
int modeAStates[] = { HIGH, HIGH, HIGH, HIGH, HIGH, LOW, LOW, LOW, LOW, LOW  };
int modeATimes[] =  { 0,    0,    0,    0,    1000, 0,   0,   0,   0,   1000 };
Mode modeA(modeAPins, modeAStates, modeATimes);

int modeBPins[] =   { O0,   O0,  O1,   O1,  O2,   O2,  O3,   O3,  O4,   O4  };
int modeBStates[] = { HIGH, LOW, HIGH, LOW, HIGH, LOW, HIGH, LOW, HIGH, LOW };
int modeBTimes[] =  { 500,  0,   500,  0,   500,  0,   500,  0,   500,  0   };
Mode modeB(modeBPins, modeBStates, modeBTimes);

int modeCPins[] =   { O0,   O2,   O4,   O0,  O2,  O4,  O1,   O3,   O1,  O3  };
int modeCStates[] = { HIGH, HIGH, HIGH, LOW, LOW, LOW, HIGH, HIGH, LOW, LOW };
int modeCTimes[] =  { 0,    0,    500,  0,   0,   0,   0,    500,  0,   0   };
Mode modeC(modeCPins, modeCStates, modeCTimes);

Mode modes[] = { modeA, modeB, modeC };

// ------------- PROGRAM SETUP AND LOOP -------------

void setup() {
  pinMode(O0, OUTPUT);
  pinMode(O1, OUTPUT);
  pinMode(O2, OUTPUT);
  pinMode(O3, OUTPUT);
  pinMode(O4, OUTPUT);
}
void loop() {
  for (int i = 0; i < 10; i++) {
    modes[currentMode].activateState(i);
  }
}