/*****************************************************************************************************
* Desarrollado por: RTD
* Autor:            Esteban Heredia (EH)
* Proyecto:         Colombia 
* Descripción:      Clase de prueba para el trigger de Movimientos              
*
* Cambios (Versiones)
* -------------------------------------
*           No.     fecha          	Autor 		               	Descripción
*           -----   ----------      ------------------------   	---------------
* @version  1.0     12-Abr-2016     Esteban Heredia (EH)        Creación de la clase   
* @version	1.1     16-Ene-2016     Joe Ayala (JA) 				Se adiciona covertura a la clase ConsultaVariablesPeriodicas que se consumen desde el trigger
*******************************************************************************************************/
@isTest(seeAllData = true)
private class AuxiliarTriggerMovimientos_tst 
{
	public static Movimientos__c objMovimientos;
	public static Reparadora__c objReparadora;
    public static list<Configuraciones_Periodicas_Salesforce__c> lstConfPeriodicas;
    public static Configuraciones_Periodicas_Salesforce__c ConfPeriodicas;
    
	public static void createData()
	{
		objReparadora							= TestCreaObjetos.CrearReparadoras(1,null,true).get(0);
		objMovimientos 							= TestCreaObjetos.CrearMovimientos(1, objReparadora.id, true).get(0);
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

	@isTest static void test_method_one() 
	{
		createData();
		update objMovimientos;
		delete objMovimientos;
	}
}