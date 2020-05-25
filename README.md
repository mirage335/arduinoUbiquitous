Copyright (C) 2018 mirage335
See the end of the file for license conditions.
See license.txt for arduinoUbiquitous license conditions.

Standalone Arduino development environment. Ensures portability comparable to "makefile" or "cmake" projects, even if external debuggers must be configured.

Contains all dependencies, including binaries and libraries, to a single directory, using only relative paths. Integrates interfaces to extrnal tools (eg. gdb, ddd, Atom, Eclipse). Employs applicaton virtualization as necessary.

Arduino has become a common component of larger industrial systems, most notably 3D printer controllers.

# Usage
From terminal, launch "_arduino" with existing sketch directory as a parameter.

./_arduino ./_lib/Blink

A "./.s_arduino" directory will appear with hardcoded shortcut scripts to compile, upload, and debug, as well as launch graphical IDE.

Additional scopes may be launched from within this environment, or directly from the script directory. Shutdown of the initiating scope will remove this environment from all scopes.

./ubiquitous_bash.sh _scope_arduinoide ./_lib/Blink/

Many of these commands should ideally be launched within a visible terminal. Vivid diagnostics are written to stdout/error.

Starting without an existing sketch is NOT OFFICIALLY SUPPORTED. For an example and template, see "_lib/Blink".

Arbitrary shellcode may be added to "ops" file in same directory as sketch. Especially intended to set sketch-specific preferences (ie. board type). Example "ops" provided with "_lib/Blink". Run "./_arduino_blink" to compile and upload an LED blink example (configured for Arduino M0 with Arduino Zero bootloader by default).

See "_prog/core.sh" for details.

# Automation
Anchor script shortcuts neighboring "ubiquitous_bash.sh" are intended for end-users, or other scripts, to launch specific actions.

./_arduino_debug ./_lib/Blink
./_arduino_blink

Interface shortcuts, named "_interface*", bridge applications used internally (eg. gdb debugger interface to atom text editor), and are not intended for end-users.

# Debugging
Real-time debugging is supported with "_scope_ddd_procedure". Binary ELF is always taken from "$au_arduinoFirmware_sym", typically "$shortTmp"/_build/"$au_basename".ino.elf .

Complete "_compile" or "_run", or compile through 'ArduinoIDE', before issuing 'load' command within "ddd" to refresh.

Typical workflow is to launch a filemanager, text editor, terminal, or 'ArduinoIDE' as scope, then to launch ddd as a scope within the same session.

./_scope_terminal ./_lib/Blink
"$ub_scope"/_scope_arduinoide_procedure
"$ub_scope"/_scope_ddd_procedure

# Dependencies
Nothing that would not be installed on a typical Linux development machine. Just run "./ubiquitous_bash.sh _setup" or "./ubiquitous_bash.sh _test" to install/check.

Arduino itself is included.

# Internal
Arduino compile, upload, debug, and similar operations, may be done within the current session.
* _compile
* _upload
* _run
* _bootloader

When running Eclipse, Atom, a terminal emulator, or any other app, under the "_scope" function, some exported arduinoBash functions and variables will be usable by a subordinate shell.
* "$safeTmp", "$shortTmp"
* "$setFakeHome"
* "$au_*"
	"$au_arduinoSketch"
	"$au_arduinoSketchDir"

However, subshells will not see unexported functions unless they are imported.
* . "$scriptAbsoluteLocation" --parent

All script functions may be imported into current shell. Additionally, issue "_setupUbiquitous" to any comprehenisve Ubiquitous Bash script to add an automatic hook in the current user's bash profile. Doing either will also import a more informative shell prompt.
* . "$scriptAbsoluteLocation" --parent _importShortcuts

Arbitrary commands from the parent script can be run within the curent session and/or shell.
* "$scriptAbsoluteLocation" --parent _echo true
* . "$scriptAbsoluteLocation" --parent _echo true

WARNING: Since you are obviously operating with a single session, do not call "_stop" anywhere within it, as this will kill the parent process, and clean up the 'temporary' directories. This also applies to any command run within the scope environment, as the scope name/location is shared.

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
* Atom packages may be copied from git submodules under "_lib". Updating these submodules will not update the packages. After copying modules, "apm install" may need to be run from within "_editFakeHome_atom". This arrangement is a precaution against interference with safety checks within _safeRMR .

# Issues
* Setting breakpoints while firmware is running does not work, and may cause problems, necessitating restart of OpenOCD.
https://github.com/31i73/atom-dbg/issues/40

* High drive current may not be available.
https://github.com/arduino/ArduinoCore-samd/issues/158

* ARM host version of Arduino is not included or selected automatically.

# Guidelines
* Keep "_lib/ArduinoCore-samd" to a version compatible with uploading sketch and bootloader code by external programmer.
https://github.com/arduino/ArduinoCore-samd/pull/265
d72f11735d3588f4128b016b346f41ef9812b060
* Cores must not use '-' character in their name as does 'ArduinoCore-samd'. Recommend restricted character set. Allowing such characters causes confusing warnings about whitespace.

# Future Work
* Integrate Arduino Builder as well.
https://github.com/arduino/arduino-builder

* Driver to retrieve firmware information over USBSerial, upload new firmware by device type.

* Clear use of git submodules directly within "_lib/app/atom/home/.atom/packages" .

# Diagnostic
PORT->Group[PORTA].OUTTGL.reg = (1ul << 17);
__asm__("nop\n\t");


# Certification

## c06893ac341567f6fa06a868e874f8b596eb4e58

+ Upload Arduino Zero bootloader via SWD to Ardunin M0 as Arduino Zero.
+ Compile Blink.
+ Upload Blink via SWD to Arduino M0 as Arduino Zero.
+ Upload Blink via Serial (including after SWD).
+ "_arduino_debug_ddd" after "_arduino_compile" and "_arduino_upload" within './_scope ./_lib/Blink/' or as './_arduino_debug_ddd ./_lib/Blink/' .


* Fading or Stuck Blink LED, inability to upload via serial.
	* Quick USB power cycling regardless of USB data presence.
	* Serial port programming by ArduinoIDE.

## c06893ac341567f6fa06a868e874f8b596eb4e58
+ ./_arduino_compile ./_lib/_examples/teensy36/Blink/
+ ./_arduino_upload ./_lib/_examples/teensy36/Blink/


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

* https://github.com/31i73/atom-dbg/issues/1
* https://github.com/31i73/atom-dbg-gdb/blob/master/README.md#supported-options

* https://forum.arduino.cc/index.php?topic=375270.0

* https://mcuoneclipse.com/2015/03/22/openocdcmsis-dap-debugging-with-eclipse-and-without-an-ide/
* https://thingtype.com/blog/gdb-debugging-in-eclipse/
* https://github.com/jdolinay/avr_debug

* https://forum.pjrc.com/threads/45091-Installing-Teensyduino-on-an-Arduino-portable
* https://www.pjrc.com/teensy/td_download.html


* https://arduino-esp8266.readthedocs.io/en/latest/installing.html#using-git-version



* https://forum.pjrc.com/threads/41751-Is-the-Teensy-boot-loader-source-available


# Third Party Copyright

All third-party files incorporated retain the licenses provided by their original authors. Incorporated works may include...

* Arduino - https://www.arduino.cc/
* Teensyduino - https://www.pjrc.com/teensy/td_download.html

All other files are part of arduinoUbiquitous . In particular, it is desired that there should be no ambiguity whatsoever the shell script segments provided under directory "_prog" and subsequently concatenated or compiled into 'ubiquitous_bash.sh', or any similar files, are intended to be covered by the GPLv3 license .


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
