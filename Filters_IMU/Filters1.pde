
#include <math.h>                     // include for atan2
int sensorValue[3]  = {0, 0, 0};
int sensorZero[3]  = {0, 0, 0}; 
int ACC_angle;
int GYRO_rate;

int val_gyro = 0;                    //value of individual accelerometer or gyroscope sensor
float accZ=0;
float accY=0;
float x1=0;
float y1=0;
float x2=0;
float y2=0;
float actAngle=0;  
float actAngleC=0;  
float actAngleRG=0;
float actAngleRA=0;
float actAngleC2=0;

unsigned long timer=0;               //timer
unsigned long  delta_t=0;            //delta time or how long it takes to execute data acquisition 
int lastLoopTime=5;
float x_angle=0;
float x_angleC=0;
float x_angleRG=0;
float  x_angleRA=0;
float x_angle2C=0;

void setup()
{
  analogReference(EXTERNAL);     //using external analog ref of 3.3V for ADC scaling
  Serial.begin(115200);          //setup serial

  DDRC = B00000000;              //make all analog ports as inputs - just in case....

  calibrateSensors();           // obtain zero values

  delay (100); 

  timer=millis(); 
}

void loop()
{
  delta_t = millis() - timer;                         // calculate time through loop i.e. acq. rate
  timer=millis();                                     // reset timer

  updateSensors();                                    // obtain sensors read values

  ACC_angle = getAccAngle()*180/PI;                   // accelerometers. in degrees                                              
  GYRO_rate = getGyroRate();                          // gyro in degrees/sec
  actAngleRA = RowAcc(ACC_angle, delta_t);            // calculate Absolute Angle with only accelerometer
  actAngleRG = RowGyro(GYRO_rate, delta_t);           // calculate Absolute Angle with only gyro
  actAngle = kalmanCalculate(ACC_angle, GYRO_rate, delta_t);   // calculate Absolute Angle with Kalman
  actAngleC = Complementary(ACC_angle, GYRO_rate, delta_t);    // calculate Absolute Angle with complementary filter
  actAngleC2 = Complementary2(ACC_angle, GYRO_rate, delta_t); 
   
  print_value();

  delay(10);             //loop delay;
}


