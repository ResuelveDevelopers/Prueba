/*******************************************************************************
Desarrollado por:   RTD
Autor:              Jeisson Hernandez
Proyecto:           Colombia III 
Descripción:        Batch que pone en cero (0) mensualmente algunos campos de Recursos Humanos 
					utilizados en los procesos de asignación de oportunidades y cierre automático de clientes  

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		---------------------	-----------------------------
    1.0     22-Oct-2015		Jeisson Hernandez(JH)	Creación de la Clase.
	1.2		04-Feb-2016		Jeisson Hernandez(JH)	Edwin Garduño(Negociacion y SC) solicita que leads con fecha de deposito con mes anterior
													se sumen a los leads de mes actual debido a que Allianz confirma saldos días despues 
													de la fecha de deposito y esto afecta la asignación de cliente a los ejecutivos de SC en los dias de cierre
													por lo cual el campo  TotalClientesMesActual__c no se reiniciara al inicio de mes    
	1.3		27-Abr-2016		Jeisson Hernandez(JH)	Se actualizara campo que sera solo para RH de Ventas    

*******************************************************************************/
global class BchRHCamposACero_bch implements Database.Batchable<sObject>
{
	global final String Query;
	
	global BchRHCamposACero_bch(String q)
	{
		query=q;		
	}

	global Database.QueryLocator start(Database.BatchableContext BC)		
	{
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
		Map<String, RecursosHumanos__c> mRecHumUpd = new Map<String, RecursosHumanos__c>();   		
		//Muy bien recorre la lista de RH y metelos a un mapa
		for (sObject obj : scope)
		{
			RecursosHumanos__c objRH = (RecursosHumanos__c)obj;
			objRH.OportunidadesTotalesArd__c = 0;
			//Agrealo al mapa de mRecHumUpd
			mRecHumUpd.put(objRH.id, objRH);
		}//Fin del for para la lista de usr 	
		//Ya tienes la lista de los que se van a actualizar, lanza el update
		if (!mRecHumUpd.isEmpty())
		{
			if (!Test.isRunningTest())
			{
				RD_TriggerExecutionControl_cls.setAlreadyDone('TriggerRecursosHumanos');
				update mRecHumUpd.values();
			}		
		}
		
	}
	global void finish(Database.BatchableContext BC)
	{
		System.debug('::::Termino Cierre de clientes::::');
	}
}