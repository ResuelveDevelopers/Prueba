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


@RestResource(urlMapping='/CancelacionContrato/*')
global with sharing class RestCancelacionContrato 
{
	private static FirmaElectronica__c objFirmaElectronica = FirmaElectronica__c.getInstance();
	
	public static String cancelacionContrato(String strCaseNumber)
	{
		
		String str; 
		Http httpWS 			= new Http();
		HttpRequest request		= new HttpRequest();
		HttpResponse response	= new HttpResponse();
		
		request.setEndpoint(objFirmaElectronica.EndpointCancelacion__c); 
		request.setHeader('Content-Type', objFirmaElectronica.ContentType__c);
		request.setHeader('x-customer', objFirmaElectronica.Customer__c);
		request.setHeader('x-token', objFirmaElectronica.Token__c);	
		request.setHeader('x-api-key', objFirmaElectronica.Key__c);
		request.setMethod('POST');
		//String postData	= '{\"caseNumber\":\"' + strCaseNumber + '\"}';
		String postData	= strCaseNumber;
		System.debug('\n\n@@@postData-------> ' + postData + '\n\n');
		request.setTimeout(20000);
		request.setBody(postData);
		response = httpWS.send(request);
		
		System.debug('\n\n@@@response-------> ' + response + '\n\n');
		
		if(response.getStatus() == 'OK')
			return response.getBody();
		else
			return 'Error Servicio Web';
			
		return str;
	} 
}