/*****************************************************************************************************
* Desarrollado por: RTD
* Autor:            Esteban Heredia (EH)
* Proyecto:         Colombia V
* Descripción:      Clase de prueba SchComisionesMensuales_sch y BchComisionesMensuales_bch         
*
* Cambios (Versiones)
* -------------------------------------
*           No.     fecha           Autor                       Descripción
*           -----   ----------      ------------------------    ---------------
* @version  1.0     29-Jul-2016     Esteban Heredia (EH)        Creación de la clase           
*******************************************************************************************************/

@isTest
private class SchComisionesMensuales_tst 
{
	
	public static Lead objCandidato;
	public static Sucursal__c objSucursal;
	public static RecursosHumanos__c objRecursoshumanos;
	public static Reparadora__c objReparadora;

	public static void createData()
	{
		objRecursoshumanos 						= TestCreaObjetos.CrearRHs(1,'test','test').get(0);
		objRecursoshumanos.Usuario__c			= UserInfo.getUserId();
		update objRecursoshumanos;
		objSucursal 							= new Sucursal__c();
		objSucursal.Name  						= 'Bogotá';
		insert objSucursal;
		objCandidato 							= TestCreaObjetos.CrearLeads(1).get(0);
		Id recordTypeId 						= Schema.SObjectType.Task.getRecordTypeInfosByName().get('Actividad de Ventas').getRecordTypeId();
		objReparadora							= TestCreaObjetos.CrearReparadoras(1,null,false).get(0);
		objReparadora.NegociadorAsignado__c		= objRecursoshumanos.id;
		Integer diasMesAnterior 				= date.daysInMonth(system.now().year(), system.now().month() - 2);
		objReparadora.FechaInicioPrograma__c	= Date.newInstance(system.now().year(), system.now().month() - 2, diasMesAnterior);
		objReparadora.BeneficioEmpleado__c		= false;
		objReparadora.NegociadorAsignado__c		= objRecursoshumanos.id;

		insert objReparadora;

	}
	
	@isTest static void test_method_one() 
	{
		createData();
		Test.startTest();
			SchComisionesMensuales_sch comisionesMensuales = new SchComisionesMensuales_sch();
			comisionesMensuales.execute(null);
		Test.stopTest();
		// Comprobamos q si creo el ingreso
		List<Reparadora__c>  lstReparadorasComp = [select Id,(SELECT Id FROM Ingresos__r WHERE FechaFacturacion__c = THIS_MONTH AND TipoIngreso__c = 'Mensualidad Colombia') 
												from Reparadora__c where Id =: objReparadora.Id];
		System.assertEquals(lstReparadorasComp.get(0).Ingresos__r.size(),1);
	}
}