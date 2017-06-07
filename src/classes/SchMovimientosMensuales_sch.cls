/*******************************************************************************
Desarrollado por:   RTD
Autor:              Marwin Pineda
Proyecto:           Movimientos automáticos.
Descripción:        Clase Scheduler Creación Movimientos Mensuales.

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha           Autor                   Descripción
    ---     ---             ----------              ---------------------------     
    1.0     19-Jul-2016     Marwin Pineda(MP)       Creación de la Clase.
*******************************************************************************/
global class SchMovimientosMensuales_sch implements Schedulable 
{
    global void execute(SchedulableContext SC)
    {
        String strQuery = '';
        
        strQuery  = 'SELECT Id,FechaInicioPrograma__c,Status__c,ComisionMensual__c,(SELECT Id FROM Movimientos__r) ';
        strQuery += 'FROM Reparadora__c '; 
        strQuery += 'WHERE FechaInicioPrograma__c < THIS_MONTH ';
        strQuery += 'AND Status__c IN (\'Activo\', \'En Tramite de Baja\', \'Graduar\') ';
        
        BchMovimientosMensuales_bch objBatchMovimientos = new BchMovimientosMensuales_bch(strQuery);
        Id batchProcessId = Database.executeBatch(objBatchMovimientos, 100);
    }
}