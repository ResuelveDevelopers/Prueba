global class WSAsignacionOportunidades_ws 
{
	webservice static void asignarOportunidades()
	{
		String strQuery='';
		if (Test.isRunningTest() )
			strQuery='SELECT Id, DeudaWeb__c, AsignacionSucursal__c FROM Lead WHERE Status = \'Lead\' AND VendedorAsignado__c = NULL Limit 1';
		else
			strQuery='SELECT Id, DeudaWeb__c, AsignacionSucursal__c FROM Lead WHERE Status = \'Lead\' AND VendedorAsignado__c = NULL';
		BchAsignacionOportunidades_bch objBchAsignacionOportunidades = new BchAsignacionOportunidades_bch(strQuery);
		Id batchProcessId = Database.executeBatch(objBchAsignacionOportunidades, 1);
	}
}