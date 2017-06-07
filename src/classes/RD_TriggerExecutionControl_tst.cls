@isTest
private class RD_TriggerExecutionControl_tst 
{

    static testMethod void test1() 
    {
		Test.startTest();
		RD_TriggerExecutionControl_cls.setAlreadyDone('TriggerLead');
		RD_TriggerExecutionControl_cls.hasAlreadyDone('TriggerLead');
		RD_TriggerExecutionControl_cls.resetTriggerExecutionStatus('TriggerLead');
		Test.stopTest();
    }
}