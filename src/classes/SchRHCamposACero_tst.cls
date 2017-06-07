/*******************************************************************************
Desarrollado por:   RTD
Autor:              Jeisson Hernandez
Proyecto:           Colombia III
Descripción:        Clase de prueba que probara la clase SchRHCamposACero_sch 

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		----------                ---------------------------     
    1.0     22-Oct-2015		Jeisson Hernandez(JH)     Creación de la Clase.
*******************************************************************************/

@isTest
private class SchRHCamposACero_tst 
{

    @isTest
    static void test1() 
    {
        Test.startTest();
	        String jobId;
            jobId = System.schedule('SchRHCamposACero_sch','0 0 0 3 9 ? 2022', new SchRHCamposACero_sch());
            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        Test.stopTest();
    }
}