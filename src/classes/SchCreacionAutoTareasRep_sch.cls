/*****************************************************************************************************
* Desarrollado por: RTD
* Autor:            Esteban Heredia (EH)
* Proyecto:         Colombia IV
* Descripción:      Scheduler para crear tareas automáticas en la reparadora            
*
* Cambios (Versiones)
* -------------------------------------
*           No.     fecha           Autor                       Descripción
*           -----   ----------      ------------------------    ---------------
* @version  1.0     19-Abr-2016     Esteban Heredia (EH)        Creación de la clase           
*******************************************************************************************************/

global class SchCreacionAutoTareasRep_sch implements Schedulable 
{
    global void execute(SchedulableContext sc) 
    {
        //****TAREASAUTOMATICASPOSTVENTA****
        List<Task> lstTareasPostVenta = new List<Task>();
        List<Reparadora__c> lstActReparadoras = new List<Reparadora__c>();
        // Se crea una fecha de 5 días después al día de hoy para utilizarla en la query, para calcular la condición Fecha de apartado mes actual – 5 días y crear la tarea de postventa 1 sino existe ya otra.
        Date dtCincoDiasDespActual = system.today().addDays(5); 
        // Tipo de registro tareas de post venta 1
        Id recordTypePostVenta1 = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Actividad de Post Venta1').getRecordTypeId();
        // Llamamos a las reparadoras que cumplan (Status = “Activo”) and  (Fecha de apartado mes actual – 5 días) or (Días en el programa = 45)
        // Se realiza el query en el for para que actue como un batch
        List<Reparadora__c> lstReparadorasPost = [SELECT Id,Status__c,EjecutivoAtencionClientes__r.Usuario__c,CreadaTareaPostVenta__c,(SELECT Id FROM Tasks WHERE RecordTypeId =: recordTypePostVenta1 AND Subject = 'Llamada Telefonica Post Venta # 1') 
                                                FROM Reparadora__c 
                                                WHERE Status__c = 'Activo' AND CreadaTareaPostVenta__c = false AND (DiasPrograma__c = 45 OR DiaApartadoMensualMesCorriente__c =: dtCincoDiasDespActual)];
        for(Reparadora__c objReparadoraTemp: lstReparadorasPost) 
        {
            // Si no tiene alguna tarea de postventa, crea esta tarea
            if(objReparadoraTemp.Tasks.isEmpty())
                {
                    Task objTask                = new Task();
                    objTask.Status              = 'En Proceso';
                    objTask.Whatid              = objReparadoraTemp.id;
                    objTask.Subject             = 'Llamada Telefonica Post Venta # 1';
                    objTask.ActivityDate        = system.today();
                    objTask.RecordTypeId        = recordTypePostVenta1;
                    objTask.OwnerId             = objReparadoraTemp.EjecutivoAtencionClientes__r.Usuario__c;
                    lstTareasPostVenta.add(objTask);
                    objReparadoraTemp.CreadaTareaPostVenta__c = true;
                    lstActReparadoras.add(objReparadoraTemp);
                }
        }
        if(!lstTareasPostVenta.isEmpty())
            insert lstTareasPostVenta;
        if(!lstActReparadoras.isEmpty())
            update lstActReparadoras;
        //****FINTAREASAUTOMATICASPOSTVENTA****

        //****TAREASAUTOMATICASSINCONTACTOODEPOSITO****
        // Llamamosalbatch que se encarga de crear las tareas automáticamente
        BchCreacionAutoTareasRep_bch bchTareasAutomaticas = new BchCreacionAutoTareasRep_bch();
        Id batchProcessId = Database.executeBatch(bchTareasAutomaticas, 100);
        //****TAREASAUTOMATICASSINCONTACTOODEPOSITO*****/
    }

}