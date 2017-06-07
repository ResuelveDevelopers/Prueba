/*******************************************************************************
Desarrollado por:   RTD
Autor:              Jeisson Hernandez
Proyecto:           Colombia III
Descripción:        Clase de Prueba para el controlador CargaDocumentosLead_ctr

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		----------                ---------------------------     
    1.0     02-Oct-2015		Jeisson Hernandez(JH)     Creación de la Clase.
*******************************************************************************/
@isTest
public class CargaDocumentosLead_tst 
{
	@isTest(seeAllData = true)
	static void testCargarCedula () 
	{
		//Insertar Lead
		List <Lead> lstLead = TestCreaObjetos.CrearLeads(1);
			//Insertar Adjunto
			Blob bodyBlob=Blob.valueOf('TestFile For Unit Test');
		Test.StartTest();  
			//Invoca a Controlador			
			CargaDocumentosLead_ctr objCargaDocumentos = new CargaDocumentosLead_ctr (new ApexPages.StandardController(lstLead[0]));
			objCargaDocumentos.blFileCedula =bodyBlob;
			objCargaDocumentos.strFileNameCedula = 'Test1';
			//Invoca a Metodo de Cargar Archivo
			objCargaDocumentos.UploadFileCedula();
			objCargaDocumentos.UploadFileCedula();
		Test.StopTest();
	}

	@isTest(seeAllData = true)
	static void testCargarReciboPublico() 
	{
		//Insertar Lead
		List <Lead> lstLead = TestCreaObjetos.CrearLeads(1);
			//Insertar Adjunto
			Blob bodyBlob=Blob.valueOf('TestFile For Unit Test');
			//Invoca a Controlador
		Test.StartTest();  
			CargaDocumentosLead_ctr objCargaDocumentos = new CargaDocumentosLead_ctr (new ApexPages.StandardController(lstLead[0]));
			objCargaDocumentos.blFileReciboPublico =bodyBlob;
			objCargaDocumentos.strFileNameReciboPublico='Test1';
			//Invoca a Metodo de Cargar Archivo
			objCargaDocumentos.UploadFileReciboPublico();
			objCargaDocumentos.UploadFileReciboPublico();
		Test.StopTest();
	}

	@isTest(seeAllData = true)
	static void testCargarComprobanteAtraso1 () 
	{
		//Insertar Lead
		List <Lead> lstLead = TestCreaObjetos.CrearLeads(1);
			//Insertar Adjunto
			Blob bodyBlob=Blob.valueOf('TestFile For Unit Test');
			//Invoca a Controlador			
		Test.StartTest();  
			CargaDocumentosLead_ctr objCargaDocumentos = new CargaDocumentosLead_ctr (new ApexPages.StandardController(lstLead[0]));
			objCargaDocumentos.blFileComprobanteAtraso1 =bodyBlob;
			objCargaDocumentos.strFileNameComprobanteAtraso1='Test1';
			//Invoca a Metodo de Cargar Archivo
			objCargaDocumentos.UploadFileComprobanteAtraso1();
			objCargaDocumentos.UploadFileComprobanteAtraso1();
		Test.StopTest();
	}

	@isTest(seeAllData = true)
	static void testCargarComprobanteAtraso2 () 
	{
		//Insertar Lead
		List <Lead> lstLead = TestCreaObjetos.CrearLeads(1);
		Test.StartTest();  
			//Insertar Adjunto
			Attachment AttachforFileComprobanteAtraso2= new Attachment();
			AttachforFileComprobanteAtraso2.Name = 'Test1';
			Blob bodyBlob=Blob.valueOf('TestFile For Unit Test');
			AttachforFileComprobanteAtraso2.body=bodyBlob;
			AttachforFileComprobanteAtraso2.parentId=lstLead[0].id;
			insert AttachforFileComprobanteAtraso2;
			//Invoca a Controlador			
			CargaDocumentosLead_ctr objCargaDocumentos = new CargaDocumentosLead_ctr (new ApexPages.StandardController(lstLead[0]));
			objCargaDocumentos.blFileComprobanteAtraso2 =bodyBlob;
			objCargaDocumentos.strFileNameComprobanteAtraso2='Test1';
			//Invoca a Metodo de Cargar Archivo
			objCargaDocumentos.UploadFileComprobanteAtraso2();
			objCargaDocumentos.UploadFileComprobanteAtraso2();
		Test.StopTest();
	}

	@isTest(seeAllData = true)
	static void testCargarComprobanteAtraso3 () 
	{
		//Insertar Lead
		List <Lead> lstLead = TestCreaObjetos.CrearLeads(1);
		Test.StartTest();  
			//Insertar Adjunto
			Attachment AttachforFileComprobanteAtraso3= new Attachment();
			AttachforFileComprobanteAtraso3.Name = 'Test1';
			Blob bodyBlob=Blob.valueOf('TestFile For Unit Test');
			AttachforFileComprobanteAtraso3.body=bodyBlob;
			AttachforFileComprobanteAtraso3.parentId=lstLead[0].id;
			insert AttachforFileComprobanteAtraso3;
			//Invoca a Controlador			
			CargaDocumentosLead_ctr objCargaDocumentos = new CargaDocumentosLead_ctr (new ApexPages.StandardController(lstLead[0]));
			objCargaDocumentos.blFileComprobanteAtraso3 =bodyBlob;
			objCargaDocumentos.strFileNameComprobanteAtraso3='Test1';
			//Invoca a Metodo de Cargar Archivo
			objCargaDocumentos.UploadFileComprobanteAtraso3();
			objCargaDocumentos.UploadFileComprobanteAtraso3();
		Test.StopTest();
	}

	@isTest(seeAllData = true)
	static void testCargarComprobanteAtraso4 () 
	{
		//Insertar Lead
		List <Lead> lstLead = TestCreaObjetos.CrearLeads(1);
		Test.StartTest();  
			//Insertar Adjunto
			Attachment AttachforFileComprobanteAtraso4= new Attachment();
			AttachforFileComprobanteAtraso4.Name = 'Test1';
			Blob bodyBlob=Blob.valueOf('TestFile For Unit Test');
			AttachforFileComprobanteAtraso4.body=bodyBlob;
			AttachforFileComprobanteAtraso4.parentId=lstLead[0].id;
			insert AttachforFileComprobanteAtraso4;
			//Invoca a Controlador			
			CargaDocumentosLead_ctr objCargaDocumentos = new CargaDocumentosLead_ctr (new ApexPages.StandardController(lstLead[0]));
			objCargaDocumentos.blFileComprobanteAtraso4 =bodyBlob;
			objCargaDocumentos.strFileNameComprobanteAtraso4='Test1';
			//Invoca a Metodo de Cargar Archivo
			objCargaDocumentos.UploadFileComprobanteAtraso4();
			objCargaDocumentos.UploadFileComprobanteAtraso4();
		Test.StopTest();
	}

	@isTest(seeAllData = true)
	static void testCargarComprobanteAtraso5 () 
	{
		//Insertar Lead
		List <Lead> lstLead = TestCreaObjetos.CrearLeads(1);
		Test.StartTest();  
			//Insertar Adjunto
			Attachment AttachforFileComprobanteAtraso5= new Attachment();
			AttachforFileComprobanteAtraso5.Name = 'Test1';
			Blob bodyBlob=Blob.valueOf('TestFile For Unit Test');
			AttachforFileComprobanteAtraso5.body=bodyBlob;
			AttachforFileComprobanteAtraso5.parentId=lstLead[0].id;
			insert AttachforFileComprobanteAtraso5;
			//Invoca a Controlador			
			CargaDocumentosLead_ctr objCargaDocumentos = new CargaDocumentosLead_ctr (new ApexPages.StandardController(lstLead[0]));
			objCargaDocumentos.blFileComprobanteAtraso5 =bodyBlob;
			objCargaDocumentos.strFileNameComprobanteAtraso5='Test1';
			//Invoca a Metodo de Cargar Archivo
			objCargaDocumentos.UploadFileComprobanteAtraso5();
			objCargaDocumentos.UploadFileComprobanteAtraso5();
		Test.StopTest();
	}

	@isTest(seeAllData = true)
	static void testCargarComprobanteAtraso6 () 
	{
		//Insertar Lead
		List <Lead> lstLead = TestCreaObjetos.CrearLeads(1);
		Test.StartTest();  
			//Insertar Adjunto
			Attachment AttachforFileComprobanteAtraso6= new Attachment();
			AttachforFileComprobanteAtraso6.Name = 'Test1';
			Blob bodyBlob=Blob.valueOf('TestFile For Unit Test');
			AttachforFileComprobanteAtraso6.body=bodyBlob;
			AttachforFileComprobanteAtraso6.parentId=lstLead[0].id;
			insert AttachforFileComprobanteAtraso6;
			//Invoca a Controlador			
			CargaDocumentosLead_ctr objCargaDocumentos = new CargaDocumentosLead_ctr (new ApexPages.StandardController(lstLead[0]));
			objCargaDocumentos.blFileComprobanteAtraso6 =bodyBlob;
			objCargaDocumentos.strFileNameComprobanteAtraso6='Test1';
			//Invoca a Metodo de Cargar Archivo
			objCargaDocumentos.UploadFileComprobanteAtraso6();
			objCargaDocumentos.UploadFileComprobanteAtraso6();
		Test.StopTest();
	}	
}