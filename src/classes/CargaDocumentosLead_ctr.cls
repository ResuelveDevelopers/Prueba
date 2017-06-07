/*******************************************************************************
Desarrollado por:   RTD
Autor:              Jeisson Hernandez
Proyecto:           Colombia III 
Descripción:        Clase Controladora de la visualforce CargaDocumentosLead para la Carga Documentos en Lead

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		----------                ---------------------------     
    1.0     30-Sep-2015		Jeisson Hernandez(JH)     Creación de la Clase.
*******************************************************************************/
public class CargaDocumentosLead_ctr 
{
	public Id idLead {get;set;}
	public Boolean blnrefreshPage {get; set;}
	public Lead objLead{get;set;}
	public Lead objSelectedLead{get;set;}
	public String strURLName{get;set;}
	public Boolean blnUploadEligible{get;set;}
	
	Transient public Blob blFileCedula {get;set;}
	public String strErrorCedula{get;set;}
	public String strFileNameCedula{get;set;}

	Transient public Blob blFileReciboPublico {get;set;}
	public String strErrorReciboPublico {get;set;}
	public String strFileNameReciboPublico {get;set;}

	Transient public Blob blFileComprobanteAtraso1 {get;set;}
	public String strErrorComprobanteAtraso1 {get;set;}
	public String strFileNameComprobanteAtraso1 {get;set;}

	Transient public Blob blFileComprobanteAtraso2 {get;set;}
	public String strErrorComprobanteAtraso2 {get;set;}
	public String strFileNameComprobanteAtraso2 {get;set;}

	Transient public Blob blFileComprobanteAtraso3 {get;set;}
	public String strErrorComprobanteAtraso3 {get;set;}
	public String strFileNameComprobanteAtraso3 {get;set;}

	Transient public Blob blFileComprobanteAtraso4 {get;set;}
	public String strErrorComprobanteAtraso4 {get;set;}
	public String strFileNameComprobanteAtraso4 {get;set;}

	Transient public Blob blFileComprobanteAtraso5 {get;set;}
	public String strErrorComprobanteAtraso5 {get;set;}
	public String strFileNameComprobanteAtraso5 {get;set;}

	Transient public Blob blFileComprobanteAtraso6 {get;set;}
	public String strErrorComprobanteAtraso6 {get;set;}
	public String strFileNameComprobanteAtraso6 {get;set;}


	public CargaDocumentosLead_ctr(ApexPages.StandardController controller) 
	{
		this.objLead = (Lead)controller.getRecord();
		this.idLead = objLead.Id;
		objSelectedLead = [Select Id,CedulaDoc__c,CedulaURL__c
								,ComprobanteAtraso1__c,ComprobanteAtraso1URL__c,ComprobanteAtraso2__c,ComprobanteAtraso2URL__c
								,ComprobanteAtraso3__c,ComprobanteAtraso3URL__c,ComprobanteAtraso4__c,ComprobanteAtraso4URL__c
								,ComprobanteAtraso5__c,ComprobanteAtraso5URL__c,ComprobanteAtraso6__c,ComprobanteAtraso6URL__c
								,ReciboPublico__c,ReciboPublicoURL__c
							FROM Lead Where Id =: idLead];
		strURLName='https://'+System.URL.getSalesforceBaseUrl().getHost().remove('-api' );
		
		List<PerfilesCargarArchivos__c> lstPerfilesPermitidos = PerfilesCargarArchivos__c.getall().values(); 
		String  currentUserProfile = [Select p.Name From Profile p where p.Id = :UserInfo.getProfileId()].Name;
		for(PerfilesCargarArchivos__c varfile : lstPerfilesPermitidos)
		{
			if(currentUserProfile == varfile.Name)
			{
				blnUploadEligible=true;
			}
		 }
	}

	public Pagereference UploadFileCedula ()
	{
		
		if(this.idLead!=null)
		{
			if(blFileCedula !=null)
			{
				strErrorCedula=null;
				if(this.objSelectedLead.CedulaURL__c !=null)
				{
					UpdateFile('Cedula',this.IdLead,this.objSelectedLead.CedulaURL__c,blFileCedula,strFileNameCedula);
				}
				else
				{
					SavePoint svP = Database.setSavepoint();
					try
					{
						
						Attachment attFile = new Attachment(); 
						attFile .Body = blFileCedula; 
						attFile .Name = strFileNameCedula; 
						attFile .ParentId = this.IdLead; 
						attFile .Description = 'Archivo Cargado'; 
						insert attFile ;
						this.objSelectedLead.CedulaURL__c =strURLName+'/servlet/servlet.FileDownload?file='+attFile.id;
						this.objSelectedLead.CedulaDoc__c= True;
						Update this.objSelectedLead;
						blnrefreshPage= true;
					}
					catch(DmlException ex)
					{
						ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'NO puede cargar documentos. ' + ex.getDmlMessage(0)));
						this.objSelectedLead.CedulaURL__c ='';
						this.objSelectedLead.CedulaDoc__c= false;
						blnrefreshPage= false;
						Database.rollback(svP);
						return null;
					}						
				}
			}
			else
			{
				strErrorCedula='Selecciona archivo a subir';
			}
		}
		return null;
	}

	public Pagereference UploadFileReciboPublico ()
	{
	     if(this.idLead!=null)
	     {
	          if(blFileReciboPublico !=null)
	          {
	             strErrorReciboPublico=null;
	             if(this.objSelectedLead.ReciboPublicoURL__c !=null)
	             {
	               UpdateFile('ReciboPublico',this.IdLead,this.objSelectedLead.ReciboPublicoURL__c,blFileReciboPublico,strFileNameReciboPublico);
	             }
	             else
	             {
	             	SavePoint svP = Database.setSavepoint();
					try
					{
		                Attachment attFile = new Attachment(); 
		                attFile.Body = blFileReciboPublico; 
		                attFile.Name = strFileNameReciboPublico; 
		                attFile.ParentId = this.IdLead; 
		                attFile.Description = 'Archivo Cargado'; 
		                insert attFile ;
		                this.objSelectedLead.ReciboPublicoURL__c =strURLName+'/servlet/servlet.FileDownload?file='+attFile.id;
		                this.objSelectedLead.ReciboPublico__c = true;
		                Update this.objSelectedLead;
		                blnrefreshPage= true;
					}
					catch(DmlException ex)
					{
						ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'NO puede cargar documentos. ' + ex.getDmlMessage(0)));
						this.objSelectedLead.ReciboPublicoURL__c ='';
						this.objSelectedLead.ReciboPublico__c= false;
						blnrefreshPage= false;
						Database.rollback(svP);
						return null;
					}						
	               
	             }             
	          }
	          else
	          {
	              strErrorReciboPublico='Selecciona archivo a subir';
	          }
	      }
	  return null;
	}

	public Pagereference UploadFileComprobanteAtraso1 ()
	{
	     if(this.idLead!=null)
	     {
	          if(blFileComprobanteAtraso1 !=null)
	          {
	             strErrorComprobanteAtraso1=null;
	             if(this.objSelectedLead.ComprobanteAtraso1URL__c !=null)
	             {
	               UpdateFile('ComprobanteAtraso1',this.IdLead,this.objSelectedLead.ComprobanteAtraso1URL__c,blFileComprobanteAtraso1,strFileNameComprobanteAtraso1);
	             }
	             else
	             {
	             	SavePoint svP = Database.setSavepoint();
					try
					{
						Attachment attFile = new Attachment(); 
						attFile.Body = blFileComprobanteAtraso1; 
						attFile.Name = strFileNameComprobanteAtraso1; 
						attFile.ParentId = this.IdLead; 
						attFile.Description = 'Archivo Cargado'; 
						insert attFile ;
						this.objSelectedLead.ComprobanteAtraso1URL__c =strURLName+'/servlet/servlet.FileDownload?file='+attFile.id;
						this.objSelectedLead.ComprobanteAtraso1__c = true;
						Update this.objSelectedLead;
						blnrefreshPage= true;
					}
					catch(DmlException ex)
					{
						ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'NO puede cargar documentos. ' + ex.getDmlMessage(0)));
						this.objSelectedLead.ComprobanteAtraso1URL__c ='';
						this.objSelectedLead.ComprobanteAtraso1__c= false;
						blnrefreshPage= false;
						Database.rollback(svP);
						return null;
					}						
	             }             
	          }
	          else
	          {
	              strErrorComprobanteAtraso1='Selecciona archivo a subir';
	          }
	      }
	  return null;
	}

	public Pagereference UploadFileComprobanteAtraso2 ()
	{
	     if(this.idLead!=null)
	     {
	          if(blFileComprobanteAtraso2 !=null)
	          {
	             strErrorComprobanteAtraso2=null;
	             if(this.objSelectedLead.ComprobanteAtraso2URL__c !=null)
	             {
	               UpdateFile('ComprobanteAtraso2',this.IdLead,this.objSelectedLead.ComprobanteAtraso2URL__c,blFileComprobanteAtraso2,strFileNameComprobanteAtraso2);
	             }
	             else
	             {
	             	SavePoint svP = Database.setSavepoint();
					try
					{
						Attachment attFile = new Attachment(); 
						attFile.Body = blFileComprobanteAtraso2; 
						attFile.Name = strFileNameComprobanteAtraso2; 
						attFile.ParentId = this.IdLead; 
						attFile.Description = 'Archivo Cargado'; 
						insert attFile ;
						this.objSelectedLead.ComprobanteAtraso2URL__c =strURLName+'/servlet/servlet.FileDownload?file='+attFile.id;
						this.objSelectedLead.ComprobanteAtraso2__c = true;
						Update this.objSelectedLead;
						blnrefreshPage= true;
					}
					catch(DmlException ex)
					{
						ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'NO puede cargar documentos. ' + ex.getDmlMessage(0)));
						this.objSelectedLead.ComprobanteAtraso2URL__c ='';
						this.objSelectedLead.ComprobanteAtraso2__c= false;
						blnrefreshPage= false;
						Database.rollback(svP);
						return null;
					}						
	             }             
	          }
	          else
	          {
	              strErrorComprobanteAtraso2='Selecciona archivo a subir';
	          }
	      }
	  return null;
	}

	public Pagereference UploadFileComprobanteAtraso3 ()
	{
	     if(this.idLead!=null)
	     {
	          if(blFileComprobanteAtraso3 !=null)
	          {
	             strErrorComprobanteAtraso3=null;
	             if(this.objSelectedLead.ComprobanteAtraso3URL__c !=null)
	             {
	               UpdateFile('ComprobanteAtraso3',this.IdLead,this.objSelectedLead.ComprobanteAtraso3URL__c,blFileComprobanteAtraso3,strFileNameComprobanteAtraso3);
	             }
	             else
	             {
					SavePoint svP = Database.setSavepoint();
					try
					{
						Attachment attFile = new Attachment(); 
						attFile.Body = blFileComprobanteAtraso3; 
						attFile.Name = strFileNameComprobanteAtraso3; 
						attFile.ParentId = this.IdLead; 
						attFile.Description = 'Archivo Cargado'; 
						insert attFile ;
						this.objSelectedLead.ComprobanteAtraso3URL__c =strURLName+'/servlet/servlet.FileDownload?file='+attFile.id;
						this.objSelectedLead.ComprobanteAtraso3__c = true;
						Update this.objSelectedLead;
						blnrefreshPage= true;
					}
					catch(DmlException ex)
					{
						ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'NO puede cargar documentos. ' + ex.getDmlMessage(0)));
						this.objSelectedLead.ComprobanteAtraso3URL__c ='';
						this.objSelectedLead.ComprobanteAtraso3__c= false;
						blnrefreshPage= false;
						Database.rollback(svP);
						return null;
					}						
	             }
	          }
	          else
	          {
	              strErrorComprobanteAtraso3='Selecciona archivo a subir';
	          }
	      }
	
		return null;
	}
	
	public Pagereference UploadFileComprobanteAtraso4 ()
	{
	     if(this.idLead!=null)
	     {
	          if(blFileComprobanteAtraso4 !=null)
	          {
	             strErrorComprobanteAtraso4=null;
	             if(this.objSelectedLead.ComprobanteAtraso4URL__c !=null)
	             {
	               UpdateFile('ComprobanteAtraso4',this.IdLead,this.objSelectedLead.ComprobanteAtraso4URL__c,blFileComprobanteAtraso4,strFileNameComprobanteAtraso4);
	             }
	             else
	             {
					SavePoint svP = Database.setSavepoint();
					try
					{
						Attachment attFile = new Attachment(); 
						attFile.Body = blFileComprobanteAtraso4; 
						attFile.Name = strFileNameComprobanteAtraso4; 
						attFile.ParentId = this.IdLead; 
						attFile.Description = 'Archivo Cargado'; 
						insert attFile ;
						this.objSelectedLead.ComprobanteAtraso4URL__c =strURLName+'/servlet/servlet.FileDownload?file='+attFile.id;
						this.objSelectedLead.ComprobanteAtraso4__c = true;
						Update this.objSelectedLead;
						blnrefreshPage= true;
					}
					catch(DmlException ex)
					{
						ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'NO puede cargar documentos. ' + ex.getDmlMessage(0)));
						this.objSelectedLead.ComprobanteAtraso4URL__c ='';
						this.objSelectedLead.ComprobanteAtraso4__c= false;
						blnrefreshPage= false;
						Database.rollback(svP);
						return null;
					}						
	             }             
	          }
	          else
	          {
	              strErrorComprobanteAtraso4='Selecciona archivo a subir';
	          }
	      }
	  return null;
	}

	public Pagereference UploadFileComprobanteAtraso5 ()
	{
	     if(this.idLead!=null)
	     {
	          if(blFileComprobanteAtraso5 !=null)
	          {
	             strErrorComprobanteAtraso5=null;
	             if(this.objSelectedLead.ComprobanteAtraso5URL__c !=null)
	             {
	               UpdateFile('ComprobanteAtraso5',this.IdLead,this.objSelectedLead.ComprobanteAtraso5URL__c,blFileComprobanteAtraso5,strFileNameComprobanteAtraso5);
	             }
	             else
	             {
					SavePoint svP = Database.setSavepoint();
					try
					{
						Attachment attFile = new Attachment(); 
						attFile.Body = blFileComprobanteAtraso5; 
						attFile.Name = strFileNameComprobanteAtraso5; 
						attFile.ParentId = this.IdLead; 
						attFile.Description = 'Archivo Cargado'; 
						insert attFile ;
						this.objSelectedLead.ComprobanteAtraso5URL__c =strURLName+'/servlet/servlet.FileDownload?file='+attFile.id;
						this.objSelectedLead.ComprobanteAtraso5__c = true;
						Update this.objSelectedLead;
						blnrefreshPage= true;
					}
					catch(DmlException ex)
					{
						ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'NO puede cargar documentos. ' + ex.getDmlMessage(0)));
						this.objSelectedLead.ComprobanteAtraso5URL__c ='';
						this.objSelectedLead.ComprobanteAtraso5__c= false;
						blnrefreshPage= false;
						Database.rollback(svP);
						return null;
					}						
	             }
	          }
	          else
	          {
	              strErrorComprobanteAtraso5='Selecciona archivo a subir';
	          }
	      }
	  return null;
	}

	public Pagereference UploadFileComprobanteAtraso6 ()
	{
	     if(this.idLead!=null)
	     {
	          if(blFileComprobanteAtraso6 !=null)
	          {
	             strErrorComprobanteAtraso6=null;
	             if(this.objSelectedLead.ComprobanteAtraso6URL__c !=null)
	             {
	               UpdateFile('ComprobanteAtraso6',this.IdLead,this.objSelectedLead.ComprobanteAtraso6URL__c,blFileComprobanteAtraso6,strFileNameComprobanteAtraso6);
	             }
	             else
	             {
					SavePoint svP = Database.setSavepoint();
					try
					{
	                        Attachment attFile = new Attachment(); 
	                        attFile.Body = blFileComprobanteAtraso6; 
	                        attFile.Name = strFileNameComprobanteAtraso6; 
	                        attFile.ParentId = this.IdLead; 
	                        attFile.Description = 'Archivo Cargado'; 
	                        insert attFile ;
	                        this.objSelectedLead.ComprobanteAtraso6URL__c =strURLName+'/servlet/servlet.FileDownload?file='+attFile.id;
	                        this.objSelectedLead.ComprobanteAtraso6__c = true;
	                        Update this.objSelectedLead;
	                        blnrefreshPage= true;
					}
					catch(DmlException ex)
					{
						ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'NO puede cargar documentos. ' + ex.getDmlMessage(0)));
						this.objSelectedLead.ComprobanteAtraso6URL__c ='';
						this.objSelectedLead.ComprobanteAtraso6__c= false;
						blnrefreshPage= false;
						Database.rollback(svP);
						return null;
					}						
	             }
	          }
	          else
	          {
	              strErrorComprobanteAtraso6='Selecciona archivo a subir';
	          }
	      }
	  return null;
	}


	public void UpdateFile(String strfield,Id RecId,String RecordDetailId,Blob blFile,String strfileName)
	{
	      try
	      { 
	         Boolean blnAlreadyAttached=true;
	         List<Attachment > lstAtt = [select Id,Name from Attachment where id=:RecordDetailId.Right(18)];
	         List<Attachment > lstAttUpdate=new List<Attachment >();
	         if(lstAtt.size()>0)
	         {
	             for(Attachment varatt:lstAtt)
	             {
	                varatt.Body =blFile;
	                varatt.Name = strfileName; 
	                lstAttUpdate.add(varatt);
	             }
	           if(lstAttUpdate.size()>0)
	           {  
	               Update lstAttUpdate;
	               if(strfield=='Cedula') 
	               {   
	                   this.objSelectedLead.CedulaURL__c =strURLName+'/'+ strfileName +'-'+lstAttUpdate[0].id; 
	                   this.objSelectedLead.CedulaDoc__c= true;
	               }
	               if(strfield=='ReciboPublico') 
	               {   
	                   this.objSelectedLead.ReciboPublicoURL__c =strURLName+'/'+ strfileName +'-'+lstAttUpdate[0].id; 
	                   this.objSelectedLead.ReciboPublico__c= true;
	               }
	               if(strfield=='ComprobanteAtraso1') 
	               {   
	                   this.objSelectedLead.ComprobanteAtraso1URL__c =strURLName+'/'+ strfileName +'-'+lstAttUpdate[0].id; 
	                   this.objSelectedLead.ComprobanteAtraso1__c= true;
	               }
	               if(strfield=='ComprobanteAtraso2') 
	               {   
	                   this.objSelectedLead.ComprobanteAtraso2URL__c =strURLName+'/'+ strfileName +'-'+lstAttUpdate[0].id; 
	                   this.objSelectedLead.ComprobanteAtraso2__c= true;
	               }
	               if(strfield=='ComprobanteAtraso3') 
	               {   
	                   this.objSelectedLead.ComprobanteAtraso3URL__c =strURLName+'/'+ strfileName +'-'+lstAttUpdate[0].id; 
	                   this.objSelectedLead.ComprobanteAtraso3__c= true;
	               }
	               if(strfield=='ComprobanteAtraso4') 
	               {   
	                   this.objSelectedLead.ComprobanteAtraso4URL__c =strURLName+'/'+ strfileName +'-'+lstAttUpdate[0].id; 
	                   this.objSelectedLead.ComprobanteAtraso4__c= true;
	               }
	               if(strfield=='ComprobanteAtraso5') 
	               {   
	                   this.objSelectedLead.ComprobanteAtraso5URL__c =strURLName+'/'+ strfileName +'-'+lstAttUpdate[0].id; 
	                   this.objSelectedLead.ComprobanteAtraso5__c= true;
	               }
	               if(strfield=='ComprobanteAtraso6') 
	               {   
	                   this.objSelectedLead.ComprobanteAtraso6URL__c =strURLName+'/'+ strfileName +'-'+lstAttUpdate[0].id; 
	                   this.objSelectedLead.ComprobanteAtraso6__c= true;
	               }
	               
	              blnrefreshPage= true;
	           }
	         }
	       }
	         catch(Exception ex)
	         {
	           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: '+ex));
	         }
	 }
}