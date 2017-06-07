public class RestTest 
{
    private static String oauthLogin(String loginUri, String clientId,
        String clientSecret, String username, String password) {
        HttpRequest req = new HttpRequest(); 
 
        req.setMethod('POST');
        req.setEndpoint(loginUri+'/services/oauth2/token');
        req.setBody('grant_type=password' +
            '&client_id=' + clientId +
            '&client_secret=' + clientSecret +
            '&username=' + EncodingUtil.urlEncode(username, 'UTF-8') +
            '&password=' + EncodingUtil.urlEncode(password, 'UTF-8'));
    
        Http http = new Http();
  
        HTTPResponse res = http.send(req);

        System.debug('BODY: '+res.getBody());
        System.debug('STATUS:'+res.getStatus());
        System.debug('STATUS_CODE:'+res.getStatusCode());
        string strvar = JSON.serialize(res.getBody());
        System.debug('strvar '+strvar );
        return strvar ;
    }
}