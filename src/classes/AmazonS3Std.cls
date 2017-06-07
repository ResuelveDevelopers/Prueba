/*****************************************************************************************************
* Desarrollado por: RTD
* Autor:            Esteban Heredia (EH)
* Proyecto:         Colombia 
* Descripción:      Clase para colocor u obtener archivos de AmazonS3 , fuente https://developer.salesforce.com/forums/?id=906F0000000BMDFIA4              
*
* Cambios (Versiones)
* -------------------------------------
*           No.     fecha           Autor                     Descripción
*           -----   ----------      ------------------------    ---------------
* @version  1.0     313-Oct-2016     Esteban Heredia (EH)        Creación de la clase           
*******************************************************************************************************/
public with sharing class AmazonS3Std 
{
	/*  Input Variable Explanations
        binaryPDF -- este es un base64 representación de cadena binaria de un PDF que recibo de un servicio web diferente
        docName --  el nombre del documento
        bucketname --  Amazon S3 bucket 
        contentType --  Dejo esto en blanco y parece que funciona bien
        region --  Importante !!!, esta tiene que ser la región se ajusta en bucket de S3 , por ejemplo, "-us-oeste-2 '
        key --  clave
        secret --  pregunta secreta
        */
	public Boolean PutObject(String binaryPDF,String docName,String bucketname,String key,String secret,String strRegion)
	{
        
		String formattedDateString = Datetime.now().format('EEE, dd MMM yyyy HH:mm:ss z','America/Bogota');    //this is needed for the PUT operation and the generation of the signature.  I use my local time zone.
        //String filename;
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        Boolean Bolrep= false; 
        String contentType ='';

        String encodocName = EncodingUtil.urlEncode(docName, 'UTF-8');

       
        req.setHeader('Content-Type', contentType);
        req.setMethod('PUT');
        req.setHeader('Host','s3' + strRegion + '.amazonaws.com');  //path style
        req.setEndpoint('https://s3' + strRegion + '.amazonaws.com' + '/'+ bucketname + '/' + encodocName);   //path style
        req.setHeader('Date', formattedDateString);
        req.setHeader('Authorization',createAuthHeader('PUT',contentType,encodocName,formattedDateString,bucketname,key,secret));
        //req.setHeader('x-amz-acl','public-read');
        req.setTimeout(120000); // tiempo de espera de respuesta
        if(binaryPDF != null && binaryPDF != '' && !Test.isRunningTest())
        {
            Blob pdfBlob = EncodingUtil.base64Decode(binaryPDF);
            req.setBodyAsBlob(pdfBlob);
            req.setHeader('Content-Length', string.valueOf(binaryPDF.length()));
            //req.setHeader('x-amz-acl','public-read'); // darle permisos de lectura
                                    
            //Execute web service call
            try {
                HTTPResponse res = http.send(req);
                System.debug('+++ docName: ' + encodocName );
                System.debug('+++ RESPONSE STRING: ' + res.toString());
                System.debug('+++ RESPONSE STATUS: '+res.getStatus());
                System.debug('+++ STATUS_CODE:'+res.getStatusCode());
                system.debug('+++res '+res.getBody());
                if(res.getStatusCode()==200)
                {
                	Bolrep= true;
                }

            } 
            catch(System.CalloutException e) 
            {
                system.debug('AWS Service Callout Exception on ' + encodocName + ' ERROR: ' + e.getMessage());
            }
        }
        return Bolrep;
	}

    public class ResponseGet
    {
        public Boolean BollExiste;   //Si el proceso fue exitoso
        Transient public Blob blobBody ;      
        
    }

    public ResponseGet GetObject(String docName,String bucketname,String key,String secret,String strRegion)
    {      
        String formattedDateString = Datetime.now().format('EEE, dd MMM yyyy HH:mm:ss z','America/Bogota'); 
        String contentType ='';
        ResponseGet resp = new ResponseGet();
        resp.BollExiste = false;
        
        HttpRequest req = new HttpRequest();

        req.setMethod('GET');

        req.setHeader('Host','s3' + strRegion + '.amazonaws.com');  //path style
        req.setEndpoint('https://s3' + strRegion + '.amazonaws.com' + '/'+ bucketname + '/' + docName);   //path style
        req.setHeader('Content-Encoding', 'UTF-8');
        req.setHeader('Date',formattedDateString);
        
        req.setHeader('Authorization',createAuthHeader('GET',contentType,docName,formattedDateString,bucketname,key,secret));
        req.setTimeout(120000); // tiempo de espera de respuesta
        Http http = new Http();

        try 
        {
            if(!Test.isRunningTest())
            {
                HTTPResponse res = http.send(req);
                System.debug('+++ docName: ' + docName );
                System.debug('+++ RESPONSE STRING: ' + res.toString());
                System.debug('+++ RESPONSE STATUS: '+res.getStatus());
                System.debug('+++ STATUS_CODE:'+res.getStatusCode());
                //system.debug('+++Body '+res.getBody());
                if(res.getStatusCode()==200) // existe el archivo
                {
                    resp.BollExiste= true;
                    resp.blobBody = res.getBodyasBlob();
                }
                else {
                    if(res.getStatusCode()==404)// no se encontró el archivo
                    {    
                        resp.BollExiste= false;
                        system.debug('+++ no hay archivos con el mismo nombre');
                    }
                }
            }
        } 
        catch(System.CalloutException e) 
        {
            system.debug('AWS Service Callout Exception on ' + docName + ' ERROR: ' + e.getMessage());
        }
        return resp;
    }

	//create authorization header for Amazon S3 REST API
    public string createAuthHeader(String method,String contentType,String filename,String formattedDateString,String bucket,String key,String secret)
    {
        string auth;
        String stringToSign = method+'\n\n'+contentType+'\n'+formattedDateString+'\n/'+bucket+'/'+filename;
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign),blob.valueof(secret));
        String sig = EncodingUtil.base64Encode(mac);
        auth = 'AWS' + ' ' + key + ':' + sig;
        
        return auth;
    }
}