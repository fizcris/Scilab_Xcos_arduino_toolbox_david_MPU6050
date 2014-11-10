//
// Scilab ( http://www.scilab.org/ ) - This file is part of Scilab
// Copyright (C) 2011-2011 - DIGITEO - Bruno JOFRET
//
// This file must be used under the terms of the CeCILL.
// This source file is licensed as described in the file COPYING, which
// you should have received as part of this distribution.  The terms
// are also available at
// http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt
//
//
  
function scs_m=ARDUINO_pre_simulate(scs_m, needcompile)
  global port_com arduino_sample_time
  presence_arduino=%f //indique la presence d'un bloc arduino setup
  presence_scope=%f;
  list_scope=[];
  display_now=0;
  funcprot(0)
  presence_mpu=%f //indique si un bloc MPU est present
  
  //recherche de la presence d'un bloc MPU6050
  for i = 1:size(scs_m.objs)
     curObj= scs_m.objs(i);
     if (typeof(curObj) == "Block" & curObj.gui == "ARDUINO_MPU6050_READ")
         presence_mpu=%t
     elseif (typeof(curObj) == "Block" & curObj.gui == "MPU6050_READ_SB")
         presence_mpu=%t
     end
  end
  
  for i = 1:size(scs_m.objs)
    curObj= scs_m.objs(i);
    if (typeof(curObj) == "Block" & curObj.gui == "ARDUINO_SETUP")
        presence_arduino=%t   
        scs_m.props.tol(5)=1;
       
        try
          close_serial(1)
          sleep(1000)
          port_com_arduino=scs_m.objs(i).model.rpar(2)
          ok=open_serial(1,port_com_arduino,115200); //ouverture du port COM de l'arduino i
          if (ok>0) then
              messagebox("Mauvais port de communication.")
              error('connexion aborted')
          end
          disp("communication with card "+string(1)+" on com "+string(port_com_arduino)+" is ok")
          sleep(1000)
          
          word='R3';
          write_serial(1,word,2);
          tic()
          [a,b,c]=status_serial(1);
          tini=toc()
          tcur=0
          while (b<2 & tcur<2) 
             [a,b,c]=status_serial(1);
             tcur=toc()-tini
          end
          values=read_serial(1,2);

          if presence_mpu then
              version_ino='v4'
          else
              version_ino='v3'
          end
          if tcur>=2 | values ~=version_ino then
              messagebox("Il faut charger avec le logiciel arduino le sketch toolbox_arduino_"+version_ino+".ino dans la carte Arduino")
              error('ino')
          else
              disp("Version "+version_ino+" de la toolbox")
          end
          
          //specifique a l'utilisation de la carte MPU6050
          //Verification qu'elle est bien connectee
          if presence_mpu then
              write_serial(1,"Gt",2);
              tic()
              [a,b,c]=status_serial(1);
              tini=toc()
              tcur=0
              while (b<2 & tcur<3) 
                 [a,b,c]=status_serial(1);
                 tcur=toc()-tini
              end
              values=read_serial(1,2);
              if values=="OK" then
                  disp("La carte MPU6050 est bien connectée")
              else
                  error("La carte MPU6050 n''est pas prête. Verifiez les branchements")
              end
          end
        
          
          
          

        catch
            close_serial(1)
            error('Mauvais port de communication.')
            
        end
    end
    if (typeof(curObj) == "Block" & curObj.gui == "TIME_SAMPLE") then
        scs_m.props.tf=scs_m.objs(i).model.rpar(1);
        arduino_sample_time=scs_m.objs(i).model.rpar(2);
        display_now=evstr(scs_m.objs(i).graphics.exprs(3));
    end
    if (typeof(curObj) == "Block" & curObj.gui == "ARDUINO_SCOPE")
      presence_scope=%t 
      list_scope($+1)=i;
    end
  end

  //update ISCOPES
  if presence_scope then
     nb_total_outputs=0;
     nb_objs_in_scopeblock=5;
        for i=1:size(list_scope,1)
            //read data from ISCOPE
           nb_outputs=evstr(scs_m.objs(list_scope(i)).graphics.exprs(1));

           //read data from ireptemp
           tf=scs_m.props.tf;
           sample_time=arduino_sample_time;
           num_pts=round(tf/sample_time);
           list_obj=scs_m.objs(list_scope(i)).model.rpar.objs;
           
           if display_now==1 then
           
                no=1;
                scope=CSCOPE('define');
                scope.model.rpar(4)=tf;

                scope.graphics.exprs(7)=string(tf);
                for j=1:size(list_obj)
                    if (typeof(list_obj(j)) == "Block" & list_obj(j).gui == "TOWS_c") then //on affecte un nom pour le stockage dans scilab
                        scope.graphics.pin = scs_m.objs(list_scope(i)).model.rpar.objs(j).graphics.pin;
                        scope.graphics.pein = scs_m.objs(list_scope(i)).model.rpar.objs(j).graphics.pein;
                        scope.graphics.sz=scs_m.objs(list_scope(i)).model.rpar.objs(j).graphics.sz;
                        scope.graphics.exprs($)=scs_m.objs(list_scope(i)).graphics.exprs(3)
                        scs_m.objs(list_scope(i)).model.rpar.objs(j)=scope;
                        no=no+1;
                    elseif (typeof(list_obj(j)) == "Block" & list_obj(j).gui == "SampleCLK") then //on modifie le pas de temps
                        scs_m.objs(list_scope(i)).model.rpar.objs(j).model.rpar(1)=sample_time;
                        scs_m.objs(list_scope(i)).model.rpar.objs(j).graphics.exprs(1)=string(sample_time);                        
                    end
                end
            else
                no=1;
                for j=1:size(list_obj)
                    if (typeof(list_obj(j)) == "Block" & list_obj(j).gui == "TOWS_c") then //on affecte un nom pour le stockage dans scilab
                        scs_m.objs(list_scope(i)).model.rpar.objs(j).graphics.exprs=[string(num_pts);"o"+string(no+nb_total_outputs);"0"];
                        scs_m.objs(list_scope(i)).model.rpar.objs(j).model.ipar=[num_pts;2;24;no+nb_total_outputs]; 
                        no=no+1;
                    elseif (typeof(list_obj(j)) == "Block" & list_obj(j).gui == "SampleCLK") then //on modifie le pas de temps
                        scs_m.objs(list_scope(i)).model.rpar.objs(j).model.rpar(1)=sample_time;          
                        scs_m.objs(list_scope(i)).model.rpar.objs(j).graphics.exprs(1)=string(sample_time);                                                
                    end
                end
                
            end
            
           nb_total_outputs=nb_total_outputs+nb_outputs;
      end
  end 
  

  continueSimulation = %t;
  disp("Fin pre_simulate arduino")
  disp('Acquisition en cours...')
  scs_m=resume(scs_m)

endfunction
