/*****************************************************************************************************
* Desarrollado por: RTD
* Autor:            Esteban Heredia (EH)
* Proyecto:         Colombia V
* Descripción:      clase de prueba bchCuentaNoLiquidada             
*
* Cambios (Versiones)
* -------------------------------------
*           No.     fecha           Autor                       Descripción
*           -----   ----------      ------------------------    ---------------
* @version  1.0     28-Nov-2016     Esteban Heredia (EH)        Creación de la clase           
*******************************************************************************************************/
@isTest
private class bchCuentaNoLiquidada_tst 
{
	public static SolicitudesDeFondos__c objSolFondos;
	public static Deudas__c objDeuda;

	public static void createData()
	{
		Notificacion_Trabajos_Programados__c notTrabajos = new Notificacion_Trabajos_Programados__c();
		notTrabajos.Name = 'bchCuentaNoLiquidada_bch';
		notTrabajos.Correo_Notificacion__c = 'Test@gmail.com';
		notTrabajos.Asunto_Correo_Notificacion__c = 'Resuelve tu deuda';
		insert notTrabajos;

		objDeuda 								= TestCreaObjetos.CreaRdDeudas(1, null).get(0);
		objSolFondos 							= TestCreaObjetos.CreaRdSolFondos(1, objDeuda.id).get(0);
		objSolFondos.Estatus__c 				= 'Solicitud Rechazada';
		objSolFondos.CambioCuentaNoLiquidada__c = false;
		update objSolFondos;
	}
	
	@isTest static void test_method_one() 
	{
		createData();
		SchCuentaNoLiquidada_sch schCuentaNoLiquidada = new SchCuentaNoLiquidada_sch();
		Test.startTest();
			schCuentaNoLiquidada.execute(null);
		Test.stopTest();
	}
}