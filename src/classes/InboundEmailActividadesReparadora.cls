/*******************************************************************************
Desarrollado por:   Resuelve tu deuda
Autor:              Ricardo Parra
Proyecto:           Calidad Colombia
Descripción:       

Cambios (Versiones)
-------------------------------------
    No.     Fecha           Autor                       Descripción
    ---     ---             ----------                  --------------------------      
    1.0     10-Sep-2015     Ricardo Parra (RP)           Creación de la Clase.
        
*******************************************************************************/
global class InboundEmailActividadesReparadora implements Messaging.InboundEmailHandler 
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
        Task T = new Task();
        Id TaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Actividades de servicio al cliente').getRecordTypeId();
         list<Reparadora__c> Listreparadora;
        if(cpDirCorreosNoDeseados.Correo_Error_Salesforce__c != email.fromAddress)
        {

            try 
            {
               
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
                    Listreparadora=[SELECT Id,
                    Name,
                    OwnerId FROM Reparadora__c
                    where Cliente__c=:lstCliente[0].id limit 1
                    ];

                    if(Listreparadora.size()>0)
                    {
                        T.OwnerId = Listreparadora[0].OwnerId;
                        T.Priority = 'Normal';
                        T.Status = 'En Proceso';
                        T.ActivityDate = Date.today();
                        T.Subject = 'Respuesta a Correo Electrónico';           
                        T.RecordTypeId = TaskRecordTypeId;
                        T.WhatId  = Listreparadora[0].Id;
                        T.Description = myPlainText;
                        T.WhoId = lstCliente[0].PersonContactId;


                    }
                    
                    


                }
               
                                                         
                
            
               
                if(Listreparadora.size() > 0)
                {
                            insert T;
                }   
                else
                {
                    result.success = false;
                    return result;
                }



    
                
                if(Listreparadora.size()>0)
                {

                    lstAtt.add( new Attachment(Body = (myPlainText != null ? Blob.valueOf(myPlainText) : Blob.valueOf('') )
                        , Name = 'Cuerpo del Correo'
                        , ContentType = 'Text'
                        , Description = 'Cuerpo del Correo'
                        , ParentId = T.Id
                        , OwnerId =Listreparadora[0].OwnerId
                    ) );


                }
                    
               
                if(email.textAttachments != null && email.textAttachments.size() > 0)
                {
                    for(Messaging.InboundEmail.TextAttachment txtAtt : email.textAttachments)
                    {
                       
                            lstAtt.add( new Attachment(Body = Blob.valueOf(txtAtt.body), 
                                                       Name = txtAtt.fileName, ContentType = txtAtt.mimeTypeSubType, 
                                                       Description = 'Archivo adjunto email', 
                                                       ParentId = T.Id,
                                                       OwnerId = Listreparadora[0].OwnerId
                                                       ) );
                       
                    }
                }


                if(email.binaryAttachments != null && email.binaryAttachments.size() > 0)
                {
                    for(Messaging.InboundEmail.BinaryAttachment binAtt : email.binaryAttachments)
                    {
                       
                            lstAtt.add( new Attachment(Body = binAtt.body, 
                                                       Name = binAtt.fileName,
                                                        ContentType = binAtt.mimeTypeSubType, 
                                                       Description = 'Archivo adjunto email', 
                                                       ParentId = T.Id,
                                                       OwnerId = Listreparadora[0].OwnerId
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