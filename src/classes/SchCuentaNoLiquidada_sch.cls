/*****************************************************************************************************
* Desarrollado por: RTD
* Autor:            Esteban Heredia (EH)
* Proyecto:         Colombia V
* Descripción:      Programar batch bchCuentaNoLiquidada_bch             
*
* Cambios (Versiones)
* -------------------------------------
*           No.     fecha           Autor                       Descripción
*           -----   ----------      ------------------------    ---------------
* @version  1.0     28-Nov-2016     Esteban Heredia (EH)        Creación de la clase           
*******************************************************************************************************/
global class SchCuentaNoLiquidada_sch implements Schedulable 
{
	global void execute(SchedulableContext sc) 
	{
		bchCuentaNoLiquidada_bch bchCuentaNoLiquidada = new bchCuentaNoLiquidada_bch();
        Id batchProcessId = Database.executeBatch(bchCuentaNoLiquidada, 100);
	}
}