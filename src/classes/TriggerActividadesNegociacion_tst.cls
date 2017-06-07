/*************************************************************************************
Desarrollado por:	Resuelve
Autor:				Angela Munévar(AM)
Proyecto:			Resuelve tu Deuda
Descripción:		Clase de prueba de TriggerActividadesNegociacion_ctr

Cambios (Versiones)
-------------------------------------
    No.		Fecha				Autor						Descripción
    ---		-----------  		------------------------	--------------------------  	
    1.0		20-Abr-2016			Angela Munévar(AM)			Creación de la Clase de prueba.
***************************************************************************************/
@isTest
private class TriggerActividadesNegociacion_tst {
	
	public static List<Deudas__c > lstDeuda;
	public static List<Account> lstCuenta;
	public static List<Reparadora__c> lstReparadora;

	public static void createData()
	{
		lstCuenta = TestCreaObjetos.CrearCuenta(1);
		lstReparadora = TestCreaObjetos.CrearReparadoras(1, lstCuenta[0].id, true);
		lstDeuda = TestCreaObjetos.CreaRdDeudas(1, lstReparadora[0].id);
		TestCreaObjetos.CrearActivadNegociacion(1, lstDeuda[0].id) ;
	}

	@isTest static void test_method_one() {
		createData(); 
	}

}