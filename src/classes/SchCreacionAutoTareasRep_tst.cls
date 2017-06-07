/*****************************************************************************************************
* Desarrollado por: RTD
* Autor:            Esteban Heredia (EH)
* Proyecto:         Colombia IV
* Descripción:      Clase de prueba para SchCreacionAutoTareasRep_sch             
*
* Cambios (Versiones)
* -------------------------------------
*           No.     fecha          	Autor 		               	Descripción
*           -----   ----------      ------------------------   	---------------
* @version  1.0     25-Abr-2016     Esteban Heredia (EH)        Creación de la clase           
*******************************************************************************************************/

@isTest
private class SchCreacionAutoTareasRep_tst 
{
	public static Task objTarea;
	public static Task objTarea2;
	public static Lead objCandidato;
	public static Sucursal__c objSucursal;
	public static RecursosHumanos__c objRecursoshumanos;
	public static Reparadora__c objReparadora;

	public static void createData()
	{
		objRecursoshumanos 							= TestCreaObjetos.CrearRHs(1,'test','test').get(0);
		objRecursoshumanos.Usuario__c				= UserInfo.getUserId();
		update objRecursoshumanos;
		objSucursal 								= new Sucursal__c();
		objSucursal.Name  							= 'Bogotá';
		insert objSucursal;
		objCandidato 								= TestCreaObjetos.CrearLeads(1).get(0);
		Id recordTypeId 							= Schema.SObjectType.Task.getRecordTypeInfosByName().get('Actividad de Ventas').getRecordTypeId();
		objReparadora								= TestCreaObjetos.CrearReparadoras(1,null,true).get(0);
		objReparadora.NegociadorAsignado__c			= objRecursoshumanos.id;
		objReparadora.CreadaTareaPostVenta__c		= false;
		objReparadora.FechaInicioPrograma__c		= system.today().addDays(-45);
		objReparadora.EjecutivoAtencionClientes__c	= objRecursoshumanos.id;
		update objReparadora;
		objTarea 									= TestCreaObjetos.CrearTareas(1, objCandidato.Id, null, recordTypeId, true).get(0);
		objTarea2 									= TestCreaObjetos.CrearTareas(1, null, objReparadora.id, recordTypeId, true).get(0);

	}
	
	@isTest static void test_method_one()
	{
		createData();
		Test.startTest();
			SchCreacionAutoTareasRep_sch creacionAutoTareasRep = new SchCreacionAutoTareasRep_sch();
			creacionAutoTareasRep.execute(null);
		Test.stopTest();
	}
	
	// Caso para no crear nínguna tarea
	@isTest static void test_method_two() 
	{
		createData();
		Id recordTypeId   = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Actividad llamada en atraso').getRecordTypeId();
		objTarea2.Subject = 'Llamada por 30 días sin Contacto o Deposito';
		objTarea2.recordTypeId = recordTypeId;
		update objTarea2;
		objReparadora.FechaUltimoContacto__c = system.today().addDays(-30);
		update	objReparadora;
		Test.startTest();
			SchCreacionAutoTareasRep_sch creacionAutoTareasRep = new SchCreacionAutoTareasRep_sch();
			creacionAutoTareasRep.execute(null);
		Test.stopTest();
	}

	// Caso para  crear  tarea por 30 días sin contacto o deposito
	@isTest static void test_method_three() 
	{
		createData();
		objReparadora.FechaUltimoContacto__c = system.today().addDays(-30);
		update	objReparadora;
		Test.startTest();
			SchCreacionAutoTareasRep_sch creacionAutoTareasRep = new SchCreacionAutoTareasRep_sch();
			creacionAutoTareasRep.execute(null);
		Test.stopTest();
	}

	// Caso para  crear  tarea por 60 días sin contacto o deposito
	@isTest static void test_method_four() 
	{
		createData();
		objReparadora.FechaUltimoContacto__c = system.today().addDays(-60);
		update	objReparadora;
		Test.startTest();
			SchCreacionAutoTareasRep_sch creacionAutoTareasRep = new SchCreacionAutoTareasRep_sch();
			creacionAutoTareasRep.execute(null);
		Test.stopTest();
	}

	// Caso para  crear  tarea por 90 días sin contacto o deposito
	@isTest static void test_method_five() 
	{
		createData();
		objReparadora.FechaUltimoContacto__c = system.today().addDays(-90);
		update	objReparadora;
		Test.startTest();
			SchCreacionAutoTareasRep_sch creacionAutoTareasRep = new SchCreacionAutoTareasRep_sch();
			creacionAutoTareasRep.execute(null);
		Test.stopTest();
	}
}