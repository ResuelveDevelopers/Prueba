/*******************************************************************************
Desarrollado por:	Resuelve tu deuda
Autor:				Jeisson Hernandez
Proyecto:			Calidad Colombia
Descripción:		Clase de Prueba de la clase InboundEmailActividadesCalidad 

Cambios (Versiones)
-------------------------------------
    No.		Fecha			Autor						Descripción
    ---		---  			----------  				--------------------------  	
    1.0		08-Jul-2015		Jeisson Hernandez (JH)		Creación de la Clase.
        
*******************************************************************************/
@isTest
private class InboundEmailActividadesCalidad_tst 
{

    static testMethod void actividadCalidadDesdeCliente() 
    {

		Id CuentaPersonalRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Colombia').getRecordTypeId();
		List<User> lstUserSistemas = [Select Id,Name FROM User Where Name ='Sistemas RTD'];
		System.debug('Usario Sistemas: ' + lstUserSistemas);		
    	Conf_IdsDesarrollos__c objConf = new Conf_IdsDesarrollos__c();
    	objConf.Name = 'InboundEmailActividadesCalidad_Id1';
    	if(!lstUserSistemas.IsEmpty())
    		objConf.Id__c = lstUserSistemas[0].Id;
    	insert  objConf;

		String sCadenaPrueba = 'This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. ';
		Blob bArchivoPrueba = Blob.valueOf(sCadenaPrueba);
 		//Crea e inserta Cliente
 		
 		Account RdAccount = new Account();
	    RdAccount.NumerodeReferencia__c ='testnum'+Math.random();
	    RdAccount.FirstName = 'Test 1 ';
	    RdAccount.LastName = 'Test 1 Last name';
	    RdAccount.PersonEmail = 'prueba@hotmail.com';
	    RdAccount.Correo_electronico2__c = 'prueba@hotmail.com';
	    RdAccount.RecordTypeId = CuentaPersonalRecordTypeId;
	    insert RdAccount;
 		
 		System.debug('Correo Cuenta: ' + RdAccount.Id + ' ' + RdAccount.PersonEmail + ' '+ RdAccount.Correo_electronico2__c);

        // Crea una nuevo correo y un nuevo sobre
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        //Un archivo de tipo texto
        Messaging.InboundEmail.TextAttachment mitTxtAtt = new Messaging.InboundEmail.TextAttachment();
		mitTxtAtt.mimeTypeSubType = 'text/calendar';
		mitTxtAtt.body = sCadenaPrueba;
		mitTxtAtt.fileName = 'PruebaTexto';
		
		//Una lista de archivos de texto
		List<Messaging.InboundEmail.TextAttachment> lMitTxtAtt = new List<Messaging.InboundEmail.TextAttachment>();
		lMitTxtAtt.add(mitTxtAtt);
		
        //Un archivo de tipo binario
        Messaging.InboundEmail.BinaryAttachment mibBinAttch = new Messaging.InboundEmail.BinaryAttachment();
		mibBinAttch.mimeTypeSubType = 'application/octet-stream';
		mibBinAttch.body = bArchivoPrueba;
		mibBinAttch.fileName = 'PruebaBinario';		
		//Una lista de archivos de binario
		List<Messaging.InboundEmail.BinaryAttachment> lMibBinAttch = new List<Messaging.InboundEmail.BinaryAttachment>();
		lMibBinAttch.add(mibBinAttch);
		
		//Inicializa los textAttachments
		email.textAttachments = lMitTxtAtt;
		email.binaryAttachments = lMibBinAttch;
		 
        // Create the email body
        email.plainTextBody = 'Prueba de correo con attch.';
        email.fromAddress ='prueba@hotmail.com';
        email.subject = 'Prueba correo con attch.';
        
		//Genera un constructor por default        
        InboundEmailActividadesCalidad mailService = new InboundEmailActividadesCalidad();

		//Inicia las pruebas        
        Test.startTest();
       	Messaging.InboundEmailResult result = mailService.handleInboundEmail(email, env);
        //Finaliza las pruebas
        Test.stopTest();    	
    }
    
    @isTest(seeAllData = true)
    static void actividadCalidadDesdeOportunidad() 
    {
		Test.startTest();
		List<User> lstUserSistemas = [Select Id,Name FROM User Where Name ='Sistemas RTD'];
		System.debug('@@Usuario Sistemas: ' + lstUserSistemas);		

		String sCadenaPrueba = 'This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. ';
		Blob bArchivoPrueba = Blob.valueOf(sCadenaPrueba);

		//Creacion de Oportunidad
		Lead O = new Lead();
		//O.FechaUltimaActividadVentas__c = System.now();
    	O.Email = 'prueba@hotmail.com';
    	O.FechaCompromisoCita__c = System.today();
    	O.FechaCompromisoDeposito__c = System.today();
    	O.LastName ='Test LastName';    	
    	insert O;
    	System.debug('Id de la oportunidad ===>'+O.Id);
    	
        // Crea una nuevo correo y un nuevo sobre
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        //Un archivo de tipo texto
        Messaging.InboundEmail.TextAttachment mitTxtAtt = new Messaging.InboundEmail.TextAttachment();
		mitTxtAtt.mimeTypeSubType = 'text/calendar';
		mitTxtAtt.body = sCadenaPrueba;
		mitTxtAtt.fileName = 'PruebaTexto';
		
		//Una lista de archivos de texto
		List<Messaging.InboundEmail.TextAttachment> lMitTxtAtt = new List<Messaging.InboundEmail.TextAttachment>();
		lMitTxtAtt.add(mitTxtAtt);
		
        //Un archivo de tipo binario
        Messaging.InboundEmail.BinaryAttachment mibBinAttch = new Messaging.InboundEmail.BinaryAttachment();
		mibBinAttch.mimeTypeSubType = 'application/octet-stream';
		mibBinAttch.body = bArchivoPrueba;
		mibBinAttch.fileName = 'PruebaBinario';		
		//Una lista de archivos de binario
		List<Messaging.InboundEmail.BinaryAttachment> lMibBinAttch = new List<Messaging.InboundEmail.BinaryAttachment>();
		lMibBinAttch.add(mibBinAttch);
		
		//Inicializa los textAttachments
		email.textAttachments = lMitTxtAtt;
		email.binaryAttachments = lMibBinAttch;
		 
        // Create the email body
        email.plainTextBody = 'Prueba de correo con attch.';
        email.fromAddress ='prueba@hotmail.com';
        email.subject = 'Prueba correo con attch.';
        
		//Genera un constructor por default        
        InboundEmailActividadesCalidad mailService = new InboundEmailActividadesCalidad();

		//Inicia las pruebas        
        
       	Messaging.InboundEmailResult result = mailService.handleInboundEmail(email, env);
        //Finaliza las pruebas
        Test.stopTest();    	
    	
    }
    
     static testMethod void actividadaCalidadSinClienteSinOpp() 
    {
    	Conf_IdsDesarrollos__c objConf = new Conf_IdsDesarrollos__c();
    	objConf.Name = 'InboundEmailActividadesCalidad_Id1';
    	insert  objConf;
    			
		String sCadenaPrueba = 'This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. This is Test. ';
		Blob bArchivoPrueba = Blob.valueOf(sCadenaPrueba);

    	// Crea una nuevo correo y un nuevo sobre
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        //Un archivo de tipo texto
        Messaging.InboundEmail.TextAttachment mitTxtAtt = new Messaging.InboundEmail.TextAttachment();
		mitTxtAtt.mimeTypeSubType = 'text/calendar';
		mitTxtAtt.body = sCadenaPrueba;
		mitTxtAtt.fileName = 'PruebaTexto';
		
		//Una lista de archivos de texto
		List<Messaging.InboundEmail.TextAttachment> lMitTxtAtt = new List<Messaging.InboundEmail.TextAttachment>();
		lMitTxtAtt.add(mitTxtAtt);
		
        //Un archivo de tipo binario
        Messaging.InboundEmail.BinaryAttachment mibBinAttch = new Messaging.InboundEmail.BinaryAttachment();
		mibBinAttch.mimeTypeSubType = 'application/octet-stream';
		mibBinAttch.body = bArchivoPrueba;
		mibBinAttch.fileName = 'PruebaBinario';		
		//Una lista de archivos de binario
		List<Messaging.InboundEmail.BinaryAttachment> lMibBinAttch = new List<Messaging.InboundEmail.BinaryAttachment>();
		lMibBinAttch.add(mibBinAttch);
		
		//Inicializa los textAttachments
		email.textAttachments = lMitTxtAtt;
		email.binaryAttachments = lMibBinAttch;
		 
        // Create the email body
        email.plainTextBody = 'Prueba de correo con attch.';
        email.fromAddress ='testjahg@correo.com';
        email.subject = 'Prueba correo con attch.';
        
		//Genera un constructor por default        
        InboundEmailActividadesCalidad mailService = new InboundEmailActividadesCalidad();

		//Inicia las pruebas        
        Test.startTest();
       	Messaging.InboundEmailResult result = mailService.handleInboundEmail(email, env);
        //Finaliza las pruebas
        Test.stopTest();
    }
}