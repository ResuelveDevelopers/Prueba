@isTest
private class TriggerAccount_tst 
{

	public static RecursosHumanos__c objRecursoshumanos;
    public static Lead objCandidato;
    public static Account objCuentaPersonal;
	
	public static void createData()
	{
		objRecursoshumanos            = TestCreaObjetos.CrearRHs(1,'test','test').get(0);
        objRecursoshumanos.Usuario__c = UserInfo.getUserId();
        update objRecursoshumanos;
		
		objCandidato = TestCreaObjetos.CrearLeads(1).get(0);
		update objCandidato;
		
		System.debug('\n\n@@@objCandidato--------> ' + objCandidato + '\n\n');
		
		String RecTypeId	= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Cliente Colombia').getRecordTypeId();
        objCuentaPersonal 	= new Account(
        						RecordTypeID			= RecTypeId,
          						FirstName				= 'Test FName',
          						LastName				= 'Test LName',
          						PersonMailingStreet		= 'test@yahoo.com',
          						PersonMailingPostalCode	= '12345',
          						PersonMailingCity		= 'SFO',
          						PersonEmail				= 'test@yahoo.com',
          						PersonHomePhone			= '1234567',
          						PersonMobilePhone		= '12345678',
          						Phone					= '2165487',
          						Oportunidad__c			= objCandidato.Id
        );
        insert objCuentaPersonal;
	}

    static testMethod void myUnitTest() 
    {
    	createData();
    	Test.startTest();
            objCuentaPersonal.Phone						= '2222222';
            objCuentaPersonal.Telefono_celular__c		= '3223332211';
            objCuentaPersonal.Telefono_oficina__c		= '2222111';
            objCuentaPersonal.PersonEmail				= 'correo@prueba.com';
            objCuentaPersonal.Correo_electronico2__c	= 'correo@customer.com';
            update objCuentaPersonal;
            Account objAccount = [SELECT Phone,Telefono_celular__c,Telefono_oficina__c,PersonEmail,Correo_electronico2__c FROM Account WHERE Id = :objCuentaPersonal.Id];
        Test.stopTest();          
    }
}