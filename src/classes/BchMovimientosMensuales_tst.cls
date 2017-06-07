/*******************************************************************************
Desarrollado por:   RTD
Autor:              Marwin Pineda
Proyecto:           Movimientos mensuales.
Descripción:        Clase de prueba BchMovimientosMensuales.

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha           Autor                   Descripción
    ---     ---             ----------              ---------------------------     
    1.0     25-Jul-2016       Marwin Pineda(MP)       Creación de la Clase.
*******************************************************************************/
@isTest

private class BchMovimientosMensuales_tst
{
	
    public static String strQuery = '';
    
    public static String strConsulta()
	{
		String strQueryScheduler;
		strQueryScheduler 	= 'SELECT Id,FechaInicioPrograma__c,Status__c,ComisionMensual1__c,(SELECT Id FROM Movimientos__r) ';
        strQueryScheduler  += 'FROM Reparadora__c ';
        strQueryScheduler  += 'WHERE FechaInicioPrograma__c < THIS_MONTH ';
        strQueryScheduler  += 'AND Status__c IN (\'Activo\', \'En Tramite de Baja\', \'Graduar\') ';
		return strQueryScheduler;
	}
	
	@isTest 
	static void test_method_one() 
	{
		
		RecordType objRecordType = [Select Id From RecordType Where SobjectType = 'Account' and Name = 'Cliente Colombia'];
		
		Notificacion_Trabajos_Programados__c config = new Notificacion_Trabajos_Programados__c();
		config.Correo_Notificacion__c 				= 'prueba@resuelve.com';
		config.Asunto_Correo_Notificacion__c 		= 'Movimientos Automáticos';
		config.Name									= 'BchMovimientosMensuales_bch';
		insert config;
		
		Account objAccount 					= new Account();
		objAccount.FirstName				= 'TEST';
		objAccount.LastName 				= 'NAME';
		objAccount.recordtypeId				= objRecordType.Id;
		objAccount.PersonMailingStreet		= 'test@yahoo.com';
		objAccount.PersonMailingPostalCode	= '12345';
		objAccount.PersonMailingCity		= 'SFO';
		objAccount.PersonEmail				= 'test@yahoo.com';
		objAccount.PersonHomePhone			= '1234567';
		objAccount.PersonMobilePhone		= '12345678';
		insert objAccount;
		
		Reparadora__c objReparadora				= new Reparadora__c();
		objReparadora.FechaInicioPrograma__c	= Date.today().addMonths(-1);
		objReparadora.Status__c					= 'Activo';
		objReparadora.Referencia__c 			= '22123456';
		insert objReparadora;
		
		strQuery 		= strConsulta();

		Test.startTest();
			BchMovimientosMensuales_bch batch = new BchMovimientosMensuales_bch(strQuery);
			database.executebatch(batch,1);
		Test.stopTest(); 
	}
}