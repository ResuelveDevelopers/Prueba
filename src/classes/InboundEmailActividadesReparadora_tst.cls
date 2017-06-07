/*******************************************************************************
Desarrollado por:   Resuelve tu deuda
Autor:              Ricardo Parra
Proyecto:           
Descripción:        Clase de Prueba de la clase InboundEmailActividadesReparadora 

Cambios (Versiones)
-------------------------------------
    No.     Fecha           Autor                       Descripción
    ---     ---             ----------                  --------------------------      
    1.0     08-Jul-2015     Jeisson Hernandez (JH)      Creación de la Clase.
        
*******************************************************************************/
@isTest
private class InboundEmailActividadesReparadora_tst 
{

    static testMethod void ActividadesReparadora() 
    {

        Id CuentaPersonalRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Colombia').getRecordTypeId();
        List<User> lstUserSistemas = [Select Id,Name FROM User Where Name ='Sistemas RTD'];
        System.debug('Usario Sistemas: ' + lstUserSistemas);        
        Conf_IdsDesarrollos__c objConf = new Conf_IdsDesarrollos__c();
        

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
        InboundEmailActividadesReparadora mailService = new InboundEmailActividadesReparadora();

        //Inicia las pruebas        
        Test.startTest();
        Messaging.InboundEmailResult result = mailService.handleInboundEmail(email, env);

         Reparadora__c Rep =new Reparadora__c();
        Rep.Cliente__c =RdAccount.id;
        insert Rep;

         Messaging.InboundEmailResult result2 = mailService.handleInboundEmail(email, env);
        //Finaliza las pruebas
        Test.stopTest();        
    }
    
    
}