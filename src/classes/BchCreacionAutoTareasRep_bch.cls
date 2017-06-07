/*****************************************************************************************************
* Desarrollado por: RTD
* Autor:            Esteban Heredia (EH)
* Proyecto:         Colombia IV
* Descripción:      Trabajo programado para crear tareas automáticas de 30 60 y 90 en la reparadora            
*
* Cambios (Versiones)
* -------------------------------------
*           No.     fecha           Autor                       Descripción
*           -----   ----------      ------------------------    ---------------
* @version  1.0     11-May-2016     Esteban Heredia (EH)        Creación de la clase           
*******************************************************************************************************/
global with sharing class BchCreacionAutoTareasRep_bch implements Database.Batchable<sObject>,Database.Stateful
{
    global String Query;
    global Id recordTypeLllamadaSin;
    
    global BchCreacionAutoTareasRep_bch()
    {
        recordTypeLllamadaSin = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Actividad llamada en atraso').getRecordTypeId();
        Query =   'SELECT Id,Status__c,DiasDesdeUltimoContactoCliente__c,DiasSinDepositar__c,EjecutivoAtencionClientes__r.Usuario__c';
        Query += ',(SELECT Id,Subject FROM Tasks WHERE RecordTypeId =\'' +  recordTypeLllamadaSin  + '\' AND Status = \'En Proceso\' '; 
        Query += 'AND (Subject = \'Llamada por 30 días sin Contacto o Deposito\' OR Subject = \'Llamada por 60 días sin Contacto o Deposito\' OR Subject = \'Llamada por 90 días sin Contacto o Deposito\')) ';
        Query += 'FROM Reparadora__c '; 
        Query += 'WHERE Status__c = \'Activo\' AND (DiasDesdeUltimoContactoCliente__c >= 30 OR DiasSinDepositar__c >= 30) ';
        //Query += 'AND Id IN(\'a001a000009ylvC\',\'a001a000009ylvK\',\'a001a000009ylvN\',\'a001a000009yluK\',\'a001a000009yluQ\',\'a001a000009yluS\',\'a001a000009yluT\',\'a001a000009yluW\',\'a001a000009yluY\',\'a001a000009yluf\',\'a001a000009yluh\',\'a001a000009yluj\',\'a001a000009yluk\',\'a001a000009ylul\',\'a001a000009ylum\',\'a001a000009ylun\',\'a001a000009yluo\',\'a001a000009ylv0\',\'a001a000009ylv1\',\'a001a000009ylv3\') ';
    }
        
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
      return Database.getQueryLocator(query);
    }

   global void execute(Database.BatchableContext BC, List<sObject> scope)
   {
     List<Task> lstTareasSinContactoDeposito = new List<Task>();
     List<Reparadora__c> lstReparadorasScope = scope;
     Boolean    blCrearTarea30 = false;
     Boolean    blCrearTarea60 = false;
     Boolean    blCrearTarea90 = false;
     
     for(Reparadora__c objReparadoraTemp : lstReparadorasScope)
     {
        // Revisamos que la reparadora no tenga una tarea en proceso de las que queremos crear, si existe  sigue con la siguiente reparadora 
            if(!objReparadoraTemp.Tasks.isEmpty()) 
            {
                continue;
            }
        
          // Revisamos las condiciones para crear las tareas (Sin contacto o deposito 30,60,90)
            blCrearTarea30 = ((objReparadoraTemp.DiasDesdeUltimoContactoCliente__c >= 30 && objReparadoraTemp.DiasDesdeUltimoContactoCliente__c < 60 ) || (objReparadoraTemp.DiasSinDepositar__c >= 30 && objReparadoraTemp.DiasSinDepositar__c < 60))?true:false;
            blCrearTarea60 = ((objReparadoraTemp.DiasDesdeUltimoContactoCliente__c >= 60 && objReparadoraTemp.DiasDesdeUltimoContactoCliente__c < 90 ) || (objReparadoraTemp.DiasSinDepositar__c >= 60 && objReparadoraTemp.DiasSinDepositar__c < 90))?true:false;
            blCrearTarea90 = (objReparadoraTemp.DiasDesdeUltimoContactoCliente__c >= 90 || objReparadoraTemp.DiasSinDepositar__c >= 90)?true:false;

            
            //Si se crean dos tareas darle prioridad a la sin deposito
            if((blCrearTarea30 && blCrearTarea60) || (blCrearTarea30 && blCrearTarea90) || (blCrearTarea60 && blCrearTarea90))
            {
              blCrearTarea30 = (objReparadoraTemp.DiasDesdeUltimoContactoCliente__c >= 30 && objReparadoraTemp.DiasDesdeUltimoContactoCliente__c < 60 )?false:blCrearTarea30;
              blCrearTarea60 = (objReparadoraTemp.DiasDesdeUltimoContactoCliente__c >= 60 && objReparadoraTemp.DiasDesdeUltimoContactoCliente__c < 90 )?false:blCrearTarea60;
              blCrearTarea90 = (objReparadoraTemp.DiasDesdeUltimoContactoCliente__c >= 90)?false:blCrearTarea90;
            }

            // Crear las tareas de 30
            Task nuevaTareasSinContDep30 = blCrearTarea30?crearTareaSinContDep(objReparadoraTemp,recordTypeLllamadaSin,'Llamada por 30 días sin Contacto o Deposito'):null;
            if(nuevaTareasSinContDep30 != null)
                lstTareasSinContactoDeposito.add(nuevaTareasSinContDep30);
            //Crear las tareas de 60
            Task nuevaTareasSinContDep60 = blCrearTarea60?crearTareaSinContDep(objReparadoraTemp,recordTypeLllamadaSin,'Llamada por 60 días sin Contacto o Deposito'):null;
            if(nuevaTareasSinContDep60 != null)
                lstTareasSinContactoDeposito.add(nuevaTareasSinContDep60);
            //Crear las tareas de 90
            Task nuevaTareasSinContDep90 = blCrearTarea90?crearTareaSinContDep(objReparadoraTemp,recordTypeLllamadaSin,'Llamada por 90 días sin Contacto o Deposito'):null;
            if(nuevaTareasSinContDep90 != null)
                lstTareasSinContactoDeposito.add(nuevaTareasSinContDep90);
     }
     if(lstTareasSinContactoDeposito.size() > 0)
            insert lstTareasSinContactoDeposito;
        //****TAREASAUTOMATICASSINCONTACTOODEPOSITO****
    }
    
    public static Task crearTareaSinContDep(Reparadora__c objReparadoraTemp, String recordTypeLllamada,String strAsunto)
    {
        Task objTask                = new Task();
        objTask.Status              = 'En Proceso';
        objTask.Whatid              = objReparadoraTemp.Id;
        // Cambiar Asunto según los días sin contacto con el cliente o sin deposito
        objTask.Subject             = strAsunto;
        objTask.ActivityDate        = system.today();
        objTask.RecordTypeId        = recordTypeLllamada;
        objTask.OwnerId             = objReparadoraTemp.EjecutivoAtencionClientes__r.Usuario__c;
        return objTask;
    }

   global void finish(Database.BatchableContext BC)
   {
    
   }
   
    

}