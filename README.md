Scilab Xcos Arduino toolbox
=========================================
Serial Communication Toolbox for Scilab provided by David Violeau to include MPU6050 bloc and filtering for use with Arduino UNO and MEGA.
=========================================
Installation:

+ Download sketch _v4 into your arduino card. 
+ Copy arduino_svn into directory \contrib. 
You will have a new block called MPU6050 where you can tell which data get from card.
+ At beginning of scilab go to menu Modules and select Arduino. (You can recompile if necessary by executing builder.sce but I think it is not necessary)
=========================================
Changes:

Arduino v4:
+ Support for MPU6050

Arduino v5_cris:
+ Added support for shield dual motor Driver POLOLU VNH5019
+ Added function to change PWM frequency in Arduino UNO and Arduino MEGA.
  (https://github.com/fizcris/PWM_frequency_Arduino_change)
- Removed support for motor driver L293 
