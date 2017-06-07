/*******************************************************************************
Desarrollado por:   RTD
Autor:              Jeisson Hernandez
Proyecto:           Colombia III Campos Autmaticos Lead
Descripción:        Clase de Prueba para el TriggerLead

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		----------                ---------------------------     
    1.0     15-Oct-2015		Jeisson Hernandez(JH)     Creación de la Clase.
    1.1     15-Oct-2015		Esteban Heredia(EH)       Sucursales diferentes
*******************************************************************************/
@isTest
private class TriggerLead_tst 
{

	static testMethod void crearLeadUsuarioLanding() 
	{
		Test.startTest();
		// EH 14/07/2016 Creación configuración
		CiudadesColombia__c ciudadesColombia = new CiudadesColombia__c();
		ciudadesColombia.Name = 'Bogotá';
		ciudadesColombia.Ciudad__c = 'Bogotá D.C.';
		ciudadesColombia.Departamento__c = 'Cundinamarca';
		ciudadesColombia.Sucursal__c = 'Bogotá';
		insert ciudadesColombia;
		PerfilesAsignacionLeadsLandingPages__c objConPers1 = new PerfilesAsignacionLeadsLandingPages__c();
		objConPers1.Name = 'Landing Page';
		insert objConPers1;
		Profile p = [SELECT Id FROM Profile WHERE Name='Landing Page'];
		User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
		EmailEncodingKey='UTF-8',FirstName = 'UsuarioTest', LastName='Landing', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = p.Id, 
		TimeZoneSidKey='America/Los_Angeles', UserName='usuario@testlanding.com');
		System.runAs(u) 
		{
			Sucursal__c objSucursal = new Sucursal__c (Name='Bogotá');
			insert  objSucursal;
			RecursosHumanos__c objRHLanding = new RecursosHumanos__c(); 
			objRHLanding.Name = u.FirstName;
			objRHLanding.Sucursal__c = objSucursal.Id;
			objRHLanding.Usuario__c = UserInfo.getUserId();
			insert objRHLanding;
			List <Lead> lstLead = TestCreaObjetos.CrearLeads(1);
			// EH 14/07/2016 Comprobamos que si colocó la sucursal de la configuración
			System.assertEquals([SELECT Id,AsignacionSucursal__r.Name FROM Lead where Id=:lstLead.get(0).Id].AsignacionSucursal__r.Name  == ciudadesColombia.Sucursal__c, true);
		}		
		Test.stopTest();
	}

	static testMethod void actualizarLeadUsuarioLanding() 
	{
		
		PerfilesAsignacionLeadsLandingPages__c objConPers1 = new PerfilesAsignacionLeadsLandingPages__c();
		objConPers1.Name = 'Landing Page';
		insert objConPers1;
		PerfilesAsignacionVendedorAsignado__c objConPers2 = new PerfilesAsignacionVendedorAsignado__c(); 
		objConPers2.Name = 'Asesor de Reparación de Deuda';
		insert objConPers2;
		Profile p = [SELECT Id FROM Profile WHERE Name='Landing Page'];
		User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
		EmailEncodingKey='UTF-8',FirstName = 'UsuarioTest', LastName='Landing', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = p.Id, 
		TimeZoneSidKey='America/Los_Angeles', UserName='usuario@testlanding.com');

		Sucursal__c objSucursal = new Sucursal__c (Name='Bogotá');
		insert  objSucursal;
		User objUserVendedor = [Select Id,Name 
								From User 
								Where Profile.Name = 'Asesor de Reparación de Deuda' AND isActive = true Limit 1];
		System.debug('@@@Usuario Vendedor: ' + objUserVendedor);
		
		Test.startTest();
		System.runAs(u) 
		{
			RecursosHumanos__c objRHLanding = new RecursosHumanos__c(); 
			objRHLanding.Name = u.FirstName;
			objRHLanding.Sucursal__c = objSucursal.Id;
			objRHLanding.Usuario__c = UserInfo.getUserId();
			insert objRHLanding;

			RecursosHumanos__c objRHVendedor = new RecursosHumanos__c(); 
			objRHVendedor.Name = u.FirstName;
			objRHVendedor.Sucursal__c = objSucursal.Id;
			objRHVendedor.Usuario__c = objUserVendedor.Id;
			insert objRHVendedor;
			

			List <Lead> lstLead = TestCreaObjetos.CrearLeads(1);
			lstLead[0].VendedorAsignado__c = objRHVendedor.Id;
			update lstLead; 
		}		
		Test.stopTest();
	}

	static testMethod void crearLeadUsuarioVendedor() 
	{
		
		PerfilesAsignacionVendedorAsignado__c objConPers2 = new PerfilesAsignacionVendedorAsignado__c(); 
		objConPers2.Name = 'Asesor de Reparación de Deuda';
		insert objConPers2;
		Profile p = [SELECT Id FROM Profile WHERE Name='Asesor de Reparación de Deuda'];
		User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
		EmailEncodingKey='UTF-8',FirstName = 'UsuarioVendedor', LastName='Landing', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = p.Id, 
		TimeZoneSidKey='America/Los_Angeles', UserName='usuario@testlanding.com');

		Sucursal__c objSucursal = new Sucursal__c (Name='Bogotá');
		insert  objSucursal;
		System.debug('@@@Usuario Vendedor: ' + u);

		Test.startTest();
		System.runAs(u) 
		{
			RecursosHumanos__c objRHVendedor = new RecursosHumanos__c(); 
			objRHVendedor.Name = u.FirstName;
			objRHVendedor.Sucursal__c = objSucursal.Id;
			objRHVendedor.Usuario__c = UserInfo.getUserId();
			insert objRHVendedor;

			List <Lead> lstLead = TestCreaObjetos.CrearLeads(1);
		}		
		Test.stopTest();
	}	

	static testMethod void eliminarLeadUsuarioVendedor() 
	{
		
		PerfilesAsignacionVendedorAsignado__c objConPers2 = new PerfilesAsignacionVendedorAsignado__c(); 
		objConPers2.Name = 'Asesor de Reparación de Deuda';
		insert objConPers2;
		Profile p = [SELECT Id FROM Profile WHERE Name='Asesor de Reparación de Deuda'];
		User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
		EmailEncodingKey='UTF-8',FirstName = 'UsuarioVendedor', LastName='Landing', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = p.Id, 
		TimeZoneSidKey='America/Los_Angeles', UserName='usuario@testlanding.com');

		Sucursal__c objSucursal = new Sucursal__c (Name='Bogotá');
		insert  objSucursal;
		System.debug('@@@Usuario Vendedor: ' + u);
		List <Lead> lstLead = new List <Lead>(); 
		Test.startTest();
		System.runAs(u) 
		{
			RecursosHumanos__c objRHVendedor = new RecursosHumanos__c(); 
			objRHVendedor.Name = u.FirstName;
			objRHVendedor.Sucursal__c = objSucursal.Id;
			objRHVendedor.Usuario__c = UserInfo.getUserId();
			insert objRHVendedor;

			lstLead = TestCreaObjetos.CrearLeads(1);
		}		
		delete lstLead;
		Test.stopTest();
	}
	
	static testMethod void errorUsuarioNORelEnRH() 
	{
		PerfilesAsignacionLeadsLandingPages__c objConPers1 = new PerfilesAsignacionLeadsLandingPages__c();
		objConPers1.Name = 'Administrador del sistema';
		Sucursal__c objSucursal = new Sucursal__c (Name='Bogotá');
		insert  objSucursal;
		
		Lead objLead = new Lead();
		objLead.FirstName = 'Lead ';
		objLead.LastName = 'Apellido Lead';
		objLead.Email = 'lead@test.com';
		
		Test.startTest();
			Database.SaveResult result = Database.insert(objLead, false);
		Test.stopTest();
		System.assert(!result.isSuccess());
		System.assert(result.getErrors().size() > 0);
		System.assertEquals('El Usuario NO se encuentra creado o relacionado en Recursos Humanos',
							 result.getErrors()[0].getMessage());		
	}	


}