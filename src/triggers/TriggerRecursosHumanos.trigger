/*******************************************************************************
Desarrollado por:   Resuelve tu deuda
Autor:              Jeisson Hernandez
Proyecto:           Colombia
Descripción:        Trigger del objeto Recursos Humanos que asocia la actualizacion de campos de busquedas 
                    de registros compartidos via Salesforce to Salesforce con la Org de Mexico

Cambios (Versiones)
-------------------------------------
    No.     Fecha           Autor                       Descripción
    ---     ---             ----------                  --------------------------      
    1.0     28-May-2015     Jeisson Hernandez (JH)      Creación de Trigger.
    1.1		31-May-2016		Jeisson Hernandez (JH)      Ajustes para mejorar rendimiento y procesar más registros.
        
*******************************************************************************/
trigger TriggerRecursosHumanos on RecursosHumanos__c (after insert, after update, before insert,before update) 
{
    ConexionesS2S__c objConexionS2S = ConexionesS2S__c.getInstance();
    System.debug('@@@ Conf Personalizada S2S: '+objConexionS2S);
    System.debug('@@@ User Info S2S: '+ UserInfo.getUserId() +' '+ UserInfo.getUserName());
    System.debug('@@@ Trigger.new.size(): '+ Trigger.new.size());
    if(objConexionS2S.ActivarTriggerS2S__c == true)
    {
    	if((Trigger.new.size() <=50  && UserInfo.getUserId() == objConexionS2S.IdUsuarioConexion__c) 
    	  || (Trigger.new.size() <=50 && Test.isRunningTest()))
    	{
	        if(system.isFuture()) return;
	        Id administrativoRecordTypeId = Schema.SObjectType.RecursosHumanos__c.getRecordTypeInfosByName().get('Administrativo').getRecordTypeId();
	        Id negociacionRecordTypeId = Schema.SObjectType.RecursosHumanos__c.getRecordTypeInfosByName().get('Negociación').getRecordTypeId();
	        Id servicioClienteRecordTypeId = Schema.SObjectType.RecursosHumanos__c.getRecordTypeInfosByName().get('Servicio al Clientes').getRecordTypeId();
	        Id ventasRecordTypeId = Schema.SObjectType.RecursosHumanos__c.getRecordTypeInfosByName().get('Ventas').getRecordTypeId();
	                
	        // JH 28-May-2015: Elimina los campos de busqueda si desde Org Mexico se eliminaron
	        if(trigger.isBefore)
	        { 
	            for (RecursosHumanos__c objRecursoHumano: Trigger.new) 
	            {       
	                System.debug('Colombia objRecursoHumano.IdDirectorMexico__c: ' + objRecursoHumano.IdDirectorMexico__c);
	                if(Trigger.isUpdate && (objRecursoHumano.IdDirectorMexico__c == null || objRecursoHumano.IdDirectorMexico__c == ''))
	                {
	                    System.debug('Colombia Eliminacion de Director');
	                    objRecursoHumano.Director__c = null;
	                }
	                
	                System.debug('Colombia objRecursoHumano.IdSubDirectorMexico__c: ' + objRecursoHumano.IdSubDirectorMexico__c);
	                if(Trigger.isUpdate && (objRecursoHumano.IdSubDirectorMexico__c == null || objRecursoHumano.IdSubDirectorMexico__c == ''))
	                {
	                    System.debug('Colombia Eliminacion de SubDirector');
	                    objRecursoHumano.SubDirector__c = null;
	                }
	    
	                System.debug('Colombia objRecursoHumano.IdSubdirectorAnteriorMexico__c: ' + objRecursoHumano.IdSubdirectorAnteriorMexico__c);
	                if(Trigger.isUpdate && (objRecursoHumano.IdSubdirectorAnteriorMexico__c == null || objRecursoHumano.IdSubdirectorAnteriorMexico__c == ''))
	                {
	                    System.debug('Colombia Eliminacion de SubDirector Anterior');
	                    objRecursoHumano.SubdirectorAnterior__c = null;
	                }
	    
	                System.debug('Colombia objRecursoHumano.IdGerenteMexico__c' + objRecursoHumano.IdGerenteMexico__c);
	                if(Trigger.isUpdate && (objRecursoHumano.IdGerenteMexico__c == null || objRecursoHumano.IdGerenteMexico__c == ''))
	                {
	                    System.debug('Colombia Eliminacion de Gerente');
	                    objRecursoHumano.Gerente__c = null;
	                }
	                
	                System.debug('Colombia objRecursoHumano.IdGerenteAnteriorMexico__c: ' + objRecursoHumano.IdGerenteAnteriorMexico__c);
	                if(Trigger.isUpdate && (objRecursoHumano.IdGerenteAnteriorMexico__c == null || objRecursoHumano.IdGerenteAnteriorMexico__c == ''))
	                {
	                    System.debug('Colombia Eliminacion de Gerente Anterior');
	                    objRecursoHumano.GerenteAnterior__c = null;
	                }
	                
	                
	                System.debug('Colombia objRecursoHumano.IdTeamLeaderMexico__c: ' + objRecursoHumano.IdTeamLeaderMexico__c);
	                if(Trigger.isUpdate && (objRecursoHumano.IdTeamLeaderMexico__c == null || objRecursoHumano.IdTeamLeaderMexico__c == ''))
	                {
	                    System.debug('Colombia Eliminacion de Teamleader');
	                    objRecursoHumano.Team_Leader__c = null;
	                }
	                
	                System.debug('Colombia objRecursoHumano.IdTeamLeaderAnteriorMexico__c: ' + objRecursoHumano.IdTeamLeaderAnteriorMexico__c);
	                if(Trigger.isUpdate && (objRecursoHumano.IdTeamLeaderAnteriorMexico__c == null || objRecursoHumano.IdTeamLeaderAnteriorMexico__c == ''))
	                {
	                    System.debug('Colombia Eliminacion de TeamLeader Anterior');
	                    objRecursoHumano.TeamLeaderAnterior__c = null;
	                }
	                
	                System.debug('Colombia objRecursoHumano.IdSupervisorMexico__c: ' + objRecursoHumano.IdSupervisorMexico__c);
	                if(Trigger.isUpdate && (objRecursoHumano.IdSupervisorMexico__c == null || objRecursoHumano.IdSupervisorMexico__c == ''))
	                {
	                    System.debug('Colombia Eliminacion de Supervisor');
	                    objRecursoHumano.Supervisor__c = null;
	                }
	    
	                System.debug('Colombia objRecursoHumano.IdJefeDirectoMexico__c: ' + objRecursoHumano.IdJefeDirectoMexico__c);
	                if(Trigger.isUpdate && (objRecursoHumano.IdJefeDirectoMexico__c == null || objRecursoHumano.IdJefeDirectoMexico__c == ''))
	                {
	                    System.debug('Colombia Eliminacion de Jefe Directo');
	                    objRecursoHumano.JefeDirecto__c = null;
	                }
	    
	                System.debug('Colombia objRecursoHumano.IdSucursalMexico__c: ' + objRecursoHumano.IdSucursalMexico__c);
	                if(Trigger.isUpdate && (objRecursoHumano.IdSucursalMexico__c == null || objRecursoHumano.IdSucursalMexico__c == ''))
	                {
	                    System.debug('Colombia Eliminacion de Sucursal');
	                    objRecursoHumano.IdSucursalMexico__c = null;
	                }
	    
	                System.debug('Colombia objRecursoHumano.IdEmpresaMexico__c: ' + objRecursoHumano.IdEmpresaMexico__c);
	                if(Trigger.isUpdate && (objRecursoHumano.IdEmpresaMexico__c == null || objRecursoHumano.IdEmpresaMexico__c == ''))
	                {
	                    System.debug('Colombia Eliminacion de Empresa');
	                    objRecursoHumano.IdEmpresaMexico__c = null;
	                }
	    
	                // JH 28-May-2015: Sincroniza el Tipo de Registro en el RH con el Tipo de Registro que se tiene en la Org de Mexico
	                if (Trigger.isInsert || (Trigger.isUpdate 
	                    && (Trigger.oldMap.get(objRecursoHumano.Id).NombreTipoRegistroMexico__c != objRecursoHumano.NombreTipoRegistroMexico__c))) 
	                {
	                    if(objRecursoHumano.NombreTipoRegistroMexico__c == 'Administrativo')
	                        objRecursoHumano.RecordTypeId = administrativoRecordTypeId;
	    
	                    if(objRecursoHumano.NombreTipoRegistroMexico__c == 'Negociación')
	                        objRecursoHumano.RecordTypeId = negociacionRecordTypeId;
	    
	                    if(objRecursoHumano.NombreTipoRegistroMexico__c == 'Servicio al Clientes')
	                        objRecursoHumano.RecordTypeId = servicioClienteRecordTypeId;
	    
	                    if(objRecursoHumano.NombreTipoRegistroMexico__c == 'Ventas')
	                        objRecursoHumano.RecordTypeId = ventasRecordTypeId;
	                }
	                
	            }
	        }
	    
	        // JH 28-May-2015: Asocia la actualizacion de campos de busquedas de registros compartidos via 
	        //                  Salesforce to Salesforce con la Org de Mexico cuando se crean o modifican registros 
	        if(trigger.isAfter)
	        {
				System.debug('Conexion: '+objConexionS2S.ConexionS2SMexico__c);
				Map<Id,Id> directorIdMap = new Map<Id,Id>();
				Map<Id,Id> subDirectorIdMap = new Map<Id,Id>();
				Map<Id,Id> subDirectorAnteriorIdMap = new Map<Id,Id>();
				Map<Id,Id> gerenteIdMap = new Map<Id,Id>();
				Map<Id,Id> teamLeaderIdMap = new Map<Id,Id>();
				Map<Id,Id> teamLeaderAnteriorIdMap = new Map<Id,Id>();  
				Map<Id,Id> supervisorIdMap = new Map<Id,Id>();
				Map<Id,Id> jefeDirectoIdMap = new Map<Id,Id>();
				Map<Id,Id> gerenteAnteriorIdMap = new Map<Id,Id>();
				Map<Id,Id> sucursalIdMap = new Map<Id,Id>();
				Map<Id,Id> empresaIdMap = new Map<Id,Id>();     
				
	            for (RecursosHumanos__c objRecursoHumano: Trigger.new) 
	            { 
	                if (objRecursoHumano.IdDirectorMexico__c != null && objRecursoHumano.IdDirectorMexico__c != '') 
	                { 
	                    System.debug('Colombia Director Mexico');
	                    System.debug('Colombia objRecursoHumano.lastModifiedById ' + objRecursoHumano.lastModifiedById);
	                    System.debug('Colombia Trigger.New '+ objRecursoHumano.IdDirectorMexico__c);
	                    if (Trigger.isInsert || 
	                        (Trigger.isUpdate 
	                        && (Trigger.oldMap.get(objRecursoHumano.Id).IdDirectorMexico__c != objRecursoHumano.IdDirectorMexico__c)
	                           || (Trigger.oldMap.get(objRecursoHumano.Id).IdDirectorMexico__c == objRecursoHumano.IdDirectorMexico__c && objRecursoHumano.Director__c == null)
	                        )
	                        ) 
	                    { 
	                        directorIdMap.put(objRecursoHumano.id, objRecursoHumano.IdDirectorMexico__c);
	                        System.debug('Colombia Director Mexico map' + directorIdMap.values()); 
	                    }
	                }
	                
	                if (objRecursoHumano.IdSubDirectorMexico__c != null && objRecursoHumano.IdSubDirectorMexico__c != '') 
	                { 
	                    System.debug('Colombia SubDirector Mexico');
	                    System.debug('Colombia objRecursoHumano.lastModifiedById ' + objRecursoHumano.lastModifiedById);
	                    System.debug('Colombia Trigger.New '+ objRecursoHumano.IdSubDirectorMexico__c);
	                        if (Trigger.isInsert || 
	                            (Trigger.isUpdate 
	                            && (Trigger.oldMap.get(objRecursoHumano.Id).IdSubDirectorMexico__c != objRecursoHumano.IdSubDirectorMexico__c)
	                               || (Trigger.oldMap.get(objRecursoHumano.Id).IdSubDirectorMexico__c == objRecursoHumano.IdSubDirectorMexico__c && objRecursoHumano.SubDirector__c == null)
	                            )
	                            ) 
	                        { 
	                            subDirectorIdMap.put(objRecursoHumano.id, objRecursoHumano.IdSubDirectorMexico__c);
	                            System.debug('Colombia SubDirector Mexico map' + subDirectorIdMap.values()); 
	                        }
	                }
	    
	    
	                if (objRecursoHumano.IdSubdirectorAnteriorMexico__c != null && objRecursoHumano.IdSubdirectorAnteriorMexico__c != '') 
	                { 
	                    System.debug('Colombia SubDirector Anterior Mexico');
	                    System.debug('Colombia objRecursoHumano.lastModifiedById ' + objRecursoHumano.lastModifiedById);
	                    System.debug('Colombia Trigger.New '+ objRecursoHumano.IdSubdirectorAnteriorMexico__c);
	                        if (Trigger.isInsert || 
	                            (Trigger.isUpdate 
	                            && (Trigger.oldMap.get(objRecursoHumano.Id).IdSubdirectorAnteriorMexico__c != objRecursoHumano.IdSubdirectorAnteriorMexico__c)
	                               || (Trigger.oldMap.get(objRecursoHumano.Id).IdSubdirectorAnteriorMexico__c == objRecursoHumano.IdSubdirectorAnteriorMexico__c && objRecursoHumano.SubdirectorAnterior__c == null)
	                            )
	                            ) 
	                        { 
	                            subDirectorAnteriorIdMap.put(objRecursoHumano.id, objRecursoHumano.IdSubdirectorAnteriorMexico__c);
	                            System.debug('Colombia SubDirector Anterior Mexico map' + subDirectorAnteriorIdMap.values()); 
	                        }
	                }
	    
	                if (objRecursoHumano.IdGerenteMexico__c != null && objRecursoHumano.IdGerenteMexico__c != '') 
	                { 
	                    System.debug('Colombia Gerente Mexico');
	                    System.debug('Colombia objRecursoHumano.lastModifiedById ' + objRecursoHumano.lastModifiedById);
	                    System.debug('Colombia Trigger.New '+ objRecursoHumano.IdGerenteMexico__c);
	                        if (Trigger.isInsert || 
	                            (Trigger.isUpdate 
	                            && (Trigger.oldMap.get(objRecursoHumano.Id).IdGerenteMexico__c != objRecursoHumano.IdGerenteMexico__c)
	                               || (Trigger.oldMap.get(objRecursoHumano.Id).IdGerenteMexico__c == objRecursoHumano.IdGerenteMexico__c && objRecursoHumano.Gerente__c == null)
	                            )
	                            ) 
	                        { 
	                            gerenteIdMap.put(objRecursoHumano.id, objRecursoHumano.IdGerenteMexico__c);
	                            System.debug('Colombia Gerente Mexico map' + gerenteIdMap.values()); 
	                        }
	                }
	    
	                if (objRecursoHumano.IdGerenteAnteriorMexico__c != null && objRecursoHumano.IdGerenteAnteriorMexico__c != '') 
	                { 
	                    System.debug('Colombia Gerente Anterior Mexico');
	                    System.debug('Colombia objRecursoHumano.lastModifiedById ' + objRecursoHumano.lastModifiedById);
	                    System.debug('Colombia Trigger.New '+ objRecursoHumano.IdGerenteAnteriorMexico__c);
	                        if (Trigger.isInsert || 
	                            (Trigger.isUpdate 
	                            && (Trigger.oldMap.get(objRecursoHumano.Id).IdGerenteAnteriorMexico__c != objRecursoHumano.IdGerenteAnteriorMexico__c)
	                               || (Trigger.oldMap.get(objRecursoHumano.Id).IdGerenteAnteriorMexico__c == objRecursoHumano.IdGerenteAnteriorMexico__c && objRecursoHumano.GerenteAnterior__c == null)
	                            )
	                            ) 
	                        { 
	                            gerenteAnteriorIdMap.put(objRecursoHumano.id, objRecursoHumano.IdGerenteAnteriorMexico__c);
	                            System.debug('Colombia Gerente Anterior Mexico map' + gerenteIdMap.values()); 
	                        }
	                }
	    
	                if (objRecursoHumano.IdTeamLeaderMexico__c != null && objRecursoHumano.IdTeamLeaderMexico__c != '') 
	                { 
	                    System.debug('Colombia TeamLeader Mexico');
	                    System.debug('Colombia objRecursoHumano.lastModifiedById ' + objRecursoHumano.lastModifiedById);
	                    System.debug('Colombia Trigger.New '+ objRecursoHumano.IdTeamLeaderMexico__c);
	                        if (Trigger.isInsert || 
	                            (Trigger.isUpdate 
	                            && (Trigger.oldMap.get(objRecursoHumano.Id).IdTeamLeaderMexico__c != objRecursoHumano.IdTeamLeaderMexico__c)
	                               || (Trigger.oldMap.get(objRecursoHumano.Id).IdTeamLeaderMexico__c == objRecursoHumano.IdTeamLeaderMexico__c && objRecursoHumano.Team_Leader__c == null)
	                            )
	                            ) 
	                        { 
	                            teamLeaderIdMap.put(objRecursoHumano.id, objRecursoHumano.IdTeamLeaderMexico__c);
	                            System.debug('Colombia TeamLeader Mexico map' + teamLeaderIdMap.values()); 
	                        }
	                }
	                
	    
	                if (objRecursoHumano.IdTeamLeaderAnteriorMexico__c != null && objRecursoHumano.IdTeamLeaderAnteriorMexico__c != '') 
	                { 
	                    System.debug('Colombia TeamLeader Anterior Mexico');
	                    System.debug('Colombia objRecursoHumano.lastModifiedById ' + objRecursoHumano.lastModifiedById);
	                    System.debug('Colombia Trigger.New '+ objRecursoHumano.IdTeamLeaderAnteriorMexico__c);
	                        if (Trigger.isInsert || 
	                            (Trigger.isUpdate 
	                            && (Trigger.oldMap.get(objRecursoHumano.Id).IdTeamLeaderAnteriorMexico__c != objRecursoHumano.IdTeamLeaderAnteriorMexico__c)
	                               || (Trigger.oldMap.get(objRecursoHumano.Id).IdTeamLeaderAnteriorMexico__c == objRecursoHumano.IdTeamLeaderAnteriorMexico__c && objRecursoHumano.TeamLeaderAnterior__c == null)
	                            )
	                            ) 
	                        { 
	                            teamLeaderAnteriorIdMap.put(objRecursoHumano.id, objRecursoHumano.IdTeamLeaderAnteriorMexico__c);
	                            System.debug('Colombia TeamLeader Anterior Mexico map' + teamLeaderAnteriorIdMap.values()); 
	                        }
	                }
	                
	                if (objRecursoHumano.IdSupervisorMexico__c != null && objRecursoHumano.IdSupervisorMexico__c != '') 
	                { 
	                    System.debug('Colombia Supervisor Mexico');
	                    System.debug('Colombia objRecursoHumano.lastModifiedById ' + objRecursoHumano.lastModifiedById);
	                    System.debug('Colombia Trigger.New '+ objRecursoHumano.IdSupervisorMexico__c);
	                        if (Trigger.isInsert || 
	                            (Trigger.isUpdate 
	                            && (Trigger.oldMap.get(objRecursoHumano.Id).IdSupervisorMexico__c != objRecursoHumano.IdSupervisorMexico__c)
	                               || (Trigger.oldMap.get(objRecursoHumano.Id).IdSupervisorMexico__c == objRecursoHumano.IdSupervisorMexico__c && objRecursoHumano.Supervisor__c == null)
	                            )
	                            ) 
	                        { 
	                            supervisorIdMap.put(objRecursoHumano.id, objRecursoHumano.IdSupervisorMexico__c);
	                            System.debug('Colombia Supervisor Mexico map' + supervisorIdMap.values()); 
	                        }
	                }
	    
	    
	                if (objRecursoHumano.IdJefeDirectoMexico__c != null && objRecursoHumano.IdJefeDirectoMexico__c != '') 
	                { 
	                    System.debug('Colombia Jefe Directo Mexico');
	                    System.debug('Colombia objRecursoHumano.lastModifiedById ' + objRecursoHumano.lastModifiedById);
	                    System.debug('Colombia Trigger.New '+ objRecursoHumano.IdJefeDirectoMexico__c);
	                        if (Trigger.isInsert || 
	                            (Trigger.isUpdate 
	                            && (Trigger.oldMap.get(objRecursoHumano.Id).IdJefeDirectoMexico__c != objRecursoHumano.IdJefeDirectoMexico__c)
	                               || (Trigger.oldMap.get(objRecursoHumano.Id).IdJefeDirectoMexico__c == objRecursoHumano.IdJefeDirectoMexico__c && objRecursoHumano.JefeDirecto__c == null)
	                            )
	                            ) 
	                        { 
	                            jefeDirectoIdMap.put(objRecursoHumano.id, objRecursoHumano.IdJefeDirectoMexico__c);
	                            System.debug('Colombia Jefe Directo Mexico map' + supervisorIdMap.values()); 
	                        }
	                }
	    
	                if (objRecursoHumano.IdSucursalMexico__c != null && objRecursoHumano.IdSucursalMexico__c != '') 
	                { 
	                
	                    System.debug('Colombia Sucursal Mexico');
	                    System.debug('Colombia objRecursoHumano.lastModifiedById ' + objRecursoHumano.lastModifiedById);
	                    System.debug('Colombia Trigger.New '+ objRecursoHumano.IdSucursalMexico__c);
	                        if (Trigger.isInsert || 
	                            (Trigger.isUpdate 
	                            && (Trigger.oldMap.get(objRecursoHumano.Id).IdSucursalMexico__c != objRecursoHumano.IdSucursalMexico__c)
	                               || (Trigger.oldMap.get(objRecursoHumano.Id).IdSucursalMexico__c == objRecursoHumano.IdSucursalMexico__c && objRecursoHumano.Sucursal__c == null)
	                            )
	                            ) 
	                        { 
	                            sucursalIdMap.put(objRecursoHumano.id, objRecursoHumano.IdSucursalMexico__c);
	                            System.debug('Colombia Sucursal Mexico map' + sucursalIdMap.values()); 
	                        }
	                }
	                
	                if (objRecursoHumano.IdEmpresaMexico__c != null && objRecursoHumano.IdEmpresaMexico__c != '') 
	                { 
	                
	                    System.debug('Colombia Empresa Mexico');
	                    System.debug('Colombia objRecursoHumano.lastModifiedById ' + objRecursoHumano.lastModifiedById);
	                    System.debug('Colombia Trigger.New '+ objRecursoHumano.IdEmpresaMexico__c);
	                        if (Trigger.isInsert || 
	                            (Trigger.isUpdate 
	                            && (Trigger.oldMap.get(objRecursoHumano.Id).IdEmpresaMexico__c != objRecursoHumano.IdEmpresaMexico__c)
	                               || (Trigger.oldMap.get(objRecursoHumano.Id).IdEmpresaMexico__c == objRecursoHumano.IdEmpresaMexico__c && objRecursoHumano.Empresa__c == null)
	                            )
	                            ) 
	                        { 
	                            empresaIdMap.put(objRecursoHumano.id, objRecursoHumano.IdEmpresaMexico__c);
	                            System.debug('Colombia Empresa Mexico map' + empresaIdMap.values()); 
	                        }
	                } 
	                 
	            } 
	        
	            // LLama metodo Futuro para asociar el Director correspondiente en la Org de Colombia  
	            if (directorIdMap.size() > 0) 
	            { 
	                System.debug('Entro actualizarCamposBusquedas Director');
	                ExternalSharingHelper.actualizarCamposBusquedas(directorIdMap,'Director'); 
	            }
	            
	            // LLama metodo Futuro para asociar el SubDirector correspondiente en la Org de Colombia  
	            if (subDirectorIdMap.size() > 0) 
	            { 
	                System.debug('Entro actualizarCamposBusquedas Sub Director'); 
	                ExternalSharingHelper.actualizarCamposBusquedas(subDirectorIdMap,'SubDirector'); 
	            }
	    
	            // LLama metodo Futuro para asociar el SubDirector Anterior correspondiente en la Org de Colombia  
	            if (subDirectorAnteriorIdMap.size() > 0) 
	            { 
	                System.debug('Entro actualizarCamposBusquedas Sub Director Anterior'); 
	                ExternalSharingHelper.actualizarCamposBusquedas(subDirectorAnteriorIdMap,'SubDirector Anterior'); 
	            }
	    
	            // LLama metodo Futuro para asociar el Gerente correspondiente en la Org de Colombia  
	            if (gerenteIdMap.size() > 0) 
	            { 
	                System.debug('Entro actualizarCamposBusquedas Gerente'); 
	                ExternalSharingHelper.actualizarCamposBusquedas(gerenteIdMap,'Gerente'); 
	            }
	    
	            // LLama metodo Futuro para asociar el Gerente Anterior correspondiente en la Org de Colombia  
	            if (gerenteAnteriorIdMap.size() > 0) 
	            { 
	                System.debug('Entro actualizarCamposBusquedas Gerente Anterior'); 
	                ExternalSharingHelper.actualizarCamposBusquedas(gerenteAnteriorIdMap,'Gerente Anterior'); 
	            }
	    
	    
	            // LLama metodo Futuro para asociar el Team Leader correspondiente en la Org de Colombia  
	            if (teamLeaderIdMap.size() > 0) 
	            { 
	                System.debug('Entro actualizarCamposBusquedas TeamLeader'); 
	                ExternalSharingHelper.actualizarCamposBusquedas(teamLeaderIdMap,'TeamLeader'); 
	            }
	    
	            // LLama metodo Futuro para asociar el Team Leader Anterior correspondiente en la Org de Colombia  
	            if (teamLeaderAnteriorIdMap.size() > 0) 
	            { 
	                System.debug('Entro actualizarCamposBusquedas TeamLeader Anterior'); 
	                ExternalSharingHelper.actualizarCamposBusquedas(teamLeaderAnteriorIdMap,'TeamLeader Anterior'); 
	            }
	    
	            // LLama metodo Futuro para asociar el Supervisor correspondiente en la Org de Colombia  
	            if (supervisorIdMap.size() > 0) 
	            { 
	                System.debug('Entro actualizarCamposBusquedas Supervisor'); 
	                ExternalSharingHelper.actualizarCamposBusquedas(supervisorIdMap,'Supervisor'); 
	            }
	            
	            // LLama metodo Futuro para asociar el Jefe Directo correspondiente en la Org de Colombia
	            if (jefeDirectoIdMap.size() > 0) 
	            { 
	                System.debug('Entro actualizarCamposBusquedas Jefe Directo'); 
	                ExternalSharingHelper.actualizarCamposBusquedas(jefeDirectoIdMap,'Jefe Directo'); 
	            }
	    
	            // LLama metodo Futuro para asociar la Sucursal correspondiente en la Org de Colombia 
	            if (sucursalIdMap.size() > 0) 
	            { 
	                System.debug('Entro actualizarCamposBusquedas Sucursal');
	                ExternalSharingHelper.actualizarCamposBusquedas(sucursalIdMap,'Sucursal'); 
	            }
	            // LLama metodo Futuro para asociar la Empresa correspondiente en la Org de Colombia 
	            if (empresaIdMap.size() > 0) 
	            { 
	                System.debug('Entro actualizarCamposBusquedas Empresa');
	                ExternalSharingHelper.actualizarCamposBusquedas(empresaIdMap,'Empresa'); 
	            }
	            
	        }
    	}
    }
}