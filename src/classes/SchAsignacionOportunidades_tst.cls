/*******************************************************************************
Desarrollado por:   RTD
Autor:              Jeisson Hernandez
Proyecto:           Colombia III
Descripción:        Clase de prueba que probara la clase SchAsignacionOportunidades_sch del batch de Asignacion de Oportunidades

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		----------                ---------------------------     
    1.0     09-Nov-2015		Jeisson Hernandez(JH)     Creación de la Clase.
*******************************************************************************/

@isTest
private class SchAsignacionOportunidades_tst 
{

    @isTest(seeAllData = true)
    static void test1() 
    {
        Test.startTest();
	        String jobId;
            jobId = System.schedule('SchAsignacionOportunidades_sch','0 0 0 3 9 ? 2022', new SchAsignacionOportunidades_sch());
            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        Test.stopTest();
    }
}