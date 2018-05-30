Copyright (C) 2018 mirage335
See the end of the file for license conditions.
See license.txt for arduinoUbiquitous license conditions.

# Usage
Define board type to compile for under "_local/ops", or through the IDE GUI in persistent mode.

Arbitrary code may be added to "ops" file in same directory as sketch. Especially intended to set sketch-specific preferences (ie. board type).

Launch Arduino IDE with "./_arduino" . Compile with "./_arduino_compile" . Upload with "./ubiquitous_bash.sh _arduino_upload_m0" or similar.

Persistent changes to the IDE can be made through "./ubiquitous_bash.sh _arduino_edit" .

See "_prog/core.sh" for details.


# Design
Portable operation supported through fakeHome, and Arduino built-in portable functionality. Both are expected to use the same files.

## Requirements
* Arduino installation placed under "_local/h".
* Path to Arduino installation, relative to script, specified under "_prog/specglobalvars.sh" .
* Symbolic links established to link portable installation to typical Arduino home folders.
_local/h/.arduino15/sketchbook -> ../Arduino
_local/h/arduino-1.8.5/portable -> ../.arduino15

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

# Diagnostic
PORT->Group[PORTA].OUTTGL.reg = (1ul << 17);
__asm__("nop\n\t");

# Reference
* https://learn.adafruit.com/debugging-the-samd21-with-gdb/setup


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
