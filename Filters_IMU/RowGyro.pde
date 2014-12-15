   
   float RowGyro(float newRate,int looptime) {
     float dtRG = float(looptime)/1000.0;                                    
     x_angleRG= x_angleRG - newRate * dtRG;
     
     return x_angleRG;
      }
