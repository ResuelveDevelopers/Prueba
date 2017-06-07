/********************************************************************************************************
Desarrollado por:   Resuelve
Autor:              Angela Munévar(AM)
Proyecto:           Resuelve tu Deuda
Descripción:        Clase de prueba del objeto Solicitud_Fondeos__c

Cambios (Versiones)
--------------------------------------------------------------------------------------------------------
    No.     Fecha               Autor                       Descripción
    ---     -----------         ------------------------    --------------------------      
    1.0     20-Abr-2016         Angela Munévar(AM)          Creación de la Clase de prueba
********************************************************************************************************/
@isTest
private class TriggerSolicitudDeFondeo_tst {
	
	public static List<Account> lstCuenta;
	public static List<Reparadora__c> lstReparadora;
	public static List<Deudas__c > lstDeuda;

	public static void createData()
	{

		lstCuenta = TestCreaObjetos.CrearCuenta(1);
		lstReparadora = TestCreaObjetos.CrearReparadoras(1, lstCuenta[0].id, true);
		lstDeuda = TestCreaObjetos.CreaRdDeudas(1, lstReparadora[0].id);
		TestCreaObjetos.CreaRdSolFondos(1, lstDeuda[0].id, 'Solicitud de Fondos');
		TestCreaObjetos.CreaSolicitudFondeo(lstDeuda[0].id, 'Flujo Negociación');
		
	}
	@isTest static void test_method_one() {
		createData();
	}
	
	
}