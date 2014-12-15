
   float RowAcc(float newAngle,int looptime) {
     float dtRA = float(looptime)/1000.0;                                    
     x_angleRA= x_angleRA + 1/2*(newAngle)*dtRA*dtRA;
     
     return x_angleRA;
      }
