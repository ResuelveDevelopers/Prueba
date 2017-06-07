/********************************************************************************************************
Desarrollado por:   Resuelve
Autor:              Angela Munévar(AM)
Proyecto:           Resuelve tu Deuda
Descripción:        Clase permite actualizar los contratos digitales con la firma del usuario

Cambios (Versiones)
--------------------------------------------------------------------------------------------------------
    No.     Fecha               Autor                       Descripción
    ---     -----------         ------------------------    --------------------------      
    1.0     13-Sep-2016         Angela Munévar(AM)          Creación de la servicio Rest 
    1.1     13-Oct-2016         Esteban Heredia(EH)         Colocación de URL, para poder descargar el documento 
    1.2     24-Oct-2016         Esteban Heredia(EH)         Validación de diferentes estados, colocación fecha de cancelación
***************************************************************************************/

@RestResource(urlMapping='/Contrato/*')
global with sharing class RestRecepcionDocumentos 
{
    static string MessageError {get;set;}
    
    @HttpPut 
    global static respuesta ActualizarContrato(string NumAutentic, Datetime FechaFirma, string Estado, string MsjRechaso,
                    Map<string,DocumentoDigital__c> mapDocDig)
                            
    {
        system.debug('+++entro a ActualizarContrato');
        system.debug('valores: '+NumAutentic+ ' '+FechaFirma+' '+Estado+ ' '+MsjRechaso+ ' '+mapDocDig ); 
        respuesta resp = new respuesta();
        list<ContratoDigital__c> lstContrato = [SELECT Id,CandidatoId__c, NumeroRadicacioAutentic__c,Estado__c,FechaFirmaRechazo__c,MotivoRechazo__c,  
                                                  (select id, TipoDocumento__c,URLDocumentoFirmado__c from Documentos__r) 
                                                FROM ContratoDigital__c WHERE NumeroRadicacioAutentic__c =: NumAutentic]; 
        
        if(!lstContrato.IsEmpty())
        {
            if(mapDocDig.isEmpty() && Estado == 'Firmado')
            {
                resp.exito = false; 
                resp.msjResp = 'Se envia en estado firmado, pero no se mandan documentos';
            }
            else 
            {
                if(actualizarContratoDigital(lstContrato, Estado, FechaFirma, MsjRechaso).exito)
                {
                    if(!mapDocDig.isEmpty()) 
                    {
                        system.debug('mapDocDig--> ' + mapDocDig);
                        if(ActualizarDocumentoDigital(mapDocDig).exito)
                        {
                            resp = actualizarCandidato(lstContrato.get(0).CandidatoId__c, 'Firmado');
                        }
                        else resp.msjResp = MessageError;
                    }
                    else if(Estado != 'Firmado' && Estado != 'Contrato Expirado') 
                    {
                        resp = actualizarCandidato(lstContrato.get(0).CandidatoId__c,'Rechazado');
                    }
                    // Si el contarto es expirado se coloca la fecha de cancelacion
                    else if(Estado == 'Contrato Expirado' && FechaFirma != null)
                    {
                        lstContrato.get(0).FechaCancelacion__c = FechaFirma;
                        resp = actualizarCandidato(lstContrato.get(0).CandidatoId__c, 'Expirado');
                        if(resp.exito == true)
                            update lstContrato;
                    }

                    else {
                        resp.exito = false; 
                        resp.msjResp = 'No envió ningun documento para actualizar';
                    }
                }
                else resp.msjResp = MessageError;
            }
        }
        else{
            resp.exito = false;
            resp.msjResp = 'no se encontró ningun contrato con número de Radicación '+NumAutentic; 
        }
        return resp;
    }
    
    global class respuesta
    {
        public boolean exito {get; set;}
        public string msjResp {get; set;}
    }
    
    //actualiza el contrato digital 
    global static respuesta actualizarContratoDigital(list<ContratoDigital__c> lstContrato, string strEstado, Datetime dtfecFir, string strMsnRech )
    {                
        system.debug('+++entro a actualizar Contrato Digital ');
        respuesta resp = new respuesta();
        for(ContratoDigital__c objContr: lstContrato)
        {
            objContr.Estado__c = strEstado;
            if(strEstado != 'Contrato Expirado')
              objContr.FechaFirmaRechazo__c = dtfecFir;
            if(strMsnRech!= '')
            {
                objContr.MotivoRechazo__c = strMsnRech;
            }
        }
        try
        {
            update lstContrato;
            resp.exito = true;
            system.debug('+++contrato actualizado '+lstContrato);
        }
        catch(System.Exception e)
        {
            resp.exito = false;
            MessageError = e.getMessage();
            resp.msjResp = 'error: '+e.getMessage();
        }
        return resp;
    }
    
    global static respuesta ActualizarDocumentoDigital(Map<string,DocumentoDigital__c> mapDocDig)
    {
        system.debug('+++entro a Actualizar Documento Digital');
        respuesta resp = new respuesta();
        list<DocumentoDigital__c> lstDocDig = new list<DocumentoDigital__c>();
        String strBucketName = '';
        string strUrl = '';
        String strNombreArchivo = '';
        String strfinal = '';
        for (String ObjDoc : mapDocDig.keySet())
        {
            system.debug('nombreInstancia--> ' + System.URL.getSalesforceBaseUrl());
            strUrl = mapDocDig.get(ObjDoc).URLDocumentoFirmadoAmazon__c;
            strBucketName = strUrl.substringBefore('.').substringAfter('//');
            system.debug('strBucketName--> ' + strBucketName);
            strNombreArchivo = strUrl.substringAfterLast('/');
            system.debug('strNombreArchivo--> ' + strNombreArchivo);

            strfinal = 'https://' + System.URL.getSalesforceBaseUrl().gethost() + '/apex/VisorDocsAmazon?nameFile=' + strNombreArchivo + '&nb=' + strBucketName;
            system.debug('strfinal--> ' + strfinal); 

            lstDocDig.add(new DocumentoDigital__c(id = ObjDoc,
                                                  URLDocumentoFirmadoAmazon__c = mapDocDig.get(ObjDoc).URLDocumentoFirmadoAmazon__c,
                                                  URLDocumentoFirmado__c = strfinal));

        }
        try
        {
            update lstDocDig;
            resp.exito = true;
            system.debug('+++documento actualizado '+lstDocDig);
        }
        catch(System.Exception e)
        {
            resp.exito = false;
            MessageError = e.getMessage();
            resp.msjResp = 'error: '+e.getMessage();
        }
        return resp;
    } 

    global static respuesta actualizarCandidato(Id idCandidato, String strEstado)
    {
        respuesta resp = new respuesta();
        try
        {

            lead objCandidato = [SELECT Id,ContratoDigitalEnviado__c,URLAutentic__c FROM Lead WHERE Id=: idCandidato ];

            if(strEstado == 'Expirado')
            {
                resp.exito = true; 
                resp.msjResp = 'Actualizado estado y fecha de expiración';
                objCandidato.ContratoDigitalEnviado__c = false;
                objCandidato.URLAutentic__c = null;
            }
            else if(strEstado == 'Rechazado')
            {
                resp.exito = true; 
                resp.msjResp = 'Actualizado estado del documento';
                objCandidato.ContratoDigitalEnviado__c = false;
                objCandidato.URLAutentic__c = null;
            }
            else if(strEstado == 'Firmado')
            {
                resp.exito = true; 
                resp.msjResp = 'Firmado el documento';
                objCandidato.ContratoDigitalEnviado__c = false;
                objCandidato.URLAutentic__c = null;
            }
            update objCandidato;
            return resp;

        }
        catch(System.Exception e)
        {
            resp.exito = false;
            MessageError = e.getMessage();
            resp.msjResp = 'error: '+e.getMessage();
            return resp;
        }


    }
   
   public class UtilException extends Exception {} 
    
}