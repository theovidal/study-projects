// ------------- DEFINITIONS -------------

#define O0 11
#define O1 10
#define O2 9
#define O3 6
#define O4 5
#define O9 3

// ------------- CLASS DECLARATION -------------

class Mode
{
public:
  Mode(int leds[10], int states[10], int times[10])
  {
    for (int i = 0; i < 10; i++)
    {
      _leds[i] = leds[i];
      _states[i] = states[i];
      _times[i] = times[i];
    }
  }

  void activateState(int index)
  {
    digitalWrite(_leds[index], _states[index]);
    delay(_times[index]);
  }

  int getSize()
  {
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

// ------------- PROGRAM SETUP AND LOOP -------------

void setup() {
  pinMode(O0, OUTPUT);
  pinMode(O1, OUTPUT);
  pinMode(O2, OUTPUT);
  pinMode(O3, OUTPUT);
  pinMode(O4, OUTPUT);
}
void loop() {
  for (int i = 0; i < modeA.getSize(); i++) {
    modeA.activateState(i);
  }
}