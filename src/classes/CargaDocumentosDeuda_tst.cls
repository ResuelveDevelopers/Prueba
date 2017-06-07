/*************************************************************************************
Desarrollado por:	Resuelve
Autor:				Angela Munévar(AM)
Proyecto:			Resuelve tu Deuda
Descripción:		Clase de prueba de CargaDocumentosDeuda_ctr

Cambios (Versiones)
-------------------------------------
    No.		Fecha				Autor						Descripción
    ---		-----------  		------------------------	--------------------------  	
    1.0		09-Sep-2016			Angela Munévar(AM)			Creación de la Clase de prueba.
***************************************************************************************/

@isTest
private class CargaDocumentosDeuda_tst 
{
	public static List<Account> lstCuenta;
	public static List<Reparadora__c> lstReparadora;
	public static List<Deudas__c > lstDeuda;
	public static Blob blbBlob;
	public static CredencialesAmazon__c credAmazon;
   	
   	public static void createData()
	{
		lstCuenta = TestCreaObjetos.CrearCuenta(1);
		lstReparadora = TestCreaObjetos.CrearReparadoras(1, lstCuenta[0].id, true);
		lstDeuda = TestCreaObjetos.CreaRdDeudas(1, lstReparadora[0].id);
		lstDeuda[0].ComprobanteLiquidacion1__c = 'https://s3.amazonaws.com/Salesforce_Files/ComprobanteLiquidacion1.pdf';
     		lstDeuda[0].ComprobanteLiquidacion2__c = 'https://s3.amazonaws.com/Salesforce_Files/ComprobanteLiquidacion2.exe';
     		lstDeuda[0].ComprobanteLiquidacion3__c = 'https://s3.amazonaws.com/Salesforce_Files/ComprobanteLiquidacion3.zip';
     		lstDeuda[0].ComprobanteLiquidacion4__c = 'https://s3.amazonaws.com/Salesforce_Files/ComprobanteLiquidacion4.doc';
     		lstDeuda[0].ComprobanteLiquidacion5__c = 'https://s3.amazonaws.com/Salesforce_Files/ComprobanteLiquidacion5.xls';
     		lstDeuda[0].ComprobanteLiquidacion6__c = 'https://s3.amazonaws.com/Salesforce_Files/ComprobanteLiquidacion6.gif';
     		lstDeuda[0].ComprobanteLiquidacion7__c = 'https://s3.amazonaws.com/Salesforce_Files/ComprobanteLiquidacion7.png';
     		lstDeuda[0].ComprobanteLiquidacion8__c = 'https://s3.amazonaws.com/Salesforce_Files/ComprobanteLiquidacion8.jpg';
     		lstDeuda[0].CartaPoder__c = 'https://s3.amazonaws.com/Salesforce_Files/CartaPoder';
     		lstDeuda[0].PazySalvo__c = 'https://s3.amazonaws.com/Salesforce_Files/PazySalvo';
     		lstDeuda[0].ConvenioLiquidacion1__c = 'https://s3.amazonaws.com/Salesforce_Files/ConvenioLiquidacion1';
     		lstDeuda[0].ConvenioLiquidacion2__c = 'https://s3.amazonaws.com/Salesforce_Files/ConvenioLiquidacion2';
     		lstDeuda[0].ConvenioLiquidacion3__c = 'https://s3.amazonaws.com/Salesforce_Files/ConvenioLiquidacion3';
     		lstDeuda[0].OtroDocumento1__c = 'https://s3.amazonaws.com/Salesforce_Files/OtroDocumento1';
     		lstDeuda[0].OtroDocumento2__c = 'https://s3.amazonaws.com/Salesforce_Files/OtroDocumento2';
     		lstDeuda[0].OtroDocumento1__c = 'https://s3.amazonaws.com/Salesforce_Files/OtroDocumento3';
     		update lstDeuda[0]; 
	}

	
	@isTest static void test_method_one() 
	{
		createData();
		Test.startTest();
			credAmazon = TestCreaObjetos.creaConfCredencialesAmazon();
			ApexPages.StandardController sc = new ApexPages.StandardController(lstDeuda[0]);
			CargaDocumentosDeuda_ctr tstCargaDocu = new CargaDocumentosDeuda_ctr(sc);
			tstCargaDocu.strFileName = 'nombreArchivo';
     		tstCargaDocu.BlobCompLiqui = Blob.valueof('BlobCompLiqui');
     		tstCargaDocu.BlobCartaPoder = Blob.valueof('BlobCartaPoder');
     		tstCargaDocu.BlobPazSalvo = Blob.valueof('BlobPazSalvo');
     		tstCargaDocu.BlobConvLiqui = Blob.valueof('BlobConvLiqui');
     		tstCargaDocu.BlobOtroDoc = Blob.valueof('BlobOtroDoc');

     		tstCargaDocu.CargaComprobanteLiquidacion1();
     		tstCargaDocu.CargaComprobanteLiquidacion2();
     		tstCargaDocu.CargaComprobanteLiquidacion3();
     		tstCargaDocu.CargaComprobanteLiquidacion4();
     		tstCargaDocu.CargaComprobanteLiquidacion5();
     		tstCargaDocu.CargaComprobanteLiquidacion6();
     		tstCargaDocu.CargaComprobanteLiquidacion7();
     		tstCargaDocu.CargaComprobanteLiquidacion8();
     		tstCargaDocu.CargaCartaPoder();
     		tstCargaDocu.CargaPazSalvo();
     		tstCargaDocu.CargaConvenioLiquidacion1();
     		tstCargaDocu.CargaConvenioLiquidacion2();
     		tstCargaDocu.CargaConvenioLiquidacion3();
     		tstCargaDocu.CargaOtroDocumento1();
     		tstCargaDocu.CargaOtroDocumento2();
     		tstCargaDocu.CargaOtroDocumento3();

     		tstCargaDocu.DescargarComprobanteLiquidacion1();
     		tstCargaDocu.DescargarComprobanteLiquidacion2();
     		tstCargaDocu.DescargarComprobanteLiquidacion3();
     		tstCargaDocu.DescargarComprobanteLiquidacion4();
     		tstCargaDocu.DescargarComprobanteLiquidacion5();
     		tstCargaDocu.DescargarComprobanteLiquidacion6();
     		tstCargaDocu.DescargarComprobanteLiquidacion7();
     		tstCargaDocu.DescargarComprobanteLiquidacion8();
     		tstCargaDocu.DescargarCartaPoder();
     		tstCargaDocu.DescargarPazSalvo();
     		tstCargaDocu.DescargarConvenioLiquidacion1();
     		tstCargaDocu.DescargarConvenioLiquidacion2();
     		tstCargaDocu.DescargarConvenioLiquidacion3();
     		tstCargaDocu.DescargarOtroDocumento1();
     		tstCargaDocu.DescargarOtroDocumento2();
     		tstCargaDocu.DescargarOtroDocumento3();

     	Test.stopTest();
	}
	
	/*@isTest static void test_method_two() {
		// Implement test code
	}*/
	
}