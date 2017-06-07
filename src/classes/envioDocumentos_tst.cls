/********************************************************************************************************
Desarrollado por:	RTD   
Autor:              Marwin Pineda(MP)
Proyecto:           Resuelve tu Deuda
Descripción:        Clase de prueba Controlador y Respuesta de Servicio Web de Envío de Documentos.

Cambios (Versiones)
--------------------------------------------------------------------------------------------------------
    No.     Fecha               Autor                       Descripción
    ---     -----------         ------------------------    --------------------------      
    1.0     22-Oct-2016         Marwin Pineda(MP)          	Creación clase de prueba Controlador botón Envío de
    														Contrato a Cliente 
***************************************************************************************/
@isTest
global class envioDocumentos_tst 
{
    public static List<Lead> lstCandidatos;
    
    public static ServiceCenter__c objServiceCenter;
    public static ContratoDigital__c objContrato;
    public static DocumentoDigital__c objDocContrato;
    
    public static Schema.DescribeSObjectResult objSchema;
    public static Map<String,Schema.RecordTypeInfo> mapRecordTypeLead;
    public static Schema.DescribeSObjectResult objSchemaSC;
	public static Map<String,Schema.RecordTypeInfo> mapRecordTypeSC;
    
    public static String recordTypeIdSC;
    public static String recordTypeId;
    
    global static void createData()
    {
    	CredencialesAmazonGeneral__c objCPCredenciales 	= new CredencialesAmazonGeneral__c(Name = 'authenticsf');
		insert objCPCredenciales;
		
		FirmaElectronica__c objCPFirmaElecrtonica	= new FirmaElectronica__c();
		objCPFirmaElecrtonica.Endpoint__c			= 'https://endpointEnvioDocs.com';
		objCPFirmaElecrtonica.Customer__c			= 'Resuelve';
		objCPFirmaElecrtonica.Key__c				= 'fg4dfg54df5g45dfg45df78dfg';
		objCPFirmaElecrtonica.Token__c				= 'Qucxdle15641fd5fsd';
		objCPFirmaElecrtonica.ContentType__c		= 'application/json;charset=UTF-8';
		insert objCPFirmaElecrtonica;
		
		objSchema 			= Schema.SObjectType.Lead;
        mapRecordTypeLead	= objSchema.getRecordTypeInfosByName();
        recordTypeId		= mapRecordTypeLead.get('En revisión de Contrato').getRecordTypeId();
        
		objSchemaSC		= Schema.SObjectType.ServiceCenter__c;
        mapRecordTypeSC	= objSchemaSC.getRecordTypeInfosByName();
        recordTypeIdSC	= mapRecordTypeSC.get('Contrato').getRecordTypeId();
        
        List<RecursosHumanos__c> lstRH = TestCreaObjetos.CrearRHs(1,'Asesor de Reparación de Deuda','Ventas');
        update lstRH;

        lstCandidatos        			= TestCreaObjetos.CrearLeads(1);
        lstCandidatos[0].RecordTypeId	= recordTypeId;
        update lstCandidatos;
        
        objServiceCenter 				= new ServiceCenter__c();
        objServiceCenter.Status__c		= 'Cerrado / Realizado';
        objServiceCenter.FechaCierre__c	= Date.today().addDays(-30);
        objServiceCenter.Oportunidad__c	= lstCandidatos[0].Id;
        objServiceCenter.RecordTypeId	= recordTypeIdSC;
        insert objServiceCenter;
        
        objContrato 				= new ContratoDigital__c();
        objContrato.Estado__c		= 'Generación de Contrato';
        objContrato.CandidatoId__c	= lstCandidatos[0].Id;
        insert objContrato;
        
        //Documentos

        objDocContrato 								= new DocumentoDigital__c();
        objDocContrato.ContratoDigitalId__c			= objContrato.Id;
        objDocContrato.TipoDocumento__c				= 'Contrato RTD';
        objDocContrato.URLDocumentoEnviadoAmazon__c	= 'https://authenticsf.s3.amazonaws.com/Contrato_RTD_3000006_24_10_2016_10_50.pdf';
        insert objDocContrato;

        DocumentoDigital__c objDocAllianz   		= new DocumentoDigital__c();
        objDocAllianz.ContratoDigitalId__c  		= objContrato.Id;
        objDocAllianz.TipoDocumento__c      		= 'Contrato Allianz';
        objDocAllianz.URLDocumentoEnviadoAmazon__c	= 'https://authenticsf.s3.amazonaws.com/Contrato_Allianz_3000006_24_10_2016_10_50.pdf';
        insert objDocAllianz;

        DocumentoDigital__c objDocReciboPago    		= new DocumentoDigital__c();
        objDocReciboPago.ContratoDigitalId__c   		= objContrato.Id;
        objDocReciboPago.TipoDocumento__c       		= 'Recibo de Pago';
        objDocReciboPago.URLDocumentoEnviadoAmazon__c	= 'https://authenticsf.s3.amazonaws.com/RP_3000006_24_10_2016_10_50.pdf';
        insert objDocReciboPago;

        DocumentoDigital__c objDocCartaPoder1   		= new DocumentoDigital__c();
        objDocCartaPoder1.ContratoDigitalId__c  		= objContrato.Id;
        objDocCartaPoder1.TipoDocumento__c      		= 'Carta Poder';
        objDocCartaPoder1.URLDocumentoEnviadoAmazon__c	= 'https://authenticsf.s3.amazonaws.com/CP_3000006_005236902_24_10_2016_10_50.pdf';
        insert objDocCartaPoder1;
    }
    
    static testMethod void myUnitTest() 
    {
    	
        createData();

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		
        Test.startTest();
    	    ApexPages.currentPage().getParameters().put('id',lstCandidatos[0].Id);
    	    ApexPages.StandardController stdControllerLead	= new ApexPages.StandardController(lstCandidatos[0]);
        	envioDocumentos_ctr objController 				= new envioDocumentos_ctr(stdControllerLead); 
            objController.actualizarContrato();
        Test.stopTest();
    }
    
    static testMethod void myUnitTest1()
    {
    	createData();

    	String strRTOportunidad 		= mapRecordTypeLead.get('Oportunidad').getRecordTypeId();
    	lstCandidatos[0].RecordTypeId	= strRTOportunidad;
    	update lstCandidatos;

    	Test.startTest();
    	    ApexPages.currentPage().getParameters().put('id',lstCandidatos[0].Id);
    	    ApexPages.StandardController stdControllerLead	= new ApexPages.StandardController(lstCandidatos[0]);
        	envioDocumentos_ctr objController 				= new envioDocumentos_ctr(stdControllerLead); 
        Test.stopTest();
    }
    
    static testMethod void myUnitTest2()
    {
    	createData();
    	
    	lstCandidatos[0].RecordTypeId = recordTypeId;
    	update lstCandidatos;

		objServiceCenter.Oportunidad__c	= null;//lstCandidatos[0].Id;
        update objServiceCenter;   	
    	
    	Test.startTest();
    	    ApexPages.currentPage().getParameters().put('id',lstCandidatos[0].Id);
    	    ApexPages.StandardController stdControllerLead	= new ApexPages.StandardController(lstCandidatos[0]);
        	envioDocumentos_ctr objController 				= new envioDocumentos_ctr(stdControllerLead); 
        Test.stopTest();
    }
    
    static testMethod void myUnitTest3()
    {
    	createData();
    	
    	String strRTServiceCenter = mapRecordTypeSC.get('Corrección de documentos').getRecordTypeId();

    	lstCandidatos[0].RecordTypeId = recordTypeId;
    	update lstCandidatos;

		objServiceCenter.Oportunidad__c	= lstCandidatos[0].Id;
		objServiceCenter.RecordTypeId 	= strRTServiceCenter; 
        update objServiceCenter;   	
    	
    	Test.startTest();
    	    ApexPages.currentPage().getParameters().put('id',lstCandidatos[0].Id);
    	    ApexPages.StandardController stdControllerLead	= new ApexPages.StandardController(lstCandidatos[0]);
        	envioDocumentos_ctr objController 				= new envioDocumentos_ctr(stdControllerLead); 
        Test.stopTest();
    }
    
    static testMethod void myUnitTest4()
    {
    	createData();
    	
    	objContrato.CandidatoId__c = null;
    	update objContrato;
    	
    	Test.startTest();
    	    ApexPages.currentPage().getParameters().put('id',lstCandidatos[0].Id);
    	    ApexPages.StandardController stdControllerLead	= new ApexPages.StandardController(lstCandidatos[0]);
        	envioDocumentos_ctr objController 				= new envioDocumentos_ctr(stdControllerLead); 
        Test.stopTest();
    }
    
    static testMethod void myUnitTest5()
    {
    	createData();
    	
    	objContrato.Estado__c = 'Enviado';
    	update objContrato;
    	
    	Test.startTest();
    	    ApexPages.currentPage().getParameters().put('id',lstCandidatos[0].Id);
    	    ApexPages.StandardController stdControllerLead	= new ApexPages.StandardController(lstCandidatos[0]);
        	envioDocumentos_ctr objController 				= new envioDocumentos_ctr(stdControllerLead); 
        Test.stopTest();
    }
    
    global class MockHttpResponseGenerator implements HttpCalloutMock 
 	{
 		// Implement this interface method
     	global HTTPResponse respond(HTTPRequest req) 
     	{
        	// Create a fake response
         	HttpResponse res = new HttpResponse();
         	res.setHeader('Content-Type', 'application/json');
         	String strJSON = '{\n' +
				'	"processId" : "a0W550000016AHjEAM",\n' +
				'	"userDoc" : "52468972",\n' +
				'	"urlAccess" : "http://autentic.com.co/digitalSigning/?SESID=f42d9a39-2107-408a-ae65-ea839298acda",\n' +
				'	"caseNumber" : "f42d9a39-2107-408a-ae65-ea839298acda"\n' +
			'}';
         	res.setBody(strJSON);
         	res.setStatus('OK');
         	res.setStatusCode(200);
         	return res;
     	}
 	}
}