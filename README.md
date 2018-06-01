Copyright (C) 2018 mirage335
See the end of the file for license conditions.
See license.txt for arduinoUbiquitous license conditions.

Custom electronics and microcontroler firmware (notably 3D for printing) may need specific libraries versions, modifications, or procedures, to use Arduino.

Keeping copies of build dependencies, and tracking dependencies, within a single repository directory, is the purpose of the arduinoUbiquitous tool.

With specific versions of the full ArduinoIDE tracked and self-contained, and Atom based IDE is also included, adding debugging support to microcontroller projects using arduino.

# Usage
Define board type to compile for under "_local/ops", or through the ArduinoIDE GUI in persistent mode.

Arbitrary code may be added to "ops" file in same directory as sketch. Especially intended to set sketch-specific preferences (ie. board type).

Launch ArduinoIDE with "./_arduino" . Compile with "./_arduino_compile" . Upload with "./ubiquitous_bash.sh _arduino_upload_m0" or similar.

Persistent changes to the ArduinoIDE can be made through "./ubiquitous_bash.sh _arduino_edit" .

See "_prog/core.sh" for details.

# Development
Fork this repository to create specialized variants of this IDE for other purposes (ie. custom hardware support).

# Distribution
Create tar packages by command "./ubiquitous_bash.sh _package". These will contain the bare ".git" directory, an "arduino" directory, and an "arduino/portable" directory. End users can either populate the repository with "git reset --hard", or directly run the "arduino/arduino" executable, which will rely on the "arduino/portable" directory.

In this way, custom IDEs can be shipped out, for example alongside specialized device firmware, as a single tar package, to end users.

# Likely Problems

* Cores installed under "~/Arduino/hardware/" require a programmer in the IDE to be selected from the list of programmers under the "programmers.txt" file of that core.

# Design
Portable operation supported through fakeHome, and Arduino built-in portable functionality. Both are expected to use the same files.

## Requirements
* Arduino installation placed under "_local/h".
* Path to Arduino installation, relative to script, specified under "_prog/specglobalvars.sh" .
* Symbolic links established to link portable installation to typical Arduino home folders.
_local/h/.arduino15/sketchbook -> ../Arduino
_local/h/arduino-1.8.5/portable -> ../.arduino15

# External

WARNING: Do not copy ".git" files or folders into "_local/h".

* ArduinoIDE itself cannot be kept directly as a git submodule under "_lib", as it must be copied to temporary home directories. As a workaround, install the IDE files to the "_local/h" global home directory.
* Forks of Arduino cores (eg. ArduinoCore-samd), while kept directly as git submodules under "_lib", cannot be safely updated in place where they must be copied from the "_local/h" global home directory. Install them under "_local/h/Arduino", and test whether needed tools can be found by the ArduinoIDE.
* Tools, under "$HOME"/.arduino15/packages/arduino/hardware/tools , and similar, may not be available from tracked git submodules. Typically, these are obtained as automatic dependencies installed by the ArduinoIDE board manager. As a workaround, run the ArduinoIDE in a temporary intstance, gather the files, collect them from the 'h_<uid>' directory, and install them in an apporpriate location. Run ArduinoIDE with "_arduino_user". Or, directly install them using "_arduino_edit".

# Issues
* Programmer support for M0 requires PR265.
https://github.com/arduino/ArduinoCore-samd/pull/265

* Programmer requires udev rule.
https://blog.kylemanna.com/hardware/start-openocd-on-usb-hotplug/

* Upload using Programmer - fails.
https://forum.arduino.cc/index.php?topic=375270.0
https://github.com/arduino/ArduinoCore-samd/issues/164

* Debugging with bootloader may not be possible with current versions.
https://github.com/arduino/ArduinoCore-samd/issues/187

* High drive current may not be available.
https://github.com/arduino/ArduinoCore-samd/issues/158

# Guidelines
* Keep "_lib/ArduinoCore-samd" to a version compatible with uploading sketch and bootloader code by external programmer.
https://github.com/arduino/ArduinoCore-samd/pull/265
d72f11735d3588f4128b016b346f41ef9812b060
* Cores must not use '-' character in their name as does 'ArduinoCore-samd'. Recommend restricted character set. Allowing such characters causes confusing warnings about whitespace.

# Future Work
* Integrate Arduino Builder as well.
https://github.com/arduino/arduino-builder

# Diagnostic
PORT->Group[PORTA].OUTTGL.reg = (1ul << 17);
__asm__("nop\n\t");

# Reference
* https://hackaday.com/2015/07/28/embed-with-elliot-there-is-no-arduino-language/

* https://learn.adafruit.com/debugging-the-samd21-with-gdb/setup
* https://github.com/esp8266/Arduino
* https://github.com/arduino/ArduinoCore-samd/pull/224/files
* https://learn.adafruit.com/using-atsamd21-sercom-to-add-more-spi-i2c-serial-ports

* http://www.rogerclark.net/work-around-for-arduino-stm32-with-ide-v-1-6-3-or-newer/
* https://atadiat.com/en/e-arduino-core-source-files-make-new-core-building-steps/#Adding_New_Arduino_Core_to_IDE_Offline


__Copyright__
This file is part of arduinoUbiquitous.

arduinoUbiquitous is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

arduinoUbiquitous is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with arduinoUbiquitous.  If not, see <http://www.gnu.org/licenses/>.
