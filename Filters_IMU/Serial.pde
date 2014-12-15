
void print_value()
{
  //   Serial.print(delta_t);     //print loop time
  //  Serial.print ("\t");
  Serial.print(actAngle);         //print kalman angle
  Serial.print (",");
  Serial.print(actAngleC);        //print complementary angle
  Serial.print (",");
  Serial.print(actAngleC2);       //print complementary 2° order angle
  Serial.print (",");
  Serial.print(actAngleRG);       //print gyro angle
  Serial.print (",");
  Serial.print(ACC_angle);        //print accelerometer angle
  Serial.println(""); 


}  



