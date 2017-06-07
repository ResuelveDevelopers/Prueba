@isTest
private class TriggerIngresos_tst 
{
	public static List<Account> lstCuenta;
	public static List<Reparadora__c> lstReparadora;
	public static List<Ingresos__c> lstIngresos;
	
	public static void createData()
	{
		lstCuenta = TestCreaObjetos.CrearCuenta(1);
		lstReparadora = TestCreaObjetos.CrearReparadoras(1, lstCuenta[0].id, true);
		lstIngresos = TestCreaObjetos.CreaIngresos(6, lstReparadora[0].id);
	}
	
	@isTest static void test_method_one() 
	{
		createData();
		lstIngresos[0].Status__c = 'Por Cobrar';
		lstIngresos[0].TipoIngreso__c = 'Mensualidad Colombia';
		update lstIngresos[0];
		lstIngresos[3].Status__c = 'Por Cobrar';
		lstIngresos[3].TipoIngreso__c = 'Liquidación Colombia';
		update lstIngresos[3];
		lstIngresos[4].Status__c = 'Cobrado';
		lstIngresos[4].TipoIngreso__c = 'Mensualidad Colombia';
		update lstIngresos[4];
		lstIngresos[5].Status__c = 'Cobrado';
		lstIngresos[5].TipoIngreso__c = 'Liquidación Colombia';
		update lstIngresos[5];
		delete lstIngresos[1];
	}

	@isTest static void test_method_two() 
	{
		createData();
		lstIngresos[2].Reparadora__c = null;
		update lstIngresos[2];
		delete lstIngresos[0];
	}

	
}