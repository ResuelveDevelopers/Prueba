/*************************************************************************************
Desarrollado por:	Resuelve
Autor:				Angela Munévar(AM)
Proyecto:			Resuelve tu Deuda
Descripción:		Clase de prueba de CargaDocumentosCartaDeInstruccion_ctr

Cambios (Versiones)
-------------------------------------
    No.		Fecha				Autor						Descripción
    ---		-----------  		------------------------	--------------------------  	
    1.0		13-Abr-2016			Angela Munévar(AM)			Creación de la Clase de prueba.
***************************************************************************************/
@isTest
private class CargaDocumentosCartaDeInstruccion_tst 
{
	public static List<Account> lstCuenta;
	public static List<Reparadora__c> lstReparadora;
	public static List<Deudas__c > lstDeuda;
	public static List<SolicitudesDeFondos__c > lstSolicitudesDeFondos;
	public static Blob blbBlob;
	public static CredencialesAmazon__c credAmazon;


	public static void createData()
	{
		lstCuenta = TestCreaObjetos.CrearCuenta(1);
		lstReparadora = TestCreaObjetos.CrearReparadoras(1, lstCuenta[0].id, true);
		lstDeuda = TestCreaObjetos.CreaRdDeudas(1, lstReparadora[0].id);
		lstSolicitudesDeFondos = TestCreaObjetos.CreaRdSolFondos(1, lstDeuda[0].id);
		
		
	}
	
	@isTest static void test_method_one() {

		createData();
		String myString = 'StringToBlob';
		blbBlob = Blob.valueof(myString);
		Test.startTest();
			credAmazon = TestCreaObjetos.creaConfCredencialesAmazon();
			ApexPages.StandardController sc = new ApexPages.StandardController(lstSolicitudesDeFondos[0]);
	        CargaDocumentosCartaDeInstruccion_ctr testAccPlan = new CargaDocumentosCartaDeInstruccion_ctr(sc);
	 		
	        testAccPlan.blopCartInst = Blob.valueof('Adjunto');
	        testAccPlan.strFileNameCartinst = 'Archivo nuevo';
	        System.debug('+++adjunto '+testAccPlan);
	        testAccPlan.Upload_Solicitud1();
	        testAccPlan.Upload_Solicitud2();
	        testAccPlan.Upload_Solicitud3();
	        testAccPlan.Upload_Solicitud1();
	        testAccPlan.Upload_Solicitud2();
	        testAccPlan.Upload_Solicitud3();
	        testAccPlan.Upload_Solicitud1();
	        testAccPlan.Upload_Solicitud2();
	        testAccPlan.Upload_Solicitud3();
	        testAccPlan.Upload_Solicitud1();
	        testAccPlan.Upload_Solicitud2();
	        testAccPlan.Upload_Solicitud3();
	    Test.stopTest();

	}
	
	@isTest static void test_method_two() 
	{
		createData();
		
		Test.startTest();
			credAmazon = TestCreaObjetos.creaConfCredencialesAmazon();
			ApexPages.StandardController sc = new ApexPages.StandardController(lstSolicitudesDeFondos[0]);
	        CargaDocumentosCartaDeInstruccion_ctr testAccPlan = new CargaDocumentosCartaDeInstruccion_ctr(sc);

	        System.debug('+++adjunto '+testAccPlan);
	        testAccPlan.Upload_Solicitud1();
	        testAccPlan.Upload_Solicitud2();
	        testAccPlan.Upload_Solicitud3();
	    Test.stopTest();
	}

	@isTest static void test_method_three() {

		createData();
		String myString = 'StringToBlob';
		blbBlob = Blob.valueof(myString);
		Test.startTest();
			credAmazon = TestCreaObjetos.creaConfCredencialesAmazon();
			ApexPages.StandardController sc = new ApexPages.StandardController(lstSolicitudesDeFondos[0]);
	        CargaDocumentosCartaDeInstruccion_ctr testAccPlan = new CargaDocumentosCartaDeInstruccion_ctr(sc);
	 		
	        testAccPlan.blopCartInst = Blob.valueof('Adjunto');
	        System.debug('+++adjunto '+testAccPlan);
	        testAccPlan.Upload_Solicitud1();
	        testAccPlan.Upload_Solicitud2();
	        testAccPlan.Upload_Solicitud3();
	    Test.stopTest();

	}

	@isTest static void test_method_four() {

		lstCuenta = TestCreaObjetos.CrearCuenta(1);
		lstReparadora = TestCreaObjetos.CrearReparadoras(1, lstCuenta[0].id, true);
		lstDeuda = TestCreaObjetos.CreaRdDeudas(1, lstReparadora[0].id);
		lstDeuda[0].CartaInstruccion1__c = 'http://prueba.com';
		lstDeuda[0].CartaInstruccion2__c = 'http://prueba.com';
		lstDeuda[0].CartaInstruccion3__c = 'http://prueba.com';
		update lstDeuda[0];
		lstSolicitudesDeFondos = TestCreaObjetos.CreaRdSolFondos(1, lstDeuda[0].id);
		String myString = 'StringToBlob';
		blbBlob = Blob.valueof(myString);
		Test.startTest();
			credAmazon = TestCreaObjetos.creaConfCredencialesAmazon();
			ApexPages.StandardController sc = new ApexPages.StandardController(lstSolicitudesDeFondos[0]);
	        CargaDocumentosCartaDeInstruccion_ctr testAccPlan = new CargaDocumentosCartaDeInstruccion_ctr(sc);
	 		
	        testAccPlan.blopCartInst = Blob.valueof('Adjunto');
	        testAccPlan.strFileNameCartinst = 'Archivo nuevo';
	        System.debug('+++adjunto '+testAccPlan.strFileNameCartinst);
	        testAccPlan.Upload_Solicitud1();
	        testAccPlan.Upload_Solicitud2();
	        testAccPlan.Upload_Solicitud3();
	    Test.stopTest();

	}

	
	
}