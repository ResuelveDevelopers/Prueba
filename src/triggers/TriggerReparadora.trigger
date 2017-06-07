/*******************************************************************************
Desarrollado por:   Resuelve tu deuda
Autor:              Jeisson Hernandez
Proyecto:           Colombia
Descripción:        TriggerReparadora

Cambios (Versiones)
-------------------------------------
    No.     Fecha           Autor                       Descripción
    ---     ---             ----------                  --------------------------      
    1.0     25-May-2015     Jeisson Hernandez (JH)      Creación de Trigger.
    1.1     18-Abr-2016     Esteban Heredia   (EH)      Modifición, para crear tareas automáticas. 
    1.2		22-Ago-2016		Marwin Pineda (MP)			Actualización sección Información Recomendado   
*******************************************************************************/
trigger TriggerReparadora on Reparadora__c (after insert) 
{
    public Boolean blnExecuteTrigger = true;    
    Map<ID, Account> mapCuentas = new Map<ID, Account>();
    Set<ID> setIdsCuentas = new Set<ID>();
    

    if( Trigger.isUpdate )
       blnExecuteTrigger = !RD_TriggerExecutionControl_cls.hasAlreadyDone('TriggerReparadora');

    if(blnExecuteTrigger)
    {
        if(Trigger.isAfter && Trigger.isInsert)
        { 
            // EH 18-Abr-2016: Clase auxiliar para crear las tareas automáticas
            auxiliarTriggerReparadora_cls.handlerAfterInsert(Trigger.new);     
            // EH END    
            //lista para Crear Ingresos
            List<Ingresos__c> lstCreateIngresos = new List<Ingresos__c>();
            //Objeto ingresos temporal
            Ingresos__c Ingresos;
            
            List<String> lstIdClientes = new List<String>();  
                    
            //Iteracion sobre reparadoras creadas
            for(Reparadora__c Reparadora: Trigger.new)
            {
                
                Ingresos = new Ingresos__c();
                
                //Mapeo de Campos
                Ingresos.TipoIngreso__c = 'Mensualidad Colombia';
                Ingresos.Monto__c = Reparadora.ComisionMensual__c;
                Ingresos.FechaFacturacion__c = Reparadora.FechaInicioPrograma__c;
                Ingresos.Status__c = 'Por Cobrar';
                Ingresos.Reparadora__c = Reparadora.Id;
                
                //Agregar Ingreso a lista
                lstCreateIngresos.add(Ingresos);
            }
            
            //MP - 22/08/2016 - Asignación de referenciado al cliente del programa
            auxiliarTriggerReparadora_cls.asignarReferenciado(Trigger.new);
            //MP - 22/08/2016 ENDING
            
            //Inserta Ingresos
            if(lstCreateIngresos.size()>0)
                insert lstCreateIngresos;
        } 
        
        if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert) )
        {
            for(Reparadora__c objRep : Trigger.new)
            {
                //JH 07-Sep-2015: Guarda Ids de Cuentas en Set setIdsCuentas
                if (!setIdsCuentas.contains(objRep.Cliente__c))
                    setIdsCuentas.add(objRep.Cliente__c);
            }
            
            //JH 07-Sep-2015: Almacena Cuentas de las reparadoras insertadas o actualizadas
            for(Account objCuenta : [Select Id
                                    ,OwnerId
                                    From Account Where id IN: setIdsCuentas])
            {
                if(!mapCuentas.containsKey(objCuenta.id))
                    mapCuentas.put(objCuenta.id, objCuenta);
            }//JH 07-Sep-2015: Fin for que almacena Cuentas de las reparadoras insertadas o actualizadas
            
            //JH 07-Sep-2015: Recorre las reparadoras para guardar campos de reparadora en cuenta
            for( Reparadora__c objReparadora : Trigger.new )
            {               
                if (mapCuentas.containsKey(objReparadora.Cliente__c))
                {
                        System.debug('ID Cuenta:' + objReparadora.Cliente__c + ' OwnerId Repadora: ' + objReparadora.OwnerId);
                        mapCuentas.get(objReparadora.Cliente__c).OwnerId = objReparadora.OwnerId;
                }
            }
            //JH 07-Sep-2015: Actualiza las cuentas
            if (!mapCuentas.isEmpty())
                if (!Test.isRunningTest())
                {
                    //RD_TriggerExecutionControl_cls.setAlreadyDone('TriggerAccount');
                    update mapCuentas.values();                             
                }
        }
    }
}