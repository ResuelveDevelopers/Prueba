/********************************************************************************************************
Desarrollado por:	RTD   
Autor:              Marwin Pineda(MP)
Proyecto:           Resuelve tu Deuda
Descripción:        Clase de consumo de Servicio Web de Cancelación de Contratos.

Cambios (Versiones)
--------------------------------------------------------------------------------------------------------
    No.     Fecha               Autor                       Descripción
    ---     -----------         ------------------------    --------------------------      
    1.0     11-Oct-2016         Marwin Pineda(MP)          	Creación clase Servicio REST 
***************************************************************************************/
public with sharing class CancelacionContrato_ctr 
{
	
	Lead objLead 					= new Lead();
	String strIdContrato			= '';
	String strNumeroRadicado		= '';
	Boolean blnValidaStatusCode 	= false;
	EstructuraJSON objEstructura	= new EstructuraJSON();  	
	
    public CancelacionContrato_ctr(ApexPages.StandardController stdController)
    {
    	String strRTRevisionContratoId	= Schema.SObjectType.Lead.getRecordTypeInfosByName().get('En revisión de Contrato').getRecordTypeId();
    	String strIdLead				= ApexPages.currentPage().getParameters().get('id');
    	
    	objLead = [SELECT Id,
						PrimerNombre__c, 
						SegundoNombre__c,
						PrimerApellido__c,
						SegundoApellido__c,
						TipoDocAfiliado__c,
						Cedula__c,
						RecordTypeId,
						RecordType.Name,
						(SELECT Id,Estado__c,NumeroRadicacioAutentic__c FROM Contratos_Digitales_del__r)
					FROM
						Lead
					WHERE Id = :strIdLead];
					
		//System.debug('\n\n@@@objLead--------> ' + objLead + '\n\n');
		
		Integer intNoEnviado = 0;
					
		if(objLead.RecordTypeId != strRTRevisionContratoId)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'El tipo de registro de la oportunidad deber ser En revisión de Contrato'));
		}
		else
		{
			for(ContratoDigital__c objContrato :objLead.Contratos_Digitales_del__r)
			{
				if(objContrato.Estado__c == 'Enviado')
				{
					objEstructura.caseNumber	= objContrato.NumeroRadicacioAutentic__c;
					String strJSON				= JSON.serialize(objEstructura);
					System.debug('@@@strJSON-------> ' + strJSON + '\n\n');
					strIdContrato 				= objContrato.Id;
					strNumeroRadicado			= objContrato.NumeroRadicacioAutentic__c;
					System.debug('\n\n@@@strNumeroRadicado--------> ' + strNumeroRadicado + '\n\n');
					String strRespuestaWS 		= RestCancelacionContrato.cancelacionContrato(strJSON);
					if(strRespuestaWS == 'Error Servicio Web')
					{
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error Message'));
					}
					else
					{
						RespuestaJSON objRespuesta = (RespuestaJSON)JSON.deserialize(strRespuestaWS, RespuestaJSON.class);
						System.debug('\n\n@@@objRespuesta ' + objRespuesta + '\n\n');
						
						if(String.isNotEmpty(objRespuesta.operationCode) && objRespuesta.operationCode == '100')
						{
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Completado (radicado cancelado)'));
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, objRespuesta.operationCode));
							blnValidaStatusCode = true;
						}
						if(String.isNotEmpty(objRespuesta.operationCode) && objRespuesta.operationCode == '101')
						{
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No completado (radicado no encontrado) Contrato no cancelado/Contrato no encontrado'));
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, objRespuesta.operationCode));
							blnValidaStatusCode = false;
						}
						if(String.isNotEmpty(objRespuesta.operationCode) && objRespuesta.operationCode == '102')
						{
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contrato firmado no se puede cancelar'));
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, objRespuesta.operationCode));
							blnValidaStatusCode = false;
						}
						if(String.isNotEmpty(objRespuesta.operationCode) && objRespuesta.operationCode == '103')
						{
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'JSON inválido'));
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, objRespuesta.operationCode));
							blnValidaStatusCode = false;
						}
						//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, strRespuestaWS));
					}
					intNoEnviado += 1;
				}
				/*else
				{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No posee contratos con estado enviado'));
				}*/
				
			}
			
			System.debug('\n\n@@@intNoEnviado----------> ' + intNoEnviado + '\n\n');
			
			if(intNoEnviado == 0)
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No posee contratos con estado enviado'));
			
			//System.debug('\n\n@@@ContratoDigital----------> ' + objLead.Contratos_Digitales_del__r.size() + '\n\n');
		}
    }
    
    public void actualizarContrato()
    {
    	if(blnValidaStatusCode)
    	{
    		objLead.ContratoDigitalEnviado__c	= false;
			objLead.URLAutentic__c				= null;
			objLead.Id							= ApexPages.currentPage().getParameters().get('id');
			update objLead;
			
			ContratoDigital__c objContrato  		= new ContratoDigital__c();
			objContrato.Id							= strIdContrato;
			objContrato.Estado__c					= 'Cancelado por Asesor';
			objContrato.FechaCancelacion__c			= System.now();
			update objContrato;
    	}
    }
    
    public class EstructuraJSON
    {
		public String caseNumber;
    }
    
    public class RespuestaJSON
    {
    	public String operationCode = '';	//statusCode
    } 
}