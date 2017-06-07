/*******************************************************************************
Desarrollado por:   RTD
Autor:              Jeisson Hernandez
Proyecto:           Colombia III 
Descripción:        Clase Scheduler para programar Batch BchRHCamposACero_bch el cual pone en cero (0) mensualmente 
					algunos campos de Recursos Humanos utilizados en los procesos de asignación de oportunidades 
					y cierre automático de clientes  

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		----------                ---------------------------     
    1.0     22-Oct-2015		Jeisson Hernandez(JH)     Creación de la Clase.
    1.1		27-Abr-2016		Jeisson Hernandez(JH)     Se modifica la consulta para solo actualizar Rh de Ventas
*******************************************************************************/
global class SchRHCamposACero_sch implements Schedulable 
{
	global void execute(SchedulableContext SC)
	{
		String strQuery='';
		strQuery='SELECT Id, OportunidadesTotalesArd__c '+ 
				  'FROM RecursosHumanos__c '+ 
				  'WHERE Status__c = \'Activo\' AND Area__c = \'Ventas\' ORDER BY Sucursal__c';
		BchRHCamposACero_bch objBchRHCamposACero = new BchRHCamposACero_bch(strQuery);
		Id batchProcessId = Database.executeBatch(objBchRHCamposACero, 25);
	}
}