/*******************************************************************************
Desarrollado por:   RTD
Autor:              Jeisson Hernandez
Proyecto:           Colombia III
Descripción:        Clase de prueba que probara la clase BchRHCamposACero_bch

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		----------                ---------------------------     
    1.0     22-Oct-2015		Jeisson Hernandez(JH)     Creación de la Clase.
    1.1		27-Abr-2016		Jeisson Hernandez(JH)     Se ajusta clase de pruebas para traer solo vendedores.
*******************************************************************************/

@isTest
private class BchRHCamposACero_tst 
{
	@isTest
	static void test1() 
	{
		List <RecursosHumanos__c> lstVendedor = TestCreaObjetos.CrearRHs(1,'Asesor de Reparación de Deuda Colombia','Ventas');
		Test.startTest();
			String strQuery='';
			strQuery =  'SELECT Id, OportunidadesTotalesArd__c,Area__c '+ 
						'FROM RecursosHumanos__c '+
						'WHERE Status__c = \'Activo\' AND Area__c = \'Ventas\' ORDER BY Sucursal__c Limit 1';
			List <RecursosHumanos__c> lstTest = [SELECT Id, OportunidadesTotalesArd__c,Area__c
												 FROM RecursosHumanos__c  
												 WHERE Status__c = 'Activo' 
												 AND Area__c = 'Ventas'
												 ORDER BY Sucursal__c Limit 1];
			System.debug('@@LST ' + lstTest);
			BchRHCamposACero_bch bchRHCamposACero = new BchRHCamposACero_bch(strQuery);
			Id batchProcessId = Database.executeBatch(bchRHCamposACero, 1);
		Test.stopTest();
	}
}