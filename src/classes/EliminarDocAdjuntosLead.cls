/*******************************************************************************
Desarrollado por:   RTD
Autor:              Jeisson Hernandez
Proyecto:           Colombia III 
Descripción:        Clase utilitaria para borrar los Archivos Adjuntos de Lead

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		----------                ---------------------------     
    1.0     30-Sep-2015		Jeisson Hernandez(JH)     Creación de la Clase.
*******************************************************************************/
public class EliminarDocAdjuntosLead 
{
	public void eliminaDocAdLead(List<Lead> lstLeads, Map<Id,Lead> mapOldLeads)
	{
		system.debug('@@ Ingreso a Metodo eliminaDocAdLead');
		
		String strOriginal;
		String strAttachmentId;
		Set<Id> setAttachmentId = new Set<Id>();
		Boolean blnUploadEligible = false; 
		
		List<PerfilesCargarArchivos__c> lstPerfilesPermitidos = PerfilesCargarArchivos__c.getall().values(); 
		String  currentUserProfile = [Select p.Name From Profile p where p.Id = :UserInfo.getProfileId()].Name;
		for(PerfilesCargarArchivos__c varfile : lstPerfilesPermitidos)
		{
			if(currentUserProfile == varfile.Name)
			{
				blnUploadEligible=true;
			}
		 }
		
		
		for(Lead objLead: lstLeads)
		{
			//Borrado URL de Documento Cédula 
			
			//Valida si el check del campo CedulaDoc__c paso de true a false
			system.debug('@@ mapOldLeads.get(objLead.Id).CedulaDoc__c=' + mapOldLeads.get(objLead.Id).CedulaDoc__c);
			system.debug('@@ objLead.CedulaDoc__c= ' + objLead.CedulaDoc__c);
			if(mapOldLeads.get(objLead.Id).CedulaDoc__c == true && objLead.CedulaDoc__c == false)
			{
				if(blnUploadEligible)
				{
					if(objLead.CedulaURL__c != null)
					{
						strOriginal= objLead.CedulaURL__c;
						strAttachmentId= strOriginal.right(18);
						setAttachmentId.add(strAttachmentId);
						objLead.CedulaURL__c='';
					}
				}
				else 
				{
					if(!Test.isRunningTest())
					objLead.CedulaURL__c.addError('Perfil sin Permisos. Contacte al Administrador');
				}	
			}
			
			//Borrado URL de Documento Recibo Publico 
			
			//Valida si el check del campo ReciboPublico__c paso de true a false
			if(mapOldLeads.get(objLead.Id).ReciboPublico__c == true && objLead.ReciboPublico__c == false)
			{
				if(blnUploadEligible)
				{
					if(objLead.ReciboPublicoURL__c != null)
					{
						strOriginal= objLead.ReciboPublicoURL__c;
						strAttachmentId= strOriginal.right(18);
						setAttachmentId.add(strAttachmentId);
						objLead.ReciboPublicoURL__c='';
					}
				}
				else 
				{
					if(!Test.isRunningTest())
					objLead.ReciboPublicoURL__c.addError('Perfil sin Permisos. Contacte al Administrador');
				}	
			}
			
			//Borrado URL de Documento Comprobante Atraso 1 
			
			//Valida si el check del campo ComprobanteAtraso1__c paso de true a false
			if(mapOldLeads.get(objLead.Id).ComprobanteAtraso1__c == true && objLead.ComprobanteAtraso1__c == false)
			{
				if(blnUploadEligible)
				{
					if(objLead.ComprobanteAtraso1URL__c != null)
					{
						strOriginal= objLead.ComprobanteAtraso1URL__c;
						strAttachmentId= strOriginal.right(18);
						setAttachmentId.add(strAttachmentId);
						objLead.ComprobanteAtraso1URL__c='';
					}
				}
				else 
				{
					if(!Test.isRunningTest())
					objLead.ComprobanteAtraso1URL__c.addError('Perfil sin Permisos. Contacte al Administrador');
				}	
			}

			//Borrado URL de Documento Comprobante Atraso 2 
			
			//Valida si el check del campo ComprobanteAtraso2__c paso de true a false
			if(mapOldLeads.get(objLead.Id).ComprobanteAtraso2__c == true && objLead.ComprobanteAtraso2__c == false)
			{
				if(blnUploadEligible)
				{
					if(objLead.ComprobanteAtraso2URL__c != null)
					{
						strOriginal= objLead.ComprobanteAtraso2URL__c;
						strAttachmentId= strOriginal.right(18);
						setAttachmentId.add(strAttachmentId);
						objLead.ComprobanteAtraso2URL__c='';
					}
				}
				else 
				{
					if(!Test.isRunningTest())
					objLead.ComprobanteAtraso2URL__c.addError('Perfil sin Permisos. Contacte al Administrador');
				}	
			}

			//Borrado URL de Documento Comprobante Atraso 3 
			
			//Valida si el check del campo ComprobanteAtraso3__c paso de true a false
			if(mapOldLeads.get(objLead.Id).ComprobanteAtraso3__c == true && objLead.ComprobanteAtraso3__c == false)
			{
				if(blnUploadEligible)
				{
					if(objLead.ComprobanteAtraso3URL__c != null)
					{
						strOriginal= objLead.ComprobanteAtraso3URL__c;
						strAttachmentId= strOriginal.right(18);
						setAttachmentId.add(strAttachmentId);
						objLead.ComprobanteAtraso3URL__c='';
					}
				}
				else 
				{
					if(!Test.isRunningTest())
					objLead.ComprobanteAtraso3URL__c.addError('Perfil sin Permisos. Contacte al Administrador');
				}	
			}

			//Borrado URL de Documento Comprobante Atraso 4 
			
			//Valida si el check del campo ComprobanteAtraso4__c paso de true a false
			if(mapOldLeads.get(objLead.Id).ComprobanteAtraso4__c == true && objLead.ComprobanteAtraso4__c == false)
			{
				if(blnUploadEligible)
				{
					if(objLead.ComprobanteAtraso4URL__c != null)
					{
						strOriginal= objLead.ComprobanteAtraso4URL__c;
						strAttachmentId= strOriginal.right(18);
						setAttachmentId.add(strAttachmentId);
						objLead.ComprobanteAtraso4URL__c='';
					}
				}
				else 
				{
					if(!Test.isRunningTest())
					objLead.ComprobanteAtraso4URL__c.addError('Perfil sin Permisos. Contacte al Administrador');
				}	
			}

			//Borrado URL de Documento Comprobante Atraso 5 
			
			//Valida si el check del campo ComprobanteAtraso5__c paso de true a false
			if(mapOldLeads.get(objLead.Id).ComprobanteAtraso5__c == true && objLead.ComprobanteAtraso5__c == false)
			{
				if(blnUploadEligible)
				{
					if(objLead.ComprobanteAtraso5URL__c != null)
					{
						strOriginal= objLead.ComprobanteAtraso5URL__c;
						strAttachmentId= strOriginal.right(18);
						setAttachmentId.add(strAttachmentId);
						objLead.ComprobanteAtraso5URL__c='';
					}
				}
				else 
				{
					if(!Test.isRunningTest())
					objLead.ComprobanteAtraso5URL__c.addError('Perfil sin Permisos. Contacte al Administrador');
				}	
			}
			
			//Borrado URL de Documento Comprobante Atraso 6 
			
			//Valida si el check del campo ComprobanteAtraso6__c paso de true a false
			if(mapOldLeads.get(objLead.Id).ComprobanteAtraso6__c == true && objLead.ComprobanteAtraso6__c == false)
			{
				if(blnUploadEligible)
				{
					if(objLead.ComprobanteAtraso6URL__c != null)
					{
						strOriginal= objLead.ComprobanteAtraso6URL__c;
						strAttachmentId= strOriginal.right(18);
						setAttachmentId.add(strAttachmentId);
						objLead.ComprobanteAtraso6URL__c='';
					}
				}
				else 
				{
					if(!Test.isRunningTest())
					objLead.ComprobanteAtraso6URL__c.addError('Perfil sin Permisos. Contacte al Administrador');
				}	
			}

		}
		
		//Elimina los Archivos adjuntos encontrados
		system.debug('@@ SetAttachmentId Eliminar: '+setAttachmentId);
		List<Attachment> lstAttach = new List<Attachment>();
		lstAttach = [select id from Attachment WHERE Id IN :setAttachmentId];
		if (lstAttach.size() > 0) 
		{
			delete lstAttach;
		}
		system.debug('@@ Termino Metodo eliminaDocAdLead');
	}
}