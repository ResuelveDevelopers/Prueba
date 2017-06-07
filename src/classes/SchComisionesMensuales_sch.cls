/*****************************************************************************************************
* Desarrollado por: RTD
* Autor:            Esteban Heredia (EH)
* Proyecto:         Colombia V
* Descripción:      Scheduler para crear ingresos en las reparadoras            
*
* Cambios (Versiones)
* -------------------------------------
*           No.     fecha           Autor                       Descripción
*           -----   ----------      ------------------------    ---------------
* @version  1.0     25-Jul-2016     Esteban Heredia (EH)        Creación de la clase           
*******************************************************************************************************/
global class SchComisionesMensuales_sch implements Schedulable 
{
	global void execute(SchedulableContext sc) 
	{
		// Llamamosalbatch que se encarga de crear el ingreso en las reparadoras
        BchComisionesMensuales_bch bchComisionesMensuales = new BchComisionesMensuales_bch();
        Id batchProcessId = Database.executeBatch(bchComisionesMensuales);
	}
}