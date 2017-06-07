/*******************************************************************************
Desarrollado por:   Resuelve tu deuda
Autor:              Jeisson Hernandez
Proyecto:           Colombia
Descripción:        Clase de pruebas para TriggerReparadora

Cambios (Versiones)
-------------------------------------
    No.     Fecha           Autor                       Descripción
    ---     ---             ----------                  --------------------------      
    1.0     25-May-2015     Jeisson Hernandez (JH)      Creación de Clase.
    1.1     25-Abr-2016     Esteban Heredia (EH)        Más cobertura      
*******************************************************************************/
@isTest
private class TriggerReparadora_tst 
{
    public static RecursosHumanos__c objRecursoshumanos;
    public static Account objCuentaPersonal;
    public static Sucursal__c objSucursal;
    public static Lead objCandidato;
	public static Lead objNuevoCandidato;
	
    public static void createData()
    {
        objRecursoshumanos            = TestCreaObjetos.CrearRHs(1,'test','test').get(0);
        objRecursoshumanos.Usuario__c = UserInfo.getUserId();
        update objRecursoshumanos;
        
        //MP - 07/09/2016 - Se agrega sucursal, Reparadora, Candidato 
        objSucursal			= new Sucursal__c();
		objSucursal.Name  	= 'Bogotá';
		insert objSucursal;
        
        Reparadora__c objReparadora =  new Reparadora__c();
        insert objReparadora;
        
        objCandidato 						= TestCreaObjetos.CrearLeads(1).get(0);
        objCandidato.ClienteRecomendado__c 	= objReparadora.Id;
        update objCandidato;
        //MP - 07/09/2016 - ENDING
        
        String RecTypeId	= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Cliente Colombia').getRecordTypeId();
        objCuentaPersonal 	= new Account(
        						RecordTypeID			= RecTypeId,
          						FirstName				= 'Test FName',
          						LastName				= 'Test LName',
          						PersonMailingStreet		= 'test@yahoo.com',
          						PersonMailingPostalCode	= '12345',
          						PersonMailingCity		= 'SFO',
          						PersonEmail				= 'test@yahoo.com',
          						PersonHomePhone			= '1234567',
          						PersonMobilePhone		= '12345678',
          						Oportunidad__c			= objCandidato.Id
          						
        );
        insert objCuentaPersonal;
    }

	static testMethod void triggerReparadoraTest() 
	{
        createData();
		Test.startTest();
            //Crear Reparadora
            Reparadora__c Reparadora 			= new Reparadora__c();
            Reparadora.FechaInicioPrograma__c 	= Date.today();
            Reparadora.Cliente__c 				= objCuentaPersonal.id;
            //Insertar Reparadora
            insert Reparadora;
        Test.stopTest();  		
	}
}