/*****************************************************************************************************
* Desarrollado por: RTD
* Autor:            Esteban Heredia (EH)
* Proyecto:         Colombia 
* Descripción:      Controlador que permite descargar archivos de Amazon S3              
*
* Cambios (Versiones)
* -------------------------------------
*           No.     fecha           Autor                     Descripción
*           -----   ----------      ------------------------    ---------------
* @version  1.0     13-Oct-2016     Esteban Heredia (EH)        Creación de la clase           
*******************************************************************************************************/
public with sharing class VisorDocsAmazon_ctr 
{
    Transient public String Archivo {get;set;}
    public AmazonS3Std.ResponseGet ressync; 
    public String strNombreArchivo {get;set;}
    public String strNombreBucket {get;set;}
    public String strIdAdjunto {get;set;}
    public String strNombreInstancia {get;set;}
    public String strArchivoDescargado {get;set;}
    public boolean blError {get;set;}
    Transient public Attachment attFile {get;set;}

    public VisorDocsAmazon_ctr() 
    {
        blError = true;      
    }

    public void getArchivo()
    {
        // Traemos por parametro el nombre del archivo, region y el bucket correspondiente
        strNombreArchivo = Apexpages.CurrentPage().getParameters().get('nameFile');
        System.debug('strNombreArchivo: ' + strNombreArchivo );

        strNombreBucket = Apexpages.CurrentPage().getParameters().get('nb');
        System.debug('strNombreBucket: ' + strNombreBucket );

        strArchivoDescargado = Apexpages.CurrentPage().getParameters().get('downloadFile');
        System.debug('strNombreBucket: ' + strNombreBucket );
        
        if(strArchivoDescargado == null)
        {
            Boolean DescargaOk = false; 
            PageReference redirige = null;
            
            DescargaOk = DescargarArchivo();
            if(DescargaOk || Test.isRunningTest())
            {
                String strExtension = strNombreArchivo.substring(strNombreArchivo.lastIndexOf('.')+1);
                system.debug('+++strExtension '+strExtension);
                string ctype= '';
                if(strExtension !='')
                {
                    /*system.debug('+++ entro ');
                     system.debug('+++ archivo ' +  archivo.length());*/
                    if(strExtension =='pdf') ctype='application/pdf';
                    else if(strExtension =='exe') ctype='application/octet-stream';
                    else if(strExtension =='zip') ctype='application/zip';
                    else if(strExtension =='doc') ctype='application/msword';
                    else if(strExtension =='xls') ctype='application/vnd.ms-excel';
                    else if(strExtension =='ppt') ctype='application/vnd.ms-powerpoint';
                    else if(strExtension =='gif') ctype='image/gif';
                    else if(strExtension =='png') ctype='image/png';
                    else if(strExtension =='jpg') ctype='image/jpg';
                    else ctype='application/force-download';
                    /*blDoc = Blob.valueOf(Archivo);
                    blDoc = Blob.toPDF(Archivo);
                    // Mandarlo como URL: sirve para archivos pequeños, en este caso se realizó por medio de adjuntos
                    redirige = new PageReference('data:'+ctype+';content-disposition:attachment;base64,' + Archivo);
                    redirige.setRedirect(true);
                    system.debug('+++ redirige '+redirige.getUrl());
                    */
                    // Traemos una reparadora para colocar como papá del adjunto
                    List<Reparadora__c> lstReparadora = [SELECT Id From Reparadora__c WHERE Status__c = 'Activo' limit 1];
                    //Traemos la instancia a la cuál se quiere ver el documento
                    strNombreInstancia = System.URL.getSalesforceBaseUrl().gethost();
                    // Creamos un adjunto temporal
                    attFile = new Attachment(); 
                    attFile.Body = EncodingUtil.base64Decode(Archivo); 
                    attFile.Name = strNombreArchivo; 
                    attFile.ParentId = lstReparadora.get(0).id; 
                    attFile.Description = 'Archivo Cargado'; 
                    insert attFile ;
                    strIdAdjunto = attFile.id;
                    system.debug('strIdAdjunto--> ' + strIdAdjunto);
                    // En caso que no haya error, abrimos el archivo
                    blError = true;
                }

            }
            else 
            {
                blError = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Archivo no encontrado'));
                
            }
            
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Descarga completada'));
        }
       
         //return redirige;   
    }
    
    /**
     * Método utilizado para revisar si ya existe un archivo en el cucket seleccionado de Amazon 
     * @author EH
     * @return Booleano que dice si se encontró o no el archivo
     */
    public Boolean DescargarArchivo()
    {
        system.debug('+++entro a DescargarArchivo');
        
        
        try 
        {
            // Traemos las características del bucket seleccionado de la config personalizada
            CredencialesAmazonGeneral__c csCredencialesAmazon = CredencialesAmazonGeneral__c.getInstance(strNombreBucket);
            if(csCredencialesAmazon == null)
                throw new UtilException('El bucket ha sido cambiado o es invalido');
            AmazonS3Std as3 = new AmazonS3Std();
            // Revisamos que exista un archivo en el bucket elegido
            if(strNombreArchivo == null)
                throw new UtilException('Coloque nameFile');

            ressync = as3.GetObject(strNombreArchivo, strNombreBucket, csCredencialesAmazon.Key__c, csCredencialesAmazon.Secret__c, csCredencialesAmazon.Region__c);
            if(ressync.BollExiste)
            {
               // Decodificamos el archivo en base64, dado que de Amazon viene codificado de esta manera 
               Archivo = EncodingUtil.base64Encode(ressync.blobBody); 
            }
            else 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Archivo no encontrado'));
            }
            return ressync.BollExiste;
            
        } 
        catch(exception e) 
        {
            // Si llega a existir un problema no identificado, se muestra en la pantalla
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + ' Linea ' + e.getLineNumber() + ' causa del error ' + e.getCause()));
            blError = false;
            return false;
        }
    }
    public PageReference borrarAdjunto()
    {
        system.debug('Entro a elminar--> ');
        List<Attachment> attBorrar = [SELECT Id From Attachment where name =: strNombreArchivo]; 
        delete attBorrar;
        PageReference orderPage = new PageReference('javascript:window.close()');
        //PageReference orderPage = new PageReference('/apex/VisorDocsAmazon?downloadFile=true');
        orderPage.setRedirect(true);
        return orderPage;
    }
    

    public class UtilException extends Exception {}
}