Copyright (C) 2018 mirage335
See the end of the file for license conditions.
See license.txt for arduinoUbiquitous license conditions.

Custom electronics and microcontroler firmware (notably 3D for printing) may need specific libraries versions, modifications, or procedures, to use Arduino.

Keeping copies of build dependencies, and tracking dependencies, within a single repository directory, is the purpose of the arduinoUbiquitous tool.

With specific versions of the full ArduinoIDE tracked and self-contained, and Atom based IDE is also included, adding debugging support to microcontroller projects using arduino.

# Usage
Launch ArduinoIDE with "./_arduino" . Compile with "./_arduino_compile" . Upload with "./ubiquitous_bash.sh _arduino_upload" or similar.

Persistent changes to the ArduinoIDE can be made through "./ubiquitous_bash.sh _arduino_edit" .

Arbitrary shellcode may be added to "ops" file in same directory as sketch. Especially intended to set sketch-specific preferences (ie. board type). Example at "_lib/Blink". Run "./_arduino_blink" to compile and upload an LED blink example configured for Arduino M0 by default.

See "_prog/core.sh" for details.

# Dependencies
Nothing that would not be installed on a typical Linux development machine. Just run "./ubiquitous_bash.sh _setup" or "./ubiquitous_bash.sh _test" to install/check.

Arduino itself is included.

# Internal
Arduino compile, upload, debug, and similar operations, may be done within the current session.
* "$scriptAbsoluteLocation" --parent _arduino_compile_commands "$au_arduinoSketch"
* "$scriptAbsoluteLocation" --parent _arduino_upload_commands "$au_arduinoSketch"
* "$scriptAbsoluteLocation" --parent _arduino_run_commands "$au_arduinoSketch"

* "$scriptAbsoluteLocation" --parent _arduino_swd_openocd_zero &

List of input parameters is available within the current shell.
* "${globalArgs[@]}"

When running Atom, a terminal emulator, or any other app, under the "_launch_env" function, as is done for the App (Atom) IDE, with the "_aide" command, some exported arduinoBash functions and variables will be usable by a subordinate shell.
* "$safeTmp", "$shortTmp"
* "$setFakeHome"
* "$au_*"
	au_arduinoInstallation
	au_arduinoSketch
	au_arduinoSketchDir
	au_arduinoBuildPath


However, subshells will not see unexported functions unless they are imported.
* . "$scriptAbsoluteLocation" --parent

Issue "_setupUbiquitous" to any comprehenisve Ubiquitous Bash script to add an automatic hook in the current user's bash profile. Doing so will also import a more informative shell prompt.
* . "$scriptAbsoluteLocation" --parent _importShortcuts

Arbitrary commands from the parent script can be run within the curent session and/or shell.
* "$scriptAbsoluteLocation" --parent _echo true
* . "$scriptAbsoluteLocation" --parent _echo true

WARNING: Since you are obviously operating with a single session, do not call "_stop" anywhere within it, as this will kill the parent process, and clean up the "temporary" directories.

# Development
Fork this repository to create specialized variants of this IDE for other purposes (ie. custom hardware support).

# Distribution
Create tar packages by command "./ubiquitous_bash.sh _package". These will contain the bare ".git" directory, an "arduino" directory, and an "arduino/portable" directory. End users can either populate the repository with "git reset --hard", or directly run the "arduino/arduino" executable, which will rely on the "arduino/portable" directory.

In this way, custom IDEs can be shipped out, for example alongside specialized device firmware, as a single tar package, to end users.

# Design
Portable operation supported through fakeHome, and Arduino built-in portable functionality. Both are expected to use the same files.

## Requirements
* Arduino installation placed under "_local/arduino".

# External
* Tools, under "$HOME"/.arduino15/packages/arduino/hardware/tools , and similar, may not be available from tracked git submodules. Typically, these are obtained as automatic dependencies installed by the ArduinoIDE board manager. As a workaround, run the ArduinoIDE in a temporary intstance, gather the files, collect them from the 'h_<uid>' directory, and install them in an apporpriate location. Run ArduinoIDE with "_arduino_user". Or, directly install them using "_arduino_edit".

# Issues
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

* Driver to retrieve firmware information over USBSerial, upload new firmware by device type.

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

* https://cdn-learn.adafruit.com/downloads/pdf/debugging-the-samd21-with-gdb.pdf

* https://github.com/arduino/Arduino/issues/3746
* https://github.com/arduino/arduino-builder/pull/9


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
