/*******************************************************************************
Desarrollado por:   RTD
Autor:              Jeisson Hernandez
Proyecto:           Colombia III Cierre de Clientes
Descripción:        Clase para identificar los triggers ejecutados por hilo de ejecución

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		----------                ---------------------------     
    1.0     07-Sep-2015		Jeisson Hernandez(JH)     Creación de la Clase.
*******************************************************************************/


global class RD_TriggerExecutionControl_cls 
{
	
	// Variable to avoid the trigger execution loop
    private static set<string> ExecutedTriggers_set = new set<string>();
     
    public static boolean hasAlreadyDone(string strAPINameOfTrigger) 
    { // Indicate if trigger has been fired once in the same thread
        if(!ExecutedTriggers_set.isEmpty()){
        	return ExecutedTriggers_set.contains(strAPINameOfTrigger);
        }else{
        	return false;
        }
    }    
    public static void setAlreadyDone(string strAPINameOfTrigger) 
    { // Sets that trigger has been fired
        ExecutedTriggers_set.add(strAPINameOfTrigger);
    }
    
    public static void resetTriggerExecutionStatus(string strAPINameOfTrigger) 
    { // Indica que NO se ha ejecutado el trigger (opcional)
        ExecutedTriggers_set.remove(strAPINameOfTrigger);
    }
}