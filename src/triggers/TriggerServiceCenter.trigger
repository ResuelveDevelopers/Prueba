/*******************************************************************************
Desarrollado por:   Resuelve tu deuda
Autor:              Jeisson Hernandez
Proyecto:           Colombia
Descripción:        Trigger del objeto Service Center 

Cambios (Versiones)
-------------------------------------
    No.     Fecha           Autor                       Descripción
    ---     ---             ----------                  --------------------------      
    1.0     16-Sep-2015     Jeisson Hernandez (JH)      Creación de Trigger.
        
*******************************************************************************/

trigger TriggerServiceCenter on ServiceCenter__c (before insert) 
{
	List<lead> lstLeadUpd= new List<lead>();
	Id ContratoRecordTypeId = Schema.SObjectType.ServiceCenter__c.getRecordTypeInfosByName().get('Contrato').getRecordTypeId();
	Id EnRevisiondeContratoRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('En revisión de Contrato').getRecordTypeId();
	
	if(trigger.isBefore && trigger.isInsert)
	{
		for(ServiceCenter__c objServiceCenter : Trigger.new)
		{
			//Actualizacion campo EnRevision__c en el candidato si tipo de registro es "Contrato"  
			system.debug('@@Service Center.RecordTypeId: ' +objServiceCenter.RecordTypeId +' objServiceCenter.Oportunidad__c: '+objServiceCenter.Oportunidad__c);
			system.debug('@@Validacion ' + (objServiceCenter.RecordTypeId == ContratoRecordTypeId));
			if(objServiceCenter.Oportunidad__c!=null && objServiceCenter.RecordTypeId== ContratoRecordTypeId)
			{
				Lead objLead= new Lead(Id =objServiceCenter.Oportunidad__c, EnRevisionOperaciones__c =true, RecordTypeId = EnRevisiondeContratoRecordTypeId);
				lstLeadUpd.add(objLead);
			}
			if(lstLeadUpd.size()>0)
			{
				try
				{
					System.debug('@lstLeadUpd ' + lstLeadUpd);
					RD_TriggerExecutionControl_cls.setAlreadyDone('TriggerLead');
					update lstLeadUpd;
				}
				catch(Exception ex)
				{
					System.debug('@@Error en actualizar Lead desde TriggerServiceCenter: ' + ex.getMessage() );
				}
			}
		}
	}
}