trigger TriggerAccount on Account (before update) 
{
	if(Trigger.isBefore && Trigger.isUpdate)
	{
		AuxiliarTriggerAccount_cls.handlerAfter(Trigger.new,Trigger.oldMap);
	}     
}