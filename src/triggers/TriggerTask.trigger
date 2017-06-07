/*****************************************************************************************************
* Desarrollado por: RTD
* Autor:            Esteban Heredia (EH)
* Proyecto:         Colombia 
* Descripción:      Trigger que controla los eventos del objeto Task              
*
* Cambios (Versiones)
* -------------------------------------
*           No.     fecha           Autor                       Descripción
*           -----   ----------      ------------------------    ---------------
* @version  1.0     30-Mar-2016     Esteban Heredia (EH)        Creación de la clase           
*******************************************************************************************************/
trigger TriggerTask on Task 
(
    before insert, 
    before update, 
    before delete, 
    after insert, 
    after update, 
    after delete, 
    after undelete
)
{
    if (Trigger.isBefore) 
    {
        if(Trigger.isInsert)
        {
           AuxiliarTriggerTask_cls.handlerBeforeInsert(trigger.new);
        }

        if(Trigger.isUpdate)
        {
           AuxiliarTriggerTask_cls.handlerBeforeUpdate(trigger.new,trigger.oldMap,trigger.newMap);
        }
    }
    if (Trigger.isAfter) 
    {
        if(Trigger.isInsert)
        {
           AuxiliarTriggerTask_cls.handlerAfterInsert(trigger.new);
        }
        if(Trigger.isUpdate)
        {
           AuxiliarTriggerTask_cls.handlerAfterUpdate(trigger.new);
        }
    }
}