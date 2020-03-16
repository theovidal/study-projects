# Arduino traffic lights

🚦 Traffic lights controlled with an Arduino board

## How it works

This project aims to recreate traffic lights with an Arduino. I'm not going to explain you how a traffic light works, I think you know well...

It's a really simple hardware setup : in a minimal configuration, there's five LEDs, a button, a potentiometer and a light sensor :

- Three LEDs for cars : green, yellow and red
- Two LEDs for pedestrians : green and red
- A button for pedestrians who want to cross the road
- A potentiometer to control the delay between red and green states
- A light sensor to adapt the intensity of the lights

## Hardware setup

Setup the components on your breadboard and connect them to your Arduino board. Here is an example using an Arduino Uno :

![Schema](docs/schema.png)

The pins on this schema are the same that inside the code.

## Software setup

All the code fits inside the `main.ino` sketch. In the `Definitions` part, edit the pins used for each component if you changed them during hardware setup. Note that the project is made using Tinkerkit, so that's why there are these weird pin names. Feel free to remove them at home !

After this step is done, upload the sketch on your board and start playing around the creation !

## Credits

- Maintainer : [Exybore](https://github.com/exybore)
- In collaboration with my two classmates, Rémi and Aloïs

## License

        DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                    Version 2, December 2004

Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>

Everyone is permitted to copy and distribute verbatim or modified
copies of this license document, and changing it is allowed as long
as the name is changed.

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE

TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

0. You just DO WHAT THE FUCK YOU WANT TO.
