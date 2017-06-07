/*****************************************************************************************************
* Desarrollado por: RTD
* Autor:            Esteban Heredia (EH)
* Proyecto:         Colombia 
* Descripción:      Llamado servicio Web para enviar mensajes de texto              
*
* Cambios (Versiones)
* -------------------------------------
*           No.     fecha          	Autor 		               	Descripción
*           -----   ----------      ------------------------   	---------------
* @version  1.0     06-Abr-2016     Esteban Heredia (EH)        Creación de la clase           
*******************************************************************************************************/

public with sharing class WSMandarSMS 
{
        public static String  envioMensajeIndividual(String numeroCelular,String mensaje) 
	{
		// Creación del request
		HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                // Parametros Request 
                // Parameter                            Type         Description
                // transaction_type  			Integer      Constant value = 400
        	// product_id, user_id and user_pw 	Integer      Product identifier. Please ask IPCOM for a list of product_id values for sms.
        	// number  				Integer      Telephone number where the message will be sent
        	// msg  				String (160) The message to be sent
        	// reference_id No obligated            String (20)  Reference identifier assigned by client. This value is recorded for reporting purposes, and will also be passed back in the response.
        	// Llamamos a la configuración personalizada que contiene los datos del servicio
                MensajesTexto__c csMesajeDeTexto = MensajesTexto__c.getInstance();
                system.debug('\n\n csMesajeDeTexto--> ' + csMesajeDeTexto);
                String strRequestEndPoint = 'http://ws.ip-com.com/?transaction_type=400&user_id=';
                strRequestEndPoint += csMesajeDeTexto.user_id__c + '&user_pw=';
                strRequestEndPoint += csMesajeDeTexto.user_pw__c + '&product_id=';
                strRequestEndPoint += csMesajeDeTexto.product_id__c + '&number=';
        	strRequestEndPoint += numeroCelular;
                String strMensaje = EncodingUtil.urlEncode(mensaje,'US-ASCII'); // Códificar ASCII 16 para que carecteres extraños se envien correctamente
                strRequestEndPoint += '&msg=' + strMensaje;
                system.debug('\n\n strMensaje--> ' + strMensaje  + 'Tamaño--> ' + strMensaje.length());
                req.setEndpoint(strRequestEndPoint);

                // Llamado al servicio web
                Http http = new Http();
                HttpResponse res = http.send(req);
                system.debug('\n\n res--> ' + res);
                system.debug('\n\n body--> ' + res.getBody());
                return res.getBody();
	}
}