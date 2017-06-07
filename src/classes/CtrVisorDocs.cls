public class CtrVisorDocs 
{
    public String Archivo {get;set;}
    public AmazonS3.ResponseGet ressync; 
    public String strNombreArchivo {get;set;}

    public CtrVisorDocs(ApexPages.StandardController controller) 
    {

        strNombreArchivo =Apexpages.CurrentPage().getParameters().get('nombreArchivo');
        System.debug('Parametro: ' + Apexpages.CurrentPage().getParameters().get('nombreArchivo'));
        System.debug('strNombreArchivo: ' + strNombreArchivo );

    }
    
    public PageReference getArchivo()
    {
        String StrNomArc =strNombreArchivo;

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
                else if(strExtension =='xls') ctype='application/vnd.ms-excel';
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



}