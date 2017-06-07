/********************************************************************************************************
Desarrollado por:	RTD   
Autor:              Marwin Pineda(MP)
Proyecto:           Resuelve tu Deuda
Descripción:        Clase de consumo de Servicio Web de Envío de Documentos.

Cambios (Versiones)
--------------------------------------------------------------------------------------------------------
    No.     Fecha               Autor                       Descripción
    ---     -----------         ------------------------    --------------------------      
    1.0     21-Sep-2016         Marwin Pineda(MP)          	Creación clase Servicio REST 
***************************************************************************************/


@RestResource(urlMapping='/EnvioDocumentos/*')
global with sharing class RestEnvioDocumentos 
{
	private static FirmaElectronica__c objFirmaElectronica = FirmaElectronica__c.getInstance();
	
	public static String envioDocumentos(String strJSON)
	{
		
		String str; 
		Http httpWS 			= new Http();
		HttpRequest request		= new HttpRequest();
		HttpResponse response	= new HttpResponse();
		
		/*try
		{*/
			request.setEndpoint(objFirmaElectronica.Endpoint__c); 
			request.setHeader('Content-Type', objFirmaElectronica.ContentType__c);
			request.setHeader('x-customer', objFirmaElectronica.Customer__c);
			request.setHeader('x-token', objFirmaElectronica.Token__c);	
			request.setHeader('x-api-key', objFirmaElectronica.Key__c);
			request.setMethod('POST');
			request.setTimeout(20000);
			request.setBody(strJSON);
			response = httpWS.send(request);
		/*}
		catch(Exception e)
		{
			System.debug( '\n\n\t<<<<<<<<< Exception >>>>>>>>> \n\t\t@@--> getCause > ' + e.getCause() + '\n\t\t@@--> getLineNumber > ' + e.getLineNumber() + '\n\t\t@@--> getMessage > '+ e.getMessage() + '\n\t\t@@--> getStackTraceString > '+ e.getStackTraceString() + '\n\t\t@@--> getTypeName > ' + e.getTypeName() + '\n\n' );
		}*/
		
		if(response.getStatus() == 'OK')
			return response.getBody();
		else
			return 'Error Servicio Web';
			
		return str;
	} 
}