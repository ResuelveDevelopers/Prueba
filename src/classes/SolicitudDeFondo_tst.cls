/*************************************************************************************
Desarrollado por:	Resuelve
Autor:				Angela Munévar(AM)
Proyecto:			Resuelve tu Deuda
Descripción:		Clase de prueba de SolicitudDeFondo_crt

Cambios (Versiones)
-------------------------------------
    No.		Fecha				Autor						Descripción
    ---		-----------  		------------------------	--------------------------  	
    1.0		12-Abr-2016			Angela Munévar(AM)			Creación de la Clase de prueba.
***************************************************************************************/

@isTest
private class SolicitudDeFondo_tst {
	
	@isTest static void test_method_one()
	{
		Test.startTest();
		Profile p = [SELECT Id FROM Profile WHERE Name = 'Administrador del sistema'];
		
        User u1 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',
        	               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        	               LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', 
        	               UserName='usuario@testlanding.com');

        Deudas__c RdDeudas = new Deudas__c();
      	RdDeudas.TotalaPagar__c = 100.00;

      	
      	RdDeudas.MontodeLiquidacion__c   = 100.00;
      	RdDeudas.DiasdePago__c  = 10.00; 
      	RdDeudas.MontoPagoInicial__c = 100.00;
      	RdDeudas.NegociadorAsignado__c  = null;
      	RdDeudas.EstadodelaDeuda__c  = 'En Negociacion';
      	RdDeudas.UltimoMontodeLiquidacion__c  = 50000;
      	
      	insert RdDeudas;

        SolicitudesDeFondos__c RdSolFondos = new SolicitudesDeFondos__c();
      	RdSolFondos.Deuda__c = RdDeudas.id;      
   
    	insert RdSolFondos;

        System.runAs(u1)
        {
        	ApexPages.StandardController sc = new ApexPages.StandardController(RdSolFondos);
        	SolicitudDeFondo_ctr solFon = new SolicitudDeFondo_ctr(sc);

        }
        Test.stopTest();

	}

  @isTest static void test_method_two()
  {
    Test.startTest();
    Profile perfil = [SELECT Id FROM Profile WHERE Name = 'Agente de Preventa'];
    
        User u1 = new User(Alias = 'standt1',Country='United Kingdom',Email='usuario@testlanding.com',
                         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                         LocaleSidKey='en_US',ProfileId = perfil.Id,TimeZoneSidKey='America/Los_Angeles', 
                         UserName='usuario@testlanding.com');

        Deudas__c RdDeudas = new Deudas__c();
        RdDeudas.TotalaPagar__c = 100.00;
        RdDeudas.MontodeLiquidacion__c   = 100.00;
        RdDeudas.DiasdePago__c  = 10.00; 
        RdDeudas.MontoPagoInicial__c = 100.00;
        RdDeudas.NegociadorAsignado__c  = null;
        RdDeudas.EstadodelaDeuda__c  = 'En Negociacion';
        RdDeudas.UltimoMontodeLiquidacion__c  = 50000;
        
        insert RdDeudas;

        SolicitudesDeFondos__c RdSolFondos = new SolicitudesDeFondos__c();
        RdSolFondos.Deuda__c = RdDeudas.id;      
   
        insert RdSolFondos;

        System.runAs(u1)
        {
          system.debug('+++ llego hasta RunAs');
          Conf_IdsDesarrollos__c objConf = new Conf_IdsDesarrollos__c();
          objConf.Name = 'PerfilAdministradorDeSistema';
          
          if(perfil!= null)
            objConf.Id__c = perfil.Id;
          insert  objConf;
          system.debug('+++confper '+objConf);
          ApexPages.StandardController sc = new ApexPages.StandardController(RdSolFondos);
          SolicitudDeFondo_ctr solFon = new SolicitudDeFondo_ctr(sc);
          system.debug('+++ llego al final de RunAs');
        }
        Test.stopTest();

  }
	

	
}