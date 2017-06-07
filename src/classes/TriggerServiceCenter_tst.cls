/*******************************************************************************
Desarrollado por:   Resuelve tu deuda
Autor:              Jeisson Hernandez
Proyecto:           Colombia
Descripción:        Clase de pruebas para TriggerServiceCenter

Cambios (Versiones)
-------------------------------------
    No.     Fecha           Autor                       Descripción
    ---     ---             ----------                  --------------------------      
    1.0     25-May-2015     Jeisson Hernandez (JH)      Creación de Trigger.
        
*******************************************************************************/
@isTest
private class TriggerServiceCenter_tst 
{

	@isTest(seeAllData = true)
	static void test1() 
	{
		Test.startTest();
		List <Lead> lstLead = TestCreaObjetos.CrearLeads(1);
		Id ContratoRecordTypeId = Schema.SObjectType.ServiceCenter__c.getRecordTypeInfosByName().get('Contrato').getRecordTypeId();
			ServiceCenter__c objServiceCenter = new ServiceCenter__c(
				 RecordTypeId = ContratoRecordTypeId
				,Oportunidad__c = lstLead[0].Id
			);
			insert objServiceCenter;
		Test.stopTest();
	}
}