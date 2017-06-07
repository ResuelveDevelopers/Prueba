/*******************************************************************************
Desarrollado por:   RTD
Autor:              Jeisson Hernandez
Proyecto:           Colombia 
Descripción:        Clase Scheduler para consultar de Cantidad de Reparadoras x Agente de SC y
					Consulta de Cantidad de Deudas Activas(NO liquidadas, NO Liquidada Fuera del Programa) x Negociador
					utilizados en el proceso de cierre automático de clientes  

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		----------              ---------------------------     
    1.0		25-Abr-2016		Jeisson Hernandez(JH)	Consulta de Cantidad de Reparadoras x Agente de SC para poblar campo Total_Clientes__c de RH
													Consulta de Cantidad de Deudas Activas(NO liquidadas, NO Liquidada Fuera del Programa) 
													por Negociador para poblar campo Total de Deudas Activas de RH
*******************************************************************************/
global class SchCamposSCNegociacionCierre_sch implements Schedulable 
{
	global void execute(SchedulableContext SC)
	{
		Map<String, RecursosHumanos__c> mapAgentesUpd = new Map<String, RecursosHumanos__c>();
		Map<String, RecursosHumanos__c> mapNegociadoresUpd = new Map<String, RecursosHumanos__c>();
		Set<String> setPuestosNegociacion = new Set<String>();
		Set<String> setPuestosServicioCliente = new Set<String>();
		
		for(CierreClientesPuestosPerfiles__c objPuestosCierreClientes: CierreClientesPuestosPerfiles__c.getAll().values())
		{
			if(objPuestosCierreClientes.Area__c=='Negociacion')
				setPuestosNegociacion.add(objPuestosCierreClientes.Puesto__c);
			if(objPuestosCierreClientes.Area__c=='Servicio al Cliente')
				setPuestosServicioCliente.add(objPuestosCierreClientes.Puesto__c);
		}

		//JH 25-Abrl-2016: Consulta de Cantidad de Reparadoras x Agente de SC para poblar campo Total_Clientes__c de RH	
		for(AggregateResult objAgenteSC : [ SELECT EjecutivoAtencionClientes__c,Count(id) TotalClientes 
											FROM Reparadora__c
											Where EjecutivoAtencionClientes__c !=null 
											AND (FechaInicioPrograma__c= THIS_MONTH OR FechaInicioPrograma__c= LAST_MONTH)
											Group by EjecutivoAtencionClientes__c])
		{
				if ( String.valueOf(objAgenteSC.get('TotalClientes')) != null)
				{
					Decimal dTotalClientes = (Decimal)(objAgenteSC.get('TotalClientes'));
					String sIdRH = String.valueOf(objAgenteSC.get('EjecutivoAtencionClientes__c')); 
					if (mapAgentesUpd.containsKey( sIdRH ))
					    mapAgentesUpd.get( sIdRH ).Total_Clientes__c = dTotalClientes;
					if (!mapAgentesUpd.containsKey( sIdRH ))
					    mapAgentesUpd.put( sIdRH , new RecursosHumanos__c(id = sIdRH, Total_Clientes__c = dTotalClientes));
				}//Fin si
		}//Fin del for para obtener los total clientes x agente de SC		
		
		
		//JH 25-Abrl-2016: Consulta Todos los Agentes de SC y les pone valor cero(0) en el campo 
		//					Total_Clientes__c a los agentes de SC que no tengan reparadoras 
		for(RecursosHumanos__c objRHPaso : 
			[Select Id,Name,Usuario__r.LastName, Usuario__c, EjecutivoPremium__c,Sucursal__c, 
					Total_Clientes__c  
					From RecursosHumanos__c 
					Where IdPuestoMexico__c IN:setPuestosServicioCliente
					And Area__c = 'Servicio al Cliente'
					And Status__c = 'Activo' 
					And Usuario__r.isActive = true    
					And NoAsignarClientes__c=false 
					And (NOT Name  like '%Virtual%') 
					And UnidadNegocio__c ='RTD Colombia' 
					Order by Sucursal__c ASC]
			)
		{
			if(!mapAgentesUpd.containsKey(objRHPaso.Id))
			{
				mapAgentesUpd.put(objRHPaso.Id, new RecursosHumanos__c(id = objRHPaso.Id, Total_Clientes__c = 0));
			}
		}
		
		//JH 25-Abrl-2016: Consulta de Cantidad de Deudas Activas(NO liquidadas, NO Liquidada Fuera del Programa) 
		//				   por Negociador para poblar campo Total de Deudas Activas de RH	
		for(AggregateResult objNegociador : [ SELECT NegociadorAsignado__c,Count(id) TotalDeudasActivas
											FROM Deudas__c 
											Where EstadodelaDeuda__c NOT IN('Liquidada','Liquidada Fuera del Programa') 
											AND NegociadorAsignado__c !=null
											AND FechadeInicio__c != null 
											AND StatusCliente__c = 'Activo' 
											Group by NegociadorAsignado__c])
		{
				if ( String.valueOf(objNegociador.get('TotalDeudasActivas')) != null)
				{
					Decimal dTotalDeudasActivas = (Decimal)(objNegociador.get('TotalDeudasActivas'));
					String sIdRH = String.valueOf(objNegociador.get('NegociadorAsignado__c')); 
					if (mapNegociadoresUpd.containsKey( sIdRH ))
					    mapNegociadoresUpd.get( sIdRH ).TotalDeudasActivas__c = dTotalDeudasActivas;
					if (!mapNegociadoresUpd.containsKey( sIdRH ))
					    mapNegociadoresUpd.put( sIdRH , new RecursosHumanos__c(id = sIdRH, TotalDeudasActivas__c = dTotalDeudasActivas));
				}//Fin si
		}//Fin del for para obtener los total activas  x negociador		
		
		//JH 25-Abrl-2016: Consulta Todos los Negociadores y les pone valor cero(0) en el campo 
		//					TotalDeudasActivas__c a los negociadores que no tengan duedas activas 
		for(RecursosHumanos__c objRHPaso : 
			[Select id,Name,Sucursal__c,Usuario__c, TotalDeudasActivas__c
			 From RecursosHumanos__c
			 Where IdPuestoMexico__c IN:setPuestosNegociacion
			 And Usuario__r.isActive = true 
			 And Status__c = 'Activo'
			 And (NOT Name  like '%Virtual%') 
			 And UnidadNegocio__c='RTD Colombia' 
			 And NoAsignarClientes__c=false
			 Order by Sucursal__c]
			)
		{
			if(!mapNegociadoresUpd.containsKey(objRHPaso.Id))
			{
				mapNegociadoresUpd.put(objRHPaso.Id, new RecursosHumanos__c(id = objRHPaso.Id, TotalDeudasActivas__c = 0));
			}
		}
		
		//JH 25-Abrl-2016: Actualiza los Agentes de SC con el campo Total_Clientes__c poblado
		if (!mapAgentesUpd.isEmpty())
		{
			System.debug('@@Actualiza Agentes SC  mapAgentesUpd.values(): ' + mapAgentesUpd.values());
			RD_TriggerExecutionControl_cls.setAlreadyDone('TriggerRecursosHumanos');
				update mapAgentesUpd.values();
		}//Fin si tiene algo mapAgentesUpd   
		
		
		//JH 25-Abrl-2016: Actualiza los Negociadores con el campo TotalDeudasActivas__c poblado
		if (!mapNegociadoresUpd.isEmpty())
		{
			System.debug('@@Actualiza Negociadores  mapNegociadoresUpd.values(): ' + mapNegociadoresUpd.values());
			RD_TriggerExecutionControl_cls.setAlreadyDone('TriggerRecursosHumanos');
				update mapNegociadoresUpd.values();
		}//Fin si tiene algo mapNegociadoresUpd   
	}
}