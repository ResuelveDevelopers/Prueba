/*******************************************************************************
Desarrollado por:   RTD
Autor:              Jeisson Hernandez
Proyecto:           Colombia III
Descripción:        Clase Scheduler para programar Batch de Asignación de Oportunidades 

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		----------                ---------------------------     
    1.0     26-Oct-2015		Jeisson Hernandez(JH)     Creación de la Clase.
*******************************************************************************/
global class SchAsignacionOportunidades_sch implements Schedulable 
{
	global void execute(SchedulableContext SC)
	{
		String strQuery='';
		if (Test.isRunningTest() )		
			strQuery='SELECT Id, DeudaWeb__c, AsignacionSucursal__c FROM Lead WHERE Status = \'Lead\' AND VendedorAsignado__c = NULL Limit 1';
		else
			strQuery='SELECT Id, DeudaWeb__c, AsignacionSucursal__c FROM Lead WHERE Status = \'Lead\' AND VendedorAsignado__c = NULL';
		BchAsignacionOportunidades_bch objBchAsignacionOportunidades = new BchAsignacionOportunidades_bch(strQuery);
		Id batchProcessId = Database.executeBatch(objBchAsignacionOportunidades, 1);
	}
}