/*******************************************************************************
Desarrollado por:   RTD
Autor:              Jeisson Hernandez
Proyecto:           Colombia III
Descripción:        Clase de prueba que probara la clase BchAsignacionOportunidades_bch del batch de Asignacion de Oportunidades

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		----------                ---------------------------     
    1.0     09-Nov-2015		Jeisson Hernandez(JH)     Creación de la Clase.
*******************************************************************************/

@isTest
private class BchAsignacionOportunidades_tst 
{
	@isTest
	static void testProceso1()
	{
		System.debug('@ Incio testProceso1 ');
		TestCreaObjetos.crearNotificacionTrabajosProgramados('BchAsignacionOportunidades_bch','Test Informe Asignación de Oportunidades','testbach@test.com');
		TestCreaObjetos.crearConfPersPerfilesAsignacionLeadsLandingPages('Administrador del sistema');
		TestCreaObjetos.crearConfPersPerfilesAsignacionVendedorAsignado('Asesor de Reparación de Deuda');
		List<Notificacion_Trabajos_Programados__c> lstConfNotBatch = Notificacion_Trabajos_Programados__c.getall().values();
		System.debug('@ Conf Notificacion Batch: ' + lstConfNotBatch);
		
		Sucursal__c objSuc1 = new Sucursal__c();
		objSuc1.Name = 'Bogotá';
		insert objSuc1;
		
		System.debug('@ Sucursal: ' + objSuc1);
		
		Empresa__c objEmpresa = new Empresa__c();
		objEmpresa.Name = 'Empresa 1 ';
		insert objEmpresa;
		
		System.debug('@ Empresa: ' + objEmpresa);
		
		List <User> lstUsuariosVendedores = [Select Id,Name,Profile.Name,IsActive
											 From User 
											 Where IsActive = true
											 And Profile.Name IN ('Team Leader Ventas','Asesor de Reparación de Deuda')
											 Limit 1];
		
		System.debug('@ lstUsuariosVendedores: ' + lstUsuariosVendedores);

		RecursosHumanos__c objUsuarioLog = new RecursosHumanos__c();
		objUsuarioLog.Name = 'Usuario Log';
		objUsuarioLog.SueldoFijo__c = 100.00;
		objUsuarioLog.Area__c = 'Procesos y TI';
		objUsuarioLog.Usuario__c = UserInfo.getUserId();
		objUsuarioLog.Sucursal__c=objSuc1.id;
		objUsuarioLog.Empresa__c = objEmpresa.id;
		objUsuarioLog.UnidadNegocio__c = 'RTD Colombia';
		objUsuarioLog.Status__c='Activo';
		insert objUsuarioLog;
		
		RecursosHumanos__c objVend1 = new RecursosHumanos__c();
		objVend1.Name = 'Vendedor 1';
		objVend1.SueldoFijo__c = 100.00;
		objVend1.Area__c = 'Ventas';
		objVend1.Usuario__c = lstUsuariosVendedores[0].Id;
		objVend1.Sucursal__c=objSuc1.id;
		objVend1.Empresa__c = objEmpresa.id;
		objVend1.UnidadNegocio__c = 'RTD Colombia';
		objVend1.Status__c='Activo';
		//Campos para Ventas
		objVend1.AsignarOportunidades__c = true;
		objVend1.FechaAsignarOportunidades__c = Date.today().toStartOfMonth();
		objVend1.TopeOportunidadesMensual__c = 1;
		objVend1.MD4__c = true;
		insert objVend1;
		
		System.debug('@ Vendedor 1: ' + objVend1);
		
		List<Lead> lstleads = new List<Lead>();
		Date dtFechahoy = Date.today();
		Date dtFechaNac = Date.newInstance(1988, 7, 21);
		
		for(Integer i=0;i < 1; i++)
		{
			Lead objLead = new Lead();
			objLead.FirstName = 'Lead ' + i;
			objLead.LastName = 'Apellido Lead ' + i;
			objLead.PrimerApellido__c = 'Apellido Lead ' + i;
			objLead.SegundoApellido__c = '2do Apellido Lead ' + i;
			objLead.PrimerNombre__c ='Lead ' + i;
			objLead.FechaNacimiento__c = dtFechaNac;
			objLead.Domicilio__c = 'Domicilo lead ' + i;
			objLead.Departamento__c ='Bogotá';
			objLead.CiudadMunicipio__c = '1';
			objLead.Cedula__c = 'CC'+i;
			objLead.TelefonoCasa__c = ''+i+ (i+1) + (i+2) ;
			objLead.TelefonoCelular__c = '300 '+i+ (i+1) + (i+2);
			objLead.TelefonoTrabajo__c = ''+i+ (i+1) + (i+2);
			objLead.Genero__c = 'Masculino';
			objLead.Ocupacion__c = 'Empleado IP';
			objLead.Email = 'lead'+i+'@lead.com';
			objLead.BeneficioEmpleado__c = false;
			objLead.Status='Lead';
			objLead.DeudaWeb__c = 45000000;
			lstleads.add(objLead);
		}
		insert lstleads;
		System.debug('@ Test Leads: ' + lstleads);
		Test.startTest();		
			String strQuery='';
			strQuery='SELECT Id, DeudaWeb__c, AsignacionSucursal__c FROM Lead WHERE Status = \'Lead\' AND VendedorAsignado__c = NULL';
			BchAsignacionOportunidades_bch objBchAsignacionOportunidades = new BchAsignacionOportunidades_bch(strQuery);
			Id batchProcessId = Database.executeBatch(objBchAsignacionOportunidades, 1);
		Test.stopTest();
	}

	@isTest
	static void testProceso4()
	{
		System.debug('@ Incio testProceso4 ');
		TestCreaObjetos.crearNotificacionTrabajosProgramados('BchAsignacionOportunidades_bch','Test Informe Asignación de Oportunidades','testbach@test.com');
		TestCreaObjetos.crearConfPersPerfilesAsignacionLeadsLandingPages('Administrador del sistema');
		TestCreaObjetos.crearConfPersPerfilesAsignacionVendedorAsignado('Asesor de Reparación de Deuda');
		List<Notificacion_Trabajos_Programados__c> lstConfNotBatch = Notificacion_Trabajos_Programados__c.getall().values();
		System.debug('@ Conf Notificacion Batch: ' + lstConfNotBatch);
		
		Sucursal__c objSuc1 = new Sucursal__c();
		objSuc1.Name = 'Bogotá';
		insert objSuc1;
		
		Sucursal__c objSuc2 = new Sucursal__c();
		objSuc1.Name = 'Cali';
		insert objSuc2;

		System.debug('@ Sucursal: ' + objSuc1);
		System.debug('@ Sucursal: ' + objSuc2);
		
		Empresa__c objEmpresa = new Empresa__c();
		objEmpresa.Name = 'Empresa 1 ';
		insert objEmpresa;
		
		System.debug('@ Empresa: ' + objEmpresa);
		
		List <User> lstUsuariosVendedores = [Select Id,Name,Profile.Name,IsActive
											 From User 
											 Where IsActive = true
											 And Profile.Name IN ('Team Leader Ventas','Asesor de Reparación de Deuda')
											 Limit 1];
		
		System.debug('@ lstUsuariosVendedores: ' + lstUsuariosVendedores);

		RecursosHumanos__c objUsuarioLog = new RecursosHumanos__c();
		objUsuarioLog.Name = 'Usuario Log';
		objUsuarioLog.SueldoFijo__c = 100.00;
		objUsuarioLog.Area__c = 'Procesos y TI';
		objUsuarioLog.Usuario__c = UserInfo.getUserId();
		objUsuarioLog.Sucursal__c=objSuc1.id;
		objUsuarioLog.Empresa__c = objEmpresa.id;
		objUsuarioLog.UnidadNegocio__c = 'RTD Colombia';
		objUsuarioLog.Status__c='Activo';
		insert objUsuarioLog;
		
		RecursosHumanos__c objVend1 = new RecursosHumanos__c();
		objVend1.Name = 'Vendedor 1';
		objVend1.SueldoFijo__c = 100.00;
		objVend1.Area__c = 'Ventas';
		objVend1.Usuario__c = lstUsuariosVendedores[0].Id;
		objVend1.Sucursal__c=objSuc1.id;
		objVend1.Empresa__c = objEmpresa.id;
		objVend1.UnidadNegocio__c = 'RTD Colombia';
		objVend1.Status__c='Activo';
		//Campos para Ventas
		objVend1.AsignarOportunidades__c = true;
		objVend1.FechaAsignarOportunidades__c = Date.today().toStartOfMonth();
		objVend1.TopeOportunidadesMensual__c = 1;
		objVend1.MD4__c = true;
		insert objVend1;
		
		System.debug('@ Vendedor 1: ' + objVend1);
		
		List<Lead> lstleads = new List<Lead>();
		Date dtFechahoy = Date.today();
		Date dtFechaNac = Date.newInstance(1988, 7, 21);
		
		for(Integer i=0;i < 1; i++)
		{
			Lead objLead = new Lead();
			objLead.FirstName = 'Lead ' + i;
			objLead.LastName = 'Apellido Lead ' + i;
			objLead.PrimerApellido__c = 'Apellido Lead ' + i;
			objLead.SegundoApellido__c = '2do Apellido Lead ' + i;
			objLead.PrimerNombre__c ='Lead ' + i;
			objLead.FechaNacimiento__c = dtFechaNac;
			objLead.Domicilio__c = 'Domicilo lead ' + i;
			objLead.Departamento__c ='Bogotá';
			objLead.CiudadMunicipio__c = '1';
			objLead.Cedula__c = 'CC'+i;
			objLead.TelefonoCasa__c = ''+i+ (i+1) + (i+2) ;
			objLead.TelefonoCelular__c = '300 '+i+ (i+1) + (i+2);
			objLead.TelefonoTrabajo__c = ''+i+ (i+1) + (i+2);
			objLead.Genero__c = 'Masculino';
			objLead.Ocupacion__c = 'Empleado IP';
			objLead.Email = 'lead'+i+'@lead.com';
			objLead.BeneficioEmpleado__c = false;
			objLead.Status='Lead';
			objLead.DeudaWeb__c = 45000000;
			objLead.AsignacionSucursal__c = objSuc2.Id;
			lstleads.add(objLead);
		}
		insert lstleads;
		System.debug('@ Test Leads: ' + lstleads);
		Test.startTest();		
			String strQuery='';
			strQuery='SELECT Id, DeudaWeb__c, AsignacionSucursal__c FROM Lead WHERE Status = \'Lead\' AND VendedorAsignado__c = NULL';
			BchAsignacionOportunidades_bch objBchAsignacionOportunidades = new BchAsignacionOportunidades_bch(strQuery);
			Id batchProcessId = Database.executeBatch(objBchAsignacionOportunidades, 1);
		Test.stopTest();
		System.debug('@ Fin testProceso4 ');
	}
	
	@isTest
	static void testProceso5()
	{
		System.debug('@ Incio testProceso5 ');
		TestCreaObjetos.crearNotificacionTrabajosProgramados('BchAsignacionOportunidades_bch','Test Informe Asignación de Oportunidades','testbach@test.com');
		TestCreaObjetos.crearConfPersPerfilesAsignacionLeadsLandingPages('Administrador del sistema');
		TestCreaObjetos.crearConfPersPerfilesAsignacionVendedorAsignado('Asesor de Reparación de Deuda');
		List<Notificacion_Trabajos_Programados__c> lstConfNotBatch = Notificacion_Trabajos_Programados__c.getall().values();
		System.debug('@ Conf Notificacion Batch: ' + lstConfNotBatch);
		
		Sucursal__c objSuc1 = new Sucursal__c();
		objSuc1.Name = 'Bogotá';
		insert objSuc1;
		
		Sucursal__c objSuc2 = new Sucursal__c();
		objSuc1.Name = 'Cali';
		insert objSuc2;

		System.debug('@ Sucursal: ' + objSuc1);
		System.debug('@ Sucursal: ' + objSuc2);
		
		Empresa__c objEmpresa = new Empresa__c();
		objEmpresa.Name = 'Empresa 1 ';
		insert objEmpresa;
		
		System.debug('@ Empresa: ' + objEmpresa);
		
		List <User> lstUsuariosVendedores = [Select Id,Name,Profile.Name,IsActive
											 From User 
											 Where IsActive = true
											 And Profile.Name IN ('Team Leader Ventas','Asesor de Reparación de Deuda')
											 Limit 1];
		
		System.debug('@ lstUsuariosVendedores: ' + lstUsuariosVendedores);

		RecursosHumanos__c objUsuarioLog = new RecursosHumanos__c();
		objUsuarioLog.Name = 'Usuario Log';
		objUsuarioLog.SueldoFijo__c = 100.00;
		objUsuarioLog.Area__c = 'Procesos y TI';
		objUsuarioLog.Usuario__c = UserInfo.getUserId();
		objUsuarioLog.Sucursal__c=objSuc1.id;
		objUsuarioLog.Empresa__c = objEmpresa.id;
		objUsuarioLog.UnidadNegocio__c = 'RTD Colombia';
		objUsuarioLog.Status__c='Activo';
		insert objUsuarioLog;
		
		RecursosHumanos__c objVend1 = new RecursosHumanos__c();
		objVend1.Name = 'Vendedor 1';
		objVend1.SueldoFijo__c = 100.00;
		objVend1.Area__c = 'Ventas';
		objVend1.Usuario__c = lstUsuariosVendedores[0].Id;
		objVend1.Sucursal__c=objSuc1.id;
		objVend1.Empresa__c = objEmpresa.id;
		objVend1.UnidadNegocio__c = 'RTD Colombia';
		objVend1.Status__c='Activo';
		//Campos para Ventas
		objVend1.AsignarOportunidades__c = true;
		objVend1.FechaAsignarOportunidades__c = Date.today().toStartOfMonth();
		objVend1.TopeOportunidadesMensual__c = 1;
		objVend1.MD4__c = false;
		insert objVend1;
		
		System.debug('@ Vendedor 1: ' + objVend1);
		
		List<Lead> lstleads = new List<Lead>();
		Date dtFechahoy = Date.today();
		Date dtFechaNac = Date.newInstance(1988, 7, 21);
		
		for(Integer i=0;i < 1; i++)
		{
			Lead objLead = new Lead();
			objLead.FirstName = 'Lead ' + i;
			objLead.LastName = 'Apellido Lead ' + i;
			objLead.PrimerApellido__c = 'Apellido Lead ' + i;
			objLead.SegundoApellido__c = '2do Apellido Lead ' + i;
			objLead.PrimerNombre__c ='Lead ' + i;
			objLead.FechaNacimiento__c = dtFechaNac;
			objLead.Domicilio__c = 'Domicilo lead ' + i;
			objLead.Departamento__c ='Bogotá';
			objLead.CiudadMunicipio__c = '1';
			objLead.Cedula__c = 'CC'+i;
			objLead.TelefonoCasa__c = ''+i+ (i+1) + (i+2) ;
			objLead.TelefonoCelular__c = '300 '+i+ (i+1) + (i+2);
			objLead.TelefonoTrabajo__c = ''+i+ (i+1) + (i+2);
			objLead.Genero__c = 'Masculino';
			objLead.Ocupacion__c = 'Empleado IP';
			objLead.Email = 'lead'+i+'@lead.com';
			objLead.BeneficioEmpleado__c = false;
			objLead.Status='Lead';
			objLead.DeudaWeb__c = 10000000;
			objLead.AsignacionSucursal__c = objSuc2.Id;
			lstleads.add(objLead);
		}
		insert lstleads;
		System.debug('@ Test Leads: ' + lstleads);
		Test.startTest();		
			String strQuery='';
			strQuery='SELECT Id, DeudaWeb__c, AsignacionSucursal__c FROM Lead WHERE Status = \'Lead\' AND VendedorAsignado__c = NULL';
			BchAsignacionOportunidades_bch objBchAsignacionOportunidades = new BchAsignacionOportunidades_bch(strQuery);
			Id batchProcessId = Database.executeBatch(objBchAsignacionOportunidades, 1);
		Test.stopTest();
		System.debug('@ Fin testProceso5 ');
	}	

	@isTest
	static void testProceso6()
	{
		System.debug('@ Incio testProceso6 ');
		TestCreaObjetos.crearNotificacionTrabajosProgramados('BchAsignacionOportunidades_bch','Test Informe Asignación de Oportunidades','testbach@test.com');
		TestCreaObjetos.crearConfPersPerfilesAsignacionLeadsLandingPages('Administrador del sistema');
		TestCreaObjetos.crearConfPersPerfilesAsignacionVendedorAsignado('Asesor de Reparación de Deuda');
		List<Notificacion_Trabajos_Programados__c> lstConfNotBatch = Notificacion_Trabajos_Programados__c.getall().values();
		System.debug('@ Conf Notificacion Batch: ' + lstConfNotBatch);
		
		Sucursal__c objSuc1 = new Sucursal__c();
		objSuc1.Name = 'Bogotá';
		insert objSuc1;
		
		System.debug('@ Sucursal 1: ' + objSuc1);
		
		Empresa__c objEmpresa = new Empresa__c();
		objEmpresa.Name = 'Empresa 1 ';
		insert objEmpresa;
		
		System.debug('@ Empresa: ' + objEmpresa);
		
		List <User> lstUsuariosVendedores = [Select Id,Name,Profile.Name,IsActive
											 From User 
											 Where IsActive = true
											 And Profile.Name IN ('Team Leader Ventas','Asesor de Reparación de Deuda')
											 Limit 1];
		
		System.debug('@ lstUsuariosVendedores: ' + lstUsuariosVendedores);

		RecursosHumanos__c objUsuarioLog = new RecursosHumanos__c();
		objUsuarioLog.Name = 'Usuario Log';
		objUsuarioLog.SueldoFijo__c = 100.00;
		objUsuarioLog.Area__c = 'Procesos y TI';
		objUsuarioLog.Usuario__c = UserInfo.getUserId();
		objUsuarioLog.Sucursal__c=objSuc1.id;
		objUsuarioLog.Empresa__c = objEmpresa.id;
		objUsuarioLog.UnidadNegocio__c = 'RTD Colombia';
		objUsuarioLog.Status__c='Activo';
		insert objUsuarioLog;
		
		RecursosHumanos__c objVend1 = new RecursosHumanos__c();
		objVend1.Name = 'Vendedor 1';
		objVend1.SueldoFijo__c = 100.00;
		objVend1.Area__c = 'Ventas';
		objVend1.Usuario__c = lstUsuariosVendedores[0].Id;
		objVend1.Sucursal__c=objSuc1.id;
		objVend1.Empresa__c = objEmpresa.id;
		objVend1.UnidadNegocio__c = 'RTD Colombia';
		objVend1.Status__c='Activo';
		//Campos para Ventas
		objVend1.AsignarOportunidades__c = true;
		objVend1.FechaAsignarOportunidades__c = Date.today().toStartOfMonth();
		objVend1.TopeOportunidadesMensual__c = 1;
		objVend1.MD4__c = true;
		insert objVend1;
		
		System.debug('@ Vendedor 1: ' + objVend1);
		
		List<Lead> lstleads = new List<Lead>();
		Date dtFechahoy = Date.today();
		Date dtFechaNac = Date.newInstance(1988, 7, 21);
		
		for(Integer i=0;i < 2; i++)
		{
			Lead objLead = new Lead();
			objLead.FirstName = 'Lead ' + i;
			objLead.LastName = 'Apellido Lead ' + i;
			objLead.PrimerApellido__c = 'Apellido Lead ' + i;
			objLead.SegundoApellido__c = '2do Apellido Lead ' + i;
			objLead.PrimerNombre__c ='Lead ' + i;
			objLead.FechaNacimiento__c = dtFechaNac;
			objLead.Domicilio__c = 'Domicilo lead ' + i;
			objLead.Departamento__c ='Bogotá';
			objLead.CiudadMunicipio__c = '1';
			objLead.Cedula__c = 'CC'+i;
			objLead.TelefonoCasa__c = ''+i+ (i+1) + (i+2) ;
			objLead.TelefonoCelular__c = '300 '+i+ (i+1) + (i+2);
			objLead.TelefonoTrabajo__c = ''+i+ (i+1) + (i+2);
			objLead.Genero__c = 'Masculino';
			objLead.Ocupacion__c = 'Empleado IP';
			objLead.Email = 'lead'+i+'@lead.com';
			objLead.BeneficioEmpleado__c = false;
			objLead.Status='Lead';
			objLead.DeudaWeb__c = 60000000;
			objLead.AsignacionSucursal__c = objSuc1.Id;
			lstleads.add(objLead);
		}
		insert lstleads;
		System.debug('@ Test Leads: ' + lstleads);
		
		lstleads[0].VendedorAsignado__c = objVend1.Id;
		update lstleads;
		
		Test.startTest();		
			String strQuery='';
			strQuery='SELECT Id, DeudaWeb__c, AsignacionSucursal__c FROM Lead WHERE Status = \'Lead\' AND VendedorAsignado__c = NULL';
			BchAsignacionOportunidades_bch objBchAsignacionOportunidades = new BchAsignacionOportunidades_bch(strQuery);
			Id batchProcessId = Database.executeBatch(objBchAsignacionOportunidades, 1);
		Test.stopTest();
		System.debug('@ Fin testProceso6 ');
	}	

	@isTest
	static void testProceso8()
	{
		System.debug('@ Incio testProceso8 ');
		TestCreaObjetos.crearNotificacionTrabajosProgramados('BchAsignacionOportunidades_bch','Test Informe Asignación de Oportunidades','testbach@test.com');
		TestCreaObjetos.crearConfPersPerfilesAsignacionLeadsLandingPages('Administrador del sistema');
		TestCreaObjetos.crearConfPersPerfilesAsignacionVendedorAsignado('Asesor de Reparación de Deuda');
		List<Notificacion_Trabajos_Programados__c> lstConfNotBatch = Notificacion_Trabajos_Programados__c.getall().values();
		System.debug('@ Conf Notificacion Batch: ' + lstConfNotBatch);
		
		Sucursal__c objSuc1 = new Sucursal__c();
		objSuc1.Name = 'Bogotá';
		insert objSuc1;
		
		Sucursal__c objSuc2 = new Sucursal__c();
		objSuc1.Name = 'Cali';
		insert objSuc2;

		System.debug('@ Sucursal 1: ' + objSuc1);
		System.debug('@ Sucursal 2: ' + objSuc2);
		
		Empresa__c objEmpresa = new Empresa__c();
		objEmpresa.Name = 'Empresa 1 ';
		insert objEmpresa;
		
		System.debug('@ Empresa: ' + objEmpresa);
		
		List <User> lstUsuariosVendedores = [Select Id,Name,Profile.Name,IsActive
											 From User 
											 Where IsActive = true
											 And Profile.Name IN ('Team Leader Ventas','Asesor de Reparación de Deuda')
											 Limit 1];
		
		System.debug('@ lstUsuariosVendedores: ' + lstUsuariosVendedores);

		RecursosHumanos__c objUsuarioLog = new RecursosHumanos__c();
		objUsuarioLog.Name = 'Usuario Log';
		objUsuarioLog.SueldoFijo__c = 100.00;
		objUsuarioLog.Area__c = 'Procesos y TI';
		objUsuarioLog.Usuario__c = UserInfo.getUserId();
		objUsuarioLog.Sucursal__c=objSuc1.id;
		objUsuarioLog.Empresa__c = objEmpresa.id;
		objUsuarioLog.UnidadNegocio__c = 'RTD Colombia';
		objUsuarioLog.Status__c='Activo';
		insert objUsuarioLog;
		
		RecursosHumanos__c objVend1 = new RecursosHumanos__c();
		objVend1.Name = 'Vendedor 1';
		objVend1.SueldoFijo__c = 100.00;
		objVend1.Area__c = 'Ventas';
		objVend1.Usuario__c = lstUsuariosVendedores[0].Id;
		objVend1.Sucursal__c=objSuc1.id;
		objVend1.Empresa__c = objEmpresa.id;
		objVend1.UnidadNegocio__c = 'RTD Colombia';
		objVend1.Status__c='Activo';
		//Campos para Ventas
		objVend1.AsignarOportunidades__c = true;
		objVend1.FechaAsignarOportunidades__c = Date.today().toStartOfMonth();
		objVend1.TopeOportunidadesMensual__c = 1;
		objVend1.MD4__c = true;
		insert objVend1;
		
		System.debug('@ Vendedor 1: ' + objVend1);
		
		List<Lead> lstleads = new List<Lead>();
		Date dtFechahoy = Date.today();
		Date dtFechaNac = Date.newInstance(1988, 7, 21);
		
		for(Integer i=0;i < 2; i++)
		{
			Lead objLead = new Lead();
			objLead.FirstName = 'Lead ' + i;
			objLead.LastName = 'Apellido Lead ' + i;
			objLead.PrimerApellido__c = 'Apellido Lead ' + i;
			objLead.SegundoApellido__c = '2do Apellido Lead ' + i;
			objLead.PrimerNombre__c ='Lead ' + i;
			objLead.FechaNacimiento__c = dtFechaNac;
			objLead.Domicilio__c = 'Domicilo lead ' + i;
			objLead.Departamento__c ='Bogotá';
			objLead.CiudadMunicipio__c = '1';
			objLead.Cedula__c = 'CC'+i;
			objLead.TelefonoCasa__c = ''+i+ (i+1) + (i+2) ;
			objLead.TelefonoCelular__c = '300 '+i+ (i+1) + (i+2);
			objLead.TelefonoTrabajo__c = ''+i+ (i+1) + (i+2);
			objLead.Genero__c = 'Masculino';
			objLead.Ocupacion__c = 'Empleado IP';
			objLead.Email = 'lead'+i+'@lead.com';
			objLead.BeneficioEmpleado__c = false;
			objLead.Status='Lead';
			objLead.DeudaWeb__c = 60000000;
			objLead.AsignacionSucursal__c = objSuc2.Id;
			lstleads.add(objLead);
		}
		insert lstleads;
		System.debug('@ Test Leads: ' + lstleads);
		
		lstleads[0].VendedorAsignado__c = objVend1.Id;
		update lstleads;
		
		Test.startTest();		
			String strQuery='';
			strQuery='SELECT Id, DeudaWeb__c, AsignacionSucursal__c FROM Lead WHERE Status = \'Lead\' AND VendedorAsignado__c = NULL';
			BchAsignacionOportunidades_bch objBchAsignacionOportunidades = new BchAsignacionOportunidades_bch(strQuery);
			Id batchProcessId = Database.executeBatch(objBchAsignacionOportunidades, 1);
		Test.stopTest();
		System.debug('@ Fin testProceso8 ');
	}	

	@isTest
	static void testProceso9()
	{
		System.debug('@ Incio testProceso9 ');
		TestCreaObjetos.crearNotificacionTrabajosProgramados('BchAsignacionOportunidades_bch','Test Informe Asignación de Oportunidades','testbach@test.com');
		TestCreaObjetos.crearConfPersPerfilesAsignacionLeadsLandingPages('Administrador del sistema');
		TestCreaObjetos.crearConfPersPerfilesAsignacionVendedorAsignado('Asesor de Reparación de Deuda');
		List<Notificacion_Trabajos_Programados__c> lstConfNotBatch = Notificacion_Trabajos_Programados__c.getall().values();
		System.debug('@ Conf Notificacion Batch: ' + lstConfNotBatch);
		
		Sucursal__c objSuc1 = new Sucursal__c();
		objSuc1.Name = 'Bogotá';
		insert objSuc1;
		
		Sucursal__c objSuc2 = new Sucursal__c();
		objSuc1.Name = 'Cali';
		insert objSuc2;

		System.debug('@ Sucursal 1: ' + objSuc1);
		System.debug('@ Sucursal 2: ' + objSuc2);
		
		Empresa__c objEmpresa = new Empresa__c();
		objEmpresa.Name = 'Empresa 1 ';
		insert objEmpresa;
		
		System.debug('@ Empresa: ' + objEmpresa);
		
		List <User> lstUsuariosVendedores = [Select Id,Name,Profile.Name,IsActive
											 From User 
											 Where IsActive = true
											 And Profile.Name IN ('Team Leader Ventas','Asesor de Reparación de Deuda')
											 Limit 1];
		
		System.debug('@ lstUsuariosVendedores: ' + lstUsuariosVendedores);

		RecursosHumanos__c objUsuarioLog = new RecursosHumanos__c();
		objUsuarioLog.Name = 'Usuario Log';
		objUsuarioLog.SueldoFijo__c = 100.00;
		objUsuarioLog.Area__c = 'Procesos y TI';
		objUsuarioLog.Usuario__c = UserInfo.getUserId();
		objUsuarioLog.Sucursal__c=objSuc1.id;
		objUsuarioLog.Empresa__c = objEmpresa.id;
		objUsuarioLog.UnidadNegocio__c = 'RTD Colombia';
		objUsuarioLog.Status__c='Activo';
		insert objUsuarioLog;
		
		RecursosHumanos__c objVend1 = new RecursosHumanos__c();
		objVend1.Name = 'Vendedor 1';
		objVend1.SueldoFijo__c = 100.00;
		objVend1.Area__c = 'Ventas';
		objVend1.Usuario__c = lstUsuariosVendedores[0].Id;
		objVend1.Sucursal__c=objSuc1.id;
		objVend1.Empresa__c = objEmpresa.id;
		objVend1.UnidadNegocio__c = 'RTD Colombia';
		objVend1.Status__c='Activo';
		//Campos para Ventas
		objVend1.AsignarOportunidades__c = true;
		objVend1.FechaAsignarOportunidades__c = Date.today().toStartOfMonth();
		objVend1.TopeOportunidadesMensual__c = 1;
		objVend1.MD4__c = false;
		insert objVend1;
		
		System.debug('@ Vendedor 1: ' + objVend1);
		
		List<Lead> lstleads = new List<Lead>();
		Date dtFechahoy = Date.today();
		Date dtFechaNac = Date.newInstance(1988, 7, 21);
		
		for(Integer i=0;i < 2; i++)
		{
			Lead objLead = new Lead();
			objLead.FirstName = 'Lead ' + i;
			objLead.LastName = 'Apellido Lead ' + i;
			objLead.PrimerApellido__c = 'Apellido Lead ' + i;
			objLead.SegundoApellido__c = '2do Apellido Lead ' + i;
			objLead.PrimerNombre__c ='Lead ' + i;
			objLead.FechaNacimiento__c = dtFechaNac;
			objLead.Domicilio__c = 'Domicilo lead ' + i;
			objLead.Departamento__c ='Bogotá';
			objLead.CiudadMunicipio__c = '1';
			objLead.Cedula__c = 'CC'+i;
			objLead.TelefonoCasa__c = ''+i+ (i+1) + (i+2) ;
			objLead.TelefonoCelular__c = '300 '+i+ (i+1) + (i+2);
			objLead.TelefonoTrabajo__c = ''+i+ (i+1) + (i+2);
			objLead.Genero__c = 'Masculino';
			objLead.Ocupacion__c = 'Empleado IP';
			objLead.Email = 'lead'+i+'@lead.com';
			objLead.BeneficioEmpleado__c = false;
			objLead.Status='Lead';
			objLead.DeudaWeb__c = 10000000;
			objLead.AsignacionSucursal__c = objSuc2.Id;
			lstleads.add(objLead);
		}
		insert lstleads;
		System.debug('@ Test Leads: ' + lstleads);
		
		lstleads[0].VendedorAsignado__c = objVend1.Id;
		update lstleads;
		
		Test.startTest();		
			String strQuery='';
			strQuery='SELECT Id, DeudaWeb__c, AsignacionSucursal__c FROM Lead WHERE Status = \'Lead\' AND VendedorAsignado__c = NULL';
			BchAsignacionOportunidades_bch objBchAsignacionOportunidades = new BchAsignacionOportunidades_bch(strQuery);
			Id batchProcessId = Database.executeBatch(objBchAsignacionOportunidades, 1);
		Test.stopTest();
		System.debug('@ Fin testProceso9 ');
	}	
			
}