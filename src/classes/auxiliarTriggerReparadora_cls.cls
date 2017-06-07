/*****************************************************************************************************
* Desarrollado por: RTD
* Autor:            Esteban Heredia (EH)
* Proyecto:         Colombia IV
* Descripción:      Lógica de negocio para el trigger de Reparadoras             
*
* Cambios (Versiones)
* -------------------------------------
*           No.     fecha          	Autor 		               	Descripción
*           -----   ----------      ------------------------   	---------------
* @version  1.0     18-Abr-2016     Esteban Heredia (EH)        Creación de la clase
* @version	1.1		22-Ago-2016		Marwin Pineda (MP)			Actualización de la sección Información Recomendado cuando la oportunidad tiene un referenciador.           
*******************************************************************************************************/

public with sharing class auxiliarTriggerReparadora_cls 
{
	public static void handlerAfterInsert(List<Reparadora__c> lstNewRecords) 
	{
		crearTareaLllamadaBien(lstNewRecords);
	}

	// Después de crar la reparadora, automaticámente se creara una tarea de llamada de bienvenida
	public static void crearTareaLllamadaBien(List<Reparadora__c> lstNewRecords) 
	{
		List<Task> lstTareasBienvenida = new List<Task>();
		Set<Id> setIdEjecutivoClientes = new Set<Id>();
		// Tipo de registro tareas de post venta 1
		Id recordTypeBienvenida = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Actividad de Bienvenida').getRecordTypeId();
		// Nos creamos un set con los Ids papás(Recursos humanos), en este caso ejecutivos de atención al cliente
		for(Reparadora__c objReparadoraTemp: lstNewRecords) 
		{
			setIdEjecutivoClientes.add(objReparadoraTemp.EjecutivoAtencionClientes__c);
		}
		// CReamos un mapa de los ejecutivos de atención al cliente relacinados con las reparadoras nuevas
		Map<Id,RecursosHumanos__c> mapRecursosHumPorId = new Map<Id,RecursosHumanos__c>([SELECT Id,Usuario__c FROM RecursosHumanos__c WHERE Id IN: setIdEjecutivoClientes]);
		// se crea la tarea de llamada de bienvenida para cada reparadora nueva
		for(Reparadora__c objReparadoraTemp: lstNewRecords) 
		{
			Task objTask 				= new Task();
			objTask.Status 				= 'En Proceso';
			objTask.Whatid 				= objReparadoraTemp.id;
			objTask.Subject 			= 'Llamada de Bienvenida';
			objTask.ActivityDate		= system.today();
			objTask.RecordTypeId 		= recordTypeBienvenida;
			if(!Test.isRunningTest())
				objTask.OwnerId 			= mapRecursosHumPorId.get(objReparadoraTemp.EjecutivoAtencionClientes__c).Usuario__c;
			else
				objTask.OwnerId 			= UserInfo.getUserId(); 
			
			lstTareasBienvenida.add(objTask);
		}
		insert lstTareasBienvenida;
	}
	
	//MP - 22/08/2016 - Método para asignar información de bonificación al Referenciador.
	public static void asignarReferenciado(List<Reparadora__c> lstNuevasReparadoras)
	{
		List<String> lstIdClientes = new List<String>();  
        
        for(Reparadora__c objReparadora :lstNuevasReparadoras)
        {
        	lstIdClientes.add(objReparadora.cliente__c);
        }
		
        if(lstIdClientes.size() > 0)
        {
	       	List<Account> lstCuentas = [SELECT Id,Oportunidad__c,Oportunidad__r.Recomendado__c,Oportunidad__r.ClienteRecomendado__c
	                                	FROM Account
	                                    WHERE Id IN :lstIdClientes];
	                                    
	        Map<String,Integer> mapa = new Map<String,Integer>();
	                                    
	        for(Account objCuenta :lstCuentas)
	        {
	        	if(mapa.containsKey(objCuenta.Oportunidad__r.ClienteRecomendado__c))
	            {
	            	Integer intCantidadRef = mapa.get(objCuenta.Oportunidad__r.ClienteRecomendado__c) + 1;
	                mapa.put(objCuenta.Oportunidad__r.ClienteRecomendado__c,intCantidadRef);
	           	}
	            else
	            {
	            	mapa.put(objCuenta.Oportunidad__r.ClienteRecomendado__c,1);
	           	}
	      	}
	      	
	        List<Reparadora__c> lstReparadoras = [SELECT Id,ClientesReferenciados__c
	                                          		FROM Reparadora__c
	                                                WHERE Id IN :mapa.keySet()];
	            
	        for(Reparadora__c objReparadoraAct :lstReparadoras)
	        {
	            if(objReparadoraAct.ClientesReferenciados__c == null)
	            {
	            	objReparadoraAct.ClientesReferenciados__c = 0 + mapa.get(objReparadoraAct.Id);
	            	objReparadoraAct.ClientesReferenciados__c = mapa.get(objReparadoraAct.Id);
	            }
	            else
	            {
	            	objReparadoraAct.ClientesReferenciados__c += mapa.get(objReparadoraAct.Id);
	            }
	 		}
	            
	        if(lstReparadoras.size() > 0)
				update lstReparadoras;
        }
	}
	//MP - 22/08/2016 - ENDING
}