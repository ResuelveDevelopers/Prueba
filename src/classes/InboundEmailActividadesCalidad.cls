/*******************************************************************************
Desarrollado por:   Resuelve tu deuda
Autor:              Jeisson Hernandez
Proyecto:           Calidad Colombia
Descripción:        Clase de Correo entrante para crear actividades de calidad a partir de correos que lleguen al 
                    correo institucional resuelvetuqueja@resuelve.mx

Cambios (Versiones)
-------------------------------------
    No.     Fecha           Autor                       Descripción
    ---     ---             ----------                  --------------------------      
    1.0     08-Jul-2015     Jeisson Hernandez (JH)      Creación de la Clase.
        
*******************************************************************************/
global class InboundEmailActividadesCalidad implements Messaging.InboundEmailHandler 
{

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) 
    {

        String sOwnerAtch = '';    
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        List<Attachment> lstAtt = new List<Attachment>();
        String myPlainText= '';
        myPlainText = email.plainTextBody;  
        System.debug('InboundEmailActividadesCalidad email.fromAddress: ' + email.fromAddress );
        System.debug('InboundEmailActividadesCalidad email.fromName: ' + email.fromName );
        DirCorreosNoDeseados__c cpDirCorreosNoDeseados = DirCorreosNoDeseados__c.getInstance();
        
        if(cpDirCorreosNoDeseados.Correo_Error_Salesforce__c != email.fromAddress)
        {

            try 
            {
                Conf_IdsDesarrollos__c ConfIds= Conf_IdsDesarrollos__c.getValues('InboundEmailActividadesCalidad_Id1'); 
                Id CorreoQuejaRecordTypeId = Schema.SObjectType.ActividadCalidad__c.getRecordTypeInfosByName().get('Correo Queja').getRecordTypeId();
                //List<User> lstPropietario = [Select Id,Name From User Where Id ='005G0000003DrRX'];
                List<User> lstPropietario = [Select Id,Name From User Where Id =:ConfIds.Id__c];
                
                System.debug('Usuario: ' + lstPropietario);
                
                //JH 09-Feb-2015 Busca en los clientes el correo electronico del remitente
                List<ActividadCalidad__c> lstActCalidad = new List<ActividadCalidad__c>(); 
    
                List<Account> lstCliente = new List<Account>(); 
                lstCliente = [Select Id, 
                              Name, 
                              OwnerId,
                              PersonContactId,
                              PersonEmail,
                              Correo_electronico2__c
                              From Account 
                              WHERE PersonEmail = :email.fromAddress 
                              OR Correo_electronico2__c = :email.fromAddress LIMIT 1];
    
                //JH 09-Feb-2015 Si encontro cliente agrega la actividad de calidad
                if(lstCliente.size()> 0)
                {
                    ActividadCalidad__c objActCalidad = new ActividadCalidad__c
                                                    (TipoActividad__c ='Correo Queja',
                                                     Origen__c ='Cliente',
                                                     EstadoRegistro__c = 'En Proceso',
                                                     ComentariosCliente__c = email.plainTextBody,
                                                     Asunto__c = email.subject,
                                                     Cliente__c = lstCliente[0].Id,
                                                     CorreoElectronico__c = email.fromAddress,
                                                     RecordTypeId = CorreoQuejaRecordTypeId
                                                    );
                    if(lstPropietario.size()>0)
                        objActCalidad.OwnerId=lstPropietario[0].Id;
                    lstActCalidad.add(objActCalidad);
                }
                else
                {
                    //JH 09-Feb-2015 Si no encontro en los clientes el correo electronico del remitentes ahora busca en las oportunidades
                    List<Lead> lstOpp = new List<Lead>();  
                    lstOpp =[Select Id, 
                                    Name, 
                                    OwnerId,
                                    Email   
                                    From Lead 
                                    WHERE Email = :email.fromAddress LIMIT 1]; 
    
                    if (lstOpp.size()>0)
                    {
                        //JH 09-Feb-2015 Si encontro oportunidad agrega la actividad de calidad
                    ActividadCalidad__c objActCalidad = new ActividadCalidad__c
                                                    (TipoActividad__c ='Correo Queja',
                                                     Origen__c ='Oportunidad',
                                                     EstadoRegistro__c = 'En Proceso',
                                                     ComentariosCliente__c = email.plainTextBody,
                                                     Asunto__c = email.subject, 
                                                     OportunidadLead__c = lstOpp[0].Id,
                                                     CorreoElectronico__c = email.fromAddress,
                                                     RecordTypeId = CorreoQuejaRecordTypeId
                                                    );
                        if(lstPropietario.size()>0)
                        objActCalidad.OwnerId=lstPropietario[0].Id;
                        lstActCalidad.add(objActCalidad);
                    }
                    else
                    {
                        //JH 09-Feb-2015 Si no encontro en los clientes ni en las oportunidades agrega la actividad de calidad sola
                        ActividadCalidad__c objActCalidad = new ActividadCalidad__c
                                (TipoActividad__c ='Correo Queja',
                                 Origen__c ='',
                                 EstadoRegistro__c = 'En Proceso',
                                 ComentariosCliente__c = email.plainTextBody,
                                 Asunto__c = email.subject,
                                 CorreoElectronico__c = email.fromAddress,
                                 RecordTypeId = CorreoQuejaRecordTypeId 
                                );
                        if(lstPropietario.size()>0)
                            objActCalidad.OwnerId=lstPropietario[0].Id;                         
                        lstActCalidad.add(objActCalidad);
                    }                                       
                
                }
                //JH 09-Feb-2015 Inserta las actividades de calidad agregadas
                if(lstActCalidad.size() > 0)
                {system.debug('/n lstActCalidad ====>/n'+ lstActCalidad);
                    insert lstActCalidad;
                }   
                else
                    return result;
    
                System.debug('lstActCalidad[0].Id: ' + lstActCalidad[0].Id);
                if(lstPropietario.size()>0)
                    lstAtt.add( new Attachment(Body = (myPlainText != null ? Blob.valueOf(myPlainText) : Blob.valueOf('') )
                        , Name = 'Cuerpo del Correo'
                        , ContentType = 'Text'
                        , Description = 'Cuerpo del Correo'
                        , ParentId = lstActCalidad[0].Id
                        , OwnerId = lstPropietario[0].Id
                    ) );
                else
                    lstAtt.add( new Attachment(Body = (myPlainText != null ? Blob.valueOf(myPlainText) : Blob.valueOf('') )
                        , Name = 'Cuerpo del Correo'
                        , ContentType = 'Text'
                        , Description = 'Cuerpo del Correo'
                        , ParentId = lstActCalidad[0].Id
                    ) );
                if(email.textAttachments != null && email.textAttachments.size() > 0){
                    for(Messaging.InboundEmail.TextAttachment txtAtt : email.textAttachments)
                    {
                        if(lstPropietario.size()>0)
                            lstAtt.add( new Attachment(Body = Blob.valueOf(txtAtt.body), 
                                                       Name = txtAtt.fileName, ContentType = txtAtt.mimeTypeSubType, 
                                                       Description = 'Archivo adjunto email', 
                                                       ParentId = lstActCalidad[0].Id,
                                                       OwnerId = lstPropietario[0].Id
                                                       ) );
                        else
                            lstAtt.add( new Attachment(Body = Blob.valueOf(txtAtt.body), 
                                                       Name = txtAtt.fileName, ContentType = txtAtt.mimeTypeSubType, 
                                                       Description = 'Archivo adjunto email', 
                                                       ParentId = lstActCalidad[0].Id                                                  
                                                       ) );
                    }
                }
                if(email.binaryAttachments != null && email.binaryAttachments.size() > 0){
                    for(Messaging.InboundEmail.BinaryAttachment binAtt : email.binaryAttachments)
                    {
                        if(lstPropietario.size()>0)
                            lstAtt.add( new Attachment(Body = binAtt.body, 
                                                   Name = binAtt.fileName, 
                                                   ContentType = binAtt.mimeTypeSubType, 
                                                   Description = 'Archivo adjunto email', 
                                                   ParentId = lstActCalidad[0].Id,
                                                   OwnerId = lstPropietario[0].Id
                                                   ) );
                        else
                            lstAtt.add( new Attachment(Body = binAtt.body, 
                               Name = binAtt.fileName, 
                               ContentType = binAtt.mimeTypeSubType, 
                               Description = 'Archivo adjunto email', 
                               ParentId = lstActCalidad[0].Id
                               ) );                    
                    }
                }
                if(lstAtt.size() > 0)
                    insert lstAtt;
            } 
            // Si una excepcion ocurre ya se en la consulta de clientes, oprotunidades o en la creacion de los registros
            catch (QueryException e) 
            { 
                System.debug('Errores en consultas o insercion de actividades calidad o archvivos adjuntos: ' + e); 
            }
        }
        else
        {
            System.debug('Se recibio correo no deseado desde la direccion de correo: ' + email.fromAddress);
        }         
        result.success = true;
        return result;
    }
}