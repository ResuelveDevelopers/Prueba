/*****************************************************************************************************
* Desarrollado por: RTD
* Autor:            Esteban Heredia (EH)
* Proyecto:         Colombia IV
* Descripción:      Controlador para la Visualforce botonTareasNoSeLocaliza, se encarga de actuializar campos de tareas y devolver a la propia tarea             
*
* Cambios (Versiones)
* -------------------------------------
*           No.     fecha          	Autor 		               	Descripción
*           -----   ----------      ------------------------   	---------------
* @version  1.0     4-Abr-2016    Esteban Heredia (EH)        Creación de la clase           
*******************************************************************************************************/
public with sharing class botonTareasNoSeLocaliza_ctr 
{
	private final Task objTarea;
	// En el constructor inicializamos la tarea estandar 
    // variable objTarea by using the getRecord method from the standard controller.
    public botonTareasNoSeLocaliza_ctr(ApexPages.StandardController stdController) 
    {
        this.objTarea = (Task)stdController.getRecord();
    }

    /**
     * Método para actualizar los campos de no se localiza
     * @author EH
     * @return A la tarea donde está el botón
     */
	public PageReference flujoNoSeLocaliza() 
	{
		//Primero actualizamos campos
		system.debug('\n\n objTarea--> ' + objTarea);
		// Número de veces en la que se ha dado clic al botón
		objTarea.NumerodeintentosdeLocalizacion__c 		= objTarea.NumerodeintentosdeLocalizacion__c == null? 1: objTarea.NumerodeintentosdeLocalizacion__c  + 1;
		system.debug('\n\n objTarea.NumerodeintentosdeLocalizacion__c--> ' + objTarea.NumerodeintentosdeLocalizacion__c);
		// Fecha en la que se da clic al botón
		objTarea.FechadeUltimoIntentodeLocalizacion__c 	= System.now().date();
		// Usuario Fecha (en la que se dio clic al botón)
		Date dtCurrDate = System.now().date();
        Time tiCurrTime = System.now().time();
        Datetime dttFechaAct = datetime.newInstanceGMT(dtCurrDate ,tiCurrTime );
        system.debug('\n\n dttFechaAct--> ' + dttFechaAct);
        system.debug('\n\n System.now()--> ' + System.now());
        if((objTarea.HistorialIntentosLocalizacion__c + '\n' + UserInfo.getName() + ' ' + System.now().format('dd/MM/YYYY hh:mm aaa')).length() < 255)
		objTarea.HistorialIntentosLocalizacion__c		= objTarea.HistorialIntentosLocalizacion__c == null? UserInfo.getName() + ' ' + System.now().format('dd/MM/YYYY hh:mm aaa'): objTarea.HistorialIntentosLocalizacion__c + '\n' + UserInfo.getName() + ' ' + System.now().format('dd/MM/YYYY hh:mm aaa');
		else 
		{
			system.debug('\n\n antes -->' + objTarea.HistorialIntentosLocalizacion__c );
			String strHistorialNuevo = objTarea.HistorialIntentosLocalizacion__c;
			//Colocamos el último historial en el primer puesto
			while((strHistorialNuevo + '\n' + UserInfo.getName() + ' ' + System.now().format('dd/MM/YYYY hh:mm aaa')).length() >= 255)
			{
				// Removemos el primer puesto para intentar cambiarlo por el último, dado que no valga con eso quitaremos el segundo y así secuencialmente
				strHistorialNuevo = strHistorialNuevo.removeStartIgnoreCase(strHistorialNuevo.split('\n').get(0) + '\n');
			}
			objTarea.HistorialIntentosLocalizacion__c = strHistorialNuevo + '\n' + UserInfo.getName() + ' ' + System.now().format('dd/MM/YYYY hh:mm aaa');
		}
		// Actualizamos el campo del correo electrónico para poder enviar el correo electrónico en su respectivo flujo de trabajo
		String strEmail = '';
		List<Reparadora__c> lstReparadoraTask = new List<Reparadora__c>();
		lstReparadoraTask = [SELECT Cliente__c, Cliente__r.Name,Cliente__r.LastName, Cliente__r.PersonEmail, Cliente__r.PersonContactId, Cliente__r.Telefono_celular__c, Id,DiasDesdeUltimoContactoCliente__c, DiasSinDepositar__c FROM Reparadora__c WHERE Id =: objTarea.whatId];
		strEmail = lstReparadoraTask.get(0).Cliente__r.PersonEmail != null?lstReparadoraTask.get(0).Cliente__r.PersonEmail:'';
		system.debug('\n\n strEmail--> ' + strEmail);
		objTarea.CorreoClienteRelacionadoReparadora__c = strEmail;


		try
		{
			// Actualizamos los campos referentes a dias sin contacto y deposito, para enviar los correos electrónicos correspondientes
			calcularCamposSinContactoDeposito(lstReparadoraTask.get(0));
			// Enviamos los mensajes de texto 
			if(lstReparadoraTask.get(0).Cliente__r.Telefono_celular__c == null)
		 		throw new UtilException('Por favor colocar el teléfono celular del cliente');
			enviarMensajeDeTexto(lstReparadoraTask.get(0));
			if(objTarea.CorreoClienteRelacionadoReparadora__c == '')
		 		throw new UtilException('El campo de correo electrónico no está diligenciado en el cliente');	
			//Actualizamos la tarea con los nuevos valores
			update objTarea;
			// Redirigimos a la misma página de la tarea
			PageReference pageRef = new PageReference('/' + objTarea.id);
			pageRef.setRedirect(true);
			return pageRef;
		}
		catch(Exception e)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, e.getMessage())) ;
			return null;
		}
		
	}

	public void calcularCamposSinContactoDeposito(Reparadora__c Objreparadora)
	{
		if(Objreparadora.DiasDesdeUltimoContactoCliente__c != null && Objreparadora.DiasDesdeUltimoContactoCliente__c >= 30 && Objreparadora.DiasDesdeUltimoContactoCliente__c < 60)
			objTarea.SinContactoClienteRep__c = true;
		else
			objTarea.SinContactoClienteRep__c = false;
		if(Objreparadora.DiasSinDepositar__c != null && Objreparadora.DiasSinDepositar__c >= 30 && Objreparadora.DiasSinDepositar__c < 60)
			objTarea.DiasSinDepositarRep__c = true;
		else
			objTarea.DiasSinDepositarRep__c = false;
		if(Objreparadora.DiasDesdeUltimoContactoCliente__c != null && Objreparadora.DiasDesdeUltimoContactoCliente__c >= 60 && Objreparadora.DiasDesdeUltimoContactoCliente__c < 90)
			objTarea.SinContactoClienteRep2__c = true;
		else
			objTarea.SinContactoClienteRep2__c = false;
		if(Objreparadora.DiasSinDepositar__c != null && Objreparadora.DiasSinDepositar__c >= 60 && Objreparadora.DiasSinDepositar__c < 90)
			objTarea.DiasSinDepositarRep2__c = true;
		else
			objTarea.DiasSinDepositarRep2__c = false;
		if(Objreparadora.DiasDesdeUltimoContactoCliente__c != null && Objreparadora.DiasDesdeUltimoContactoCliente__c >= 90)
			objTarea.SinContactoClienteRep3__c = true;
		else
			objTarea.SinContactoClienteRep3__c = false;
		if(Objreparadora.DiasSinDepositar__c != null && Objreparadora.DiasSinDepositar__c >= 90)
			objTarea.DiasSinDepositarRep3__c = true;
		else
			objTarea.DiasSinDepositarRep3__c = false;

	}
	public void enviarMensajeDeTexto(Reparadora__c Objreparadora)
	{
		// Llamamos a la configuración personalizada que contiene los datos del servicio
        MensajesTexto__c csMensajeDeTexto = MensajesTexto__c.getInstance();
        system.debug('\n\n csMensajeDeTexto--> ' + csMensajeDeTexto);
        system.debug('\n\n objTarea.Subject--> ' + objTarea.Subject);
        system.debug('\n\n objTarea.NumerodeintentosdeLocalizacion__c--> ' + objTarea.NumerodeintentosdeLocalizacion__c);
        system.debug('\n\n objTarea.Status--> ' + objTarea.Status);
		if(objTarea.Subject == 'Llamada de Bienvenida' && objTarea.NumerodeintentosdeLocalizacion__c == 7 && objTarea.Status == 'En Proceso')
		{
			system.debug('\n\n Entro llamada bienvenida--> ');
			WSMandarSMS.envioMensajeIndividual('57' + Objreparadora.Cliente__r.Telefono_celular__c, csMensajeDeTexto.Mensaje1__c.replace('{0}',Objreparadora.Cliente__r.Name.substringBefore(' ')  + ' ' + Objreparadora.Cliente__r.LastName));
		}

		else if(objTarea.Subject == 'Llamada de Bienvenida' && (objTarea.NumerodeintentosdeLocalizacion__c == 8 || objTarea.NumerodeintentosdeLocalizacion__c == 9 || objTarea.NumerodeintentosdeLocalizacion__c == 10) && objTarea.Status == 'En Proceso')
		{
			WSMandarSMS.envioMensajeIndividual('57' + Objreparadora.Cliente__r.Telefono_celular__c, csMensajeDeTexto.Mensaje2__c.replace('{0}',Objreparadora.Cliente__r.Name.substringBefore(' ') ));
		}

		else if(objTarea.Subject == 'Llamada Telefonica Post Venta # 1' && (objTarea.NumerodeintentosdeLocalizacion__c == 5 || objTarea.NumerodeintentosdeLocalizacion__c == 6 || objTarea.NumerodeintentosdeLocalizacion__c == 7) && objTarea.Status == 'En Proceso')
		{
			WSMandarSMS.envioMensajeIndividual('57' + Objreparadora.Cliente__r.Telefono_celular__c, csMensajeDeTexto.Mensaje3__c.replace('{0}',Objreparadora.Cliente__r.Name.substringBefore(' ')));
		}

		else if(objTarea.Subject == 'Llamada por 30 días sin Contacto o Deposito' && objTarea.NumerodeintentosdeLocalizacion__c == 5 && objTarea.Status == 'En Proceso')
		{	
			WSMandarSMS.envioMensajeIndividual('57' + Objreparadora.Cliente__r.Telefono_celular__c, csMensajeDeTexto.Mensaje4__c.replace('{0}',Objreparadora.Cliente__r.Name.substringBefore(' ') ));
		}

		else if(objTarea.Subject == 'Llamada por 60 días sin Contacto o Deposito' && objTarea.NumerodeintentosdeLocalizacion__c == 5 && objTarea.Status == 'En Proceso' && Objreparadora.DiasSinDepositar__c >= 60 && Objreparadora.DiasSinDepositar__c < 90)
		{
			WSMandarSMS.envioMensajeIndividual('57' + Objreparadora.Cliente__r.Telefono_celular__c, csMensajeDeTexto.Mensaje5__c.replace('{0}',Objreparadora.Cliente__r.Name.substringBefore(' ') ));
		}

		else if(objTarea.Subject == 'Llamada por 60 días sin Contacto o Deposito' && objTarea.NumerodeintentosdeLocalizacion__c == 5 && objTarea.Status == 'En Proceso' &&  Objreparadora.DiasDesdeUltimoContactoCliente__c >= 60 && Objreparadora.DiasDesdeUltimoContactoCliente__c < 90 && (Objreparadora.DiasSinDepositar__c < 60 || Objreparadora.DiasSinDepositar__c > 90 || Objreparadora.DiasSinDepositar__c ==null))
		{
			WSMandarSMS.envioMensajeIndividual('57' + Objreparadora.Cliente__r.Telefono_celular__c, csMensajeDeTexto.Mensaje8__c.replace('{0}',Objreparadora.Cliente__r.Name.substringBefore(' ') ));
		}

		else if(objTarea.Subject == 'Llamada por 90 días sin Contacto o Deposito' && objTarea.NumerodeintentosdeLocalizacion__c == 5 && objTarea.Status == 'En Proceso' && Objreparadora.DiasSinDepositar__c >= 90)
		{
			WSMandarSMS.envioMensajeIndividual('57' + Objreparadora.Cliente__r.Telefono_celular__c, csMensajeDeTexto.Mensaje6__c.replace('{0}',Objreparadora.Cliente__r.Name.substringBefore(' ') ));
		}

		else if(objTarea.Subject == 'Llamada por 90 días sin Contacto o Deposito' && objTarea.NumerodeintentosdeLocalizacion__c == 5 && objTarea.Status == 'En Proceso' && Objreparadora.DiasDesdeUltimoContactoCliente__c >= 90 && (Objreparadora.DiasSinDepositar__c < 90 || Objreparadora.DiasSinDepositar__c == null) )
		{
			WSMandarSMS.envioMensajeIndividual('57' + Objreparadora.Cliente__r.Telefono_celular__c, csMensajeDeTexto.Mensaje7__c.replace('{0}',Objreparadora.Cliente__r.Name.substringBefore(' ') ));
		}
	}

	public class UtilException extends Exception {}
}