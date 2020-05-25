
##### specglobalvars #####

#Default not to create "project.afs" file, unless "$afs_nofs" explicitly set to "false".
[[ "$afs_nofs" != "false" ]] && export afs_nofs=true



##### specglobalvars_arduino #####

export au_arduinoLocal="$scriptLocal"/arduino

# WARNING: Some sane defaults may be defined here due to slim possibility may be found necessary due to historical reasons which have not been identified.
# Disabled by default. Strongly discouraged.
###
# export au_arduinoVersion=arduino-1.8.5
# export au_arduinoDir="$au_arduinoLocal"/"$au_arduinoVersion"
# 
# export au_gdbBin="$au_arduinoLocal"/.arduino15/packages/arduino/tools/arm-none-eabi-gcc/4.8.3-2014q1/bin/arm-none-eabi-gdb
# 
# export au_openocdStatic="$scriptLib"/openocd-static
# export au_openocdStaticUB="$au_openocdStatic"/ubiquitous_bash.sh
# export au_openocdStaticBin="$au_openocdStatic"/build/bin/openocd
# export au_openocdStaticScript="$au_openocdStatic"/build/share/openocd/scripts
###



##### specglobalvars_arduino_device zero #####





