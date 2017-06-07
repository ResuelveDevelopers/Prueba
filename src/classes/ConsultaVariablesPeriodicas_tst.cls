/**********************************************************************************************************
Desarrollado por:   RTD
Autor:              Joe Ayala Rodriguez
Proyecto:           Parametrización del IVA Colombia
Descripción:        Clase que realiza prueba a la clase ConsultaVariablesPeriodicas 

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		----------                ---------------------------     
    1.0     11-ene-2017		Joe Ayala(JA)     		Creación de la Clase.
************************************************************************************************************/
@isTest(seeAllData = true)
public class ConsultaVariablesPeriodicas_tst {
    
    public static List<Account> lstCuenta;
	public static List<Reparadora__c> lstReparadora;	
	public static List<Deudas__c > lstDeuda;
    public static list<Configuraciones_Periodicas_Salesforce__c> lstConfPeriodicas;
    static Configuraciones_Periodicas_Salesforce__c ConfPeriodicas;
	public static List<Flujo__c > lstFlujo;
	public static List<Sucursal__c> lstSucursal;
    public static Movimientos__c objMovimientos;
      
	public static void createData()
	{
		lstCuenta = TestCreaObjetos.CrearCuenta(1);
		lstReparadora = TestCreaObjetos.CrearReparadoras(1, lstCuenta[0].id, true);
		lstDeuda = TestCreaObjetos.CreaRdDeudas(1, lstReparadora[0].id);
        lstFlujo = TestCreaObjetos.CreaFlujo(4);
		lstSucursal = TestCreaObjetos.CreaSucursal(1);
        objMovimientos 	= TestCreaObjetos.CrearMovimientos(1, lstReparadora[0].id, true).get(0);
        
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

	@isTest static void test_method_1() {
		createData();
		lstDeuda[0].EstadodelaDeuda__c = 'En Trámite de Liquidación';
		lstDeuda[0].StatusdelTramite__c = 'Convenio Confirmado por el Banco';
		lstDeuda[0].FondeosRealizadosEstaDeuda__c = 0;
		update lstDeuda;
        
        lstFlujo[0].Deuda__c = lstDeuda[0].id;
		lstFlujo[0].StatusFlujo__c = 'En espera de pago';
		lstFlujo[0].Sucursal__c  = lstSucursal[0].id;
		update lstFlujo;
        
        objMovimientos.Monto__c	= 100000;
        update objMovimientos;
        
        lstDeuda = ConsultaVariablesPeriodicas.getlistValorActual('IVA','FechadeLiquidacion__c','FechadeLiquidacion__c',lstDeuda,'Porcentaje_de_IVA_Actual__c');

	}

    @isTest static void test_method_2() {
		createData();
		lstDeuda[0].StatusdelTramite__c = 'Convenio Confirmado por el Banco';
		lstDeuda[0].FechadeLiquidacion__c = system.today();
		update lstDeuda;
        
        lstFlujo[0].FechaFacturacion__c = Date.newInstance(System.now().Year()+15,1, 1);
        update lstFlujo;
        
        lstFlujo = ConsultaVariablesPeriodicas.getlistValorActual('IVA','TODAY','TODAY',lstFlujo,'Porcentaje_de_IVA_Actual__c');
        List<Flujo__c > lstFlujonull = new List<Flujo__c >();
        list<Sobject> lsobjectvacio = new list<Sobject>();
        lstConfPeriodicas = new list<Configuraciones_Periodicas_Salesforce__c>();
        lstFlujo = ConsultaVariablesPeriodicas.getlistValorActual('IVA','TODAY','TODAY',lsobjectvacio,'Porcentaje_de_IVA_Actualx__c');
	}
    
    @isTest static void test_method_3() {
		createData();
		lstDeuda[0].StatusdelTramite__c = 'Convenio Confirmado por el Banco';
		lstDeuda[0].FechadeLiquidacion__c = null;
        update lstDeuda;
        
        lstFlujo[0].FechaFacturacion__c = null;
        update lstFlujo;
        lstFlujo = ConsultaVariablesPeriodicas.getlistValorActual('IVA','FechaFacturacion__c','CreatedDate',lstFlujo,'Porcentaje_de_IVA_Actual__c');
        
        
	}
	
	
    
}