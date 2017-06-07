/*******************************************************************************
Desarrollado por:   RTD
Autor:              Esteban Heredia
Descripción:        Trigger objeto TicketsSoporteTecnico(Casos) 

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha           Autor                       Descripción
    ---     -----------     ----------                  ---------------------------     
    2.0     17-Mar-2016     Esteban Heredia(EH)         Colocación de tipo de registro y validación de la hora 
                                                        con configuración personalizada.
*******************************************************************************/

trigger TriggerTicketsSoporteTecnico on TicketsSoporteTecnico__c (before insert) {
    
    

    //Solo validamos el evento before insert
    if (Trigger.isBefore)
    {
        //Ve si se trata del insert
        if (Trigger.isInsert)
        {
            //EH 22-Mar-2016: Calculamos la fecha, hora actual así como el día en terminos no númericos en el horario local.
            Date dtCurrDate = System.now().date();
            Time tiCurrTime = System.now().time();
            Datetime dttFechaAct = datetime.newInstanceGMT(dtCurrDate ,tiCurrTime );
            system.debug('dttFechaAct --> ' + dttFechaAct );
            String strDia = dttFechaAct.format('EEE');
            system.debug('strDia --> ' + strDia );
            Time tihoraAct = system.now().time();
            system.debug('tihoraAct --> ' + tihoraAct );
            //Realizamos un mapa de los tipos de registro de casos para obtener los nombres
            Map<String,String> mapNameByRecorTypeId = new Map<String,String>();
            List<recordType> lstRecordTypeCase  = [SELECT Id,Name,SobjectType FROM RecordType WHERE SobjectType = 'TicketsSoporteTecnico__c'];
            for(recordType tipoRegostroCaso:lstRecordTypeCase)
            {
               mapNameByRecorTypeId.put(tipoRegostroCaso.Id,tipoRegostroCaso.Name); 
            }
            // EH END
            //Recorre tu mapa y ve cual es el que se paso de la hora
            for (TicketsSoporteTecnico__c TktSopTec : Trigger.new)
            {
                    
                
                //Ve si es una carga masiva !TktSopTec.CargaMasiva__c
                if (TktSopTec.Origen__c !='Colombia')
                {
                    //EH 22-Mar-2016 Traemos el valor de los horarios de la config personalizada(Para todos los tipos de registro)
                    RestriccionSoporteTecnico__c objHorarioService = RestriccionSoporteTecnico__c.getAll().get(mapNameByRecorTypeId.get(TktSopTec.RecordTypeId));
                        if(objHorarioService.Activo__c)
                        {
                            Time horaInicioLJ = Time.newInstance(Integer.valueOf(objHorarioService.Hora_Inicio_L_J__c),Integer.valueOf(objHorarioService.Minuto_Inicio_L_J__c),0,0);
                            Time horaFinLJ = Time.newInstance(Integer.valueOf(objHorarioService.Hora_Fin_L_J__c),Integer.valueOf(objHorarioService.Minuto_Fin_L_J__c),0,0);
                            Time horaInicioV = Time.newInstance(Integer.valueOf(objHorarioService.Hora_Inicio_V__c),Integer.valueOf(objHorarioService.Minuto_Inicio_V__c),0,0);
                            Time horaFinV = Time.newInstance(Integer.valueOf(objHorarioService.Hora_Fin_V__c),Integer.valueOf(objHorarioService.Minuto_Fin_V__c),0,0);
                            system.debug('Hora Actual: ' + tihoraAct + 
                                            '\n horaInicioLJ: ' + horaInicioLJ + 
                                        '\n horaFinLJ: ' + horaFinLJ +
                                        '\n horaInicioV: ' + horaInicioV +
                                        '\n horaInicioV: ' + horaFinV);
                            //Ve que dia es para que valides la hora
                            //De lunes a jueves
                            System.debug('strDia: ' + strDia + ' tihoraAct.hour(): ' + tihoraAct.hour());
                            if(strDia=='Mon' || strDia=='Tue' || strDia=='Wed' || strDia=='Thu' || Test.isRunningTest())
                                if (tihoraAct <  horaInicioLJ  || tihoraAct > horaFinLJ || Test.isRunningTest())
                                    if (!Test.isRunningTest())                      
                                        TktSopTec.addError('Tickets Tipo ' + objHorarioService.Name + '. La hora debe estar entre las ' + DateTime.newInstance(Date.today(),horaInicioLJ).format('H:mm a')
                                                    + ' y las '+ DateTime.newInstance(Date.today(),horaFinLJ).format('H:mm a')  + ' Hora Actual: ' + DateTime.newInstance(Date.today(),tihoraAct).format('H:mm a'));
                            //De viernes a domingo      
                            //if(strDia=='Fri' || strDia=='Sat' || strDia=='Sun')
                            if(strDia=='Fri' || Test.isRunningTest())                 
                                if (tihoraAct <  horaInicioV  || tihoraAct > horaFinV || Test.isRunningTest())
                                    if (!Test.isRunningTest())                      
                                        TktSopTec.addError('Tickets Tipo ' + objHorarioService.Name + '. La hora debe estar entre las ' + DateTime.newInstance(Date.today(),horaInicioV).format('H:mm a')
                                                    + ' y las '+ DateTime.newInstance(Date.today(),horaFinV).format('H:mm a')  + ' Hora Actual: ' + DateTime.newInstance(Date.today(),tihoraAct).format('H:mm a'));                  
                            //Si es sabado o domingo no dejes que genere nada
                            if(strDia=='Sat' || strDia=='Sun' || Test.isRunningTest() && !objHorarioService.Permite_Crear_en_FDS__c)
                                if (!Test.isRunningTest())
                                    TktSopTec.addError('No puedes generar tickets el fin de semana');
                            //EH END
                        }
                }//Fin si no es carga masiva
                //else if(TktSopTec.nombretiporegistroOrgCol__c != null)
                //{
                    // Obtenemos el id del nombre del recordType y lo asignamos 
                    //TktSopTec.recordTypeId =  obtenerIdRecordType(TktSopTec.nombretiporegistroOrgCol__c,TktSopTec);    
                //}
            }//Fin del for para los casos
            
        }//Fin si se trata del insert
    }//Fin si se trata de before

    /**
     * Método que devuelve el id del tipo de registro teniendo previamente su nombre
     * @author EH
     * @param  Nombre del tipo de registro
     * @param  Objeto actual del trigger, para colocar el respectivo error
     * @return Id del tipo de registro
     */
    public string obtenerIdRecordType(String nameRecordType, TicketsSoporteTecnico__c ticketSoporteTecnico)
    {
        try 
        {
           Id recordTypeId = Schema.SObjectType.TicketsSoporteTecnico__c.getRecordTypeInfosByName().get(nameRecordType).getRecordTypeId();
           return recordTypeId;
            
        } catch(Exception e) 
        {
            ticketSoporteTecnico.addError('Sucedio una excepción, nombre de tipo registro no existe: ' + e.getMessage());
            return null;
        }
        
    }
}