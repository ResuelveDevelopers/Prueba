/*******************************************************************************
Desarrollado por:   RTD
Autor:              Marwin Pineda
Proyecto:           Movimientos Automáticos.
Descripción:        Clase de prueba del scheduler SchMovimientosMensuales_sch.

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha           Autor                   Descripción
    ---     ---             ----------              ---------------------------     
    1.0     25-Jul-2016       Marwin Pineda(MP)       Creación de la Clase.
*******************************************************************************/
@isTest
    
private class SchMovimientosMensuales_tst  
{
    
    @isTest
    static void test1()
    {
        Notificacion_Trabajos_Programados__c config = new Notificacion_Trabajos_Programados__c();
        config.Correo_Notificacion__c               = 'prueba@resuelve.com';
        config.Asunto_Correo_Notificacion__c        = 'Movimientos Automáticos';
        config.Name                                 = 'BchMovimientosMensuales_bch';
        insert config;

        Datetime fecha  = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 0 * ' + fecha.day() + ' ' + fecha.month() + ' ? ' + fecha.year();

        Test.startTest();
            System.schedule('ScheduleApexClassTest', CRON_EXP, new SchMovimientosMensuales_sch());          
        Test.stopTest();
    }
}