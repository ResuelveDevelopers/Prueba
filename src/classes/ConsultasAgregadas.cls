public class ConsultasAgregadas 
{
	public Map<String, RecursosHumanos__c> consultaRHOportunidadesTotalesArd (Set<String>  setIdVenAsig, Map<String, RecursosHumanos__c> mapRHUpd)
	{
		if(!setIdVenAsig.IsEmpty())
		{
			for(AggregateResult objLead : [Select VendedorAsignado__c, Count(id) TotLeadArd 
				From Lead Where FechaHoraCreacionOportunidad__c = THIS_MONTH 
				And VendedorAsignado__c IN :setIdVenAsig 
				group By VendedorAsignado__c])
				{
				if(String.valueOf(objLead.get('VendedorAsignado__c')) != null)
				{
					Decimal dTotLeadArd = (Decimal)(objLead.get('TotLeadArd'));
					String sIdRH = String.valueOf(objLead.get('VendedorAsignado__c')); 
					if (mapRHUpd.containsKey( sIdRH ))
						mapRHUpd.get( sIdRH ).OportunidadesTotalesArd__c = dTotLeadArd;
					if (!mapRHUpd.containsKey( sIdRH ))
						mapRHUpd.put( sIdRH , new RecursosHumanos__c(id = sIdRH, OportunidadesTotalesArd__c = dTotLeadArd));
				}
			}//Fin del for para obtener los totales del campo OportunidadesTotalesArd__c
		}//Fin Si !setIdVenAsig.IsEmpty()
		return mapRHUpd;
	}

	public Map<String, RecursosHumanos__c> consultaRHOppMensualesNextMonth (Set<String>  setIdVenAsig, Map<String, RecursosHumanos__c> mapRHUpd)
	{
		//Consulta la cantidad de leads  asignados para el proximo mes de los vendedores asignados en el campo OppMensuales_NextMonth__c
		if(!setIdVenAsig.IsEmpty())
		{
			for(AggregateResult objLead : [  Select VendedorAsignado__c, Count(id) TotLeadNextMonth 
											From Lead Where FechaHoraCreacionOportunidad__c = NEXT_MONTH 
											And VendedorAsignado__c IN :setIdVenAsig 
											group By VendedorAsignado__c])
			{
				if ( String.valueOf(objLead.get('VendedorAsignado__c')) != null)
				{
					Decimal dTotLeadNextMonth = (Decimal)(objLead.get('TotLeadNextMonth'));
					String sIdRH = String.valueOf(objLead.get('VendedorAsignado__c')); 
					if (mapRHUpd.containsKey( sIdRH ))
					    mapRHUpd.get( sIdRH ).OppMensuales_NextMonth__c = dTotLeadNextMonth;
					if (!mapRHUpd.containsKey( sIdRH ))
					    mapRHUpd.put( sIdRH , new RecursosHumanos__c(id = sIdRH, OppMensuales_NextMonth__c = dTotLeadNextMonth));
				}//Fin si
			}//Fin del for para obtener los totales
		}//Fin Si !setIdVenAsig.IsEmpty()
		return mapRHUpd;
	}

	
}