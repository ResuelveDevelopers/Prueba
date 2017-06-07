public class servicioWebEnvioDoc 
{
	public static String nombreAdjunto {get; set;}

    //oauth
    private static String oauthLogin(String loginUri, String clientId, String clientSecret, String username, String password)
    {
        HttpRequest req = new HttpRequest();

        req.setMethod('POST');
        req.setEndpoint(loginUri+'/services/oauth2/token');
        req.setBody('grant_type=password' +
            '&client_id=' + clientId +
            '&client_secret=' + clientSecret +
            '&username=' + EncodingUtil.urlEncode(username, 'UTF-8') +
            '&password=' + EncodingUtil.urlEncode(password, 'UTF-8'));
   		System.debug('+++req '+req);
   		System.debug('+++oauth '+req.getBody());
   		System.debug('+++oauth '+req.getEndpoint());

        Http http = new Http();
 
        HTTPResponse res = http.send(req);
		
        return  res.getBody();
    }

    public void restTest() 
    {

        String oauth = oauthLogin('https://test.salesforce.com',
            '3MVG9RHx1QGZ7OsiiTEoWc6UaOs86ypWHhoKGlU5EmnH.pinAhxntbNSJ2mlPymTjPfttzXrH8cwgHRJ5D2L5',
            '2928034951410779575',
            'jose@resuelvecolombia.com.fullcopy',
            'demonito26');
        
        System.debug('+++oauth '+oauth);
        List<String> parts = oauth.split('\"');
        System.debug('+++parts '+parts);
            
        // lstRecords = (List<Records>)JSON.deserialize(res.getBody(), List<Records>.class);   
        String accessToken = parts.get(3);
        String  instanceUrl = parts.get(7);
               
        system.debug('+++ token '+accessToken);
        system.debug('+++url '+instanceUrl);
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        if(nombreAdjunto.contains(' '))
        {
              nombreAdjunto = nombreAdjunto.replaceAll(' ','%20');      //searchtext = searchtext.replaceAll('\\s+','%20');
        }

        req.setEndpoint(instanceUrl+'/services/apexrest/nombreAdjunto?name='+nombreAdjunto);
        req.setHeader('Authorization', 'OAuth '+accessToken);
       
        Http http = new Http();
 
        HttpResponse res = http.send(req);

        system.debug('\n\n res--> ' + res);
        /* End of Fetch Records */
    }

}