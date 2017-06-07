public class AWS_AmazonS3 
{
	public AWS_AmazonS3() 
	{
		
	}

	/*  Input Variable Explanations
        binaryPDF -- este es un base64 representación de cadena binaria de un PDF que recibo de un servicio web diferente
        docName --  el nombre del documento
        bucketname --  Amazon S3 bucket 
        method --  I currently only use PUT
        contentType --  Dejo esto en blanco y parece que funciona bien
        region --  Importante !!!, esta tiene que ser la región se ajusta en bucket de S3 , por ejemplo, "-us-oeste-2 '
        key --  clave
        secret --  pregunta secreta
        */
	public void saveToS3(String binaryPDF,String docName,String bucketname,String method,String contentType,String region,String key,String secret)
	{
		String formattedDateString = Datetime.now().format('EEE, dd MMM yyyy HH:mm:ss z','America/Denver');    //this is needed for the PUT operation and the generation of the signature.  I use my local time zone.
        String filename;
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        filename = 'TEST_BUCKET_FOLDER_1/TEST_SUBFOLDER_1/' +    //Include any folders and subfolders you are using in your S3 Bucket
            docName.replace(' ', '+') + '.pdf';   //this replaces any spaces in the desired document name with a Plus symbol '+', as the filename needs to be URL friendly
        
        req.setHeader('Content-Type', contentType);
        req.setMethod(method);
        req.setHeader('Host','s3' + region + '.amazonaws.com');  //path style
        req.setEndpoint('https://s3' + region + '.amazonaws.com' + '/'+ bucketname + '/' + filename);   //path style
        req.setHeader('Date', formattedDateString);
        req.setHeader('Authorization',createAuthHeader(method,contentType,filename,formattedDateString,bucketname,key,secret));
        
        if(binaryPDF != null && binaryPDF != '')
        {
            Blob pdfBlob = EncodingUtil.base64Decode(binaryPDF);
            req.setBodyAsBlob(pdfBlob);
            req.setHeader('Content-Length', string.valueOf(binaryPDF.length()));
            
            //Execute web service call
            try {
                HTTPResponse res = http.send(req);
                System.debug('+++ docName: ' + docName );
                System.debug('+++ RESPONSE STRING: ' + res.toString());
                System.debug('+++ RESPONSE STATUS: '+res.getStatus());
                System.debug('+++ STATUS_CODE:'+res.getStatusCode());
                
            } 
            catch(System.CalloutException e) 
            {
                system.debug('AWS Service Callout Exception on ' + docName + 'ERROR: ' + e.getMessage());
            }
        }
	}

	//create authorization header for Amazon S3 REST API
    public string createAuthHeader(String method,String contentType,String filename,String formattedDateString,String bucket,String key,String secret){
        string auth;
        String stringToSign = method+'\n\n'+contentType+'\n'+formattedDateString+'\n/'+bucket+'/'+filename;
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign),blob.valueof(secret));
        String sig = EncodingUtil.base64Encode(mac);
        auth = 'AWS' + ' ' + key + ':' + sig;
        return auth;
    }
}