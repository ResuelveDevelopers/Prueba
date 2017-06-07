/*****************************************************************************************************
* Desarrollado por: RTD
* Autor:            Esteban Heredia (EH)
* Proyecto:         Colombia 
* Descripción:      Clase de prueba para botonTareasNoSeLocaliza_ctr             
*
* Cambios (Versiones)
* -------------------------------------
*           No.     fecha          	Autor 		               	Descripción
*           -----   ----------      ------------------------   	---------------
* @version  1.0     12-Abr-2016     Esteban Heredia (EH)        Creación de la clase         
*******************************************************************************************************/

@isTest
global class botonTareasNoSeLocaliza_tst 
{
	public static Task objTarea2;
	public static Reparadora__c objReparadora;
	public static Account objCuentaPersonal;

	public static void createData()
	{
		String RecTypeId 	= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Cliente Colombia').getRecordTypeId();
		Id recordTypeId 	= Schema.SObjectType.Task.getRecordTypeInfosByName().get('Actividad de Ventas').getRecordTypeId();
 		
 		 MensajesTexto__c csMensajeDeTexto = new MensajesTexto__c();
 		 csMensajeDeTexto.product_id__c = 'abc';
 		 csMensajeDeTexto.user_id__c = 'abc';
 		 csMensajeDeTexto.user_pw__c = 'abc';
 		 csMensajeDeTexto.Mensaje8__c = 'abc';
 		 csMensajeDeTexto.Mensaje7__c = 'abc';
 		 csMensajeDeTexto.Mensaje6__c = 'abc';
 		 csMensajeDeTexto.Mensaje5__c = 'abc';
 		 csMensajeDeTexto.Mensaje4__c = 'abc';
 		 csMensajeDeTexto.Mensaje3__c = 'abc';
 		 csMensajeDeTexto.Mensaje2__c = 'abc';
 		 csMensajeDeTexto.Mensaje1__c = 'abc';
 		 insert csMensajeDeTexto;

		objCuentaPersonal = new Account(
		  RecordTypeID=RecTypeId,
		  FirstName='Test FName',
		  LastName='Test LName',
		  PersonMailingStreet='test@yahoo.com',
		  PersonMailingPostalCode='12345',
		  PersonMailingCity='SFO',
		  PersonEmail='test@yahoo.com',
		  PersonHomePhone='1234567',
		  Telefono_celular__c = '3005674562',
		  PersonMobilePhone='12345678' 
		);
		insert objCuentaPersonal;
		objReparadora					= TestCreaObjetos.CrearReparadoras(1,objCuentaPersonal.id,true).get(0);
		objTarea2 						= TestCreaObjetos.CrearTareas(1, null, objReparadora.id, recordTypeId, false).get(0);
			
	}

	@isTest static void test_method_one() 
	{
		createData();
		objTarea2.Subject = 'Llamada de Bienvenida';
		objTarea2.NumerodeintentosdeLocalizacion__c = 6;
		insert objTarea2;
		// Set mock callout class 
		ApexPages.StandardController sc = new ApexPages.StandardController(objTarea2);
        botonTareasNoSeLocaliza_ctr botonNoSeLocaliza = new botonTareasNoSeLocaliza_ctr(sc);
        PageReference pageRef = Page.botonTareasNoSeLocaliza;
        Test.setCurrentPage(pageRef);
        	Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
	        Test.startTest();
	        	botonNoSeLocaliza.flujoNoSeLocaliza();
	        Test.stopTest();
	}
	
	@isTest static void test_method_two() 
	{
		createData();
		objTarea2.Subject = 'Llamada de Bienvenida';
		objTarea2.NumerodeintentosdeLocalizacion__c = 7;
		insert objTarea2;
		// Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		objReparadora.FechaUltimoContacto__c = system.today().addDays(-30);
		objReparadora.FechaUltimoDeposito__c = system.today().addDays(-30);
		update objReparadora;
		objTarea2.HistorialIntentosLocalizacion__c = 'Texto muy\n largobsdhgfbesdbgbdhjsbgs\ndyhkusvftudsgyufgdyusvgfdsvgf\ndsyugfyudsgyfkuagfgyudaefdasbg\nghsdagfsdvgabfvgghfdasvfgh\nhigeswfbdhasbgbdshlfbgdfsbgf\ndtgufvgdvasfvdasvfgh\ndasfgasdkuvfdasv\nhdjsvfgdsvfvvfghdsvfghdsvdfvsdfsadvfsvfsvfdvfghdsv';
		update objTarea2;
		ApexPages.StandardController sc = new ApexPages.StandardController(objTarea2);
        botonTareasNoSeLocaliza_ctr botonNoSeLocaliza = new botonTareasNoSeLocaliza_ctr(sc);
        PageReference pageRef = Page.botonTareasNoSeLocaliza;
        Test.setCurrentPage(pageRef);
	        Test.startTest();
	        	botonNoSeLocaliza.flujoNoSeLocaliza();
	        Test.stopTest();
	}
	
	@isTest static void test_method_Three() 
	{
		createData();
		insert objTarea2;
		// Set mock callout class 
		objReparadora.FechaUltimoContacto__c = system.today().addDays(-60);
		objReparadora.FechaUltimoDeposito__c = system.today().addDays(-60);
		update objReparadora;
		ApexPages.StandardController sc = new ApexPages.StandardController(objTarea2);
        botonTareasNoSeLocaliza_ctr botonNoSeLocaliza = new botonTareasNoSeLocaliza_ctr(sc);
        PageReference pageRef = Page.botonTareasNoSeLocaliza;
        Test.setCurrentPage(pageRef);
	        Test.startTest();
	        	botonNoSeLocaliza.flujoNoSeLocaliza();
	        Test.stopTest();
	}

	@isTest static void test_method_Four() 
	{
		createData();
		objTarea2.Subject = 'Llamada Telefonica Post Venta # 1';
		objTarea2.NumerodeintentosdeLocalizacion__c = 4;
		insert objTarea2;
		// Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		objReparadora.FechaUltimoContacto__c = system.today().addDays(-90);
		objReparadora.FechaUltimoDeposito__c = system.today().addDays(-90);
		update objReparadora;
		ApexPages.StandardController sc = new ApexPages.StandardController(objTarea2);
        botonTareasNoSeLocaliza_ctr botonNoSeLocaliza = new botonTareasNoSeLocaliza_ctr(sc);
        PageReference pageRef = Page.botonTareasNoSeLocaliza;
        Test.setCurrentPage(pageRef);
	        Test.startTest();
	        	botonNoSeLocaliza.flujoNoSeLocaliza();
	        Test.stopTest();
	}

	@isTest static void test_method_Ten() 
	{
		createData();
		objTarea2.Subject = 'Llamada por 90 días sin Contacto o Deposito';
		objTarea2.NumerodeintentosdeLocalizacion__c = 4;
		insert objTarea2;
		// Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		objReparadora.FechaUltimoContacto__c = system.today().addDays(-90);
		objReparadora.FechaUltimoDeposito__c = system.today().addDays(-90);
		update objReparadora;
		ApexPages.StandardController sc = new ApexPages.StandardController(objTarea2);
        botonTareasNoSeLocaliza_ctr botonNoSeLocaliza = new botonTareasNoSeLocaliza_ctr(sc);
        PageReference pageRef = Page.botonTareasNoSeLocaliza;
        Test.setCurrentPage(pageRef);
	        Test.startTest();
	        	botonNoSeLocaliza.flujoNoSeLocaliza();
	        Test.stopTest();
	}

	@isTest static void test_method_Five() 
	{
		createData();
		objTarea2.Subject = 'Llamada por 90 días sin Contacto o Deposito';
		objTarea2.NumerodeintentosdeLocalizacion__c = 4;
		insert objTarea2;
		// Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		objReparadora.FechaUltimoContacto__c = system.today().addDays(-90);
		objReparadora.FechaUltimoDeposito__c = system.today().addDays(-89);
		update objReparadora;
		ApexPages.StandardController sc = new ApexPages.StandardController(objTarea2);
        botonTareasNoSeLocaliza_ctr botonNoSeLocaliza = new botonTareasNoSeLocaliza_ctr(sc);
        PageReference pageRef = Page.botonTareasNoSeLocaliza;
        Test.setCurrentPage(pageRef);
	        Test.startTest();
	        	botonNoSeLocaliza.flujoNoSeLocaliza();
	        Test.stopTest();
	}

	@isTest static void test_method_Six() 
	{
		createData();
		objTarea2.Subject = 'Llamada por 30 días sin Contacto o Deposito';
		objTarea2.NumerodeintentosdeLocalizacion__c = 4;
		insert objTarea2;
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		ApexPages.StandardController sc = new ApexPages.StandardController(objTarea2);
        botonTareasNoSeLocaliza_ctr botonNoSeLocaliza = new botonTareasNoSeLocaliza_ctr(sc);
        PageReference pageRef = Page.botonTareasNoSeLocaliza;
        Test.setCurrentPage(pageRef);
	        Test.startTest();
	        	botonNoSeLocaliza.flujoNoSeLocaliza();
	        Test.stopTest();
	}

	@isTest static void test_method_Seven() 
	{
		createData();
		objTarea2.Subject = 'Llamada por 60 días sin Contacto o Deposito';
		objTarea2.NumerodeintentosdeLocalizacion__c = 4;
		insert objTarea2;
		objReparadora.FechaUltimoDeposito__c = system.today().addDays(-60);
		update objReparadora;
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		ApexPages.StandardController sc = new ApexPages.StandardController(objTarea2);
        botonTareasNoSeLocaliza_ctr botonNoSeLocaliza = new botonTareasNoSeLocaliza_ctr(sc);
        PageReference pageRef = Page.botonTareasNoSeLocaliza;
        Test.setCurrentPage(pageRef);
	        Test.startTest();
	        	botonNoSeLocaliza.flujoNoSeLocaliza();
	        Test.stopTest();
	}

	@isTest static void test_method_Eight() 
	{
		createData();
		objTarea2.Subject = 'Llamada por 60 días sin Contacto o Deposito';
		objTarea2.NumerodeintentosdeLocalizacion__c = 4;
		insert objTarea2;
		objReparadora.FechaUltimoContacto__c = system.today().addDays(-60);
		objReparadora.FechaUltimoDeposito__c = system.today().addDays(-91);
		update objReparadora;
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		ApexPages.StandardController sc = new ApexPages.StandardController(objTarea2);
        botonTareasNoSeLocaliza_ctr botonNoSeLocaliza = new botonTareasNoSeLocaliza_ctr(sc);
        PageReference pageRef = Page.botonTareasNoSeLocaliza;
        Test.setCurrentPage(pageRef);
	        Test.startTest();
	        	botonNoSeLocaliza.flujoNoSeLocaliza();
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
	        res.setBody('response_code=1&response_msg=Success&response_desc=Transaction accepted, message queued for delivery.&transaction_type=400&rate=0.0246&balance=26.9742&reference_id=&transaction_id=16701725');
	        res.setStatusCode(200);
	        return res;
	    }
	}
}