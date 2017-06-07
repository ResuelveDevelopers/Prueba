/*******************************************************************************
Desarrollado por:   RTD
Autor:              Jeisson Hernandez
Proyecto:           Colombia III
Descripción:        Batch de Asignación de Oportunidades 

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		----------                ---------------------------     
    1.0     23-Oct-2015		Jeisson Hernandez(JH)     Creación de la Clase.
*******************************************************************************/

global class BchAsignacionOportunidades_bch implements Database.Batchable<sObject>, Database.Stateful 
{
	global final String query;
	global Integer intContador;
	global String strRenglonInforme;
	global List<Lead> lstCantLeads;

	//Wrap para copiar RH de Vendedores y poder realizar comparación posterior y 
	//encontrar diferencia de Porcentaje de ocupación > 4% entre los Vendedores
	public class HRdata
	{
		public string id;
		public string Usuario_name;
		public id Usuario;
		public decimal OportunidadesTotalesArd;        
		public decimal TopeOportunidadesMensual; 
		public decimal Percentage_Occupied;
		public decimal OppMensuales_NextMonth;
		public decimal Next_Month_Percentage_Occupied;
		public boolean AsignarOportunidades;    
	}

	global BchAsignacionOportunidades_bch (string strQuery)
	{
		this.query= strQuery;
		lstCantLeads = Database.query(query);		
		intContador = 1;
		strRenglonInforme = '"Consecutivo","Proceso","Usuario Vendedor","Oportunidad","% Ocupacion Mes Actual Antes","% Ocupacion Mes Actual","Oportunidades Mes Actual","Oportunidades Siguiente Mes","% Ocupacion Siguiente Mes","Observaciones"\n';
	
	}
	
	//Start
	global Database.querylocator start(Database.BatchableContext BC)
	{
		system.debug('--Start BchAsignacionOportunidades_bch--');
		return Database.getQueryLocator(query);
	}
	
	//Execute
	global void execute(Database.BatchableContext BC,List<Lead> scope)
	{
		//Lista de los Leads que llegan del scope del Batch
		List<Lead> listLeadScope = scope;

		//Map de Leads a actualizar
		Map<Id,Lead> mapLeadUpdate = new Map<Id,Lead>();
		
		//Map de Leads que contendra los leads cuya Sucursal no sea igual a ninguna Sucursal de los Vendedores
		Map<Id, Lead> mapLeadsSucursalNoIgualRH = new Map<Id, Lead>();
		
		//Map de Leads que contendra los leads cuando el Numero de Lead del Mes actual (OportunidadesTotalesArd__c) sea igual o mayor a su Tope dinamico.
		//Es decir en este map estaran los leads sobrantes cuando el cupo asignado de los vendedores de los vendedores sea alcanzado, estos leads serán asignados 
		//para el mes siguiente
		Map<Id, Lead> mapLeadsRHTopeDinLleno = new Map<Id, Lead>(); 

		
		//Set con Perfiles de Usuarios a los cuales se les asignaran Leads
		Set<String> sPerfilesAsesores = new Set<String>{'Team Leader Ventas','Asesor de Reparación de Deuda'};
		
		List<RecursosHumanos__c> listHR = new List<RecursosHumanos__c>();
		
		listHR = [SELECT  Id, Sucursal__r.Name,OppMensuales_NextMonth__c,
						  Next_Month_Percentage_Occupied__c,Name, MD4__c,
						  AsignarOportunidades__c, 
						  TopeOportunidadesMensual__c,
						  OportunidadesTotalesArd__c, 
						  Usuario__c, Usuario__r.ProfileId,Percentage_OccupiedRP__c,
						  Usuario__r.isActive,Percentage_Occupied__c,tope_dinamico__c,
						  Usuario__r.Profile.name,
						  Usuario__r.Name 
					FROM RecursosHumanos__c 
					WHERE Usuario__r.isActive = TRUE
					AND Status__c = 'Activo'
					AND UnidadNegocio__c = 'RTD Colombia' 
					AND AsignarOportunidades__c = true
					AND (Usuario__r.Profile.name in : sPerfilesAsesores )
					AND TopeOportunidadesMensual__c>0
					ORDER BY Percentage_OccupiedRP__c ASC];
		
		System.debug('@@ listHR ' + listHR);
		
		for(RecursosHumanos__c hr: listHR)
		{
			System.debug('@@ hr ' + hr.Name + ' %Ocupacion: ' + hr.Percentage_Occupied__c);
		}
		
		//Map para guardar RH para comparación posterior y 
		//encontrar diferencia de Porcentaje de ocupación > 4% entre los Vendedores
		Map<Id, HRdata> Recursos_porcentage= new Map<Id, HRdata>();
		
		//LLenado de Wrap de Vendedores
		for(RecursosHumanos__c temp:listHR)
		{
			if(temp.AsignarOportunidades__c == true)
			{
				HRdata awrap = new HRdata();
				awrap.id= temp.id;
				awrap.Usuario = temp.Usuario__r.id;
				awrap.OportunidadesTotalesArd = temp.OportunidadesTotalesArd__c;
				awrap.TopeOportunidadesMensual = temp.tope_dinamico__c;
				awrap.Percentage_Occupied = temp.Percentage_OccupiedRP__c;
				awrap.AsignarOportunidades =temp.AsignarOportunidades__c;
				awrap.Next_Month_Percentage_Occupied = temp.Next_Month_Percentage_Occupied__c;
				awrap.OppMensuales_NextMonth = temp.OppMensuales_NextMonth__c;
				awrap.Usuario_name=temp.Usuario__r.name;
				Recursos_porcentage.put(temp.id,awrap); 
			}
		}
		
		// ***************** Empieza Validacion de Leads********************
		
		for(Lead objLead: listLeadScope)
		{
			if(objLead.DeudaWeb__c >=40000001)
			{
				for(RecursosHumanos__c hr: listHR)
				{
					if(mapLeadUpdate.get(objLead.id)== NULL)
					{
						System.debug('@@ 1 Lead= ' + objLead + ' RH=' + hr + ' SUCURSAL RH: '+ hr.Sucursal__r.Name);
						if(objLead.AsignacionSucursal__c == hr.Sucursal__c)
						{
							System.debug('@@ 1 Sucursal Lead '+ objLead.AsignacionSucursal__c + ' SUCURSAL RH: '+ hr.Sucursal__c);
							
							if(hr.OportunidadesTotalesArd__c ==NULL ||  (hr.OportunidadesTotalesArd__c < hr.tope_dinamico__c))
							{
								System.debug('@@ 1 Leads Totales ' + hr.OportunidadesTotalesArd__c + ' > ' + ' Tope Dinamico ' + hr.tope_dinamico__c);
								if(hr.MD4__c)
								{
									//Asignacion de Lead Proceso 1:
									// - Lead.DeudaWeb__c >=40000001
									// - Sucursal RH == Sucursal Lead
									// - RH OportunidadesTotalesArd__c < RH.tope_dinamico__c
									// - RH es MD4
									objLead.OwnerId = hr.Usuario__c;
									objLead.VendedorAsignado__c = hr.Id;
									objLead.AsignadoProceso__c = true;
									objLead.ConsecutivoAssigProcess__c = intContador;
									System.debug('@@ ANTES Proceso 1 RH ' + hr.Id + ' Percentage_Occupied__c '+hr.Percentage_Occupied__c);
									System.debug('@@ ANTES Proceso 1 RH ' + hr.Id + ' tope_dinamico__c '+hr.tope_dinamico__c);
									System.debug('@@ ANTES Proceso 1 RH ' + hr.Id + ' OppMensuales_NextMonth__c '+hr.OppMensuales_NextMonth__c);
									
									// Se suma 1 a las oportunidades Totales del mes actual del vendedor
									if(hr.OportunidadesTotalesArd__c == null)
										hr.OportunidadesTotalesArd__c = 1;
									else
										hr.OportunidadesTotalesArd__c = hr.OportunidadesTotalesArd__c + 1;
									if (hr.tope_dinamico__c > 0)     
									{
										hr.Percentage_Occupied__c = (hr.OportunidadesTotalesArd__c/hr.tope_dinamico__c) * 100;
										hr.Percentage_Occupied__c = hr.Percentage_Occupied__c.setscale(4);
									}

									System.debug('@@ Proceso 1 RH ' + hr.Id + ' Percentage_Occupied__c '+hr.Percentage_Occupied__c);
									System.debug('@@ Proceso 1 RH ' + hr.Id + ' tope_dinamico__c '+hr.tope_dinamico__c);
									System.debug('@@ Proceso 1 RH ' + hr.Id + ' OppMensuales_NextMonth__c '+hr.OppMensuales_NextMonth__c);
										
									strRenglonInforme += '"' + intContador + '","Proceso 1","' + hr.Usuario__r.Name + '","'+objLead.id+'","'+ hr.Percentage_OccupiedRP__c +'","'+ hr.Percentage_Occupied__c +'","'+ hr.OportunidadesTotalesArd__c+'","'+ hr.OppMensuales_NextMonth__c +'","'+ hr.Next_Month_Percentage_Occupied__c+'","",\n';
									System.debug('"' + intContador + '","Proceso 1","' + hr.Usuario__r.Name + '","'+objLead.id+'","'+ hr.Percentage_OccupiedRP__c +'","'+ hr.Percentage_Occupied__c +'","'+ hr.OportunidadesTotalesArd__c+'","'+ hr.OppMensuales_NextMonth__c +'","'+ hr.Next_Month_Percentage_Occupied__c+'","",\n');
									//Agregar a Map para actualizar Lead
									mapLeadUpdate.put(objLead.Id,objLead);
									
									//Remueve del Map mapLeadsRHTopeDinLleno
									if(mapLeadsRHTopeDinLleno.containsKey(objLead.Id))
										mapLeadsRHTopeDinLleno.remove(objLead.Id);
									//Remueve del Map mapLeadsSucursalNoIgualRH
									if(mapLeadsSucursalNoIgualRH.containsKey(objLead.Id))
										mapLeadsSucursalNoIgualRH.remove(objLead.Id);

								}//Fin if(hr.MD4) 
							}//Fin if hr.OportunidadesTotalesArd__c < hr.tope_dinamico__c
							else
								mapLeadsRHTopeDinLleno.put(objLead.Id,objLead);
						}//Fin if objLead.AsignacionSucursal__c == hr.Sucursal__c
						else
						{
							mapLeadsSucursalNoIgualRH.put(objLead.Id,objLead);
						}
					}//Fin if(mapLeadUpdate.get(objLead.id)== NULL)
				}//Fin For listHR
			}//Fin If DeudaWeb__c >=40000001
			
			
			
			if(objLead.DeudaWeb__c <40000001)
			{
				for(RecursosHumanos__c hr: listHR)
				{
					if(mapLeadUpdate.get(objLead.id)== NULL)
					{
						System.debug('@@ 2 Lead= ' + objLead + ' RH=' + hr + ' SUCURSAL RH: '+ hr.Sucursal__r.Name);
						if(objLead.AsignacionSucursal__c == hr.Sucursal__c)
						{
							System.debug('@@ 2 Sucursal Lead '+ objLead.AsignacionSucursal__c + ' SUCURSAL RH: '+ hr.Sucursal__c);
							
							if(hr.OportunidadesTotalesArd__c ==NULL ||  (hr.OportunidadesTotalesArd__c < hr.tope_dinamico__c))
							{
								Boolean blnLeadActualizado = false;
								for(Id idRH : Recursos_porcentage.keySet())
								{
									Decimal dcDiferencia = 0;
									System.debug('@@ 2 Recursos_porcentage.get(hr.id) '+Recursos_porcentage.get(hr.id).id  + ' Percentage_Occupied: ' +Recursos_porcentage.get(hr.id).Percentage_Occupied);
									System.debug('@@ 2 Recursos_porcentage.get(idRH) '+Recursos_porcentage.get(idRH).id  + ' Percentage_Occupied: ' +Recursos_porcentage.get(idRH).Percentage_Occupied);  
									dcDiferencia = Recursos_porcentage.get(hr.id).Percentage_Occupied - Recursos_porcentage.get(idRH).Percentage_Occupied;
									System.debug('@@ 2 Diferencia '+dcDiferencia);
									System.debug('@@ 2 blnLeadActualizado '+blnLeadActualizado);
									if(dcDiferencia >=0.04 && blnLeadActualizado == false)
									{
										//Asignacion de Lead Proceso 2:
										// - Lead.DeudaWeb__c < 40000001
										// - Sucursal RH != Sucursal Lead
										// - RH OportunidadesTotalesArd__c < RH.tope_dinamico__c
										// - Diferencia entre Porcentaje de Ocupacion (Percentage_Occupied) entre vendedores es > 5%
										
										System.debug('@@ 2  Encontro menor ' + Recursos_porcentage.get(idRH).Id + ' Nombre:' + Recursos_porcentage.get(idRH).Usuario_name);
										objLead.OwnerId = Recursos_porcentage.get(idRH).Usuario;
										objLead.VendedorAsignado__c = Recursos_porcentage.get(idRH).Id;
										objLead.AsignadoProceso__c = true;
										objLead.ConsecutivoAssigProcess__c = intContador;
										// Se suma 1 a las oportunidades Totales del mes actual del vendedor
										if(Recursos_porcentage.get(idRH).OportunidadesTotalesArd == null)
											Recursos_porcentage.get(idRH).OportunidadesTotalesArd = 1;
										else
											Recursos_porcentage.get(idRH).OportunidadesTotalesArd = Recursos_porcentage.get(idRH).OportunidadesTotalesArd + 1;
										Decimal dcPercentage_OccupiedRP = Recursos_porcentage.get(idRH).Percentage_Occupied;
										System.debug('@@ 2 Recursos_porcentage.get(idRH).TopeOportunidadesMensual ' + Recursos_porcentage.get(idRH).TopeOportunidadesMensual);
										System.debug('@@ 2 Recursos_porcentage.get(idRH).OportunidadesTotalesArd ' + Recursos_porcentage.get(idRH).OportunidadesTotalesArd);
										System.debug('@@ 2 dcPercentage_OccupiedRP ' + dcPercentage_OccupiedRP);
										
										Recursos_porcentage.get(idRH).Percentage_Occupied = (Recursos_porcentage.get(idRH).OportunidadesTotalesArd/Recursos_porcentage.get(idRH).TopeOportunidadesMensual) *100;
										System.debug('@@ 2 Recursos_porcentage.get(idRH).Percentage_Occupied ' + Recursos_porcentage.get(idRH).Percentage_Occupied);
										Recursos_porcentage.get(idRH).Percentage_Occupied = Recursos_porcentage.get(idRH).Percentage_Occupied.setScale(4);
										System.debug('@@ 2 Recursos_porcentage.get(idRH).Percentage_Occupied setScale ' + Recursos_porcentage.get(idRH).Percentage_Occupied);
										
										if (Recursos_porcentage.get(idRH).TopeOportunidadesMensual !=null && Recursos_porcentage.get(idRH).TopeOportunidadesMensual > 0)
										{
											System.debug('@@ 2 Recursos_porcentage.get(idRH).OppMensuales_NextMonth ' + Recursos_porcentage.get(idRH).OppMensuales_NextMonth);
											if(Recursos_porcentage.get(idRH).OppMensuales_NextMonth !=null)
											{
												Recursos_porcentage.get(idRH).Next_Month_Percentage_Occupied = (Recursos_porcentage.get(idRH).OppMensuales_NextMonth/Recursos_porcentage.get(idRH).OportunidadesTotalesArd) * 100;
												Recursos_porcentage.get(idRH).Next_Month_Percentage_Occupied =Recursos_porcentage.get(idRH).Next_Month_Percentage_Occupied.setScale(4);
											}
										}
										
										System.debug('"' + intContador + '","Proceso 2","' + Recursos_porcentage.get(idRH).Usuario_name + '","'+objLead.id+'","'+ dcPercentage_OccupiedRP +'","'+ Recursos_porcentage.get(idRH).Percentage_Occupied.setscale(4) +'","'+ Recursos_porcentage.get(idRH).OportunidadesTotalesArd +'","'+ Recursos_porcentage.get(idRH).OppMensuales_NextMonth +'","'+ Recursos_porcentage.get(idRH).Next_Month_Percentage_Occupied+'","",\n');	
										strRenglonInforme += '"' + intContador + '","Proceso 2","' + Recursos_porcentage.get(idRH).Usuario_name + '","'+objLead.id+'","'+ dcPercentage_OccupiedRP +'","'+ Recursos_porcentage.get(idRH).Percentage_Occupied.setscale(4) +'","'+ Recursos_porcentage.get(idRH).OportunidadesTotalesArd +'","'+ Recursos_porcentage.get(idRH).OppMensuales_NextMonth +'","'+ Recursos_porcentage.get(idRH).Next_Month_Percentage_Occupied+'","",\n';
										blnLeadActualizado = true;
									}
								}//Fin for(Id idRH : Recursos_porcentage.keySet())
								
								if(blnLeadActualizado ==false)
								{

									//Asignacion de Lead Proceso 3:
									// - Lead.DeudaWeb__c < 40000001
									// - Sucursal RH == Sucursal Lead
									// - RH OportunidadesTotalesArd__c < RH.tope_dinamico__c
									// - Diferencia entre Porcentaje de Ocupacion (Percentage_Occupied) entre vendedores es < 5%
									
									objLead.OwnerId = hr.Usuario__c;
									objLead.VendedorAsignado__c = hr.Id;
									objLead.AsignadoProceso__c = true;
									objLead.ConsecutivoAssigProcess__c = intContador;
									// Se suma 1 a las oportunidades Totales del mes actual del vendedor
									if(hr.OportunidadesTotalesArd__c == null)
										hr.OportunidadesTotalesArd__c = 1;
									else
										hr.OportunidadesTotalesArd__c = hr.OportunidadesTotalesArd__c + 1;
									if (hr.tope_dinamico__c > 0)
									{
										hr.Percentage_Occupied__c = (hr.OportunidadesTotalesArd__c/hr.tope_dinamico__c) * 100;
										hr.Percentage_Occupied__c = hr.Percentage_Occupied__c.setscale(4);
									}
										
									strRenglonInforme += '"' + intContador + '","Proceso 3","' + hr.Usuario__r.Name + '","'+objLead.id+'","'+ hr.Percentage_OccupiedRP__c +'","'+ hr.Percentage_Occupied__c +'","'+ hr.OportunidadesTotalesArd__c +'","'+ hr.OppMensuales_NextMonth__c +'","'+ hr.Next_Month_Percentage_Occupied__c+'","",\n';
									System.debug('"' + intContador + '","Proceso 3","' + hr.Usuario__r.Name + '","'+objLead.id+'","'+ hr.Percentage_OccupiedRP__c +'","'+ hr.Percentage_Occupied__c +'","'+ hr.OportunidadesTotalesArd__c +'","'+ hr.OppMensuales_NextMonth__c +'","'+ hr.Next_Month_Percentage_Occupied__c+'","",\n');
								}//Fin if(blnLeadActualizado ==false)
								
								//Agregar a Map para actualizar Lead
								mapLeadUpdate.put(objLead.Id,objLead);
								
								//Remueve del Map mapLeadsRHTopeDinLleno
								if(mapLeadsRHTopeDinLleno.containsKey(objLead.Id))
									mapLeadsRHTopeDinLleno.remove(objLead.Id);
								
							}//Fin if hr.OportunidadesTotalesArd__c < hr.tope_dinamico__c
							else
								mapLeadsRHTopeDinLleno.put(objLead.Id,objLead);
						}//Fin if objLead.AsignacionSucursal__c == hr.Sucursal__c
						else
							mapLeadsSucursalNoIgualRH.put(objLead.Id,objLead);
					}//Fin if(mapLeadUpdate.get(objLead.id)== NULL)
				}//Fin For listHR
			}//Fin If DeudaWeb__c >=40000001

			
		}//Fin for(Lead objLead: listLeadScope)
		
		// ***************** Termina Validacion de Leads********************
		
		//Se ordena los Vendedores Ascedentemente por el campo Percentage_Occupied__c 
		Lead_Utility.sortList(listHR,'Percentage_Occupied__c','ASC');
		System.debug('@@ Lista RH Ordenada ASC Percentage_Occupied__c \n:' + listHR);
		
		// ***************** Empieza Asignacion de Leads de Sucursales que no pertenecen a ninguna Sucursal de Vendedor ********************
		
		if(mapLeadsSucursalNoIgualRH.size()>0)
		{
			System.debug('@@ Entro a mapLeadsSucursalNoIgualRH');
			for(Lead objLead: mapLeadsSucursalNoIgualRH.values())
			{
				if(objLead.DeudaWeb__c >=40000001)
				{
					for(RecursosHumanos__c hr: listHR)
					{
						if(mapLeadUpdate.get(objLead.id)== NULL)
						{
							if(hr.OportunidadesTotalesArd__c ==NULL ||  (hr.OportunidadesTotalesArd__c < hr.tope_dinamico__c))
							{
								if(hr.MD4__c)
								{
									//Asignacion de Lead Proceso 4:
									// - Lead.DeudaWeb__c >=40000001
									// - Sucursal RH != Sucursal Lead
									// - RH OportunidadesTotalesArd__c < RH.tope_dinamico__c
									// - RH es MD4
									System.debug('@@ Entro Proceso 4 RH ' + hr.Id + ' Lead Id:' + objLead.Id);
									objLead.OwnerId = hr.Usuario__c;
									objLead.VendedorAsignado__c = hr.Id;
									objLead.AsignadoProceso__c = true;
									objLead.ConsecutivoAssigProcess__c = intContador;
									// Se suma 1 a las oportunidades Totales del mes actual del vendedor
									if(hr.OportunidadesTotalesArd__c == null)
										hr.OportunidadesTotalesArd__c = 1;
									else
										hr.OportunidadesTotalesArd__c = hr.OportunidadesTotalesArd__c + 1;
									if (hr.tope_dinamico__c > 0)     
									{
										hr.Percentage_Occupied__c = (hr.OportunidadesTotalesArd__c/hr.tope_dinamico__c) * 100;
										hr.Percentage_Occupied__c = hr.Percentage_Occupied__c.setscale(4);
									}
										
									strRenglonInforme += '"' + intContador + '","Proceso 4","' + hr.Usuario__r.Name + '","'+objLead.id+'","'+ hr.Percentage_OccupiedRP__c +'","'+ hr.Percentage_Occupied__c +'","'+ hr.OportunidadesTotalesArd__c +'","'+ hr.OppMensuales_NextMonth__c +'","'+ hr.Next_Month_Percentage_Occupied__c+'","",\n';
									System.debug('"' + intContador + '","Proceso 4","' + hr.Usuario__r.Name + '","'+objLead.id+'","'+ hr.Percentage_OccupiedRP__c +'","'+ hr.Percentage_Occupied__c +'","'+ hr.OportunidadesTotalesArd__c +'","'+ hr.OppMensuales_NextMonth__c +'","'+ hr.Next_Month_Percentage_Occupied__c+'","",\n');
									//Agregar a Map para actualizar Lead
									mapLeadUpdate.put(objLead.Id,objLead);
									
									//Remueve del Map mapLeadsRHTopeDinLleno
									if(mapLeadsRHTopeDinLleno.containsKey(objLead.Id))
										mapLeadsRHTopeDinLleno.remove(objLead.Id);
									//Remueve del Map mapLeadsSucursalNoIgualRH
									if(mapLeadsSucursalNoIgualRH.containsKey(objLead.Id))
										mapLeadsSucursalNoIgualRH.remove(objLead.Id);							
								}//Fin if(hr.MD4__c)
							}//Fin if(hr.OportunidadesTotalesArd__c < hr.tope_dinamico__c)
							else
								mapLeadsRHTopeDinLleno.put(objLead.Id,objLead);
						}//Fin if(mapLeadUpdate.get(objLead.id)== NULL)
					}//Fin for(RecursosHumanos__c rh: listlistHR)
				}//if(objLead.DeudaWeb__c >=40000001)
				
				if(objLead.DeudaWeb__c < 40000001)
				{
					for(RecursosHumanos__c hr: listHR)
					{
						if(mapLeadUpdate.get(objLead.id)== NULL)
						{
							if(hr.OportunidadesTotalesArd__c ==NULL ||  (hr.OportunidadesTotalesArd__c < hr.tope_dinamico__c))
							{
								//Asignacion de Lead Proceso 5:
								// - Lead.DeudaWeb__c < 40000001
								// - Sucursal RH != Sucursal Lead
								// - RH OportunidadesTotalesArd__c < RH.tope_dinamico__c
								System.debug('@@ Entro Proceso 5 RH ' + hr.Id + ' Lead Id:' + objLead.Id);
								objLead.OwnerId = hr.Usuario__c;
								objLead.VendedorAsignado__c = hr.Id;
								objLead.AsignadoProceso__c = true;
								objLead.ConsecutivoAssigProcess__c = intContador;

								// Se suma 1 a las oportunidades Totales del mes actual del vendedor
								if(hr.OportunidadesTotalesArd__c == null)
									hr.OportunidadesTotalesArd__c = 1;
								else
									hr.OportunidadesTotalesArd__c = hr.OportunidadesTotalesArd__c + 1;
								if (hr.tope_dinamico__c > 0)     
								{
									hr.Percentage_Occupied__c = (hr.OportunidadesTotalesArd__c/hr.tope_dinamico__c) * 100;
									hr.Percentage_Occupied__c = hr.Percentage_Occupied__c.setscale(4);
								}
									
								strRenglonInforme += '"' + intContador + '","Proceso 5","' + hr.Usuario__r.Name + '","'+objLead.id+'","'+ hr.Percentage_OccupiedRP__c +'","'+ hr.Percentage_Occupied__c +'","'+ hr.OportunidadesTotalesArd__c +'","'+ hr.OppMensuales_NextMonth__c +'","'+ hr.Next_Month_Percentage_Occupied__c+'","",\n';
								System.debug('"' + intContador + '","Proceso 5","' + hr.Usuario__r.Name + '","'+objLead.id+'","'+ hr.Percentage_OccupiedRP__c +'","'+ hr.Percentage_Occupied__c +'","'+ hr.OportunidadesTotalesArd__c +'","'+ hr.OppMensuales_NextMonth__c +'","'+ hr.Next_Month_Percentage_Occupied__c+'","",\n');
								//Agregar a Map para actualizar Lead
								mapLeadUpdate.put(objLead.Id,objLead);
								
								//Remueve del Map mapLeadsRHTopeDinLleno
								if(mapLeadsRHTopeDinLleno.containsKey(objLead.Id))
									mapLeadsRHTopeDinLleno.remove(objLead.Id);
								//Remueve del Map mapLeadsSucursalNoIgualRH
								if(mapLeadsSucursalNoIgualRH.containsKey(objLead.Id))
									mapLeadsSucursalNoIgualRH.remove(objLead.Id);							
							}//Fin if(hr.OportunidadesTotalesArd__c < hr.tope_dinamico__c)
							else
								mapLeadsRHTopeDinLleno.put(objLead.Id,objLead);
						}//Fin if(mapLeadUpdate.get(objLead.id)== NULL)
					}//Fin for(RecursosHumanos__c rh: listlistHR)
				}//if(objLead.DeudaWeb__c >=40000001)
				
			}//Fin for(Lead objLead: mapLeadsSucursalNoIgualRH.values())
		}//Fin if(mapLeadsSucursalNoIgualRH.size()>0)
		
		// ***************** Termina Asignacion de Leads de Sucursales que no pertenecen a ninguna Sucursal de Vendedor ********************
		
		// ***************** Empieza Asignacion de Leads con Tope Dinamico lleno y Sucursal igual a Vendedor que deben ser asignados para el mes siguiente*************
		if(mapLeadsRHTopeDinLleno.size()>0)
		{
			//Se ordena los Vendedores Ascedentemente por el campo Percentage_Occupied__c 
			Lead_Utility.sortList(listHR,'Next_Month_Percentage_Occupied__c','ASC');
			System.debug('@@ Lista RH Ordenada ASC Next_Month_Percentage_Occupied__c \n:' + listHR);
			
			System.debug('@@ 1 Entro a mapLeadsRHTopeDinLleno');
			for(Lead objLead: mapLeadsRHTopeDinLleno.values())
			{
				if(objLead.DeudaWeb__c >=40000001)
				{
					for(RecursosHumanos__c hr: listHR)
					{
						if(mapLeadUpdate.get(objLead.id)== NULL)
						{
							if(objLead.AsignacionSucursal__c == hr.Sucursal__c)
							{
								if(hr.MD4__c)
								{
									//Asignacion de Lead Proceso 6:
									// - Lead.DeudaWeb__c >=40000001
									// - Sucursal RH == Sucursal Lead
									// - RH OportunidadesTotalesArd__c > RH.tope_dinamico__c (Tope de RH alcanzado, Asignar a siguiente mes)
									// - RH es MD4
									System.debug('@@ Entro Proceso 6 RH ' + hr.Id + ' Lead Id:' + objLead.Id);
									objLead.OwnerId = hr.Usuario__c;
									objLead.VendedorAsignado__c = hr.Id;
									objLead.AsignadoProceso__c = true;
									objLead.ConsecutivoAssigProcess__c = intContador;
									//Asigna como Fecha/Hora Creacion de Oportunidad la fecha actual más un mes
									Date dt = date.today();
									objLead.FechaHoraCreacionOportunidad__c = Datetime.newInstance(dt.year(), dt.month()+1, 1);    
									
									System.debug('@@ ANTES Proceso 6 RH ' + hr.Id + ' Percentage_Occupied__c '+hr.Percentage_Occupied__c);
									System.debug('@@ ANTES Proceso 6 RH ' + hr.Id + ' tope_dinamico__c '+hr.tope_dinamico__c);
									System.debug('@@ ANTES Proceso 6 RH ' + hr.Id + ' OppMensuales_NextMonth__c '+hr.OppMensuales_NextMonth__c);
									// Se suma 1 a las oportunidades Totales del siguiente Mes del vendedor
									if(hr.OppMensuales_NextMonth__c!=null)
										hr.OppMensuales_NextMonth__c= hr.OppMensuales_NextMonth__c+ 1;
									else
										hr.OppMensuales_NextMonth__c=1;   

									System.debug('@@ Proceso 6 RH ' + hr.Id + ' Percentage_Occupied__c '+hr.Percentage_Occupied__c);
									System.debug('@@ Proceso 6 RH ' + hr.Id + ' tope_dinamico__c '+hr.tope_dinamico__c);
									System.debug('@@ Proceso 6 RH ' + hr.Id + ' OppMensuales_NextMonth__c '+hr.OppMensuales_NextMonth__c);

									if (hr.TopeOportunidadesMensual__c > 0)     
									{
										hr.Next_Month_Percentage_Occupied__c = (hr.OppMensuales_NextMonth__c/hr.TopeOportunidadesMensual__c) * 100;
										hr.Next_Month_Percentage_Occupied__c = hr.Next_Month_Percentage_Occupied__c.setScale(4);
									}	
									strRenglonInforme += '"' + intContador + '","Proceso 6","' + hr.Usuario__r.Name + '","'+objLead.id+'","'+ hr.Percentage_OccupiedRP__c +'","'+ hr.Percentage_Occupied__c +'","'+ hr.OportunidadesTotalesArd__c +'","'+ hr.OppMensuales_NextMonth__c +'","'+ hr.Next_Month_Percentage_Occupied__c+'","",\n';
									System.debug('"' + intContador + '","Proceso 6","' + hr.Usuario__r.Name + '","'+objLead.id+'","'+ hr.Percentage_OccupiedRP__c +'","'+ hr.Percentage_Occupied__c +'","'+ hr.OportunidadesTotalesArd__c +'","'+ hr.OppMensuales_NextMonth__c +'","'+ hr.Next_Month_Percentage_Occupied__c+'","",\n');
									//Agregar a Map para actualizar Lead
									mapLeadUpdate.put(objLead.Id,objLead);
									
									//Remueve del Map mapLeadsRHTopeDinLleno
									if(mapLeadsRHTopeDinLleno.containsKey(objLead.Id))
										mapLeadsRHTopeDinLleno.remove(objLead.Id);
								}//Fin if(hr.MD4__c)
							}//Fin if(objLead.AsignacionSucursal__c == hr.Sucursal__c)
						}//Fin if(mapLeadUpdate.get(objLead.id)== NULL)
					}//Fin for(RecursosHumanos__c rh: listlistHR)
				}//if(objLead.DeudaWeb__c >=40000001)
				
				if(objLead.DeudaWeb__c < 40000001)
				{
					for(RecursosHumanos__c hr: listHR)
					{
						if(mapLeadUpdate.get(objLead.id)== NULL)
						{
							if(objLead.AsignacionSucursal__c == hr.Sucursal__c)
							{
								//Asignacion de Lead Proceso 7:
								// - Lead.DeudaWeb__c <40000001
								// - Sucursal RH == Sucursal Lead
								// - RH OportunidadesTotalesArd__c > RH.tope_dinamico__c (Tope de RH alcanzado, Asignar a siguiente mes)
								System.debug('@@ Entro Proceso 7 RH ' + hr.Id + ' Lead Id:' + objLead.Id);
								objLead.OwnerId = hr.Usuario__c;
								objLead.VendedorAsignado__c = hr.Id;
								objLead.AsignadoProceso__c = true;
								objLead.ConsecutivoAssigProcess__c = intContador;
								//Asigna como Fecha/Hora Creacion de Oportunidad la fecha actual más un mes
								Date dt = date.today();
								objLead.FechaHoraCreacionOportunidad__c = Datetime.newInstance(dt.year(), dt.month()+1, 1);    
								
								System.debug('@@ ANTES Proceso 7 RH ' + hr.Id + ' Percentage_Occupied__c '+hr.Percentage_Occupied__c);
								System.debug('@@ ANTES Proceso 7 RH ' + hr.Id + ' tope_dinamico__c '+hr.tope_dinamico__c);
								System.debug('@@ ANTES Proceso 7 RH ' + hr.Id + ' OppMensuales_NextMonth__c '+hr.OppMensuales_NextMonth__c);
								// Se suma 1 a las oportunidades Totales del siguiente Mes del vendedor
								if(hr.OppMensuales_NextMonth__c!=null)
									hr.OppMensuales_NextMonth__c= hr.OppMensuales_NextMonth__c+ 1;
								 else
									hr.OppMensuales_NextMonth__c=1;   

								System.debug('@@ Proceso 7 RH ' + hr.Id + ' Percentage_Occupied__c '+hr.Percentage_Occupied__c);
								System.debug('@@ Proceso 7 RH ' + hr.Id + ' tope_dinamico__c '+hr.tope_dinamico__c);
								System.debug('@@ Proceso 7 RH ' + hr.Id + ' OppMensuales_NextMonth__c '+hr.OppMensuales_NextMonth__c);

								if (hr.TopeOportunidadesMensual__c > 0)
								{
									hr.Next_Month_Percentage_Occupied__c = (hr.OppMensuales_NextMonth__c/hr.TopeOportunidadesMensual__c) * 100;
									hr.Next_Month_Percentage_Occupied__c = hr.Next_Month_Percentage_Occupied__c.setScale(4);
								}
								strRenglonInforme += '"' + intContador + '","Proceso 7","' + hr.Usuario__r.Name + '","'+objLead.id+'","'+ hr.Percentage_OccupiedRP__c +'","'+ hr.Percentage_Occupied__c +'","'+ hr.OportunidadesTotalesArd__c +'","'+ hr.OppMensuales_NextMonth__c +'","'+ hr.Next_Month_Percentage_Occupied__c+'","",\n';
								System.debug('"' + intContador + '","Proceso 7","' + hr.Usuario__r.Name + '","'+objLead.id+'","'+ hr.Percentage_OccupiedRP__c +'","'+ hr.Percentage_Occupied__c +'","'+ hr.OportunidadesTotalesArd__c +'","'+ hr.OppMensuales_NextMonth__c +'","'+ hr.Next_Month_Percentage_Occupied__c+'","",\n');
								//Agregar a Map para actualizar Lead
								mapLeadUpdate.put(objLead.Id,objLead);
								
								//Remueve del Map mapLeadsRHTopeDinLleno
								if(mapLeadsRHTopeDinLleno.containsKey(objLead.Id))
									mapLeadsRHTopeDinLleno.remove(objLead.Id);
							}//Fin objLead.AsignacionSucursal__c == hr.Sucursal__c
						}//Fin if(mapLeadUpdate.get(objLead.id)== NULL)
					}//Fin for(RecursosHumanos__c rh: listlistHR)
				}//if(objLead.DeudaWeb__c >=40000001)
				
			}//Fin for(Lead objLead: mapLeadsSucursalNoIgualRH.values())
		}//Fin if(mapLeadsSucursalNoIgualRH.size()>0)		
		
		// ***************** Termina Asignacion de Leads con Tope Dinamico lleno y Sucursal igual a Vendedor que deben ser asignados para el mes siguiente*************
		
		// ***************** Empieza Asignacion de Leads con Tope Dinamico lleno y Sucursal NO igual a Vendedor que deben ser asignados para el mes siguiente*************
		if(mapLeadsRHTopeDinLleno.size()>0)
		{
			//Se ordena los Vendedores Ascedentemente por el campo Percentage_Occupied__c 
			Lead_Utility.sortList(listHR,'Next_Month_Percentage_Occupied__c','ASC');
			System.debug('@@ Entro a Tope Dinamico lleno y Sucursal NO igual a Vendedor');
			System.debug('@@ Lista RH Ordenada ASC Next_Month_Percentage_Occupied__c \n:' + listHR);
			
			for(Lead objLead: mapLeadsRHTopeDinLleno.values())
			{
				if(objLead.DeudaWeb__c >=40000001)
				{
					for(RecursosHumanos__c hr: listHR)
					{
						if(mapLeadUpdate.get(objLead.id)== NULL)
						{
							if(hr.MD4__c)
							{
								//Asignacion de Lead Proceso 8:
								// - Lead.DeudaWeb__c >=40000001
								// - Sucursal RH != Sucursal Lead
								// - RH OportunidadesTotalesArd__c > RH.tope_dinamico__c (Tope de RH alcanzado, Asignar a siguiente mes)
								// - RH es MD4
								System.debug('@@ Entro Proceso 8 RH ' + hr.Id + ' Lead Id:' + objLead.Id);
								objLead.OwnerId = hr.Usuario__c;
								objLead.VendedorAsignado__c = hr.Id;
								objLead.AsignadoProceso__c = true;
								objLead.ConsecutivoAssigProcess__c = intContador;
								//Asigna como Fecha/Hora Creacion de Oportunidad la fecha actual más un mes
								Date dt = date.today();
								objLead.FechaHoraCreacionOportunidad__c = Datetime.newInstance(dt.year(), dt.month()+1, 1);    
								
								System.debug('@@ Proceso 8 RH ' + hr.Id + ' Percentage_Occupied__c '+hr.Percentage_Occupied__c);
								System.debug('@@ Proceso 8 RH ' + hr.Id + ' tope_dinamico__c '+hr.tope_dinamico__c);
								System.debug('@@ Proceso 8 RH ' + hr.Id + ' OppMensuales_NextMonth__c '+hr.OppMensuales_NextMonth__c);
								// Se suma 1 a las oportunidades Totales del siguiente Mes del vendedor
								if(hr.OppMensuales_NextMonth__c!=null)
									hr.OppMensuales_NextMonth__c= hr.OppMensuales_NextMonth__c+ 1;
								 else
									hr.OppMensuales_NextMonth__c=1;   

								if (hr.TopeOportunidadesMensual__c > 0)     
								{
									hr.Next_Month_Percentage_Occupied__c = (hr.OppMensuales_NextMonth__c/hr.TopeOportunidadesMensual__c) * 100;
									hr.Next_Month_Percentage_Occupied__c = hr.Next_Month_Percentage_Occupied__c.setScale(4);
								}									
								strRenglonInforme += '"' + intContador + '","Proceso 8","' + hr.Usuario__r.Name + '","'+objLead.id+'","'+ hr.Percentage_OccupiedRP__c +'","'+ hr.Percentage_Occupied__c +'","'+ hr.OportunidadesTotalesArd__c +'","'+ hr.OppMensuales_NextMonth__c +'","'+ hr.Next_Month_Percentage_Occupied__c+'","",\n';
								System.debug('"' + intContador + '","Proceso 8","' + hr.Usuario__r.Name + '","'+objLead.id+'","'+ hr.Percentage_OccupiedRP__c +'","'+ hr.Percentage_Occupied__c +'","'+ hr.OportunidadesTotalesArd__c +'","'+ hr.OppMensuales_NextMonth__c +'","'+ hr.Next_Month_Percentage_Occupied__c+'","",\n');
								//Agregar a Map para actualizar Lead
								mapLeadUpdate.put(objLead.Id,objLead);
								
								//Remueve del Map mapLeadsRHTopeDinLleno
								if(mapLeadsRHTopeDinLleno.containsKey(objLead.Id))
									mapLeadsRHTopeDinLleno.remove(objLead.Id);
							}//Fin if(hr.MD4__c)							
						}//Fin if(mapLeadUpdate.get(objLead.id)== NULL)
					}//Fin for(RecursosHumanos__c rh: listlistHR)
				}//if(objLead.DeudaWeb__c >=40000001)
				
				if(objLead.DeudaWeb__c < 40000001)
				{
					for(RecursosHumanos__c hr: listHR)
					{
						if(mapLeadUpdate.get(objLead.id)== NULL)
						{
							//Asignacion de Lead Proceso 9:
							// - Lead.DeudaWeb__c < 40000001
							// - Sucursal RH != Sucursal Lead
							// - RH OportunidadesTotalesArd__c > RH.tope_dinamico__c (Tope de RH alcanzado, Asignar a siguiente mes)
							System.debug('@@ Entro Proceso 9 RH ' + hr.Id + ' Lead Id:' + objLead.Id);
							objLead.OwnerId = hr.Usuario__c;
							objLead.VendedorAsignado__c = hr.Id;
							objLead.AsignadoProceso__c = true;
							objLead.ConsecutivoAssigProcess__c = intContador;
							//Asigna como Fecha/Hora Creacion de Oportunidad la fecha actual más un mes
							Date dt = date.today();
							objLead.FechaHoraCreacionOportunidad__c = Datetime.newInstance(dt.year(), dt.month()+1, 1);    
							
							System.debug('@@ Proceso 9 RH ' + hr.Id + ' Percentage_Occupied__c '+hr.Percentage_Occupied__c);
							System.debug('@@ Proceso 9 RH ' + hr.Id + ' tope_dinamico__c '+hr.tope_dinamico__c);
							System.debug('@@ Proceso 9 RH ' + hr.Id + ' OppMensuales_NextMonth__c '+hr.OppMensuales_NextMonth__c);
							// Se suma 1 a las oportunidades Totales del siguiente Mes del vendedor
							if(hr.OppMensuales_NextMonth__c!=null)
								hr.OppMensuales_NextMonth__c= hr.OppMensuales_NextMonth__c+ 1;
							 else
								hr.OppMensuales_NextMonth__c=1;   
							if (hr.TopeOportunidadesMensual__c > 0)     
							{
								hr.Next_Month_Percentage_Occupied__c = (hr.OppMensuales_NextMonth__c/hr.TopeOportunidadesMensual__c) * 100;
								hr.Next_Month_Percentage_Occupied__c = hr.Next_Month_Percentage_Occupied__c.setScale(4);
							}
								
							strRenglonInforme += '"' + intContador + '","Proceso 9","' + hr.Usuario__r.Name + '","'+objLead.id+'","'+ hr.Percentage_OccupiedRP__c +'","'+ hr.Percentage_Occupied__c +'","'+ hr.OportunidadesTotalesArd__c +'","'+ hr.OppMensuales_NextMonth__c +'","'+ hr.Next_Month_Percentage_Occupied__c+'","",\n';
							System.debug('"' + intContador + '","Proceso 9","' + hr.Usuario__r.Name + '","'+objLead.id+'","'+ hr.Percentage_OccupiedRP__c +'","'+ hr.Percentage_Occupied__c +'","'+ hr.OportunidadesTotalesArd__c +'","'+ hr.OppMensuales_NextMonth__c +'","'+ hr.Next_Month_Percentage_Occupied__c+'","",\n');
							//Agregar a Map para actualizar Lead
							mapLeadUpdate.put(objLead.Id,objLead);
							
							//Remueve del Map mapLeadsRHTopeDinLleno
							if(mapLeadsRHTopeDinLleno.containsKey(objLead.Id))
								mapLeadsRHTopeDinLleno.remove(objLead.Id);						
						}//Fin if(mapLeadUpdate.get(objLead.id)== NULL)
					}//Fin for(RecursosHumanos__c rh: listlistHR)
				}//if(objLead.DeudaWeb__c >=40000001)
				
			}//Fin for(Lead objLead: mapLeadsSucursalNoIgualRH.values())
		}//Fin if(mapLeadsSucursalNoIgualRH.size()>0)		
		
		// ***************** Termina Asignacion de Leads con Tope Dinamico lleno y Sucursal igual a Vendedor que deben ser asignados para el mes siguiente*************



		
		//Actualizacion de Leads
		try
		{
			update mapLeadUpdate.values();
		}
		catch(Exception ex)
		{
			System.debug(intContador + ' Error en Batch Asignacion de Leads ' + ex.getMessage() + ' Registro que genero error: \n'+ listLeadScope +'\n');
			strRenglonInforme += '"' + intContador + '","Error","Error",' +'"'+listLeadScope[0].id+'","Error","Error","Error","Error","Error","' + ex.getMessage()   +'"\n';
		}
		
		
		
		//Incrementa Contador
		intContador++;
	}
	
	//Finish
	global void finish(Database.BatchableContext BC)
	{
		System.debug('::::Ingreso a Metodo Finish Asignación de Leads::::');
		Notificacion_Trabajos_Programados__c config = Notificacion_Trabajos_Programados__c.getInstance( 'BchAsignacionOportunidades_bch' );
		Datetime dtFechaHoraActual = Datetime.now();
		String strFechaHoraActual = dtFechaHoraActual.format('dd/MM/yyyy HH:mm:ss');
		Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
		blob csvBlob = Blob.valueOf(strRenglonInforme);	
		String csvname= 'InformeAsignacionOportundiadesRTDColombia' + dtFechaHoraActual.format('dd_MM_yyyy_HH_mm_ss') +'.csv';		
		csvAttc.setFileName(csvname);
		csvAttc.setBody(csvBlob);		
		Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();		
		String strCorreos = config.Correo_Notificacion__c;
		String[] toAddresses = strCorreos.split(',');
		toAddresses.add(UserInfo.getUserEmail());
		mail.setToAddresses(toAddresses);
		mail.setSubject(config.Asunto_Correo_Notificacion__c + ' ' + strFechaHoraActual);
		mail.setPlainTextBody('INFORME ASIGNACIÓN OPORTUNIDADES RTD COLOMBIA \n\n' 
		+'Fecha Hora de Ejecución: ' + strFechaHoraActual +'\n\n'
		+'Usuario que ejecuto el Batch: ' + UserInfo.getName() + ' ID: ' + UserInfo.getUserId()  +'\n\n'
		+ 'Cantidad de Leads a Asignar ' + lstCantLeads.size() + +'\n\n'
		+ 'Por favor revisar el archivo adjunto');
		mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});		
		if (!Test.isRunningTest() ) 
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });			
		System.debug('::::Termino Batach Asignación de Leads::::');
	}
	
}