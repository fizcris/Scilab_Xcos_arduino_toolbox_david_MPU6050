void calibrateSensors() {                                       // Set zero sensor values
  long v;
  for(int n=0; n<3; n++) {
    v = 0;
    for(int i=0; i<50; i++)       v += readSensor(n);
    sensorZero[n] = v/50;
  }                                    
  sensorZero[1] -= 102; //Acc Z
}

void updateSensors() {                                         // data acquisition
  long v;
  for(int n=0; n<3; n++) {
    v = 0;
    for(int i=0; i<5; i++)       v += readSensor(n);
    sensorValue[n] = v/5 - sensorZero[n];
  }
}

int readSensor(int channel){
  return (analogRead(channel));
}


float getGyroRate() {
  // Giro = AdcGyro * Vref / 1023 / Sensitivity
  float  Gyro=float(sensorValue[0])* (3.3 / 1023.0) / (3.3/ 1000.0);
  return Gyro;
}


float getAccAngle() {              
  // AccX = AdcGyro * Vref / 1023 / Sensitivity * g  
  accZ=float(sensorValue[1])*(3.3 / 1023.0) / (330 / 1000) * 9.8; 
  accY=float(sensorValue[2])*(3.3 / 1023.0) / (330 / 1000) * 9.8;

  return (atan2(accY,accZ));
}

