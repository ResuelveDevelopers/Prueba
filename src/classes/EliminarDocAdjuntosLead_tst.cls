/*******************************************************************************
Desarrollado por:   RTD
Autor:              Jeisson Hernandez
Proyecto:           Colombia III
Descripción:        Clase de Prueba de la clase EliminarDocAdjuntosLead

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		----------                ---------------------------     
    1.0     02-Oct-2015		Jeisson Hernandez(JH)     Creación de la Clase.
*******************************************************************************/
@isTest
public class EliminarDocAdjuntosLead_tst 
{
	@isTest(seeAllData = true)
	static void test1() 
	{
		String strURLName='https://'+System.URL.getSalesforceBaseUrl().getHost().remove('-api' );
		//Insertar Lead
		List <Lead> lstLead = TestCreaObjetos.CrearLeads(1);
			//Insertar Adjuntos
			Attachment AttachforFile= new Attachment();
			AttachforFile.Name = 'Test1';
			Blob bodyBlob=Blob.valueOf('TestFile For Unit Test');
			AttachforFile.body=bodyBlob;
			AttachforFile.parentId=lstLead[0].id;
			insert AttachforFile;

			Attachment AttachforFile2= new Attachment();
			AttachforFile2.Name = 'Test1';
			Blob bodyBlob2=Blob.valueOf('TestFile For Unit Test');
			AttachforFile2.body=bodyBlob2;
			AttachforFile2.parentId=lstLead[0].id;
			insert AttachforFile2;
			
			Attachment AttachforFile3= new Attachment();
			AttachforFile3.Name = 'Test1';
			Blob bodyBlob3=Blob.valueOf('TestFile For Unit Test');
			AttachforFile3.body=bodyBlob3;
			AttachforFile3.parentId=lstLead[0].id;
			insert AttachforFile3;

			Attachment AttachforFile4= new Attachment();
			AttachforFile4.Name = 'Test1';
			Blob bodyBlob4=Blob.valueOf('TestFile For Unit Test');
			AttachforFile4.body=bodyBlob4;
			AttachforFile4.parentId=lstLead[0].id;
			insert AttachforFile4;

			Attachment AttachforFile5= new Attachment();
			AttachforFile5.Name = 'Test1';
			Blob bodyBlob5=Blob.valueOf('TestFile For Unit Test');
			AttachforFile5.body=bodyBlob5;
			AttachforFile5.parentId=lstLead[0].id;
			insert AttachforFile5;

			Attachment AttachforFile6= new Attachment();
			AttachforFile6.Name = 'Test1';
			Blob bodyBlob6=Blob.valueOf('TestFile For Unit Test');
			AttachforFile6.body=bodyBlob6;
			AttachforFile6.parentId=lstLead[0].id;
			insert AttachforFile6;

			Attachment AttachforFile7= new Attachment();
			AttachforFile7.Name = 'Test1';
			Blob bodyBlob7=Blob.valueOf('TestFile For Unit Test');
			AttachforFile7.body=bodyBlob7;
			AttachforFile7.parentId=lstLead[0].id;
			insert AttachforFile7;

			Attachment AttachforFile8= new Attachment();
			AttachforFile8.Name = 'Test1';
			Blob bodyBlob8=Blob.valueOf('TestFile For Unit Test');
			AttachforFile8.body=bodyBlob8;
			AttachforFile8.parentId=lstLead[0].id;
			insert AttachforFile8;


			lstLead[0].CedulaURL__c =strURLName+'/servlet/servlet.FileDownload?file='+AttachforFile.id;
			lstLead[0].CedulaDoc__c = true; 

			lstLead[0].ReciboPublicoURL__c =strURLName+'/servlet/servlet.FileDownload?file='+AttachforFile2.id;
			lstLead[0].ReciboPublico__c = true; 

			lstLead[0].ComprobanteAtraso1URL__c =strURLName+'/servlet/servlet.FileDownload?file='+AttachforFile3.id;
			lstLead[0].ComprobanteAtraso1__c = true; 

			lstLead[0].ComprobanteAtraso2URL__c =strURLName+'/servlet/servlet.FileDownload?file='+AttachforFile4.id;
			lstLead[0].ComprobanteAtraso2__c = true; 

			lstLead[0].ComprobanteAtraso3URL__c =strURLName+'/servlet/servlet.FileDownload?file='+AttachforFile5.id;
			lstLead[0].ComprobanteAtraso3__c = true; 

			lstLead[0].ComprobanteAtraso4URL__c =strURLName+'/servlet/servlet.FileDownload?file='+AttachforFile6.id;
			lstLead[0].ComprobanteAtraso4__c = true; 

			lstLead[0].ComprobanteAtraso5URL__c =strURLName+'/servlet/servlet.FileDownload?file='+AttachforFile7.id;
			lstLead[0].ComprobanteAtraso5__c = true; 

			lstLead[0].ComprobanteAtraso6URL__c =strURLName+'/servlet/servlet.FileDownload?file='+AttachforFile8.id;
			lstLead[0].ComprobanteAtraso6__c = true; 

			update lstLead;
		Test.StartTest();  		
			lstLead[0].CedulaDoc__c = false;
			lstLead[0].ReciboPublico__c = false;
			lstLead[0].ComprobanteAtraso1__c = false;
			lstLead[0].ComprobanteAtraso2__c = false;
			lstLead[0].ComprobanteAtraso3__c = false;
			lstLead[0].ComprobanteAtraso4__c = false;
			lstLead[0].ComprobanteAtraso5__c = false;
			lstLead[0].ComprobanteAtraso6__c = false;
			update lstLead;				
		Test.StopTest();
	}
		
}