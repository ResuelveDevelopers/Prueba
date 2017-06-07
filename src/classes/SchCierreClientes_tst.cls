/*******************************************************************************
Desarrollado por:   RTD
Autor:              Jeisson Hernandez
Proyecto:           Colombia III
Descripción:        Clase de prueba que probara la clase SchCierreClientes_sch del batch de cierre de clientes

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		----------                ---------------------------     
    1.0     10-Sep-2015		Jeisson Hernandez(JH)     Creación de la Clase.
*******************************************************************************/

@isTest
private class SchCierreClientes_tst 
{

    @isTest(seeAllData = true)
    static void test1() 
    {
        Test.startTest();
	        String jobId;
            jobId = System.schedule('SchCierreClientes_sch','0 0 0 3 9 ? 2022', new SchCierreClientes_sch());
            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        Test.stopTest();
    }
}