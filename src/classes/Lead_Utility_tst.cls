@IsTest
private class Lead_Utility_tst 
{
	@isTest
	static void test1() 
	{
		Test.startTest();		
			Lead_Utility.DiaSemanaDesdeFechaTexto('MON');
			Lead_Utility.DiaSemanaDesdeFechaTexto('TUE');
			Lead_Utility.DiaSemanaDesdeFechaTexto('THU');
			Lead_Utility.DiaSemanaDesdeFechaTexto('WED');
			Lead_Utility.DiaSemanaDesdeFechaTexto('FRI');
			Lead_Utility.DiaSemanaDesdeFechaTexto('SAT');
			Lead_Utility.DiaSemanaDesdeFechaTexto('SUN');
		Test.stopTest();			
	}
}