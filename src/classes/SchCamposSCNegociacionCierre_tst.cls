/*******************************************************************************
Desarrollado por:   RTD
Autor:              Jeisson Hernandez
Proyecto:           Colombia III
Descripción:        Clase de prueba que probara la clase SchCamposSCNegociacionCierre_sch 

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		----------                ---------------------------     
    1.0     27-Abr-2016		Jeisson Hernandez(JH)     Creación de la Clase.
*******************************************************************************/

@isTest
private class SchCamposSCNegociacionCierre_tst 
{

	@isTest
	static void test1() 
	{
		CierreClientesPuestosPerfiles__c objConfPerNegPuestoPerfil = new CierreClientesPuestosPerfiles__c();
		objConfPerNegPuestoPerfil.Name = 'N1';
		objConfPerNegPuestoPerfil.Area__c = 'Negociacion';
		objConfPerNegPuestoPerfil.Puesto__c = 'Negociador Colombia';
		insert objConfPerNegPuestoPerfil;
		
		CierreClientesPuestosPerfiles__c objConfPerSCPuestoPerfil = new CierreClientesPuestosPerfiles__c();
		objConfPerSCPuestoPerfil.Name = 'SC1';
		objConfPerSCPuestoPerfil.Area__c = 'Servicio al Cliente';
		objConfPerSCPuestoPerfil.Puesto__c = 'Ejecutivo de Servicio al Cliente Colombia';
		insert objConfPerSCPuestoPerfil;

		List <RecursosHumanos__c> lstEjeSC = TestCreaObjetos.CrearRHs(2,'Ejecutivo de Servicio al Cliente Colombia','Servicio al Cliente');
		lstEjeSC[0].EjecutivoPremium__c = false;
		lstEjeSC[1].EjecutivoPremium__c = true;
		update lstEjeSC;
		
		List <RecursosHumanos__c> lstNegociador = TestCreaObjetos.CrearRHs(2,'Negociador Colombia','Negociacion');
		
		String RecTypeId 	= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Cliente Colombia').getRecordTypeId();
		Id recordTypeId 	= Schema.SObjectType.Task.getRecordTypeInfosByName().get('Actividad de Ventas').getRecordTypeId();
 
		Account objCuentaPersonal = new Account(
		  RecordTypeID=RecTypeId,
		  FirstName='Test FName',
		  LastName='Test LName',
		  PersonMailingStreet='test@yahoo.com',
		  PersonMailingPostalCode='12345',
		  PersonMailingCity='SFO',
		  PersonEmail='test@yahoo.com',
		  PersonHomePhone='1234567',
		  PersonMobilePhone='12345678' 
		);
		insert objCuentaPersonal;
		
		List <Reparadora__c> lstReparadoras = TestCreaObjetos.CrearReparadoras(1,objCuentaPersonal.Id, true);
		lstReparadoras[0].EjecutivoAtencionClientes__c = lstEjeSC[0].Id;
		lstReparadoras[0].NegociadorAsignado__c = lstNegociador[0].Id;
		lstReparadoras[0].FechaInicioPrograma__c = Date.today();
		update lstReparadoras;

		Deudas__c objDeuda = new Deudas__c();
		objDeuda.TotalaPagar__c = 100000;
		objDeuda.MontodeLiquidacion__c   = 100000;
		objDeuda.DiasdePago__c  = 10000; 
		objDeuda.MontoPagoInicial__c = 100000;
		objDeuda.NegociadorAsignado__c  = lstNegociador[0].Id;
		objDeuda.EstadodelaDeuda__c  = 'En Negociacion';
		objDeuda.UltimoMontodeLiquidacion__c  = 50000;
		objDeuda.MontoLiqBanco__c = 50000;
		objDeuda.RTD__c = lstReparadoras[0].id;
		insert objDeuda;

		Test.startTest();
			String jobId;
			jobId = System.schedule('SchCamposSCNegociacionCierre_sch','0 0 0 3 9 ? 2022', new SchCamposSCNegociacionCierre_sch());
			CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		Test.stopTest();
	}
}