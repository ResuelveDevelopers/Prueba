/*************************************************************************************
Desarrollado por:	Resuelve
Autor:				Angela Munévar(AM)
Proyecto:			Resuelve tu Deuda
Descripción:		Clase de prueba de TriggerFlujo

Cambios (Versiones)
-------------------------------------
    No.		Fecha				Autor						Descripción
    ---		-----------  		------------------------	-------------------------------  	
    1.0		20-Abr-2016			Angela Munévar(AM)			Creación de la Clase de prueba.
	1.1     16-Ene-2016     	Joe Ayala (JA) 				Se adiciona covertura a la clase ConsultaVariablesPeriodicas que se consumen desde el TriggerFlujo

*******************************************************************************************/
@isTest(seeAllData = true)
private class TriggerFlujo_tst 
{
	public static List<Account> lstCuenta;
	public static List<Reparadora__c> lstReparadora;
	public static List<Deudas__c > lstDeuda;
	public static List<Flujo__c > lstFlujo;
	public static List<Sucursal__c> lstSucursal;
    public static list<Configuraciones_Periodicas_Salesforce__c> lstConfPeriodicas;
    public static Configuraciones_Periodicas_Salesforce__c ConfPeriodicas;

	public static void createData()
	{

		lstCuenta = TestCreaObjetos.CrearCuenta(1);
		lstReparadora = TestCreaObjetos.CrearReparadoras(1, lstCuenta[0].id, true);
		lstDeuda = TestCreaObjetos.CreaRdDeudas(1, lstReparadora[0].id);
		lstFlujo = TestCreaObjetos.CreaFlujo(4);
		lstSucursal = TestCreaObjetos.CreaSucursal(1);
		lstDeuda[0].DeudaRESUELVE__c = 200000;
		
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

        update lstDeuda;
	}
	
	@isTest static void test_method_one() 
	{
		createData();
		lstFlujo[0].Deuda__c = lstDeuda[0].id;
		lstFlujo[0].StatusFlujo__c = 'En espera de pago';
		lstFlujo[0].Sucursal__c  = lstSucursal[0].id;
		update lstFlujo;
		
	}
	
	@isTest static void test_method_two() 
	{
		createData();
		system.debug('+++lstDeuda[0].id '+lstDeuda[0].id);
		lstDeuda[0].EstadodelaDeuda__c= 'Liquidada';
		update lstDeuda;
		lstFlujo[0].Deuda__c = lstDeuda[0].id;
		system.debug('+++lstFlujo[0].Deuda__c '+lstFlujo[0].Deuda__c);
		lstFlujo[0].StatusFlujo__c = 'Pagado';
		lstFlujo[0].Sucursal__c  = lstSucursal[0].id;

		update lstFlujo;
		AggregateResult objFlujo = [Select Deuda__c, Count(id) FondeosRealEnEstaDeuda  
	                                        From Flujo__c 
	                                        Where Deuda__c = :lstDeuda[0].id
	                                        and StatusFlujo__c !='Cancelado'
	                                        group By Deuda__c];
	    system.debug('+++objFlujo '+objFlujo);                                    
		delete lstFlujo;
	}

	@isTest static void test_method_tree() 
	{
		createData();
		lstFlujo[0].Deuda__c = lstDeuda[0].id;
		lstFlujo[0].StatusFlujo__c = 'En espera de pago';
		update lstFlujo[0];
		lstFlujo[3].Deuda__c = lstDeuda[0].id;
		lstFlujo[3].StatusFlujo__c = 'En espera de pago';
		update lstFlujo[3];
		delete lstFlujo[1];
	}
	
}