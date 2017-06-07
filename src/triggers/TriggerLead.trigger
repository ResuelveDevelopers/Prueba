/*******************************************************************************
Desarrollado por:   RTD
Autor:              Jeisson Hernandez
Proyecto:           Colombia III 
Descripción:        Trigger del objeto Lead

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		----------                ---------------------------     
    1.0     30-Sep-2015		Jeisson Hernandez(JH)	Creación de la Clase.
	1.1		16-Mar-2016		Jeisson Hernandez(JH)	Se agrega calificacion = Sin Tocar en el momento de asignar 
													la oportundidad de acuerdo a caso Nro. 58625
	1.2     13/07/2016		Esteban Heredia(EH)     Se agrega la asignación de oportunidades a diferentes sucursales
													dependiendo de la conf personalizada de ciudades Colombia	
*******************************************************************************/
trigger TriggerLead on Lead (before insert, before update, after insert, after update, after delete) 
{
	System.debug('@@ Id Usuario  Logeado: ' + UserInfo.getUserId());
	public Boolean blnExecuteBeforeTrigger {get;Set;}
	public Boolean blnExecuteTriggerAfter {get;Set;}
	public List<RecursosHumanos__c> objUser = [Select Id, Usuario__c,Usuario__r.Profile.Name from RecursosHumanos__c Where Usuario__c=:UserInfo.getUserId()];
	public List<Lead> lstAssignVendedorAsignadoLeadOpp = new List<Lead>();
	public String strTRLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
	public String strTROportunidad = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Oportunidad').getRecordTypeId();
	// EH 13/07/2016  Traer todas las sucursales para agregarlas a un mapa
	public List<Sucursal__c>  lstSucursales = [Select Id,Name from Sucursal__c];
	
	blnExecuteBeforeTrigger = true;
	
	if(Trigger.isBefore)
		blnExecuteBeforeTrigger = !RD_TriggerExecutionControl_cls.hasAlreadyDone('TriggerLead');

	if(blnExecuteBeforeTrigger)
	{
		if(Trigger.isBefore)
		{
			if(Trigger.isUpdate)
			{	
				EliminarDocAdjuntosLead objEliminarDocAdjLead = new EliminarDocAdjuntosLead();
				objEliminarDocAdjLead.eliminaDocAdLead(trigger.new,trigger.oldMap);
			}
			
			if(Trigger.IsInsert || Trigger.IsUpdate)
			{
				Map<String, PerfilesAsignacionVendedorAsignado__c> mapPerfilesAsigVendedorAsig = PerfilesAsignacionVendedorAsignado__c.getAll();
				Map<String, PerfilesAsignacionLeadsLandingPages__c> mapPerfilesAsigLandingPages = PerfilesAsignacionLeadsLandingPages__c.getAll();
				Set<Id> setVendedorAsignadoID = new set<Id>();
				//EH 13/07/2016  Llenado de un mapa con los valores del departamento y ciudad, para obtener la sucursal asignada
				Map<String,String> mapNameSucursalByDepCiud = new Map<String,String>();
				Map<String,Id> mapIdSucursalByNameSucursal = new Map<String,Id>();
				// Traemos los valores de la config personalizada de asignación:
				List<CiudadesColombia__c> lstCiudadesColombia = CiudadesColombia__c.getall().values();
				//Llenamos un pequeño mapa para pasar el string de las sucursales a su correspondiente Id en la instancia 
				for(Sucursal__c objSucursalTemp:lstSucursales)
				{
					// Colocamos todo en mayus y reemplazamos tíldes, además de quitar espacios, esto con el fin de que si por alguna razón está escrita lo de la landing dif a la configuración por estos detalles no haya problema
					String strNameSinTildesMayus = objSucursalTemp.Name.toUpperCase().replace('Á', 'A').replace('É', 'E').replace('Í', 'I').replace('Ó', 'O').replace('Ú', 'U').trim();
					mapIdSucursalByNameSucursal.put(strNameSinTildesMayus,objSucursalTemp.Id);					
				}
				for(CiudadesColombia__c objCiudadColombiaTemp:lstCiudadesColombia)
				{
					String strDeparSinTildesMayus = objCiudadColombiaTemp.Departamento__c.toUpperCase().replace('Á', 'A').replace('É', 'E').replace('Í', 'I').replace('Ó', 'O').replace('Ú', 'U').trim();
					String strCiudSinTildesMayus = objCiudadColombiaTemp.Ciudad__c.toUpperCase().replace('Á', 'A').replace('É', 'E').replace('Í', 'I').replace('Ó', 'O').replace('Ú', 'U').trim();
					String strSucurSinTildesMayus = objCiudadColombiaTemp.Sucursal__c.toUpperCase().replace('Á', 'A').replace('É', 'E').replace('Í', 'I').replace('Ó', 'O').replace('Ú', 'U').trim();
					mapNameSucursalByDepCiud.put(strDeparSinTildesMayus + strCiudSinTildesMayus, strSucurSinTildesMayus);
				}
				system.debug('\n\n mapNameSucursalByDepCiud: \n' + mapNameSucursalByDepCiud);
				//EH END

				for(Lead objLead : Trigger.New)
				{
					if(objLead.VendedorAsignado__c != null)
						setVendedorAsignadoID.add(objLead.VendedorAsignado__c);
				}
				system.debug('**1 setVendedorAsignadoID: \n' + setVendedorAsignadoID);
				Map<Id,RecursosHumanos__c> mapRecursosHumanos = new map<Id,RecursosHumanos__c>([Select r.Id, r.Usuario__c From RecursosHumanos__c r where r.Id In: setVendedorAsignadoID]);
				system.debug('**2 mapRecursosHumanos:\n' + mapRecursosHumanos);
				System.debug('@@ Usuario en sesion: ' + objUser);
				
				for(Lead objLead : Trigger.New)
				{
					//Evalua si el usuario que ejecuta la insercion/actualizacion es de Administrativo/Landig Page o NO para 
					//realizar la modificacion de campos FechaHoraCreacionOportunidad__c y Status
					if(!objUser.isEmpty() && objUser[0].Usuario__c !=null)
					{
						if(mapPerfilesAsigVendedorAsig.containsKey(objUser[0].Usuario__r.Profile.Name) && objLead.VendedorAsignado__c == null)
						{
							System.debug('@@ 2 Entro con Usuario Vendedor ' + UserInfo.getUserId());
							objLead.VendedorAsignado__c = objUser[0].Usuario__c !=null ? objUser[0].Id :null;
							lstAssignVendedorAsignadoLeadOpp.add(objLead); 
						}
						//Pregunta si el Lead ya tiene un vendedor asignado para no modificar el vendedor 
						if(objLead.VendedorAsignado__c != null)
						{
							System.debug('@@ Entro con Usuario Landing a Lead con Vendedor Asignado: ' + objLead.VendedorAsignado__c);
							if(mapPerfilesAsigLandingPages.containsKey(objUser[0].Usuario__r.Profile.Name))
							{
								System.debug('@@ 2 Entro con Usuario Landing a Lead con Vendedor Asignado: ' + objLead.VendedorAsignado__c);
								lstAssignVendedorAsignadoLeadOpp.add(objLead); 
							}
						}
					}
					else
					{	
						objLead.addError('El Usuario NO se encuentra creado o relacionado en Recursos Humanos');
					}
					
					//Calculo del Campo Dia__c (Dia de la Semana en que se creo el Lead)
					DateTime dtFechaDiaSemanaCreacionLead = null;
					if(Trigger.IsInsert)
					{
						//EH 13/07/2016 Se asignarán dinámicamente dependiendo del departamento y la ciudad elegida en el LandingPage
						if(objLead.AsignacionSucursal__c==null)
						{
							if(objLead.Departamento__c != null && objLead.CiudadMunicipio__c != null )
							{
								String strDeparSinTildesMayusLead = objLead.Departamento__c.toUpperCase().replace('Á', 'A').replace('É', 'E').replace('Í', 'I').replace('Ó', 'O').replace('Ú', 'U').trim();
								String strCiudSinTildesMayusLead = objLead.CiudadMunicipio__c.toUpperCase().replace('Á', 'A').replace('É', 'E').replace('Í', 'I').replace('Ó', 'O').replace('Ú', 'U').trim();
								if(mapNameSucursalByDepCiud.containsKey(strDeparSinTildesMayusLead + strCiudSinTildesMayusLead) && mapIdSucursalByNameSucursal.containsKey(mapNameSucursalByDepCiud.get(strDeparSinTildesMayusLead + strCiudSinTildesMayusLead)))
									objLead.AsignacionSucursal__c = mapIdSucursalByNameSucursal.get(mapNameSucursalByDepCiud.get(strDeparSinTildesMayusLead + strCiudSinTildesMayusLead));
								// Si no llegá a existir una concordancia de la config personalizada y de la Landing se asignan a bogotá:
								else 
							 		objLead.AsignacionSucursal__c =  mapIdSucursalByNameSucursal.get('BOGOTA');
							}
							// Si no llegan datos de la Landing se asignan a bogotá:
							else 
							 	objLead.AsignacionSucursal__c =  mapIdSucursalByNameSucursal.get('BOGOTA');
						}

						//EH END
						dtFechaDiaSemanaCreacionLead = System.now();
					}
					else
					{
						dtFechaDiaSemanaCreacionLead = objLead.CreatedDate;
					}
					objLead.Dia__c = dtFechaDiaSemanaCreacionLead.format('EEE');
					objLead.Dia__c = Lead_Utility.DiaSemanaDesdeFechaTexto(objLead.Dia__c);
					System.debug('@@ Fecha a Convertir para Dia__c ' + dtFechaDiaSemanaCreacionLead);
					System.debug('@@ objLead.Dia__c ' + objLead.Dia__c);
					//Fin Calculo Campo Dia__c	
				}
				
				//Modificacion de los campos FechaHoraCreacionOportunidad__c y Status
				if(!lstAssignVendedorAsignadoLeadOpp.isEmpty())
				{
					Map<id, List<Lead>> mapVendedorLeads = new Map<id, List<Lead>>();
					for(Lead objLead : lstAssignVendedorAsignadoLeadOpp)
					{
						
						if(objLead.VendedorAsignado__c !=null && objLead.RecordTypeId == strTRLead)
						{
							System.debug('@@ Fecha Hora Creacion Oportunidad ' + objLead.FechaHoraCreacionOportunidad__c);
							System.debug('@@ Status ' + objLead.Status);
							if(objLead.FechaHoraCreacionOportunidad__c == null)
								objLead.FechaHoraCreacionOportunidad__c = System.now();
							//JH 16-Mar-2016 Se agrega calificacion = Sin Tocar en el momento de asignar la oportundidad de acuerdo a caso Nro. 58625
							objLead.Calificacion__c = 'Sin Tocar';
							objLead.Status = 'Oportunidad';
							System.debug('@@ After Fecha Hora Creacion Oportunidad ' + objLead.FechaHoraCreacionOportunidad__c);
							System.debug('@@ After Status ' + objLead.Status);
							objLead.RecordTypeId = strTROportunidad;
						}
						
						//Se guardan los vendedores asignados y los Leads a los cuales estan asignados para sincronizacion del campo Propietario
						if(!mapVendedorLeads.containsKey(objLead.VendedorAsignado__c))
							mapVendedorLeads.put(objLead.VendedorAsignado__c, new List<Lead>());
						mapVendedorLeads.get(objLead.VendedorAsignado__c).add(objLead);
					}
					
					//Se realiza sincronizacion del campo Propietario con el campo VendedorAsignado__c de Leads
					if(!mapVendedorLeads.isEmpty())
					{
						//Recorre la lista de reg de RH que pertenezcan al mapa de mapVendedorLeads
						for(RecursosHumanos__c objRh : [Select Id, Usuario__c from RecursosHumanos__c where id =: mapVendedorLeads.keySet()])
						{
							if(objRh.Usuario__c != null)
							{
								for(Lead objLead : mapVendedorLeads.get(objRh.Id))
								{
									system.debug('@@@ RH Vendedor Asignado: '+objRh);
									objLead.OwnerId = objRh.Usuario__c;
								}
							}//Fin si objRh.Usuario__c != null
						}//Fin del for para RH
					}//Fin si !mapVendedorLeads.isEmpty()
				}//Fin Modificacion de los campos FechaHoraCreacionOportunidad__c y Status
				
			}//Fin Before  Trigger.IsInsert || Trigger.IsUpdate		
		}//Fin Triger IsBefore
	}//Fin if blnExecuteBeforeTrigger
	
	blnExecuteTriggerAfter = true;
	if( Trigger.isAfter )
		blnExecuteTriggerAfter = !RD_TriggerExecutionControl_cls.hasAlreadyDone('TriggerLead');
	
	if( blnExecuteTriggerAfter)
	{
		if(Trigger.isAfter)
		{
			if(trigger.isInsert || trigger.isUpdate)
			{
				Map<Id, Lead> mapNewLeads = Trigger.newMap;
				Map<Id, Lead> mapOldLeads = Trigger.oldMap;               
				Set<String> setIdVenAsig = new Set<String>(); 
				Map<String, RecursosHumanos__c> mapRHUpd = new Map<String, RecursosHumanos__c>();
				ConsultasAgregadas objConsultasAgregadas = new ConsultasAgregadas(); 
				
				//Se obtienen los Vendedores Asignados de los Leads
				for (Lead objLead : Trigger.new)
				{
					System.debug('@@ 1 VendedorAsignado en Trigger Insert/Update: ' + objLead.VendedorAsignado__c);
					//Agrega los vendedores asignados siempre y cuando sean diferentes al RH de ARD Virtual (a051a000002bUk3,a051a000002bUk3AAE)
					if (objLead.VendedorAsignado__c != null && objLead.VendedorAsignado__c != 'a051a000002bUk3' && objLead.VendedorAsignado__c != 'a051a000002bUk3AAE')
						setIdVenAsig.add( objLead.VendedorAsignado__c );
					//Ve si esta haciendo un update
					if (mapOldLeads != null)
					{
						if (mapOldLeads.get(objLead.id).VendedorAsignado__c != null && mapOldLeads.get(objLead.id).VendedorAsignado__c != 'a051a000002bUk3' 
						&& mapOldLeads.get(objLead.id).VendedorAsignado__c != 'a051a000002bUk3AAE')
						{
							System.debug('@@ 2 VendedorAsignado en Trigger Insert/Update: ' + objLead.VendedorAsignado__c);
							setIdVenAsig.add( mapOldLeads.get(objLead.id).VendedorAsignado__c );
						}
					}
				}//Fin del for para las Leads
				//Se Calcula el valor del campo OportunidadesTotalesArd__c de RH para el proceso de asignacion de Oportunidades
				mapRHUpd = objConsultasAgregadas.consultaRHOportunidadesTotalesArd(setIdVenAsig,mapRHUpd);
				System.debug('@@ mapRHUpd OportunidadesTotalesArd en Trigger Insert/Update: \n' + mapRHUpd);				
				//Se Calcula el valor del campo OppMensuales_NextMonth__c de RH para el proceso de asignacion de Oportunidades
				mapRHUpd = objConsultasAgregadas.consultaRHOppMensualesNextMonth(setIdVenAsig,mapRHUpd);
				System.debug('@@ mapRHUpd OppMensuales_NextMonth__c en Trigger Insert/Update: \n' + mapRHUpd);

				Map<String, RecursosHumanos__c> mapRH = new  Map<String, RecursosHumanos__c>(
															[SELECT Id,
																	TopeOportunidadesMensual__c,
																	tope_dinamico__c,
																	FechaAsignarOportunidades__c,
																	OppMensuales_NextMonth__c,
																	Next_Month_Percentage_Occupied__c
															FROM RecursosHumanos__c
															WHERE Id IN :setIdVenAsig]);
				System.debug('@@ MAP RH mapRH ' + mapRH.values());


				for (ID idOwn : setIdVenAsig)
				{
					//Pone en ceros los campos OppMensuales_NextMonth__c y OportunidadesTotalesArd__c de los vendedores que no tengan Leads
					//asignados para el mes actual o el mes siguiente
					if (!mapRHUpd.containsKey(idOwn))
						{
							mapRHUpd.put( idOwn , new RecursosHumanos__c(id = idOwn, OportunidadesTotalesArd__c = 0,OppMensuales_NextMonth__c=0));
							System.debug('@@ Puso MAP RH mapRH en Cero ' + idOwn);
						}					
					else
						{
							if(mapRHUpd.get(idOwn).OportunidadesTotalesArd__c == null)
								mapRHUpd.get(idOwn).OportunidadesTotalesArd__c = 0;
							if(mapRHUpd.get(idOwn).OppMensuales_NextMonth__c == null)
								mapRHUpd.get(idOwn).OppMensuales_NextMonth__c = 0;
						}
					if (mapRH.containsKey(idOwn))
					{						
						if(mapRH.get(idOwn).tope_dinamico__c !=null) 
						{
							//Calculo de Campo Percentage_Occupied__c de RH
							if(mapRH.get(idOwn).tope_dinamico__c >0)
								mapRHUpd.get(idOwn).Percentage_Occupied__c = (mapRHUpd.get(idOwn).OportunidadesTotalesArd__c / mapRH.get(idOwn).tope_dinamico__c)*100;
							else
								mapRHUpd.get(idOwn).Percentage_Occupied__c = 100;
							//Calculo de Campo Next_Month_Percentage_Occupied__c de RH		
							if(mapRH.get(idOwn).TopeOportunidadesMensual__c >0)
								mapRHUpd.get(idOwn).Next_Month_Percentage_Occupied__c = (mapRHUpd.get(idOwn).OppMensuales_NextMonth__c / mapRH.get(idOwn).TopeOportunidadesMensual__c)*100;
							else
								mapRHUpd.get(idOwn).Next_Month_Percentage_Occupied__c = 100;							
						}//Fin if(mapRH.get(idOwn).tope_dinamico__c !=null)
						System.debug('@@ RH tope_dinamico__c: ' + mapRH.get(idOwn).tope_dinamico__c);
						System.debug('@@ RH FechaAsignarOportunidades__c: ' + mapRH.get(idOwn).FechaAsignarOportunidades__c);
						System.debug('@@ RH OportunidadesTotalesArd__c: ' + mapRHUpd.get(idOwn).OportunidadesTotalesArd__c);
						System.debug('@@ RH Percentage_Occupied__c: ' + mapRHUpd.get(idOwn).Percentage_Occupied__c);
						System.debug('@@ RH TopeOportunidadesMensual__c: ' + mapRH.get(idOwn).TopeOportunidadesMensual__c);
						System.debug('@@ RH OppMensuales_NextMonth__c: ' + mapRHUpd.get(idOwn).OppMensuales_NextMonth__c);
						System.debug('@@ RH Next_Month_Percentage_Occupied__c: ' + mapRHUpd.get(idOwn).Next_Month_Percentage_Occupied__c);
					}	
				}//fin del for para el setIdVenAsig

				//Actualiza los Vendedores Asignados
				if (!mapRHUpd.isEmpty())
				{
					System.debug('@@Actualiza RH en Trigger Lead mapRHUpd.values(): ' + mapRHUpd.values());
					RD_TriggerExecutionControl_cls.setAlreadyDone('TriggerRecursosHumanos');
					//if (!Test.isRunningTest())
						update mapRHUpd.values();
				}//Fin si tiene algo mapRHUpd   
			}//Fin Trigger.isAfter IsInsert || IsUpdate
			
			if(trigger.isDelete)
			{
				Map<Id, Lead> mapOldLeads = Trigger.oldMap;               
				Set<String> setIdVenAsig = new Set<String>(); 
				Map<String, RecursosHumanos__c> mapRHUpd = new Map<String, RecursosHumanos__c>();
				ConsultasAgregadas objConsultasAgregadas = new ConsultasAgregadas(); 
				
				//Se obtienen los Vendedores Asignados de los Leads
				for (Lead objLead : mapOldLeads.values())
				{
					System.debug('@@  VendedorAsignado en Trigger After Delete: ' + objLead.VendedorAsignado__c);
					//Agrega los vendedores asignados siempre y cuando sean diferentes al RH de ARD Virtual (a051a000002bUk3,a051a000002bUk3AAE)
					if (objLead.VendedorAsignado__c != null && objLead.VendedorAsignado__c != 'a051a000002bUk3' && objLead.VendedorAsignado__c != 'a051a000002bUk3AAE')
						setIdVenAsig.add( objLead.VendedorAsignado__c );
				}//Fin del for para las Leads
				
				//Se Calcula el valor del campo OportunidadesTotalesArd__c de RH para el proceso de asignacion de Oportunidades
				mapRHUpd = objConsultasAgregadas.consultaRHOportunidadesTotalesArd(setIdVenAsig,mapRHUpd);
				System.debug('@@ mapRHUpd OportunidadesTotalesArd en Trigger After Delete: \n' + mapRHUpd);				
				//Se Calcula el valor del campo OppMensuales_NextMonth__c de RH para el proceso de asignacion de Oportunidades
				mapRHUpd = objConsultasAgregadas.consultaRHOppMensualesNextMonth(setIdVenAsig,mapRHUpd);
				System.debug('@@ mapRHUpd OppMensuales_NextMonth__c en Trigger After Delete: \n' + mapRHUpd);

				Map<String, RecursosHumanos__c> mapRH = new  Map<String, RecursosHumanos__c>(
															[SELECT Id,
																	TopeOportunidadesMensual__c,
																	tope_dinamico__c,
																	FechaAsignarOportunidades__c,
																	OppMensuales_NextMonth__c,
																	Next_Month_Percentage_Occupied__c
															FROM RecursosHumanos__c
															WHERE Id IN :setIdVenAsig]);
				System.debug('@@ MAP RH mapRH Trigger After Delete ' + mapRH.values());
				
				//Pone en ceros los campos OppMensuales_NextMonth__c y OportunidadesTotalesArd__c de los vendedores que no tengan Leads
				//asignados para el mes actual o el mes siguiente
				for (ID idOwn : setIdVenAsig)
				{				
					if (!mapRHUpd.containsKey(idOwn))
					{
						mapRHUpd.put( idOwn , new RecursosHumanos__c(id = idOwn, OportunidadesTotalesArd__c = 0,OppMensuales_NextMonth__c=0));
						System.debug('@@ Puso MAP RH mapRH en Cero Trigger After Delete ' + idOwn);
					}					
					else
					{
						if(mapRHUpd.get(idOwn).OportunidadesTotalesArd__c == null)
							mapRHUpd.get(idOwn).OportunidadesTotalesArd__c = 0;
						if(mapRHUpd.get(idOwn).OppMensuales_NextMonth__c == null)
							mapRHUpd.get(idOwn).OppMensuales_NextMonth__c = 0;
					}//Fin 	if (!mapRHUpd.containsKey(idOwn))
					
					if (mapRH.containsKey(idOwn))
					{						
						if(mapRH.get(idOwn).tope_dinamico__c !=null) 
						{
							//Calculo de Campo Percentage_Occupied__c de RH
							if(mapRH.get(idOwn).tope_dinamico__c >0)
								mapRHUpd.get(idOwn).Percentage_Occupied__c = (mapRHUpd.get(idOwn).OportunidadesTotalesArd__c / mapRH.get(idOwn).tope_dinamico__c)*100;
							else
								mapRHUpd.get(idOwn).Percentage_Occupied__c = 100;
							//Calculo de Campo Next_Month_Percentage_Occupied__c de RH		
							if(mapRH.get(idOwn).TopeOportunidadesMensual__c >0)
								mapRHUpd.get(idOwn).Next_Month_Percentage_Occupied__c = (mapRHUpd.get(idOwn).OppMensuales_NextMonth__c / mapRH.get(idOwn).TopeOportunidadesMensual__c)*100;
							else
								mapRHUpd.get(idOwn).Next_Month_Percentage_Occupied__c = 100;							
						}//Fin if(mapRH.get(idOwn).tope_dinamico__c !=null)
						System.debug('@@ RH Trigger After Delete tope_dinamico__c: ' + mapRH.get(idOwn).tope_dinamico__c);
						System.debug('@@ RH Trigger After Delete FechaAsignarOportunidades__c: ' + mapRH.get(idOwn).FechaAsignarOportunidades__c);
						System.debug('@@ RH Trigger After Delete OportunidadesTotalesArd__c: ' + mapRHUpd.get(idOwn).OportunidadesTotalesArd__c);
						System.debug('@@ RH Trigger After Delete Percentage_Occupied__c: ' + mapRHUpd.get(idOwn).Percentage_Occupied__c);
						System.debug('@@ RH Trigger After Delete TopeOportunidadesMensual__c: ' + mapRH.get(idOwn).TopeOportunidadesMensual__c);
						System.debug('@@ RH Trigger After Delete OppMensuales_NextMonth__c: ' + mapRHUpd.get(idOwn).OppMensuales_NextMonth__c);
						System.debug('@@ RH Trigger After Delete Next_Month_Percentage_Occupied__c: ' + mapRHUpd.get(idOwn).Next_Month_Percentage_Occupied__c);
					}//Fin if (mapRH.containsKey(idOwn))
					
				}//Fin for (ID idOwn : setIdVenAsig)
				
				//Actualiza los Vendedores Asignados
				if (!mapRHUpd.isEmpty())
				{
					System.debug('@@Actualiza RH en Trigger After Delete Lead mapRHUpd.values(): ' + mapRHUpd.values());
					RD_TriggerExecutionControl_cls.setAlreadyDone('TriggerRecursosHumanos');
					if (!Test.isRunningTest())
						update mapRHUpd.values();
				}//Fin si tiene algo mapRHUpd   
			}//Fin trigger.isDelete
		
		}//Fin Trigger.isAfter
	}//Fin If blnExecuteTriggerAfter
	
	
}