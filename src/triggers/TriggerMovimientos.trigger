/*****************************************************************************************************
* Desarrollado por: RTD
* Autor:            Esteban Heredia (EH)
* Proyecto:         Colombia 
* Descripción:      Trigger que controla los eventos del objeto Movimientos__c              
*
* Cambios (Versiones)
* -------------------------------------
*           No.     fecha          	Autor 		               	Descripción
*           -----   ----------      ------------------------   	---------------
* @version  1.0     11-Abr-2016     Esteban Heredia (EH)        Creación de la clase  
* @version  1.1     16-Ene-2016     Joe Ayala (JA)        		Se adiciona campo Porcentaje_de_IVA_Actual__c para controlar el porcentaje del calculo de IVA de la deuda 
    															basado en un rango de tiempo definido en una conf personalizada a partir de la fecha de liquidación,
	               												en caso de no tenerla se calculará con la fecha del dia en que crea o modifica y cada ves que se actualice evaluará estas condiciones. 

*******************************************************************************************************/
trigger TriggerMovimientos on Movimientos__c 
(
    before insert, 
    before update, 
    before delete, 
    after insert, 
    after update, 
    after delete, 
    after undelete
)
{
	if (Trigger.isAfter) 
	{
		if(Trigger.isInsert)
        {
            AuxiliarTriggerMovimientos_cls.handlerAfterInsert(trigger.new);
            system.debug('\n\n estos son mis campos after ====>>> ' + trigger.new);
        }
        if(Trigger.isUpdate)
        {
            AuxiliarTriggerMovimientos_cls.handlerAfterUpdate(trigger.new);
        }
        if(Trigger.isDelete)
        {
           AuxiliarTriggerMovimientos_cls.handlerAfterDelete(trigger.old);
        }
	}else if(Trigger.Isbefore) 
    {
        if (Trigger.isInsert || Trigger.isUpdate)
        {
            List<Movimientos__c> ActualizarVarperiodica = new List<Movimientos__c>();
            //JA 16-Ene-2017 Llamado al Metodo ActualizarVarperiodica el cual actualiza los valores de porcentaje de IVAteniendo en cuenta su fecha de creación
			ActualizarVarperiodica = AuxiliarTriggerMovimientos_cls.ActualizarVarperiodica(trigger.new); 
            for (Movimientos__c objMovimiento : Trigger.new)	
                {
                    //Recorro los datos de la respuesta del método ActualizarVarperiodica para actualizar los valores en el trigger
                    for(Movimientos__c Movactualizado : ActualizarVarperiodica)
                    {
                        objMovimiento =  Movactualizado;                    
                    }
                }
        }
    }

}