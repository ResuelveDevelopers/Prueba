/********************************************************************************************************
Desarrollado por:   Resuelve
Autor:              Angela Munévar(AM)
Proyecto:           Resuelve tu Deuda
Descripción:        Trigger que controla los eventos del objeto solicitud de fondeo

Cambios (Versiones)
--------------------------------------------------------------------------------------------------------
    No.     Fecha               Autor                       Descripción
    ---     -----------         ------------------------    --------------------------      
    1.0     14-Abr-2016         Angela Munévar(AM)          Creación de la Clase 
***************************************************************************************/
trigger TriggerSolicitudDeFondeo on Solicitud_Fondeos__c (before insert,before update,after insert) 
{
   

    if(trigger.isbefore)
	{
        Id CrearFlujoRecordTypeId = Schema.SObjectType.Solicitud_Fondeos__c.getRecordTypeInfosByName().get('Crear Flujo').getRecordTypeId();
        map<Id,String> mapRecordTypes= new map<Id,String>();
        set<Id> setDeuda = new set<Id>(); // deudas asociadas a las solicitudes de fondeo
        list<Solicitud_Fondeos__c> listToProcess = new list<Solicitud_Fondeos__c>();  // lista de las solicitudes de fondeo

        for(RecordType r:[Select r.SobjectType, r.Name, r.Id From RecordType r where SobjectType='Solicitud_Fondeos__c'])
        {
                mapRecordTypes.put(r.Id,r.Name);
        }

        for(Solicitud_Fondeos__c objSolFondeo:trigger.new)
        {
           if(objSolFondeo.Deuda__c != null)
           {
               setDeuda.add(objSolFondeo.Deuda__c);
           }
           listToProcess.add(objSolFondeo); 
        }

        system.debug('+++setDeuda '+setDeuda);
        // Actualiza los datos de la solicitud de fondeos
        if(setDeuda != null && setDeuda.size()>0)
        {   
           //consulta las solicitudes de fondeo correspondienes a las deudas          
            map<Id,Deudas__c> mapdeudaAndSolicitudesDeFondos = new map<Id,Deudas__c>(
            [Select d.Id,d.Contacto__c, (Select Estatus__c,Fecha__c,TotalSolicitado__c From 
            Solicitudes_de_Fondos__r order by CreatedDate desc limit 1) From Deudas__c d where id in:setDeuda]);

            if(mapdeudaAndSolicitudesDeFondos != null && mapdeudaAndSolicitudesDeFondos.size()>0)
            {
                system.debug('+++listToProcess '+listToProcess);
                for(Solicitud_Fondeos__c objSolFondeo:listToProcess)
                {      
                    system.debug('+++mapa '+mapdeudaAndSolicitudesDeFondos);  
                    system.debug('+++mapa1 '+mapRecordTypes.containskey(objSolFondeo.RecordTypeId)); 
                    system.debug('+++mapa2 '+mapRecordTypes.get(objSolFondeo.RecordTypeId));            
                    if(objSolFondeo.Deuda__c  != null && mapdeudaAndSolicitudesDeFondos.containskey(objSolFondeo.Deuda__c)
                        && mapRecordTypes.containskey(objSolFondeo.RecordTypeId) &&
                         mapRecordTypes.get(objSolFondeo.RecordTypeId)== 'Flujo Negociación')
                    {                             
                        Deudas__c objDeuda= mapdeudaAndSolicitudesDeFondos.get(objSolFondeo.Deuda__c);
                        system.debug('+++objDeuda.Solicitudes_de_Fondos__r '+objDeuda.Solicitudes_de_Fondos__r);
                        if(objDeuda.Solicitudes_de_Fondos__r != null && objDeuda.Solicitudes_de_Fondos__r.size()>0)
                        {
                            SolicitudesDeFondos__c objSolicitudFondos = objDeuda.Solicitudes_de_Fondos__r.get(0); 
                            objSolFondeo.StatusFondos__c=objSolicitudFondos.Estatus__c;
                            objSolFondeo.FechaFondos__c=objSolicitudFondos.Fecha__c;    
                            objSolFondeo.Deuda__c=objDeuda.Id;
                            objSolFondeo.TotalSolicitado__c=objSolicitudFondos.TotalSolicitado__c;
                            system.debug('+++objSolFondeo.Status__c '+objSolFondeo.Status__c);
                            if(objSolFondeo.Status__c == 'Aceptado')
                            {
                                objSolFondeo.RecordTypeId = CrearFlujoRecordTypeId; 
                            }
                            
                        }                             
                    }
                    
                }
            }
        }

    }
    // crea una tarea
    /*if(trigger.isafter) 
    {
       
        if(trigger.Isinsert)
        {
            Id SoliFondRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Solicitud de Fondeo').getRecordTypeId();
            list<Task> listTask=new list<Task>(); 
                           
            for(Solicitud_Fondeos__c objSolFon:trigger.new)
            {
                
                    Task objTask = new Task();
                    objTask.WhatId=objSolFon.Id;
                    objTask.OwnerId=objSolFon.Manager__c;
                    objTask.ActivityDate = date.newinstance(objSolFon.CreatedDate.year(), objSolFon.CreatedDate.month(), objSolFon.CreatedDate.day()); 
                    objTask.Subject='Solicitud de Fondeo';            
                    objTask.RecordTypeId = SoliFondRecordTypeId;
                    objTask.IsReminderSet= true;
                    objTask.ReminderDateTime=Date.Today().addDays(1);    
                    listTask.add(objTask);
                if(!test.isRunningTest())
                {
                	insert listTask;
                
                }
            }
        }

    }*/

}