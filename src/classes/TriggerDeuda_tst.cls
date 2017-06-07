/********************************************************************************************************
Desarrollado por:   Resuelve
Autor:              Angela Munévar(AM)
Proyecto:           Resuelve tu Deuda
Descripción:        Clase de prueba del objeto Deudas

Cambios (Versiones)
--------------------------------------------------------------------------------------------------------
    No.     Fecha               Autor                       Descripción
    ---     -----------         ------------------------    --------------------------      
    1.0     20-Abr-2016         Angela Munévar(AM)          Creación de la Clase 
	1.1     16-Ene-2016     	Joe Ayala (JA) 				Se adiciona covertura a la clase ConsultaVariablesPeriodicas que se consumen desde el trigger

********************************************************************************************************/
@isTest(seeAllData = true)
private class TriggerDeuda_tst 
{
	public static List<Account> lstCuenta;
	public static List<Reparadora__c> lstReparadora;	
	public static List<Deudas__c > lstDeuda;
    public static list<Configuraciones_Periodicas_Salesforce__c> lstConfPeriodicas;
    static Configuraciones_Periodicas_Salesforce__c ConfPeriodicas;
 
	public static void createData()
	{
		lstCuenta = TestCreaObjetos.CrearCuenta(1);
		lstReparadora = TestCreaObjetos.CrearReparadoras(1, lstCuenta[0].id, true);
		lstDeuda = TestCreaObjetos.CreaRdDeudas(1, lstReparadora[0].id);
        //16-Ene-2016 Joe Ayala Se adiciona objeto  Configuraciones_Periodicas_Salesforce__c el cual se invoca desde el trigger
        lstConfPeriodicas = new list<Configuraciones_Periodicas_Salesforce__c>();
        ConfPeriodicas = new Configuraciones_Periodicas_Salesforce__c();
        ConfPeriodicas.Activa__c = true;
        ConfPeriodicas.Name = 'configuracion_IVA';
        ConfPeriodicas.Fecha_Final__c = Date.newInstance(system.now().Year()+5,1, 1);
        ConfPeriodicas.Fecha_inicial__c = Date.newInstance(system.now().Year()-5,1, 1);
        ConfPeriodicas.Tipo__c = 'IVA';
        ConfPeriodicas.Valor__c = 19;
        ConfPeriodicas.Enviar_notificacion_por_correo__c = true;
        ConfPeriodicas.Notificar_a__c = 'pryeba@abc.com';	
        insert ConfPeriodicas;
        lstConfPeriodicas.add(ConfPeriodicas);
        
        		
	}

	@isTest static void test_method_one() {
		createData();
		lstDeuda[0].EstadodelaDeuda__c = 'En Trámite de Liquidación';
		lstDeuda[0].StatusdelTramite__c = 'Convenio Confirmado por el Banco';
		lstDeuda[0].FondeosRealizadosEstaDeuda__c = 0;
		update lstDeuda;
	}

	@isTest static void test_method_two() {
		createData();
		lstDeuda[0].EstadodelaDeuda__c = 'Liquidada';
		lstDeuda[0].StatusdelTramite__c = 'Fondos Depositados en Cuenta del Cliente';
		lstDeuda[0].MontodeLiquidacion__c = 10000;
		update lstDeuda;
	}

	@isTest static void test_method_tree() {
		createData();
		lstDeuda[0].StatusdelTramite__c = 'Convenio Confirmado por el Banco';
		lstDeuda[0].FechadeLiquidacion__c = system.today();
		update lstDeuda;
	}
	@isTest static void test_method_four() {
		createData();
		lstDeuda[0].EstadodelaDeuda__c = 'En Trámite de Liquidación';
		lstDeuda[0].StatusdelTramite__c = 'Pagos Estructurados / Convenio Confirmado';
		lstDeuda[0].FechadeLiquidacion__c = system.today();
		update lstDeuda;
	}
	@isTest static void test_method_six() {
		createData();
		lstDeuda[0].MontodeLiquidacion__c = 0;
		update lstDeuda;
	}

	
}