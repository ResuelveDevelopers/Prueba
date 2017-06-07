/********************************************************************************************************
Desarrollado por:	RTD   
Autor:              Marwin Pineda(MP)
Proyecto:           Resuelve tu Deuda
Descripción:        Clase de consumo de Servicio Web de Envío de Documentos.

Cambios (Versiones)
--------------------------------------------------------------------------------------------------------
    No.     Fecha               Autor                       Descripción
    ---     -----------         ------------------------    --------------------------      
    1.0     21-Sep-2016         Marwin Pineda(MP)          	Creación clase Servicio REST 
***************************************************************************************/

public with sharing class EstructuraJSON 
{
	public String processId;						
	public cls_signerProperties signerProperties;
	public cls_pdfArray pdfArray; 
	
	public class cls_signerProperties 
	{
		public String firstName;		
		public String secondName;		
		public String surName;			
		public String secondSurName;	
		public String docType;			
		public String docId;			
	}
	
	public class cls_pdfArray 
	{
		public cls_payStubDoc payStubDoc;
		public List<cls_insuranceCoverDocs> insuranceCoverDocs;
		public List<cls_contractDocs> contractDocs;
		public List<cls_attorneyPowerDocs> attorneyPowerDocs;
	}
	
	public class cls_accessPath 
	{
		public String urlAccess;	
		public String bucket;		
	}
	
	public class cls_attorneyPowerDocs 
	{
		public String id;					
		public String name;					
		public cls_accessPath accessPath;
	}
	
	public class cls_insuranceCoverDocs 
	{
		public String id;					
		public String name;					
		public cls_accessPath accessPath;
	}
	
	public class cls_contractDocs 
	{
		public String id;					
		public String name;					
		public cls_accessPath accessPath;
	}
	
	public class cls_payStubDoc 
	{
		public String id;					
		public String name;					
		public cls_accessPath accessPath;
	}
	
	public static EstructuraJSON parse(String json)
	{
		System.debug('\n\n@@@Entra Clase EstructuraJSON--------->');
		return (EstructuraJSON) System.JSON.deserialize(json, EstructuraJSON.class); 
	}
}