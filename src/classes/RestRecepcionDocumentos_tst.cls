@isTest
private class RestRecepcionDocumentos_tst 
{
	public static List<ContratoDigital__c> lstContrato; 
	public static List<DocumentoDigital__c> lstDocumento;

	public static void createData()
	{
		lstContrato = TestCreaObjetos.CreaContratoDigital(1);
		lstDocumento = TestCreaObjetos.CreaDocumentoDigital(2);
		
	}

	@isTest static void test_method_one() 
	{
		createData();
		Map<string, DocumentoDigital__c> m1 = new Map<string, DocumentoDigital__c>();
		m1.put(lstDocumento[0].id, lstDocumento[0]);
		m1.put(lstDocumento[1].id, lstDocumento[1]);

		Test.startTest();
			RestRequest req = new RestRequest();
			req.addParameter('NumAutentic','123');
			req.addParameter('FechaFirma','2016-09-22');
			req.addParameter('Estado','Firmado');
			req.addParameter('MsjRechaso','');
			req.addHeader('Content-Type', 'application/json');
			req.requestURI = 'services/apexrest/Contrato';
			req.httpMethod = 'PUT';
		    String JSONMsg = '{"message":"success"}';
		    req.requestBody = Blob.valueof(JSONMsg); // Add JSON Message as a POST
		    
		    RestResponse res = new RestResponse();
		    RestContext.request = req;
		    RestContext.response = res;
		    RestRecepcionDocumentos.ActualizarContrato(lstContrato[0].NumeroRadicacioAutentic__c, lstContrato[0].FechaFirmaRechazo__c,
		    'Firmado','',m1);
		Test.stopTest();

	}

	@isTest static void test_method_two() 
	{
		createData();
		Map<string, DocumentoDigital__c> m1 = new Map<string, DocumentoDigital__c>();
		m1.put(lstDocumento[0].id, lstDocumento[0]);
		m1.put(lstDocumento[1].id, lstDocumento[1]);

		Test.startTest();
			RestRequest req = new RestRequest();
			req.addParameter('NumAutentic','123');
			req.addParameter('FechaFirma','2016-09-22');
			req.addParameter('Estado','Firmado');
			req.addParameter('MsjRechaso','');
			req.addHeader('Content-Type', 'application/json');
			req.requestURI = 'services/apexrest/Contrato';
			req.httpMethod = 'PUT';
		    String JSONMsg = '{"message":"success"}';
		    req.requestBody = Blob.valueof(JSONMsg); // Add JSON Message as a POST
		    
		    RestResponse res = new RestResponse();
		    RestContext.request = req;
		    RestContext.response = res;
		    RestRecepcionDocumentos.ActualizarContrato('1', lstContrato[0].FechaFirmaRechazo__c,
		    'Firmado','',m1);
		Test.stopTest();

	}

	@isTest static void test_method_tree() 
	{
		createData();
		Map<string, DocumentoDigital__c> m1 = new Map<string, DocumentoDigital__c>();

		Test.startTest();
			RestRequest req = new RestRequest();
			req.addParameter('NumAutentic','123');
			req.addParameter('FechaFirma','2016-09-22');
			req.addParameter('Estado','Firmado');
			req.addParameter('MsjRechaso','');
			req.addHeader('Content-Type', 'application/json');
			req.requestURI = 'services/apexrest/Contrato';
			req.httpMethod = 'PUT';
		    String JSONMsg = '{"message":"success"}';
		    req.requestBody = Blob.valueof(JSONMsg); // Add JSON Message as a POST
		    
		    RestResponse res = new RestResponse();
		    RestContext.request = req;
		    RestContext.response = res;
		    RestRecepcionDocumentos.ActualizarContrato('123', lstContrato[0].FechaFirmaRechazo__c,
		    'Firmado','error en el documento',m1);
		Test.stopTest();

	}
	
}