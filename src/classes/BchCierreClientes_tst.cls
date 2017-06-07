/*******************************************************************************
Desarrollado por:   RTD
Autor:              Jeisson Hernandez
Proyecto:           Colombia III
Descripción:        Clase de prueba que probara la clase BchCierreClientes_bch del batch de cierre de clientes

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		----------                ---------------------------     
    1.0     10-Sep-2015		Jeisson Hernandez(JH)     Creación de la Clase.
*******************************************************************************/

@isTest
private class BchCierreClientes_tst 
{
	@isTest(seeAllData = true)
	static void test1() 
	{
		List <RecursosHumanos__c> lstRHEjecPremiun = TestCreaObjetos.CrearRHs(1,'Ejecutivo de Servicio al Cliente Colombia','Servicio al Cliente');
		lstRHEjecPremiun[0].EjecutivoPremium__c = true;
		update lstRHEjecPremiun;
		
		List <RecursosHumanos__c> lstNegociador = TestCreaObjetos.CrearRHs(1,'Negociador Colombia','');

		List <Lead> lstLead = TestCreaObjetos.CrearLeads(1);
		lstLead[0].AdeudoTotal__c = 39000000;
		lstLead[0].CaratulaApartadoMensual__c = 200000;
		lstLead[0].MontoDepositado__c = 199000;
		update lstLead;
		List <DeudaOportunidad__c> lstDeudasOp = TestCreaObjetos.CrearDeudasOportunidad(1,lstLead[0].Id,39000000, 'Citibank');
		
		System.debug('RH Creados: ' + lstRHEjecPremiun);
		System.debug('Lead Creados: ' + lstLead);
		System.debug('Deudas Opp Creadas: ' + lstDeudasOp);
		
		Test.startTest();
			String strQuery='';
			strQuery='Select o.id, o.CaratulaApartadoMensual__c, o.MontoDepositado__c, ' +
			' o.LastName, o.ApellidoM__c, o.PrimerNombre__c, SegundoNombre__c, PrimerApellido__c, SegundoApellido__c, '+
			' o.FechaNacimiento__c , o.Domicilio__c,' +
			' o.Departamento__c, o.Cedula__c, o.CiudadMunicipio__c, o.TelefonoCasa__c, ' +
			' o.TelefonoCelular__c, o.TelefonoTrabajo__c,o.Email, o.CaratulaAniosResidencia__c, ' +
			' o.PersonasCargo__c, o.TVPaga__c, o.TipoVivienda__c, o.EstadoCivil__c, ' +
			' o.NivelAcademico__c, o.CaratulaIngresoBruto__c, o.CaratulaIngresoNeto__c, ' +
			' o.CausaDejoPagar__c, o.Referencia__c,' +
			' o.FechaDeposito__c, o.VendedorAsignado__c, o.RefRecomendado__c, o.CaratulaDiaDeposito__c, ' +
			' o.Genero__c, o.EmpleoCaratula__c, o.BeneficioEmpleado__c, o.AdeudoTotal__c,o.FechaExpedicion__c, o.LugarExpedicion__c, o.TipoDocAfiliado__c ' +
			' From LEAD o Where o.ClienteCerrado__c = false And PorcentajeMontoDepositado__c >= 95 AND o.Id=\''+lstLead[0].Id+ '\'  ';		
			BchCierreClientes_bch bchCierreClientes = new BchCierreClientes_bch(strQuery);
			Id batchProcessId = Database.executeBatch(bchCierreClientes, 1);
		Test.stopTest();
	}

	@isTest(seeAllData = true)
	static void test2() 
	{
		List <RecursosHumanos__c> lstRHEjecNOPremiun = TestCreaObjetos.CrearRHs(1,'Ejecutivo de Servicio al Cliente Colombia','Servicio al Cliente');
		lstRHEjecNOPremiun[0].EjecutivoPremium__c = false;
		update lstRHEjecNOPremiun;
		
		List <RecursosHumanos__c> lstNegociador = TestCreaObjetos.CrearRHs(1,'Negociador Colombia','');

		List <Lead> lstLead = TestCreaObjetos.CrearLeads(1);
		lstLead[0].AdeudoTotal__c = 30000000;
		lstLead[0].CaratulaApartadoMensual__c = 200000;
		lstLead[0].MontoDepositado__c = 199000;
		update lstLead;
		List <DeudaOportunidad__c> lstDeudasOp = TestCreaObjetos.CrearDeudasOportunidad(1,lstLead[0].Id,30000000, 'Banco Bogota');
		
		System.debug('RH Creados: ' + lstRHEjecNOPremiun);
		System.debug('Lead Creados: ' + lstLead);
		System.debug('Deudas Opp Creadas: ' + lstDeudasOp);
		
		Test.startTest();
			String strQuery='';
			strQuery='Select o.id, o.CaratulaApartadoMensual__c, o.MontoDepositado__c, ' +
			' o.LastName, o.ApellidoM__c, o.PrimerNombre__c, SegundoNombre__c, PrimerApellido__c, SegundoApellido__c, '+
			' o.FechaNacimiento__c , o.Domicilio__c,' +
			' o.Departamento__c, o.Cedula__c, o.CiudadMunicipio__c, o.TelefonoCasa__c, ' +
			' o.TelefonoCelular__c, o.TelefonoTrabajo__c,o.Email, o.CaratulaAniosResidencia__c, ' +
			' o.PersonasCargo__c, o.TVPaga__c, o.TipoVivienda__c, o.EstadoCivil__c, ' +
			' o.NivelAcademico__c, o.CaratulaIngresoBruto__c, o.CaratulaIngresoNeto__c, ' +
			' o.CausaDejoPagar__c, o.Referencia__c,' +
			' o.FechaDeposito__c, o.VendedorAsignado__c, o.RefRecomendado__c, o.CaratulaDiaDeposito__c, ' +
			' o.Genero__c, o.EmpleoCaratula__c, o.BeneficioEmpleado__c, o.AdeudoTotal__c,o.FechaExpedicion__c, o.LugarExpedicion__c, o.TipoDocAfiliado__c ' +
			' From LEAD o Where o.ClienteCerrado__c = false And PorcentajeMontoDepositado__c >= 95 AND o.Id=\''+lstLead[0].Id+ '\'  ';		
			BchCierreClientes_bch bchCierreClientes = new BchCierreClientes_bch(strQuery);
			Id batchProcessId = Database.executeBatch(bchCierreClientes, 1);
		Test.stopTest();
	}

}