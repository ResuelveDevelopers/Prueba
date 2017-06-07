/********************************************************************************************************
Desarrollado por:   Resuelve
Autor:              Angela Munévar(AM)
Proyecto:           Resuelve tu Deuda
Descripción:        Clase permite adjuntar un archivo de Documento Carta de instrucción en la solicitud de fondo

Cambios (Versiones)
--------------------------------------------------------------------------------------------------------
    No.     Fecha               Autor                       Descripción
    ---     -----------         ------------------------    --------------------------      
    1.0     17-Mar-2016         Angela Munévar(AM)          Creación de la Clase 
***************************************************************************************/
public class CargaDocumentosCartaDeInstruccion_ctr 
{
        
    public SolicitudesDeFondos__c objSolicitudesDeFondos{get;set;}
    Transient public Blob blopCartInst {get;set;} 
   
    public String strURLName{get;set;}
    public Boolean blnrefreshPage {get; set;}
    public Boolean blnUploadEligible{get;set;} 
    public String strError{get;set;}
    public String strFileNameCartinst{get;set;}
    public Id idSolFondo{get;set;}
    public String strBucketName;

    public CargaDocumentosCartaDeInstruccion_ctr(ApexPages.StandardController controller) 
    {
        objSolicitudesDeFondos = (SolicitudesDeFondos__c)controller.getRecord();
        idSolFondo = objSolicitudesDeFondos.id;
        blnUploadEligible=true; 

        if (objSolicitudesDeFondos.Id != null) 
        {  
            objSolicitudesDeFondos  = [Select Id,CartaInstruccion1__c,CartaInstruccion2__c,CartaInstruccion3__c,Deuda__c
                                       from SolicitudesDeFondos__c where Id=: objSolicitudesDeFondos.Id];
        }
         strURLName='https://'+System.URL.getSalesforceBaseUrl().getHost().remove('-api' );
         CredencialesAmazon__c credentials = [Select Key__c, BucketName__c, Secret__c from CredencialesAmazon__c];
         strBucketName = credentials.BucketName__c;
         system.debug('+++mostrar '+blnUploadEligible);
    }

    //upload file for PagosEstructurados 1
    public void Upload_Solicitud1()
    {
        if(blopCartInst!=null)
            CargaCartaInstruccion(1);
         else
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No ha seleccionado ningun documento.'));   
    }
    //upload file for PagosEstructurados 2
    public void Upload_Solicitud2()
    {
        if(blopCartInst!=null)
            CargaCartaInstruccion(2);
        else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No ha seleccionado ningun documento.'));    
    }
    //upload file for PagosEstructurados 3
    public void Upload_Solicitud3()
    {
        if(blopCartInst!=null)
            CargaCartaInstruccion(3);
        else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No ha seleccionado ningun documento.'));    
    }


    public Pagereference CargaCartaInstruccion(Integer intConvLiq)
    {
        system.debug('+++Entro a cargar carta de instrucción '+blopCartInst);
        Boolean BoolSubioArchivo = false;
        AmazonS3 as3 = new AmazonS3();
        Deudas__c objDeuda_Update=new Deudas__c();

        if(objSolicitudesDeFondos.Deuda__c!=null)
        {
            objDeuda_Update=[SELECT CartaInstruccion1__c,CartaInstruccion2__c,CartaInstruccion3__c,CartaInstruccion4__c,
                                    CartaInstruccion5__c,CartaInstruccion6__c,CartaInstruccion7__c,CartaInstruccion8__c,
                                    CartaInstruccion9__c,CartaInstruccion10__c,CartaInstruccion11__c,CartaInstruccion12__c,
                                    CartaInstruccionCasilla__c FROM Deudas__c where Id=:objSolicitudesDeFondos.Deuda__c];
        }


        if(blopCartInst !=null && strFileNameCartinst!= null)
        {
            BoolSubioArchivo = as3.ConexionAmazon (blopCartInst, strFileNameCartinst );
            if(BoolSubioArchivo || Test.isRunningTest())
            {
                String encodedURL = EncodingUtil.urlEncode(strFileNameCartinst, 'UTF-8');

                if(intConvLiq==1)
                    objSolicitudesDeFondos.CartaInstruccion1__c  = 'https://s3.amazonaws.com/' + strBucketName + '/'+ encodedURL;
                if(intConvLiq==2)
                    objSolicitudesDeFondos.CartaInstruccion2__c  = 'https://s3.amazonaws.com/' + strBucketName + '/'+ encodedURL;
                if(intConvLiq==3)
                    objSolicitudesDeFondos.CartaInstruccion3__c  = 'https://s3.amazonaws.com/' + strBucketName + '/'+ encodedURL;

                Update objSolicitudesDeFondos;

                if(objSolicitudesDeFondos.Deuda__c!=null)
                updateDeuda(objDeuda_Update,'https://s3.amazonaws.com/' + strBucketName + '/'+ encodedURL);
                blnrefreshPage= true;
                blnUploadEligible=false; 
                return null;
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ya existe un documento con el mismo nombre'));
                return null;
            }
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No ha seleccionado ningun archivo.'));
            return null;
        }
        
        return null ;
    }



    //update Deuda__c
    public void updateDeuda(Deudas__c objDeuda,String strFileName)
    {
        Boolean blnflagFieldNo=true; 
        Integer intcountFieldNo=0;//get field no to update
        if(objDeuda.CartaInstruccion1__c==null){
            blnflagFieldNo=false;
            objDeuda.CartaInstruccion1__c=strFileName;
        }
        else
            if(objDeuda.CartaInstruccion2__c==null)
            {
                if(blnflagFieldNo){
                  blnflagFieldNo=false;
                  objDeuda.CartaInstruccion2__c=strFileName;
                }
            }
        else
            if(objDeuda.CartaInstruccion3__c==null){
                if(blnflagFieldNo){
                  blnflagFieldNo=false;
                  objDeuda.CartaInstruccion3__c=strFileName;
                }
            }
        else
            if(objDeuda.CartaInstruccion4__c==null){
                if(blnflagFieldNo){
                  blnflagFieldNo=false;
                  objDeuda.CartaInstruccion4__c=strFileName;
                }
            }
        else
            if(objDeuda.CartaInstruccion5__c==null){
                if(blnflagFieldNo){
                  blnflagFieldNo=false;
                  objDeuda.CartaInstruccion5__c=strFileName;
                }
            }
        else 
            if(objDeuda.CartaInstruccion6__c==null){
                if(blnflagFieldNo){
                  blnflagFieldNo=false;
                  objDeuda.CartaInstruccion6__c=strFileName;
                }
            }
        else
            if(objDeuda.CartaInstruccion7__c==null){
                if(blnflagFieldNo){
                  blnflagFieldNo=false;
                  objDeuda.CartaInstruccion7__c=strFileName;
                }
            }
        else
            if(objDeuda.CartaInstruccion8__c==null){
                if(blnflagFieldNo){
                    blnflagFieldNo=false;
                    objDeuda.CartaInstruccion8__c=strFileName;
                }
            }
        else
            if(objDeuda.CartaInstruccion9__c==null){
                if(blnflagFieldNo){
                  blnflagFieldNo=false;
                  objDeuda.CartaInstruccion9__c=strFileName;
                }
            }
        else
            if(objDeuda.CartaInstruccion10__c==null){
                if(blnflagFieldNo){
                  blnflagFieldNo=false;
                  objDeuda.CartaInstruccion10__c=strFileName;
                }
            }
        else
            if(objDeuda.CartaInstruccion11__c==null){
                if(blnflagFieldNo){
                  blnflagFieldNo=false;
                  objDeuda.CartaInstruccion11__c=strFileName;
                }
            }
        else
            if(objDeuda.CartaInstruccion12__c==null){
                if(blnflagFieldNo){
                    blnflagFieldNo=false;
                    objDeuda.CartaInstruccion12__c=strFileName;
                }
            }

        objDeuda.CartaInstruccionCasilla__c=true;
        Update objDeuda;
    
    }


}