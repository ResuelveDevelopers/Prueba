/*****************************************************************************************************
* Desarrollado por: RTD
* Autor:            Esteban Heredia (EH)
* Proyecto:         Colombia V
* Descripción:      Trabajo programado para cambiar  a cuenta no liquidada           
*
* Cambios (Versiones)
* -------------------------------------
*           No.     fecha           Autor                       Descripción
*           -----   ----------      ------------------------    ---------------
* @version  1.0     24-Nov-2016     Esteban Heredia (EH)        Creación de la clase           
*******************************************************************************************************/
global class bchCuentaNoLiquidada_bch implements Database.Batchable<sObject>, Database.Stateful 
{
	
	String query;
	// Variable para realizar el informe
	global String strRenglonInforme;
	
	global bchCuentaNoLiquidada_bch() 
	{
		// El título del informe
		strRenglonInforme   = 'Id deuda,# deuda,id solicitud,# solicitud\n';
		//Calculamos el día hábil de cinco días en el pasado, traemos el horario de oficina de Colombia con sus respectivos festivos
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name='FestivosColombia'];
        DateTime dtFechaInicial = system.now().addDays(-1);
        DateTime dtFechaFinal = system.now();
        integer intCincoDiasHabiles = 0;
        while(intCincoDiasHabiles < 5)
        {
        	system.debug('dtFechaFinalDentro--> ' + dtFechaFinal);
        	system.debug('intCincoDiasHabiles--> ' + intCincoDiasHabiles);
        	// Preguntamos si el día anterior a la fecha que queremos es festivo
        	// dtFechaInicial es la fecha de referencia
        	if(!BusinessHours.isWithin(bh.id, dtFechaInicial))
        	{
	        	dtFechaFinal = dtFechaFinal.addDays(-2);
	        	// Si restando sigue siendo día no laborable atrasamos un día
	        	while(!BusinessHours.isWithin(bh.id, dtFechaFinal))
	        	{
	        		dtFechaFinal = dtFechaFinal.addDays(-1);
	        	}
	        	intCincoDiasHabiles ++;
        	}
	        else
	        {
	        	dtFechaFinal = dtFechaFinal.addDays(-1);	
	        	intCincoDiasHabiles ++;        	
	        }

	        dtFechaInicial = dtFechaFinal.addDays(-1);
        }
		// Calculamos el día de hace cinco días
		system.debug('dtFechaFinal--> ' + dtFechaFinal);
		String strDateTimeFormat = dtFechaFinal.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
		system.debug('strDateTimeFormat--> ' + strDateTimeFormat);
        Query =   'SELECT Id,Deuda__c FROM SolicitudesDeFondos__c WHERE Estatus__c = \'Solicitud Rechazada\' ';
        if(!Test.isRunningTest())
        Query += 'AND CreatedDate < ' + strDateTimeFormat  + ' AND CambioCuentaNoLiquidada__c = false AND Deuda__c != null';
		//Query += 'AND Deuda__c != null';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		system.debug('query--> ' + query);
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) 
   	{
   		system.debug('scope--> ' + scope);
   		// Creamos un set con las deudas papás
   		set<id> setIdDeudas = new set<id>();
   		List<SolicitudesDeFondos__c> lstSolFondos = scope;

   		for(SolicitudesDeFondos__c objTempSolFondos: lstSolFondos) 
   		{
   			setIdDeudas.add(objTempSolFondos.Deuda__c);
   			// Actualizar campo solicitud de fondos para que el batch no lo vuelva a coger
   			objTempSolFondos.CambioCuentaNoLiquidada__c = true;
   		}

   		// Traemas las deudas con su última solicitud de fondeo
   		List<Deudas__c> lstDeudas = [SELECT Id, Name,( SELECT Id,Name,Estatus__c FROM Solicitudes_de_Fondos__r ORDER BY CreatedDate DESC LIMIT 1), Cuenta_No_Liquidada__c 
   									FROM Deudas__c WHERE Id IN: setIdDeudas AND EstadodelaDeuda__c != 'Liquidada'];
   		system.debug('lstDeudas--> ' + lstDeudas);
   		system.debug('objTempDeuda.SolicitudFondeos__r--> ' + lstDeudas.get(0).Solicitudes_de_Fondos__r);

   		for(Deudas__c objTempDeuda: lstDeudas) 
   		{
   			if(objTempDeuda.Solicitudes_de_Fondos__r.get(0).Estatus__c == 'Solicitud Rechazada')
   			{
   				objTempDeuda.Cuenta_No_Liquidada__c = 'Cuenta no Liquidada'; 
   				strRenglonInforme += '"' + objTempDeuda.Id + '","'+ objTempDeuda.Name +'","'+ objTempDeuda.Solicitudes_de_Fondos__r.get(0).Id + '","' + objTempDeuda.Solicitudes_de_Fondos__r.get(0).Name+'",\n';
   			}
   		}
   		update lstDeudas;
   		update lstSolFondos;
   		

	}
	
	global void finish(Database.BatchableContext BC) 
	{
		Notificacion_Trabajos_Programados__c config = Notificacion_Trabajos_Programados__c.getInstance('bchCuentaNoLiquidada_bch');
        Datetime dtFechaHoraActual                  = Datetime.now();
        String strFechaHoraActual                   = dtFechaHoraActual.format('dd/MM/yyyy HH:mm:ss');
        Messaging.EmailFileAttachment csvAttc       = new Messaging.EmailFileAttachment();
        blob csvBlob                                = Blob.valueOf(strRenglonInforme);  
        String csvname                              = 'InformeCuentasNoLiquidadas' + dtFechaHoraActual.format('dd_MM_yyyy_HH_mm_ss') +'.csv';     
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);       
        Messaging.SingleEmailMessage mail           = new Messaging.SingleEmailMessage();
        String strCorreos                           = config.Correo_Notificacion__c;
        String[] toAddresses                        = strCorreos.split(',');
        toAddresses.add(UserInfo.getUserEmail());
        mail.setToAddresses(toAddresses);
        mail.setSubject(config.Asunto_Correo_Notificacion__c + ' ' + strFechaHoraActual);
        mail.setPlainTextBody('INFORME CUENTA NO LIQUIDADA \n\n' 
        +'Fecha Hora de Ejecución: ' + strFechaHoraActual +'\n\n'
        +'Usuario que ejecuto el Batch: ' + UserInfo.getName() + ' ID: ' + UserInfo.getUserId()  +'\n\n'
        //+ 'Cantidad de Leads a Asignar ' + lstCantLeads.size() + +'\n\n'
        + 'Por favor revisar el archivo adjunto');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});      
        if (!Test.isRunningTest() ) 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
	
}