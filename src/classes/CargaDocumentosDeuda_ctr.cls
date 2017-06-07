/********************************************************************************************************
Desarrollado por:   Resuelve
Autor:              Angela Munévar(AM)
Proyecto:           Resuelve tu Deuda
Descripción:        Clase permite adjuntar un archivo de Documentos en la Deuda

Cambios (Versiones)
--------------------------------------------------------------------------------------------------------
    No.     Fecha               Autor                       Descripción
    ---     -----------         ------------------------    --------------------------      
    1.0     22-Ago-2016         Angela Munévar(AM)          Creación de la Clase 
    1.1     19-Oct-2016         Esteban Heredia(EH)         Colocación Bucket URL y abrir adjunto antiguos normal 
***************************************************************************************/
public class CargaDocumentosDeuda_ctr 
{
    public Id idDeuda {get;set;} 
    public Deudas__c objDeuda {get;set;} 
    public Boolean blnrefreshPage {get; set;}
    public Integer fileSize {get;set;}
    public Boolean ExisteArchivo {get;set;}
    public String strFileName{get;set;}
    Transient public Blob BlobCompLiqui {get;set;}
    Transient public Blob BlobCartaPoder {get;set;} 
    Transient public Blob BlobPazSalvo {get;set;} 
    Transient public Blob BlobConvLiqui {get;set;}
    Transient public Blob BlobOtroDoc {get;set;}
    public AmazonS3.ResponseGet ressync; 
    public String Archivo {get;set;}
    // the variable being set from the commandlink
    public String nombreArchivoDescargar {get; set;}
    public String strBucketName;
    
        

    public CargaDocumentosDeuda_ctr(ApexPages.StandardController controller) 
    {
        this.objDeuda = (Deudas__c)controller.getRecord();
        this.idDeuda= objDeuda.Id;
        objDeuda= getDeuda(this.objDeuda.id);
        ExisteArchivo = false;
        CredencialesAmazon__c credentials = [Select Key__c, BucketName__c, Secret__c from CredencialesAmazon__c];
        strBucketName = credentials.BucketName__c;
    }

    public PageReference CargaComprobanteLiquidacion1(){
        return CargaComprobantesLiquidacion(1);
    }
     //upload file for ConvenioLiquidacion 2
    public PageReference CargaComprobanteLiquidacion2(){
        return CargaComprobantesLiquidacion(2);
    }
     //upload file for ConvenioLiquidacion 3
    public PageReference CargaComprobanteLiquidacion3(){
        return CargaComprobantesLiquidacion(3); 
    }
     public PageReference CargaComprobanteLiquidacion4(){
        return CargaComprobantesLiquidacion(4);
    }
     //upload file for ConvenioLiquidacion 5
    public PageReference CargaComprobanteLiquidacion5(){
        return CargaComprobantesLiquidacion(5);
    }
     //upload file for ConvenioLiquidacion 6
    public PageReference CargaComprobanteLiquidacion6(){
        return CargaComprobantesLiquidacion(6); 
    }
    public PageReference CargaComprobanteLiquidacion7(){
        return CargaComprobantesLiquidacion(7);
    }
    public PageReference CargaComprobanteLiquidacion8(){
        return CargaComprobantesLiquidacion(8);
    }

    public Pagereference CargaComprobantesLiquidacion(Integer intConpLiq)
    {
        system.debug('+++Entro a cargar Comprobante de liquidación '+intConpLiq);
        Boolean BoolSubioArchivo;
        AmazonS3 as3 = new AmazonS3();

        if(BlobCompLiqui !=null)
        {
            BoolSubioArchivo = as3.ConexionAmazon (BlobCompLiqui, strFileName );
            if(BoolSubioArchivo || Test.isRunningTest())
            {
                String encodedURL = EncodingUtil.urlEncode(strFileName, 'UTF-8');
                if(intConpLiq == 1)
                    objDeuda.ComprobanteLiquidacion1__c = 'https://s3.amazonaws.com/' + strBucketName + '/' + encodedURL;
                if(intConpLiq == 2)
                    objDeuda.ComprobanteLiquidacion2__c = 'https://s3.amazonaws.com/' + strBucketName + '/' + encodedURL;
                if(intConpLiq == 3)
                    objDeuda.ComprobanteLiquidacion3__c = 'https://s3.amazonaws.com/' + strBucketName + '/' + encodedURL;
                if(intConpLiq == 4)
                    objDeuda.ComprobanteLiquidacion4__c = 'https://s3.amazonaws.com/' + strBucketName + '/' + encodedURL;
                if(intConpLiq == 5)
                    objDeuda.ComprobanteLiquidacion5__c = 'https://s3.amazonaws.com/' + strBucketName + '/' + encodedURL;
                if(intConpLiq == 6)
                    objDeuda.ComprobanteLiquidacion6__c = 'https://s3.amazonaws.com/' + strBucketName + '/' + encodedURL;
                if(intConpLiq == 7)
                    objDeuda.ComprobanteLiquidacion7__c = 'https://s3.amazonaws.com/' + strBucketName + '/' + encodedURL;
                if(intConpLiq == 8)
                    objDeuda.ComprobanteLiquidacion8__c = 'https://s3.amazonaws.com/' + strBucketName + '/' + encodedURL;

                objDeuda.ComprobanteLiquidacionCasilla__c = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Archivo cargado Correctamente'));
                update objDeuda;
                system.debug('+++ComprobanteLiquidacion7__c '+objDeuda.ComprobanteLiquidacion7__c); 
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ya existe un documento con el mismo nombre'));
            }
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No ha seleccionado ningun archivo.'));
            return null;
        }
        PageReference pageRef = new PageReference('/apex/CargaDocumentosDeuda?id='+objDeuda.Id);
        return pageRef ;
        
    }

    public Pagereference CargaCartaPoder()
    {
        system.debug('+++Entro a cargar Carta poder '+BlobCartaPoder);
        Boolean BoolSubioArchivo;
        AmazonS3 as3 = new AmazonS3();

        if(BlobCartaPoder !=null)
        {
            BoolSubioArchivo = as3.ConexionAmazon (BlobCartaPoder, strFileName );
            if(BoolSubioArchivo || Test.isRunningTest())
            {
                String encodedURL = EncodingUtil.urlEncode(strFileName, 'UTF-8');
                objDeuda.CartaPoder__c = 'https://s3.amazonaws.com/' + strBucketName + '/' + encodedURL;
                objDeuda.CartaPoderCasilla__c = true;
                update objDeuda;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Archivo cargado Correctamente'));
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ya existe un documento con el mismo nombre'));
            }
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No ha seleccionado ningun archivo.'));
            return null;
        }
        PageReference pageRef = new PageReference('/apex/CargaDocumentosDeuda?id='+objDeuda.Id);
        return pageRef ;
    }

    public Pagereference CargaPazSalvo()
    {
        system.debug('+++Entro a cargar Paz y salvo '+BlobPazSalvo);
        Boolean BoolSubioArchivo;
        AmazonS3 as3 = new AmazonS3();
        
        if(BlobPazSalvo !=null)
        {
            BoolSubioArchivo = as3.ConexionAmazon (BlobPazSalvo, strFileName );
            if(BoolSubioArchivo || Test.isRunningTest())
            {
                String encodedURL = EncodingUtil.urlEncode(strFileName, 'UTF-8');
                objDeuda.PazySalvo__c = 'https://s3.amazonaws.com/' + strBucketName + '/' + encodedURL;
                objDeuda.PazYSalvoCasilla__c = true;
                update objDeuda;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Archivo cargado Correctamente'));
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ya existe un documento con el mismo nombre'));
            }
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No ha seleccionado ningun archivo.'));
            return null;
        }
        PageReference pageRef = new PageReference('/apex/CargaDocumentosDeuda?id='+objDeuda.Id);
        return pageRef ;
    }

    public PageReference CargaConvenioLiquidacion1(){
        return CargaConveniosLiquidacion(1);
    }
     //upload file for ConvenioLiquidacion 2
    public PageReference CargaConvenioLiquidacion2(){
        return CargaConveniosLiquidacion(2);
    }
     //upload file for ConvenioLiquidacion 3
    public PageReference CargaConvenioLiquidacion3(){
        return CargaConveniosLiquidacion(3); 
    }

    public Pagereference CargaConveniosLiquidacion(Integer intConvLiq)
    {
        system.debug('+++Entro a cargar convenio de liquidacion '+BlobConvLiqui);
        Boolean BoolSubioArchivo;
        AmazonS3 as3 = new AmazonS3();

        if(BlobConvLiqui !=null)
        {
            BoolSubioArchivo = as3.ConexionAmazon (BlobConvLiqui, strFileName );
            if(BoolSubioArchivo || Test.isRunningTest())
            {
                String encodedURL = EncodingUtil.urlEncode(strFileName, 'UTF-8');
                if(intConvLiq == 1)
                    objDeuda.ConvenioLiquidacion1__c = 'https://s3.amazonaws.com/' + strBucketName + '/' + encodedURL;
                if(intConvLiq == 2)
                    objDeuda.ConvenioLiquidacion2__c = 'https://s3.amazonaws.com/' + strBucketName + '/' + encodedURL;
                if(intConvLiq == 3)
                    objDeuda.ConvenioLiquidacion3__c = 'https://s3.amazonaws.com/' + strBucketName + '/' + encodedURL;

                objDeuda.ConvenioLiquidacionCasilla__c = true;
                update objDeuda;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Archivo cargado Correctamente'));
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ya existe un documento con el mismo nombre'));
            }
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No ha seleccionado ningun archivo.'));
            return null;
        }
        PageReference pageRef = new PageReference('/apex/CargaDocumentosDeuda?id='+objDeuda.Id);
        return pageRef ;
    }


    public PageReference CargaOtroDocumento1(){
        return CargaOtrosDocumentos(1);
    }

    public PageReference CargaOtroDocumento2(){
        return CargaOtrosDocumentos(2);
    }

    public PageReference CargaOtroDocumento3(){
        return CargaOtrosDocumentos(3); 
    }



    public Pagereference CargaOtrosDocumentos(Integer intOtroDoc)
    {
        system.debug('+++Entro a cargar Cargar Otros Documentos '+BlobOtroDoc);
        Boolean BoolSubioArchivo;
        AmazonS3 as3 = new AmazonS3();
        if(BlobOtroDoc !=null)
        {
            BoolSubioArchivo = as3.ConexionAmazon (BlobOtroDoc, strFileName );
            if(BoolSubioArchivo || Test.isRunningTest())
            {
                String encodedURL = EncodingUtil.urlEncode(strFileName, 'UTF-8');
                if(intOtroDoc == 1)
                    objDeuda.OtroDocumento1__c = 'https://s3.amazonaws.com/' + strBucketName + '/' + encodedURL;
                if(intOtroDoc == 2)
                    objDeuda.OtroDocumento2__c = 'https://s3.amazonaws.com/' + strBucketName + '/' + encodedURL;
                if(intOtroDoc == 3)
                    objDeuda.OtroDocumento3__c = 'https://s3.amazonaws.com/' + strBucketName + '/' + encodedURL;

                objDeuda.OtrosDocumentos__c = true;

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Archivo cargado Correctamente'));
                update objDeuda;
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ya existe un documento con el mismo nombre'));
            }
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No ha seleccionado ningun archivo.'));
            return null;
        }
        PageReference pageRef = new PageReference('/apex/CargaDocumentosDeuda?id='+objDeuda.Id);
        return pageRef ;
    }

    public PageReference DescargarComprobanteLiquidacion1()
    {
        system.debug('+++objDeuda '+objDeuda.ComprobanteLiquidacion1__c);
        return getArchivo(objDeuda.ComprobanteLiquidacion1__c);
    }
    public PageReference DescargarComprobanteLiquidacion2()
    {
        return getArchivo(objDeuda.ComprobanteLiquidacion2__c);
    }

    public PageReference DescargarComprobanteLiquidacion3()
    {
        return getArchivo(objDeuda.ComprobanteLiquidacion3__c); 
    }
    public PageReference DescargarComprobanteLiquidacion4()
    {
        return getArchivo(objDeuda.ComprobanteLiquidacion4__c);
    }

    public PageReference DescargarComprobanteLiquidacion5()
    {
        return getArchivo(objDeuda.ComprobanteLiquidacion5__c);
    }

    public PageReference DescargarComprobanteLiquidacion6()
    {
        return getArchivo(objDeuda.ComprobanteLiquidacion6__c);
    }
    public PageReference DescargarComprobanteLiquidacion7()
    {
        return getArchivo(objDeuda.ComprobanteLiquidacion7__c);
    }
    public PageReference DescargarComprobanteLiquidacion8()
    {
        return getArchivo(objDeuda.ComprobanteLiquidacion8__c);
    }
    public PageReference DescargarCartaPoder()
    {
        return getArchivo(objDeuda.CartaPoder__c);
    }
    public PageReference DescargarPazSalvo()
    {
        return getArchivo(objDeuda.PazySalvo__c);
    }
    public PageReference DescargarConvenioLiquidacion1()
    {
        return getArchivo(objDeuda.ConvenioLiquidacion1__c);
    }
    public PageReference DescargarConvenioLiquidacion2()
    {
        return getArchivo(objDeuda.ConvenioLiquidacion2__c);
    }
    public PageReference DescargarConvenioLiquidacion3()
    {
        return getArchivo(objDeuda.ConvenioLiquidacion3__c);
    }
    public PageReference DescargarOtroDocumento1()
    {
        return getArchivo(objDeuda.OtroDocumento1__c);
    }
    public PageReference DescargarOtroDocumento2()
    {
        return getArchivo(objDeuda.OtroDocumento2__c);
    }

    public PageReference DescargarOtroDocumento3()
    {
        return getArchivo(objDeuda.OtroDocumento3__c);
    }
    public PageReference DescargarCartaInstruccion1()
    {
        if(objDeuda.CartaInstruccion1__c.contains('servlet/servlet'))
            return descargarAdjunto(objDeuda.CartaInstruccion1__c);
        else
            return getArchivo(objDeuda.CartaInstruccion1__c); 
    }
    public PageReference DescargarCartaInstruccion2()
    {
        if(objDeuda.CartaInstruccion2__c.contains('servlet/servlet'))
            return descargarAdjunto(objDeuda.CartaInstruccion2__c);
        else
            return getArchivo(objDeuda.CartaInstruccion2__c); 
       
    }
    public PageReference DescargarCartaInstruccion3()
    {
        if(objDeuda.CartaInstruccion3__c.contains('servlet/servlet'))
            return descargarAdjunto(objDeuda.CartaInstruccion3__c);
        else
            return getArchivo(objDeuda.CartaInstruccion3__c); 
    }
    public PageReference DescargarCartaInstruccion4()
    {
        if(objDeuda.CartaInstruccion4__c.contains('servlet/servlet'))
            return descargarAdjunto(objDeuda.CartaInstruccion4__c);
        else
            return getArchivo(objDeuda.CartaInstruccion4__c); 
    }
    public PageReference DescargarCartaInstruccion5()
    {
        if(objDeuda.CartaInstruccion5__c.contains('servlet/servlet'))
            return descargarAdjunto(objDeuda.CartaInstruccion5__c);
        else
            return getArchivo(objDeuda.CartaInstruccion5__c); 
    }
    public PageReference DescargarCartaInstruccion6()
    {
        if(objDeuda.CartaInstruccion6__c.contains('servlet/servlet'))
            return descargarAdjunto(objDeuda.CartaInstruccion6__c);
        else
            return getArchivo(objDeuda.CartaInstruccion6__c); 
    }
    public PageReference DescargarCartaInstruccion7()
    {
        if(objDeuda.CartaInstruccion7__c.contains('servlet/servlet'))
            return descargarAdjunto(objDeuda.CartaInstruccion7__c);
        else
            return getArchivo(objDeuda.CartaInstruccion7__c); 
    }
    public PageReference DescargarCartaInstruccion8()
    {
        if(objDeuda.CartaInstruccion8__c.contains('servlet/servlet'))
            return descargarAdjunto(objDeuda.CartaInstruccion8__c);
        else
            return getArchivo(objDeuda.CartaInstruccion8__c); 
    }
    public PageReference DescargarCartaInstruccion9()
    {
        if(objDeuda.CartaInstruccion9__c.contains('servlet/servlet'))
            return descargarAdjunto(objDeuda.CartaInstruccion9__c);
        else
            return getArchivo(objDeuda.CartaInstruccion9__c); 
    }
    public PageReference DescargarCartaInstruccion10()
    {
        if(objDeuda.CartaInstruccion10__c.contains('servlet/servlet'))
            return descargarAdjunto(objDeuda.CartaInstruccion10__c);
        else
            return getArchivo(objDeuda.CartaInstruccion10__c); 
    }
    public PageReference DescargarCartaInstruccion11()
    {
        if(objDeuda.CartaInstruccion11__c.contains('servlet/servlet'))
            return descargarAdjunto(objDeuda.CartaInstruccion11__c);
        else
            return getArchivo(objDeuda.CartaInstruccion11__c); 
    }
    public PageReference DescargarCartaInstruccion12()
    {
        if(objDeuda.CartaInstruccion12__c.contains('servlet/servlet'))
            return descargarAdjunto(objDeuda.CartaInstruccion12__c);
        else
            return getArchivo(objDeuda.CartaInstruccion12__c); 
    }


    // EH START 19-10-2016: Leer los adjuntos antiguos
    public PageReference descargarAdjunto(string strUrlArchivo)
    {
        PageReference redirige = new PageReference(strUrlArchivo);
        return redirige; 
    }

    //


    // metodo que obtiene a partir del nombre del archivo la ctype para la descarga
    public PageReference getArchivo(string StrNomArc)
    {
        system.debug('+++entro a getArchivo: '+StrNomArc);
        Boolean DescargaOk = false; 
        PageReference redirige = null;
        //obtiene el nombre del archivo de la url
        StrNomArc = StrNomArc.substring(StrNomArc.lastIndexOf('/')+1);
        system.debug('+++strNombreArchivo '+StrNomArc );
        DescargaOk = DescargarArchivo(StrNomArc);
        if(DescargaOk || Test.isRunningTest())
        {
            String strExtension = StrNomArc.substring(StrNomArc.lastIndexOf('.')+1);
            system.debug('+++strExtension '+strExtension);
            string ctype= '';
            if(strExtension !='')
            {
                if(strExtension =='pdf') ctype='application/pdf';
                else if(strExtension =='exe') ctype='application/octet-stream';
                else if(strExtension =='zip') ctype='application/zip';
                else if(strExtension =='doc') ctype='application/msword';
                else if(strExtension =='docx') ctype='application/vnd.openxmlformats-officedocument.wordprocessingml.document';
                else if(strExtension =='xls') ctype='application/vnd.ms-excel';
                else if(strExtension =='xlsx') ctype='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
                else if(strExtension =='ppt') ctype='application/vnd.ms-powerpoint';
                else if(strExtension =='gif') ctype='image/gif';
                else if(strExtension =='png') ctype='image/png';
                else if(strExtension =='jpg') ctype='image/jpg';
                else ctype='application/force-download';

                redirige = new PageReference('data:'+ctype+';content-disposition:attachment;base64,' + Archivo);
                redirige.setRedirect(true);
                system.debug('+++ redirige '+redirige.getUrl());
            }

        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Archivo no encontrado'));
           
        }
         return redirige;   
    }
    

   
    public Boolean DescargarArchivo( string strFileName)
    {
        system.debug('+++entro a DescargarArchivo');
        
        CredencialesAmazon__c credentials = [Select Key__c, BucketName__c, Secret__c from CredencialesAmazon__c];
        AmazonS3 as3 = new AmazonS3(credentials.Key__c,credentials.Secret__c);

        if(credentials != null)
        {
            // Consulta si ya existe un archivo con el mismo nombre en Amazon
            ressync = as3.getObject( strFileName, credentials.BucketName__c,  credentials.Key__c, credentials.Secret__c);
            system.debug('+++llegó hasta aqui');
            if(ressync.BollExiste)
            {
                Archivo = EncodingUtil.base64Encode(ressync.blobBody);
                system.debug('Archivo '+Archivo);
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Archivo no encontrado'));
            }
        }
        return ressync.BollExiste;
    }

    // metodo que obtiene a partir del nombre del archivo la ctype para la descarga ESTEBAN
    public PageReference getArchivo2()
    {
        system.debug('nombreArchivoDescargar --> ' + nombreArchivoDescargar);
        String StrNomArc = '';
        Boolean DescargaOk = false; 
        PageReference redirige = null;
        //obtiene el nombre del archivo de la url
        nombreArchivoDescargar = nombreArchivoDescargar.substring(nombreArchivoDescargar.lastIndexOf('/')+1);
        system.debug('+++strNombreArchivo '+nombreArchivoDescargar );
        DescargaOk = DescargarArchivo2(nombreArchivoDescargar);
        if(DescargaOk || Test.isRunningTest())
        {
            String strExtension = nombreArchivoDescargar.substring(nombreArchivoDescargar.lastIndexOf('.')+1);
            system.debug('+++strExtension '+strExtension);
            string ctype= '';
            if(strExtension !='')
            {
                if(strExtension =='pdf') ctype='application/pdf';
                else if(strExtension =='exe') ctype='application/octet-stream';
                else if(strExtension =='zip') ctype='application/zip';
                else if(strExtension =='doc') ctype='application/msword';
                else if(strExtension =='docx') ctype='application/vnd.openxmlformats-officedocument.wordprocessingml.document';
                else if(strExtension =='xls') ctype='application/vnd.ms-excel';
                else if(strExtension =='xlsx') ctype='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
                else if(strExtension =='ppt') ctype='application/vnd.ms-powerpoint';
                else if(strExtension =='gif') ctype='image/gif';
                else if(strExtension =='png') ctype='image/png';
                else if(strExtension =='jpg') ctype='image/jpg';
                else ctype='application/force-download';

                redirige = new PageReference('data:'+ctype+';content-disposition:attachment;base64,' + Archivo);
                redirige.setRedirect(true);
                system.debug('+++ redirige '+redirige.getUrl());
            }

        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Archivo no encontrado'));
           
        }
         return redirige;   
    }
    

   
    public Boolean DescargarArchivo2( string strFileName)
    {
        system.debug('+++entro a DescargarArchivo');
        
        CredencialesAmazon__c credentials = [Select Key__c, BucketName__c, Secret__c from CredencialesAmazon__c];
        AmazonS3 as3 = new AmazonS3(credentials.Key__c,credentials.Secret__c);

        if(credentials != null)
        {
            // Consulta si ya existe un archivo con el mismo nombre en Amazon
            ressync = as3.getObject( strFileName, credentials.BucketName__c,  credentials.Key__c, credentials.Secret__c);
            system.debug('+++llegó hasta aqui');
            if(ressync.BollExiste)
            {
                Archivo = EncodingUtil.base64Encode(ressync.blobBody);
                system.debug('Archivo '+Archivo);
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Archivo no encontrado'));
            }
        }
        return ressync.BollExiste;
    }







    //*************************************AREA DE QUERYS**************************************************************//

    public Deudas__c getDeuda (String strDeudaId)
    {
        Deudas__c objDeu =[Select id, CartaPoder__c,PazySalvo__c, ComprobanteLiquidacion2__c, ComprobanteLiquidacion3__c,
                                  ComprobanteLiquidacion4__c, ComprobanteLiquidacion5__c, ComprobanteLiquidacion6__c,
                                  ComprobanteLiquidacion7__c, ComprobanteLiquidacion8__c, ComprobanteLiquidacion1__c,
                                  ConvenioLiquidacion1__c, ConvenioLiquidacion2__c, ConvenioLiquidacion3__c,
                                  OtroDocumento1__c, OtroDocumento2__c, OtroDocumento3__c, CartaInstruccion1__c,
                                  CartaInstruccion2__c,CartaInstruccion3__c, CartaInstruccion4__c,CartaInstruccion5__c,
                                  CartaInstruccion6__c,CartaInstruccion7__c, CartaInstruccion8__c, CartaInstruccion9__c,
                                  CartaInstruccion10__c, CartaInstruccion11__c, CartaInstruccion12__c 
                            from Deudas__c where id=: strDeudaId ];

        return objDeu;
    }
}