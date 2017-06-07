/********************************************************************************************************
Desarrollado por:	RTD   
Autor:              Marwin Pineda(MP)
Proyecto:           Resuelve tu Deuda
Descripci�n:        Clase de consumo de Servicio Web de Env�o de Documentos.

Cambios (Versiones)
--------------------------------------------------------------------------------------------------------
    No.     Fecha               Autor                       Descripción
    ---     -----------         ------------------------    --------------------------      
    1.0     21-Sep-2016         Marwin Pineda(MP)          	Creación clase Servicio REST 
***************************************************************************************/


public class envioDocumentos_ctr 
{
	
	/*public String strMessage					{get; set;}
	public String strMessageSeverity			{get; set;}
	public Boolean blnShowMessage				{get; set;}
	
	public Map<String, Mensajes__c> mapMensajes	= Mensajes__c.getAll();*/
	
	EstructuraJSON objEstructura 					= new EstructuraJSON();
	EstructuraJSON.cls_pdfArray pdfDocs				= new EstructuraJSON.cls_pdfArray();
	Lead objLead 									= new Lead();
	List<DocumentoDigital__c> lstDocumentos			= new List<DocumentoDigital__c>();
	List<ContratoDigital__c> lstGeneracionContratos	= new List<ContratoDigital__c>();
	String strIdContrato							= '';
	Boolean blnValidaCaseNumber 					= false;
	String strCaseNumber							= '';
	String strURLAutentic							= '';
	Boolean blnValidar								= false;
	Boolean blnvalidarEstadoContrato				= false;
	

	//Este metodo se encarga de validar............
	public envioDocumentos_ctr(ApexPages.StandardController stdController)
	{
		
		CredencialesAmazonGeneral__c objCPCredenciales 	= CredencialesAmazonGeneral__c.getValues('authenticsf');
		String strBucket 								= objCPCredenciales.Name;
		String strRTRevisionContratoId					= Schema.SObjectType.Lead.getRecordTypeInfosByName().get('En revisión de Contrato').getRecordTypeId();
		String strRTContratoId							= Schema.SObjectType.ServiceCenter__c.getRecordTypeInfosByName().get('Contrato').getRecordTypeId();
		
		String strIdLead	= ApexPages.currentPage().getParameters().get('id');
		Boolean blnEstado 	= false;
		Boolean blnValidaSC	= false;
		
		Map<String, ContratoDigital__c> mapContratos = new Map<String, ContratoDigital__c>(); 					
								
		EstructuraJSON.cls_attorneyPowerDocs cartasPoder;//				= new EstructuraJSON.cls_attorneyPowerDocs();
		EstructuraJSON.cls_insuranceCoverDocs cartasAllianz				= new EstructuraJSON.cls_insuranceCoverDocs();
		EstructuraJSON.cls_contractDocs cartasContratoRTD 				= new EstructuraJSON.cls_contractDocs ();
		EstructuraJSON.cls_payStubDoc reciboPago 						= new EstructuraJSON.cls_payStubDoc();
			
		List<EstructuraJSON.cls_attorneyPowerDocs > lstCartasPoder		= new List<EstructuraJSON.cls_attorneyPowerDocs>();
		List<EstructuraJSON.cls_insuranceCoverDocs> lstcartasAllianz	= new List<EstructuraJSON.cls_insuranceCoverDocs>();
		List<EstructuraJSON.cls_contractDocs> lstContratosRTD 			= new List<EstructuraJSON.cls_contractDocs>();
		
		objLead = [SELECT Id,
						PrimerNombre__c, 
						SegundoNombre__c,
						PrimerApellido__c,
						SegundoApellido__c,
						TipoDocAfiliado__c,
						Cedula__c,
						RecordTypeId,
						RecordType.Name,
						Referencia__c,
						ContratoDigitalEnviado__c,
						(SELECT Id,Estado__c,Name FROM Contratos_Digitales_del__r),
						(SELECT FechaCierre__c, Id, Name, RecordTypeId, Status__c FROM ServiceCenter__r)
					FROM
						Lead
					WHERE Id = :strIdLead];
					
		try
		{
			if(objLead.RecordTypeId != strRTRevisionContratoId)
			{
				System.debug('\n\n@@@Entra RT----->\n\n');
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'El tipo de registro de la oportunidad debe ser En revisión de Contrato'));
			}
			
			else
			{
				if(objLead.ServiceCenter__r.size() == 0)
				{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'El candidato no tiene un Service Center asociado'));
				}
				else
				{
					List<AggregateResult> lstFechasCierre =	[SELECT 
																MAX(FechaCierre__c) ultimaFechaCierre,
																Oportunidad__c 
															FROM 
																ServiceCenter__c 
															WHERE Status__c = 'Cerrado / Realizado'
															AND RecordTypeId = :strRTContratoId
															AND Oportunidad__c = :strIdLead
															GROUP BY Oportunidad__c];
				
					System.debug('\n\n@@@lstFechasCierre--------> ' + lstFechasCierre + '\n\n');
					
					if(lstFechasCierre.isEmpty())
					{
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'La oportunidad debe contener un service center con las siguientes condiciones:'));
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Status = Cerrado / Realizado')); 
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Fecha de cierre sea menor o igual a 30 días'));
						throw new UtilException('La oportunidad debe contener un service center con las siguientes condiciones:');	
					}
					
					for(AggregateResult objARFechaCierre :lstFechasCierre)
					{
						Datetime dtFechaCierre = (Datetime)objARFechaCierre.get('ultimaFechaCierre');
						
						if(dtFechaCierre.date().daysBetween(Date.today()) <= 30)
						{
							blnValidaSC = true;	
						}						
					}
				}
														
				if(objLead.Contratos_Digitales_del__r.size() == 0)
				{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No tiene contratos digitales relacionados con la oportunidad'));
				}
				else
				{
					for(ContratoDigital__c objContrato :objLead.Contratos_Digitales_del__r)
					{
						if(objContrato.Estado__c == 'Generación de Contrato')
						{
							lstGeneracionContratos.add(objContrato);
							blnvalidarEstadoContrato = true;
						}
						if(objContrato.Estado__c == 'Enviado')
						{
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Actualmente existe un contrato con estado enviado'));
							blnEstado = false;
							blnvalidarEstadoContrato = false;
						}
					}
					
					System.debug('\n\n@@@Size---------> ' + lstGeneracionContratos.size() + '\n' + 
						'@@@blnvalidarEstadoContrato-------> ' + blnvalidarEstadoContrato + '\n\n');
					
					if(lstGeneracionContratos.size() == 1 && blnvalidarEstadoContrato)
					{
						strIdContrato 	= lstGeneracionContratos.get(0).Id;
						blnEstado 		= true;
						mapContratos.put(lstGeneracionContratos.get(0).Id,lstGeneracionContratos.get(0));
					}
					else //if(lstGeneracionContratos.size() == 1 && !objLead.ContratoDigitalEnviado__c)
					{
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Tiene más de un contrato con estado \'Generación de Contrato\''));							
					}
				}
								
				if(blnEstado && blnValidaSC)
				{
					for(DocumentoDigital__c objDocumento :[SELECT 
																Id, 
																Name, 
																ContratoDigitalId__c,
																URLDocumentoEnviado__c,
																TipoDocumento__c,
																URLDocumentoEnviadoAmazon__c,
																ContratoDigitalId__r.Name 
															FROM 
																DocumentoDigital__c 
															WHERE ContratoDigitalId__c = :strIdContrato])
					{
						
						String strUrl			= objDocumento.URLDocumentoEnviadoAmazon__c;
						String strNombreArchivo	= strUrl.substringAfterLast('/');
						
						if(objDocumento.TipoDocumento__c == 'Carta Poder')
						{
							EstructuraJSON.cls_accessPath rutaAccesoCP	= new EstructuraJSON.cls_accessPath();
							rutaAccesoCP.urlAccess 						= objDocumento.URLDocumentoEnviadoAmazon__c;
							rutaAccesoCP.bucket 						= strBucket;
							cartasPoder									= new EstructuraJSON.cls_attorneyPowerDocs();
							cartasPoder.accessPath 						= rutaAccesoCP;
							cartasPoder.name 							= strNombreArchivo;
							cartasPoder.id 								= objDocumento.Id;
							lstCartasPoder.add(cartasPoder);
						}
						
						if(objDocumento.TipoDocumento__c == 'Contrato Allianz')
						{
							EstructuraJSON.cls_accessPath rutaAccesoCA	= new EstructuraJSON.cls_accessPath();
							rutaAccesoCA.urlAccess 						= objDocumento.URLDocumentoEnviadoAmazon__c;
							rutaAccesoCA.bucket 						= strBucket;
							cartasAllianz.accessPath 					= rutaAccesoCA;
							cartasAllianz.name 							= strNombreArchivo;
							cartasAllianz.id							= objDocumento.Id;
							lstcartasAllianz.add(cartasAllianz);
						}
						
						if(objDocumento.TipoDocumento__c == 'Contrato RTD')
						{
							EstructuraJSON.cls_accessPath rutaAccesoCRTD	= new EstructuraJSON.cls_accessPath();
							rutaAccesoCRTD.urlAccess 						= objDocumento.URLDocumentoEnviadoAmazon__c;
							rutaAccesoCRTD.bucket 							= strBucket;
							cartasContratoRTD.accessPath					= rutaAccesoCRTD;
							cartasContratoRTD.name							= strNombreArchivo;
							cartasContratoRTD.id							= objDocumento.Id;
							lstContratosRTD.add(cartasContratoRTD);
						}
						
						if(objDocumento.TipoDocumento__c == 'Recibo de Pago')
						{
							EstructuraJSON.cls_accessPath rutaAccesoRP	= new EstructuraJSON.cls_accessPath();
							rutaAccesoRP.urlAccess 						= objDocumento.URLDocumentoEnviadoAmazon__c;
							rutaAccesoRP.bucket 						= strBucket;
							reciboPago.accessPath						= rutaAccesoRP;
							reciboPago.name								= strNombreArchivo;
							reciboPago.id								= objDocumento.Id;
						}
					}
					
					objEstructura.processId								= strIdContrato;
					EstructuraJSON.cls_signerProperties datosPersonales = new EstructuraJSON.cls_signerProperties();
					datosPersonales.firstName 							= objLead.PrimerNombre__c;
					datosPersonales.secondName 							= objLead.SegundoNombre__c;
					datosPersonales.surName 							= objLead.PrimerApellido__c;
					datosPersonales.secondSurName 						= objLead.SegundoApellido__c;
					datosPersonales.docType 							= objLead.TipoDocAfiliado__c;			
					datosPersonales.docId 								= objLead.Cedula__c;
					objEstructura.signerProperties						= datosPersonales;
					
					pdfDocs.attorneyPowerDocs	= lstCartasPoder;
					pdfDocs.insuranceCoverDocs	= lstcartasAllianz;
					pdfDocs.contractDocs		= lstContratosRTD;
					pdfDocs.payStubDoc 			= reciboPago;
					
					objEstructura.pdfArray	= pdfDocs;
					String strJSON			= JSON.serialize(objEstructura);
					
					if(!pdfDocs.attorneyPowerDocs.isEmpty() 
						&& !pdfDocs.insuranceCoverDocs.isEmpty()
						&& !pdfDocs.contractDocs.isEmpty()
						&& pdfDocs.payStubDoc.id != null)
					{
						String strRespuestaWS = RestEnvioDocumentos.envioDocumentos(strJSON);
						
						if(strRespuestaWS == 'Error Servicio Web')
						{
							 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error en el Servicio Web'));
						}
						else
						{
							RespuestaJSON objRespuesta = (RespuestaJSON)JSON.deserialize(strRespuestaWS, RespuestaJSON.class);
							
							if(String.isNotEmpty(objRespuesta.caseNumber))
							{
								blnValidaCaseNumber = true;
								strCaseNumber 		= objRespuesta.caseNumber;
								strURLAutentic		= objRespuesta.urlAccess; 
							}
							blnValidar 			= true;
							String strContrato	= mapContratos.get(strIdContrato).Name;
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'El contrato ' + strContrato + ' perteneciente a la referencia ' + objLead.Referencia__c + ' se ha enviado correctamente. ' + 'Número de radicación Autentic ' + strCaseNumber)); 
						}
					}
					else
					{
						if(pdfDocs.attorneyPowerDocs.isEmpty())
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Hace falta la carta poder'));
						if(pdfDocs.insuranceCoverDocs.isEmpty())
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Hace falta el contrato Allianz'));
						if(pdfDocs.contractDocs.isEmpty())
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Hace falta el contrato RTD'));
						if(pdfDocs.payStubDoc.id == null)
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Hace falta el recibo de pago'));
					}
				}
			}
		}
		catch(Exception e)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}
		
		
	}
	
	public void actualizarContrato()
	{
		try
		{
			if(blnValidaCaseNumber)
			{
				objLead.ContratoDigitalEnviado__c	= true;
				objLead.URLAutentic__c				= strURLAutentic;
				objLead.Id							= ApexPages.currentPage().getParameters().get('id');
				update objLead;
				
				ContratoDigital__c objContrato  		= new ContratoDigital__c();
				objContrato.Id							= strIdContrato;
				objContrato.Estado__c					= 'Enviado';
				objContrato.FechaEnvio__c				= System.now();
				objContrato.NumeroRadicacioAutentic__c	= strCaseNumber;
				//objContrato.VendedorAsignado__c		= objRH.Id;
				update objContrato;
			}
			if(blnValidar)
			{
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'El servicio Web se ejecutó correctamente'));
				
			}	
		}
		catch(Exception e)
		{
			//blnValidar = false;
			if(!blnValidar)
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Debido a que no se actualizaron los registros el Servicio Web no se ejecutó correctamente'));
			}
			
		}
	}
	
	public class RespuestaJSON
	{
		String caseNumber	= '';
		String urlAccess 	= '';
		String errorMsg 	= '';
	}
	
	public class UtilException extends Exception {}

	/*public void setMessage( String strMessage, String strMessageSeverity, Boolean blnShowMessage )
	{
		this.strMessage												= strMessage;
		this.strMessageSeverity										= strMessageSeverity;
		this.blnShowMessage											= blnShowMessage;
	}*/	
	
}