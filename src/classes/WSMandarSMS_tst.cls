/*****************************************************************************************************
* Desarrollado por: RTD
* Autor:            Esteban Heredia (EH)
* Proyecto:         Colombia 
* Descripción:      Clase de prueba de WSMandarSMS              
*
* Cambios (Versiones)
* -------------------------------------
*           No.     fecha          	Autor 		               	Descripción
*           -----   ----------      ------------------------   	---------------
* @version  1.0     16-May-2016     Esteban Heredia (EH)        Creación de la clase           
*******************************************************************************************************/
@isTest
global class WSMandarSMS_tst 
{
	
	@isTest static void test_method_one() 
	{
		 MensajesTexto__c csMensajeDeTexto = new MensajesTexto__c();
 		 csMensajeDeTexto.product_id__c = 'abc';
 		 csMensajeDeTexto.user_id__c = 'abc';
 		 csMensajeDeTexto.user_pw__c = 'abc';
 		 csMensajeDeTexto.Mensaje8__c = 'abc';
 		 csMensajeDeTexto.Mensaje7__c = 'abc';
 		 csMensajeDeTexto.Mensaje6__c = 'abc';
 		 csMensajeDeTexto.Mensaje5__c = 'abc';
 		 csMensajeDeTexto.Mensaje4__c = 'abc';
 		 csMensajeDeTexto.Mensaje3__c = 'abc';
 		 csMensajeDeTexto.Mensaje2__c = 'abc';
 		 csMensajeDeTexto.Mensaje1__c = 'abc';
 		 insert csMensajeDeTexto;
		// Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            // Call method to test.
	        // This causes a fake response to be sent
	        // from the class that implements HttpCalloutMock. 
	        Test.startTest();
	        	String res = WSMandarSMS.envioMensajeIndividual('3008765765','Mensaje de prueba');
	        Test.stopTest();
	}
	
	global class MockHttpResponseGenerator implements HttpCalloutMock 
	{
	    // Implement this interface method
	    global HTTPResponse respond(HTTPRequest req) 
	    {
	        // Create a fake response
	        HttpResponse res = new HttpResponse();
	        res.setHeader('Content-Type', 'application/json');
	        res.setBody('response_code=1&response_msg=Success&response_desc=Transaction accepted, message queued for delivery.&transaction_type=400&rate=0.0246&balance=26.9742&reference_id=&transaction_id=16701725');
	        res.setStatusCode(200);
	        return res;
	    }
	}
	
}