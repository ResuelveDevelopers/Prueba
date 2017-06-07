/*******************************************************************************
Desarrollado por:   Resuelve tu deuda
Autor:              Jeisson Hernandez
Proyecto:           Colombia
Descripción:        Clase utilitaria para realizar la actualizacion de campos de busquedas 
					de registros compartidos via Salesforce to Salesforce

Cambios (Versiones)
-------------------------------------
    No.     Fecha           Autor                       Descripción
    ---     ---             ----------                  --------------------------      
    1.0     28-May-2015     Jeisson Hernandez (JH)      Creación de Clase.
        
*******************************************************************************/
global class ExternalSharingHelper 
{
    
    @future 
    public static void actualizarCamposBusquedas(Map<Id,Id> cambiosIdMap,String campoActualizar)
    { 
  
 		Set<Id> partnerContactIdSet = new Set<Id>(); 
        for (Id partnerContactId : cambiosIdMap.values()) 
        { 
            partnerContactIdSet.add(partnerContactId); 
        } 
        System.debug('Colombia partnerContactIdSet: ' + partnerContactIdSet);
        Map<Id,Id> contactMap = new Map<Id,Id>(); 
        
        for (PartnerNetworkRecordConnection contactConnection: 
            [SELECT Id, Status, ConnectionId, PartnerRecordId, LocalRecordId 
             FROM PartnerNetworkRecordConnection 
             WHERE PartnerRecordId in:partnerContactIdSet]) { 
             System.debug('Colombia contactConnection: ' + contactConnection);   
            if ( contactConnection.Status == 'Sent' || contactConnection.Status == 'Received') 
            {                                                                
                contactMap.put(contactConnection.PartnerRecordId, contactConnection.LocalRecordId);
                System.debug('Colombia contactConnection KeySet: ' + contactMap.KeySet()); 
                System.debug('Colombia contactConnection KeySet: ' + contactMap.values());
            } 
        } 
  		if(campoActualizar == 'Director')
		{
	        List<RecursosHumanos__c> localContactList = new List<RecursosHumanos__c>(); 
	        for (Id contactId: cambiosIdMap.keySet())
	        { 
	            RecursosHumanos__c rhForUpdate = new RecursosHumanos__c(id=contactId); 
	            rhForUpdate.Director__c  =  contactMap.get(cambiosIdMap.get(contactId));
	            System.debug('Colombia rhForUpdate.Director__c ' + rhForUpdate.Director__c);
	            localContactList.add(rhForUpdate);                                                          
	        }                                                            
	        database.update(localContactList);
		}
		
		if(campoActualizar == 'SubDirector')
		{
	        List<RecursosHumanos__c> localContactList = new List<RecursosHumanos__c>(); 
	        for (Id contactId: cambiosIdMap.keySet())
	        { 
	            RecursosHumanos__c rhForUpdate = new RecursosHumanos__c(id=contactId); 
	            rhForUpdate.SubDirector__c  =  contactMap.get(cambiosIdMap.get(contactId));
	            System.debug('Colombia rhForUpdate.SubDirector__c ' + rhForUpdate.SubDirector__c);
	            localContactList.add(rhForUpdate);                                                          
	        }                                                            
	        database.update(localContactList);
		}

		if(campoActualizar == 'SubDirector Anterior')
		{
	        List<RecursosHumanos__c> localContactList = new List<RecursosHumanos__c>(); 
	        for (Id contactId: cambiosIdMap.keySet())
	        { 
	            RecursosHumanos__c rhForUpdate = new RecursosHumanos__c(id=contactId); 
	            rhForUpdate.SubdirectorAnterior__c  =  contactMap.get(cambiosIdMap.get(contactId));
	            System.debug('Colombia rhForUpdate.SubdirectorAnterior__c ' + rhForUpdate.SubdirectorAnterior__c);
	            localContactList.add(rhForUpdate);                                                          
	        }                                                            
	        database.update(localContactList);
		}


		if(campoActualizar == 'Gerente')
		{
	        List<RecursosHumanos__c> localContactList = new List<RecursosHumanos__c>(); 
	        for (Id contactId: cambiosIdMap.keySet())
	        { 
	            RecursosHumanos__c rhForUpdate = new RecursosHumanos__c(id=contactId); 
	            rhForUpdate.Gerente__c  =  contactMap.get(cambiosIdMap.get(contactId));
	            System.debug('Colombia rhForUpdate.Gerente__c ' + rhForUpdate.Gerente__c);
	            localContactList.add(rhForUpdate);                                                          
	        }                                                            
	        database.update(localContactList);
		}

		if(campoActualizar == 'Gerente Anterior')
		{
	        List<RecursosHumanos__c> localContactList = new List<RecursosHumanos__c>(); 
	        for (Id contactId: cambiosIdMap.keySet())
	        { 
	            RecursosHumanos__c rhForUpdate = new RecursosHumanos__c(id=contactId); 
	            rhForUpdate.GerenteAnterior__c  =  contactMap.get(cambiosIdMap.get(contactId));
	            System.debug('Colombia rhForUpdate.GerenteAnterior__c ' + rhForUpdate.GerenteAnterior__c);
	            localContactList.add(rhForUpdate);                                                          
	        }                                                            
	        database.update(localContactList);
		}


		if(campoActualizar == 'TeamLeader')
		{
	        List<RecursosHumanos__c> localContactList = new List<RecursosHumanos__c>(); 
	        for (Id contactId: cambiosIdMap.keySet())
	        { 
	            RecursosHumanos__c rhForUpdate = new RecursosHumanos__c(id=contactId); 
	            rhForUpdate.Team_Leader__c  =  contactMap.get(cambiosIdMap.get(contactId));
	            System.debug('Colombia rhForUpdate.Team_Leader__c ' + rhForUpdate.Team_Leader__c);
	            localContactList.add(rhForUpdate);                                                          
	        }                                                            
	        database.update(localContactList);
		}
		
		if(campoActualizar == 'TeamLeader Anterior')
		{
	        List<RecursosHumanos__c> localContactList = new List<RecursosHumanos__c>(); 
	        for (Id contactId: cambiosIdMap.keySet())
	        { 
	            RecursosHumanos__c rhForUpdate = new RecursosHumanos__c(id=contactId); 
	            rhForUpdate.TeamLeaderAnterior__c  =  contactMap.get(cambiosIdMap.get(contactId));
	            System.debug('Colombia rhForUpdate.TeamLeaderAnterior__c ' + rhForUpdate.TeamLeaderAnterior__c);
	            localContactList.add(rhForUpdate);                                                          
	        }                                                            
	        database.update(localContactList);
		}

		if(campoActualizar == 'Supervisor')
		{
	        List<RecursosHumanos__c> localContactList = new List<RecursosHumanos__c>(); 
	        for (Id contactId: cambiosIdMap.keySet())
	        { 
	            RecursosHumanos__c rhForUpdate = new RecursosHumanos__c(id=contactId); 
	            rhForUpdate.Supervisor__c  =  contactMap.get(cambiosIdMap.get(contactId));
	            System.debug('Colombia rhForUpdate.Supervisor__c ' + rhForUpdate.Supervisor__c);
	            localContactList.add(rhForUpdate);                                                          
	        }                                                            
	        database.update(localContactList);
		}

		if(campoActualizar == 'Jefe Directo')
		{
	        List<RecursosHumanos__c> localContactList = new List<RecursosHumanos__c>(); 
	        for (Id contactId: cambiosIdMap.keySet())
	        { 
	            RecursosHumanos__c rhForUpdate = new RecursosHumanos__c(id=contactId); 
	            rhForUpdate.JefeDirecto__c  =  contactMap.get(cambiosIdMap.get(contactId));
	            System.debug('Colombia rhForUpdate.JefeDirecto__c ' + rhForUpdate.JefeDirecto__c);
	            localContactList.add(rhForUpdate);                                                          
	        }                                                            
	        database.update(localContactList);
		}

		if(campoActualizar == 'Sucursal')
		{
	        List<RecursosHumanos__c> localContactList = new List<RecursosHumanos__c>(); 
	        for (Id contactId: cambiosIdMap.keySet())
	        { 
	            RecursosHumanos__c rhForUpdate = new RecursosHumanos__c(id=contactId); 
	            rhForUpdate.Sucursal__c  =  contactMap.get(cambiosIdMap.get(contactId));
	            System.debug('Colombia rhForUpdate.Sucursal__c ' + rhForUpdate.Sucursal__c);
	            localContactList.add(rhForUpdate);                                                          
	        }                                                            
	        database.update(localContactList);
		}

		if(campoActualizar == 'Empresa')
		{
	        List<RecursosHumanos__c> localContactList = new List<RecursosHumanos__c>(); 
	        for (Id contactId: cambiosIdMap.keySet())
	        { 
	            RecursosHumanos__c rhForUpdate = new RecursosHumanos__c(id=contactId); 
	            rhForUpdate.Empresa__c  =  contactMap.get(cambiosIdMap.get(contactId));
	            System.debug('Colombia rhForUpdate.Empresa__c ' + rhForUpdate.Empresa__c);
	            localContactList.add(rhForUpdate);                                                          
	        }                                                            
	        database.update(localContactList);
		}
    }
}