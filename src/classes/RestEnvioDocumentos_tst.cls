@isTest
global class RestEnvioDocumentos_tst implements HttpCalloutMock 
{
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) 
    {
        // Optionally, only send a mock response for a specific endpoint and method.
        //System.assertEquals('http://api.salesforce.com/foo/bar', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String json = '{\n' +
        '   "processId" : "a0W550000016AHjEAM",\n' +
        '   "userDoc" : "52468972",\n' +
        '   "urlAccess" : "http://autentic.com.co/digitalSigning/?SESID=f42d9a39-2107-408a-ae65-ea839298acda",\n' +
        '   "caseNumber" : "f42d9a39-2107-408a-ae65-ea839298acda"\n' +
        '}';
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }
}