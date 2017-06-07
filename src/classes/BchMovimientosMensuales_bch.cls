/*******************************************************************************
Desarrollado por:   RTD
Autor:              Marwin Pineda
Proyecto:           Movimientos Automáticos.
Descripción:        Clase Batch Creación Movimientos Mensuales.

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha           Autor                   Descripción
    ---     ---             ----------              ---------------------------     
    1.0     25-Jul-2016     Marwin Pineda(MP)       Creación de la Clase.
*******************************************************************************/
global class BchMovimientosMensuales_bch implements Database.Batchable<sObject>, Database.Stateful
{
    global final String Query;
    global String strRenglonInforme;
    global Integer intContador;             
    
    global BchMovimientosMensuales_bch(String q)
    {
        Query = q;
        intContador = 0;
        strRenglonInforme = 'Consecutivo,Reparadora,Tipo Movimiento,Monto\n'; 
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        List<Reparadora__c> lstReparadoras 	= scope;
        List<Movimientos__c> lstMovimientos = new List<Movimientos__c>();
    	Movimientos__c objMovimiento;
    	
        for(Reparadora__c objReparadora :lstReparadoras)
        {
        	objMovimiento 						= new Movimientos__c();
            objMovimiento.Fecha__c 				= Date.newInstance(Date.today().year(),Date.today().month(),1);
            objMovimiento.Tipo_de_movimiento__c	= 'Comision Mensual';
            objMovimiento.Monto__c 				= objReparadora.ComisionMensual__c != null ? objReparadora.ComisionMensual__c * -1 : 0.00;
            
            lstMovimientos.add(objMovimiento);
            intContador++;
        	strRenglonInforme += '"' + intContador + '","'+objReparadora.Id + '","'+objMovimiento.Tipo_de_movimiento__c+'","'+ objMovimiento.Monto__c+'",\n';
        }
        insert lstMovimientos;        
    }
    
    global void finish(Database.BatchableContext BC)
    {
        Notificacion_Trabajos_Programados__c config = Notificacion_Trabajos_Programados__c.getInstance( 'BchMovimientosMensuales_bch' );
        Datetime dtFechaHoraActual                  = Datetime.now();
        String strFechaHoraActual                   = dtFechaHoraActual.format('dd/MM/yyyy HH:mm:ss');
        Messaging.EmailFileAttachment csvAttc       = new Messaging.EmailFileAttachment();
        blob csvBlob                                = Blob.valueOf(strRenglonInforme);  
        String csvname= 'InformeMovimientosMensualesRTDColombia' + dtFechaHoraActual.format('dd_MM_yyyy_HH_mm_ss') +'.csv';      
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);       
        Messaging.SingleEmailMessage mail   = new Messaging.SingleEmailMessage();
        String strCorreos                   = config.Correo_Notificacion__c;
        System.debug('\n\n@@@strCorreos--------> ' + strCorreos + '\n\n');
        String[] toAddresses                = strCorreos.split(',');
        toAddresses.add(UserInfo.getUserEmail());
        mail.setToAddresses(toAddresses);
        mail.setSubject(config.Asunto_Correo_Notificacion__c + ' ' + strFechaHoraActual);
        mail.setPlainTextBody('INFORME MOVIMIENTOS MENSUALES RTD COLOMBIA \n\n' 
        +'Fecha Hora de Ejecución: ' + strFechaHoraActual +'\n\n'
        +'Usuario que ejecuto el Batch: ' + UserInfo.getName() + ' ID: ' + UserInfo.getUserId()  +'\n\n'
        //+ 'Cantidad de Leads a Asignar ' + lstCantLeads.size() + +'\n\n'
        + 'Por favor revisar el archivo adjunto');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});      
        if (!Test.isRunningTest() ) 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}