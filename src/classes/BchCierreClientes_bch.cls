/*******************************************************************************
Desarrollado por:   RTD
Autor:              Jeisson Hernandez
Proyecto:           Colombia III Cierre de Clientes
Descripción:        Clase Batch de Cierre de Clientes

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                     Descripción
    ---     -----------		---------------------    -----------------------------
    1.0     03-Sep-2015		Jeisson Hernandez(JH)	Creación de la Clase.
    1.1     28-Ene-2016		Jeisson Hernandez(JH)	Se adiciona la Conf Pers "CierreClientesPuestosPerfiles__c"
    												para almacenar los puestos de los negociadores y ejecutivos de servicio al cliente
    												para la asignacion de cuentas y deudas
	1.2		04-Feb-2016		Jeisson Hernandez(JH)	Edwin Garduño(Negociacion y SC) solicita que leads con fecha de deposito con mes anterior
													se sumen a los leads de mes actual debido a que Allianz confirma saldos días despues
													de la fecha de deposito y esto afecta la asignación de cliente a los ejecutivos de SC en los dias de cierre
	1.3		25-Abr-2016		Jeisson Hernandez(JH)	Edwin Garduño(Negociacion y SC) solicita que la asignacion sea modificada para que se tome el campo
													Total_Clientes__c el cual actualizado una vez al mes por el batch SchRHCamposACero_sch
	1.4		18-Jul-2016		Angela Munévar(AM)		Edwin Garduño solicita que en la creación de las deudas se agreguen los valores SucursalDeAperturaDeObligacion__c
													y MontoDeUltimoPago__c
	1.5		18-Jul-2016		Marwin Pineda (MP)		Se valida si la fecha es menor a 01/07/2015 asigna .55% de comisión mensual, de lo contrario asigna .6% de comisión menusal.
													Proyecto Movimientos automáticos.
	1.6		9-Ago2016		Jeisson Hernandez (JH)	Se agrega campo copiado de campo Nro_Referencia__c de la Reparadora
													en campo texto para guardar respaldo de Nro de Referencia cuando se
													desvincula una deuda de la reparadora. De acuerdo a Caso Nro 68062 Mx Nro 2059 Colombia
	1.7		04-ene-2017   	Joe Ayala(JA)			Se realiza ajuste en el calculo de las fechas para asegurar que cuando se requiera restar un mes a la fecha actual se tenga en cuenta cuando el mes es 1 y cambia a 12
	1.8		11-ene-2017		Marwin Pineda (MP)		Se adiciona el campo Reparadora en el Contrato Digital el cual se debe poblar al ejecutarse el cierre de clientes.
	1.9		08-feb-2017  	Joe Ayala(JA)			Se adiciona la creación de ingresos a partir de la creacion de la reparadora
	2.0		05-Abr-2017		Katherine Cardenas(KC)	Duplicidad de documentos de la oportunidad a la reparadora. Ajuste para liberacion de licencias SFDC. JIRA SC-570
*******************************************************************************/

global class BchCierreClientes_bch implements Database.Batchable<sObject>,Database.Stateful
{
	global final String Query;
	global Integer intConsecutivo;
	global String strError;

	global BchCierreClientes_bch(String q)
	{
		Query=q;
		intConsecutivo = 1;
		strError='Consecutivo,Registro Origen,Ejecutivo SC,Total Clientes,Negociador,Total Deudas Activas,Observaciones\n';

	}

	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		return Database.getQueryLocator(query);
	}
    
	global void execute(Database.BatchableContext BC, List<Lead> scope)
	{
		system.debug(' Toma la lista que viene del alcance del batch  ' + scope);
		List<Lead> lstLeadsScope 								= scope;
		Map<Integer, Account> mapCtesNuevosIns 					= new Map<Integer, Account>();
		Map<Integer, Lead> mapLeadSel 							= new Map<Integer, Lead>();
		Map<String, Decimal> mapLeadMonto 						= new Map<String, Decimal>();
		Map<String, List<DeudaOportunidad__c>> mapLeadDeudas 	= new Map<String, List<DeudaOportunidad__c>>();
		List<Deudas__c> lstLeadDeudasIns 						= new List<Deudas__c>();
		Map<Integer, String> mapIdCtesNuevo 					= new Map<Integer, String>();
		Map<Integer, String> mapIdRepNuevo 						= new Map<Integer, String>();
		Map<String, Lead> mLeadsAct 							= new Map<String, Lead>();
		List<Lead> lstLeadUpd 									= new List<Lead>();
		List<Reparadora__c> lstRepNuevas 						= new List<Reparadora__c>();
		Map<String, Reparadora__c> mRepNuevasCons 				= new Map<String, Reparadora__c>();
		Map<Boolean, List<RecursosHumanos__c>> mRHPrem			= new Map<Boolean, List<RecursosHumanos__c>>();
		Map<String, RecursosHumanos__c> mRHPremUpd 				= new Map<String, RecursosHumanos__c>();
		Map<String, RecursosHumanos__c> mRHNegAsig 				= new Map<String, RecursosHumanos__c>();
		List<Movimientos__c> lstMovNuevos 						= new List<Movimientos__c>();
        List<Ingresos__c> lstIngrNuevo 							= new List<Ingresos__c>();
		Map<String, String> mRtMov 								= new Map<String, String>();
		Map<String, String> mEmpresas 							= new Map<String, String>();
		Map<String, String> mapRepLead 							= new Map<String, String>();
		Map<String, String> mapCuentaRep 						= new Map<String, String>();
		//KC 05-04-2017: se consulta la url de la instancia para duplicar url de imagenes
		//String strURLBase = URLInstancia__c.getInstance().URLBaseImagenes__c;

		String sIdEjecServCte 			= '';
		String sIdEjecServCteRH 		= '';
		String sIdNegAsig 				= '';
		String strIdReparadora 			= '';
		String strIdRHNegociadorVirtual	= '';

		system.debug('+++entró al execute');
		
		//JH 28-Ene-2015: Se adiciona la Conf Pers "CierreClientesPuestosPerfiles__c" para realizar consulta de ejecutivos SC y Negociadores
		Set<String> setPuestosNegociacion 		= new Set<String>();
		Set<String> setPuestosServicioCliente 	= new Set<String>();
		
		for(CierreClientesPuestosPerfiles__c objPuestosCierreClientes: CierreClientesPuestosPerfiles__c.getAll().values())
		{
			if(objPuestosCierreClientes.Area__c == 'Negociacion')
				setPuestosNegociacion.add(objPuestosCierreClientes.Puesto__c);
			if(objPuestosCierreClientes.Area__c == 'Servicio al Cliente')
				setPuestosServicioCliente.add(objPuestosCierreClientes.Puesto__c);
		}
		System.debug('@@ Puestos Negociacion ' + setPuestosNegociacion);
		System.debug('@@ Puestos Servicio al Cliente ' + setPuestosServicioCliente);
		//Fin JH 28-Ene-2015: Se adiciona la Conf Pers "CierreClientesPuestosPerfiles__c" para realizar consulta de ejecutivos SC y Negociadores

		Integer iCntCtesNuevos = 1;
		
		//Consulta los Recursos Humanos de Servicio al Cliente Premiun y No Premiun para la asignacion de Reparadoras
		for(RecursosHumanos__c objRHPaso :[SELECT r.id, r.Usuario__r.LastName, r.Usuario__c, r.EjecutivoPremium__c, r.Total_Clientes__c, Name
											FROM RecursosHumanos__c r
											WHERE r.IdPuestoMexico__c IN :setPuestosServicioCliente
											AND Area__c = 'Servicio al Cliente'
											AND r.Status__c = 'Activo'
											AND r.Usuario__r.isActive = true
											AND NoAsignarClientes__c = false
											AND (NOT Name like '%Virtual%')
											AND UnidadNegocio__c = 'RTD Colombia'
											ORDER BY Total_Clientes__c ASC])
		{
			if(!mRHPrem.containsKey(true))
			{
				//Ve si es premium
				if(objRHPaso.EjecutivoPremium__c == true)
				{
					if (objRHPaso.Total_Clientes__c == null)
					objRHPaso.Total_Clientes__c = 0;
					mRHPrem.put(objRHPaso.EjecutivoPremium__c, new List<RecursosHumanos__c>{objRHPaso});
				}


			}
			if(!mRHPrem.containsKey(false))
			{
				if(objRHPaso.EjecutivoPremium__c == false)
				{
					if (objRHPaso.Total_Clientes__c == null)
					objRHPaso.Total_Clientes__c = 0;
					mRHPrem.put(objRHPaso.EjecutivoPremium__c, new List<RecursosHumanos__c>{objRHPaso});
				}
			}
		}//Fin del for para la Consulta los Recursos Humanos de Servicio al Cliente Premiun y No Premiun para la asignacion de Reparadoras

		System.debug('@@@ Recursos Humanos Premiun y No Premiun: ' + mRHPrem);

		//Consulta el Recurso Humano de Negociacion para la asignacion de las Deudas dado que el batch es 1 a 1
		

		// Se arma un map con los leads que llegan al batch
		for (Lead objLeadUpd : lstLeadsScope)
		{
			System.debug('@@Lead  ' +  objLeadUpd);
			System.debug('@@Lead LugarExp: ' +  objLeadUpd.LugarExpedicion__c);
			mLeadsAct.put(objLeadUpd.id, objLeadUpd);
		}//Fin del for Se arma un map con los leads que llegan al batch
		
		System.debug('@@@@ MAP mLeadsAct: ' + mLeadsAct);

//////////////////////////////////////////////////   GENERACION E INSERCION DE CLIENTES      /////////////////////////////////////
		if(!mLeadsAct.isEmpty())
		{
			Decimal comisionMensualMasIVA 	= 0.0;
			String strIdLead				= '';
			
			//Consulta el Monto Total de las Deudas Oportunidad asociadas a los Leads
			for(AggregateResult objDeudaOportunidad :[SELECT OportunidadLead__c, SUM(Monto__c) TotMonto
													FROM DeudaOportunidad__c  
													WHERE OportunidadLead__c IN :mLeadsAct.KeySet()
													GROUP BY OportunidadLead__c])
			{
				if(String.valueOf(objDeudaOportunidad.get('OportunidadLead__c')) != null)
				{
					Decimal dTotMonto 	= (Decimal)(objDeudaOportunidad.get('TotMonto'));
					strIdLead 			= String.valueOf(objDeudaOportunidad.get('OportunidadLead__c'));
					mapLeadMonto.put(strIdLead, dTotMonto);
					comisionMensualMasIVA = ((dTotMonto * 0.006) * 1.19);
				}
			}//Fin del for para obtener Monto Total de las Deudas Oportunidad asociadas a los Leads
			
			System.debug('@@@@ MAP mapLeadMonto:  ' + mapLeadMonto);
			System.debug('\n\n@@@comisionMensualMasIVA---------> ' + comisionMensualMasIVA + '\n\n');
			
			// Se arma un map con el leads y sus deudas oportunidad asociadas
			for(DeudaOportunidad__c objDeudaOpp :[SELECT UltimoPago__c, PagoEstimadoBanco__c, OportunidadLead__c, 
													NumeroCredito__c, Monto__c, LimitePago__c, FechaEstimadaLiquidacion__c, LimiteCredito__c, 
													EntidadFinanciera__c, TipoProducto__c, MontoDeUltimoPago__c, SucursalDeAperturaDeObligacion__c
												FROM DeudaOportunidad__c 
												WHERE OportunidadLead__c IN :mLeadsAct.KeySet()]) 
			{ 
				//Agrega la deuda oportunidad al mapa de mapLeadDeudas 
				if (mapLeadDeudas.containsKey(objDeudaOpp.OportunidadLead__c))
					mapLeadDeudas.get(objDeudaOpp.OportunidadLead__c).add(objDeudaOpp);
				if (!mapLeadDeudas.containsKey(objDeudaOpp.OportunidadLead__c))
					mapLeadDeudas.put(objDeudaOpp.OportunidadLead__c, new List<DeudaOportunidad__c>{objDeudaOpp});
			}//Fin del for 
			System.debug('@@@@ MAP mapLeadDeudas: ' + mapLeadDeudas);
			System.debug('\n\n@@@strIdLead-------> ' + strIdLead + '\n\n');
			  
			Integer contMayorDiez = 0;
			Integer contMenorDiez = 0;
			
			for(Id idLead :mapLeadDeudas.keySet())
			{
				Decimal decAhorroLibre = mLeadsAct.get(idLead).CaratulaApartadoMensual__c - comisionMensualMasIVA;
				System.debug('\n\n@@@idLead------> ' + idLead + '\n' +  
					'@@@decAhorroLibre------> ' + decAhorroLibre + '\n\n');
				for(DeudaOportunidad__c objDeudaOportunidad :mapLeadDeudas.get(idLead))
				{
					Decimal porcentajePrimerApartado = decAhorroLibre / objDeudaOportunidad.Monto__c;
					System.debug('\n\n@@@porcentajePrimerApartado-------> ' + porcentajePrimerApartado + '\n\n');
					
					if(porcentajePrimerApartado < 0.1)//Este valor debe ir en una configuración personalizada
					{
						contMenorDiez += 1;						
					}
					else
					{
						contMayorDiez += 1;
					}
					System.debug('\n\n@@@objDeudaOportunidad---------> ' + objDeudaOportunidad + '\n\n');
				}
			}
			
			System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
		    System.debug('Total Number of records that can be queried  in this apex code context: ' +  Limits.getLimitDmlRows());
		    System.debug('Total Number of DML statements allowed in this apex code context: ' +  Limits.getLimitDmlStatements() );
			
			System.debug('\n\n@@@contMenorDiez--------> ' + contMenorDiez + '\n' + 
				'@@@contMayorDiez---------> ' + contMayorDiez + '\n\n');
			
			if(contMenorDiez > 0 && contMayorDiez == 0)
			{
				System.debug('\n\n@@@Asignar a negociador virtual\n\n');
				sIdNegAsig = [SELECT Id FROM RecursosHumanos__c WHERE Name = 'Negociador Virtual'].Id;
			}
			else if((contMenorDiez > 0 && contMayorDiez > 0) || (contMenorDiez == 0 && contMayorDiez > 0))
			{
				for(RecursosHumanos__c objRHPaso :[SELECT r.id, r.Usuario__r.LastName, r.Usuario__c, r.TotalDeudasActivas__c, Name
			 								FROM RecursosHumanos__c r
											WHERE r.IdPuestoMexico__c IN :setPuestosNegociacion
											AND r.Usuario__r.isActive = true
											AND r.Status__c = 'Activo'
											AND r.TotalDeudasActivas__c >= 0
											AND (NOT Name  like '%Virtual%')
											AND UnidadNegocio__c = 'RTD Colombia'
											AND NoAsignarClientes__c = false
											ORDER BY TotalDeudasActivas__c LIMIT 1])
				{
					if (!objRHPaso.Name.contains('Ejecutivo Virtual'))
					{
						if (objRHPaso.TotalDeudasActivas__c == null)
							objRHPaso.TotalDeudasActivas__c = 0;
						if (!mRHNegAsig.containsKey(objRHPaso.Id))
							mRHNegAsig.put(objRHPaso.id, objRHPaso);
					}
				}//Fin del for para la Consulta el Recurso Humano de Negociacion para la asignacion de las Deudas dado que el batch es 1 a 1
				System.debug('@@@ Recurso Humano Negociador para las deudas mRHNegAsig: ' + mRHNegAsig);
				System.debug('\n\n@@@Asignar a negociador\n\n');
			}
		
			System.debug('\n\n@@@sIdNegAsig------> ' + sIdNegAsig + '\n\n');
			
			//KC: Consulta los documentos asociados a la oportunidad

			//Recorre la lista de Lead y genera las cuentas asociadas
			for(String leadPaso : mLeadsAct.KeySet())
			{
				Account AccPaso = new Account(LastName = !Test.isRunningTest() ? mLeadsAct.get(leadPaso).PrimerApellido__c : 'prueba'
					,Apellidomaterno__c = !Test.isRunningTest() ? mLeadsAct.get(leadPaso).SegundoApellido__c : 'prueba'
					,FirstName = (!Test.isRunningTest() ? mLeadsAct.get(leadPaso).PrimerNombre__c : 'prueba') + ' ' + (mLeadsAct.get(leadPaso).SegundoNombre__c!=null ? mLeadsAct.get(leadPaso).SegundoNombre__c : '')
					,PersonBirthdate = mLeadsAct.get(leadPaso).FechaNacimiento__c
					,Domicilio__c = mLeadsAct.get(leadPaso).Domicilio__c
					,Departamento__c = mLeadsAct.get(leadPaso).Departamento__c
					,CiudadMunicipio__c = mLeadsAct.get(leadPaso).CiudadMunicipio__c
					,numCC__c = mLeadsAct.get(leadPaso).Cedula__c
					,Phone = mLeadsAct.get(leadPaso).TelefonoCasa__c
					,Telefono_celular__c = mLeadsAct.get(leadPaso).TelefonoCelular__c
					,Telefono_oficina__c = mLeadsAct.get(leadPaso).TelefonoTrabajo__c
					,Genero__c = mLeadsAct.get(leadPaso).Genero__c
					//,Actividadeconomica__c = mLeadsAct.get(leadPaso).Ocupacion__c
					,Actividadeconomica__c = mLeadsAct.get(leadPaso).EmpleoCaratula__c
					,PersonEmail = !Test.isRunningTest() ? mLeadsAct.get(leadPaso).Email : 'prueba@hotmail.com'
					,AnosdeResidencia__c = mLeadsAct.get(leadPaso).CaratulaAniosResidencia__c!=null ? Decimal.valueOf(mLeadsAct.get(leadPaso).CaratulaAniosResidencia__c) : 0.00
					,Numerodedependientes__c = mLeadsAct.get(leadPaso).PersonasCargo__c
					,TVdepaga__c = mLeadsAct.get(leadPaso).TVPaga__c
					,Tipodevivienda__c = mLeadsAct.get(leadPaso).TipoVivienda__c
					,Estado_Civil__c = mLeadsAct.get(leadPaso).EstadoCivil__c
					,Niveleducativo__c = mLeadsAct.get(leadPaso).NivelAcademico__c
					,Ingreso_bruto__c = mLeadsAct.get(leadPaso).CaratulaIngresoBruto__c
					,Ingreso_Neto__c = mLeadsAct.get(leadPaso).CaratulaIngresoNeto__c
					,AccountSource = 'RTD Colombia'
					,Oportunidad__c = mLeadsAct.get(leadPaso).id
					,Empleado__c = mLeadsAct.get(leadPaso).BeneficioEmpleado__c
					,FechaExpedicion__c = mLeadsAct.get(leadPaso).FechaExpedicion__c
					,LugarExpedicion__c = mLeadsAct.get(leadPaso).LugarExpedicion__c
					,Tipodocumento__c = mLeadsAct.get(leadPaso).TipoDocAfiliado__c
					,Status__c = 'Activo'
				);
				mapCtesNuevosIns.put(iCntCtesNuevos,AccPaso);
				mapLeadSel.put(iCntCtesNuevos,mLeadsAct.get(leadPaso));
				iCntCtesNuevos++;
			}//Fin del for para la lista de mLeadsAct
		}

		System.debug('\n\n@@@mapLeadSel---------> ' + mapLeadSel + '\n\n');
		//Se crea un savepoint para poder realizar un Rollback si la creacion de todos los objetos no se completa correctamente
		SavePoint svP = Database.setSavepoint();

		try
		{
			//Inserta las Cuentas con un Database.insert
			if(!mapCtesNuevosIns.isEmpty())
			{
				System.debug('@@@ Inserta Clientes BchCierreClientes_bch mapCtesNuevosIns.values(): ' + mapCtesNuevosIns.values());
				//Reinicia
				iCntCtesNuevos = 1;
				List<Database.Saveresult> lDtSV = Database.insert(mapCtesNuevosIns.values(), true);
				//Recorre la lista de resultados y ve cuales no tuvieron error
				for (Database.Saveresult objDtSV : lDtSV)
				{
					if (objDtSV.isSuccess())
					mapIdCtesNuevo.put(iCntCtesNuevos, objDtSV.getId());
					iCntCtesNuevos++;
				}//Fin del for para la lista de lDtSV
				System.debug('@@@ Clientes Insertados mapIdCtesNuevo.values(): ' + mapIdCtesNuevo.values());
			}//Fin Insercion de Cuentas con un Database.insert

//////////////////////////////////////////////////  FIN GENERACION E INSERCION DE CLIENTES      /////////////////////////////////////

//////////////////////////////////////////////////   ASIGNACION DE REPARADORAS      /////////////////////////////////////
			//Realiza Asignacion a Reparadora de Ejecutivo de SC Premiun o no Premiun
			if (!mapCtesNuevosIns.isEmpty())
			{
				System.debug('@@ mapLeadSel.get(1).id ' + mapLeadSel.get(1).id);
				if(mapLeadMonto.containsKey(mapLeadSel.get(1).id))
				{
					// Verifica si TODAS las deudas del lead son del Banco Citibank para la asignacion a Ejecutivos de SC
					Boolean blTodasDeudasOppCitibank = false;
					List <DeudaOportunidad__c> lstDeudasOppCitibank = [Select d.Name,d.UltimoPago__c, d.PagoEstimadoBanco__c, d.OportunidadLead__c
					, d.NumeroCredito__c, d.Monto__c, d.LimitePago__c, d.FechaEstimadaLiquidacion__c, LimiteCredito__c
					, d.EntidadFinanciera__c
					From DeudaOportunidad__c d
					Where (d.EntidadFinanciera__c = 'CITIBANK' OR d.EntidadFinanciera__c ='Citibank')
					And OportunidadLead__c =: mapLeadSel.get(1).id];

					if(!lstDeudasOppCitibank.isEmpty())
					{
						if(lstDeudasOppCitibank.size() == mapLeadDeudas.get(mapLeadSel.get(1).Id).size())
							blTodasDeudasOppCitibank = true;
					}
					system.debug('@@@ Condicion 1 asignacion reparadora \n'+mapLeadMonto.get(mapLeadSel.get(1).id));
					system.debug('@@@ Condicion 2 asignacion reparadora \n'+mRHPrem);
					system.debug('@@@ Condicion 3 asignacion reparadora: '+ blTodasDeudasOppCitibank);
					system.debug('@@@ lstDeudasOppCitibank.size() : ' +   lstDeudasOppCitibank.size()
								  +  '  mapLeadDeudas.get(mapLeadSel.get(1).Id).size():  '+  mapLeadDeudas.get(mapLeadSel.get(1).Id).size());
					//Verifica si hay ejecutivo Premiun y No Premiun para asignacion, en caso de no haber, asigna Reparadora a usuario que ejecuta Cierre
					if(!mRHPrem.containsKey(false) && !mRHPrem.containsKey(true))
					{
						sIdEjecServCte =  UserInfo.getUserId();
						sIdEjecServCteRH = null;
					}
					// Verifica si el Monto de las Deudas de Oportunidad es de mas de 38 Millones ó
					// si todas las Deudas del Lead son del Banco Citibank  para asignar a ejecutivo Premiun
					System.debug('@@@ Lead Monto Deudas :' + mapLeadMonto.get(mapLeadSel.get(1).id));
					//JA 4-ene-2016  Se realiza ajuste en el calculo de las fechas para asegurar que cuando se requiera restar un mes a la fecha actual se tenga en cuenta cuando el mes es 1
					Date fechamesant   = Date.newInstance(Date.today().year(), Date.today().month()-1, 1);

					if((mapLeadMonto.get(mapLeadSel.get(1).id) >= 38000000.00 && mRHPrem.containsKey(true)) || 
						(blTodasDeudasOppCitibank && mRHPrem.containsKey(true)))
					{
						System.debug('@@@ Entro a Lead Monto Deudas > 38 millones Ejecutivo Premiun :' + mapLeadMonto.get(mapLeadSel.get(1).id));
						sIdEjecServCte = mRHPrem.get(true).get(0).Usuario__c;
						sIdEjecServCteRH = mRHPrem.get(true).get(0).id;
						//JH-25-Abr-2016: Edwin Garduño(Negociacion y SC) solicita que la asignacion sea modificada para que se tome el campo
						//				  Total_Clientes__c el cual actualizado una vez al mes por el batch SchRHCamposACero_sch

						if(mapLeadSel.get(1).FechaDeposito__c.month() == Date.today().month())
						{
								mRHPrem.get(true).get(0).Total_Clientes__c++;
						}

						//JH 4-Feb-2016: Edwin Garduño(Negociacion y SC) solicita que leads con fecha de deposito con mes anterior
						//				 se sumen a los leads de mes actual debido a que Allianz confirma saldos días despues
						//				 de la fecha de deposito y esto afecta la asignación de cliente a los ejecutivos de SC
						//JA 4-ene-2016  Se realiza ajuste en el calculo de las fechas para asegurar que cuando se requiera restar un mes a la fecha actual se tenga en cuenta cuando el mes es 1
						if ( mapLeadSel.get(1).FechaDeposito__c.month() == fechamesant.month())
						{
								system.debug('La fecha de deposito fue en el mes anterior . se sumara uno al total de clientes , mes a evaluar = ' + fechamesant.month());
								mRHPrem.get(true).get(0).Total_Clientes__c++;
						}
						//Agrega al usuario al mapa de mRHPremUpd para ser actualizado despues
						mRHPremUpd.put( mRHPrem.get(true).get(0).id, new RecursosHumanos__c(
										id = mRHPrem.get(true).get(0).id,
										Name = mRHPrem.get(true).get(0).Name
										,Total_Clientes__c = mRHPrem.get(true).get(0).Total_Clientes__c));
					}
					//Verifica si el Monto de las Deudas de Oportunidad es de mas de 38 Millones para asignar a ejecutivo NO Premiun
					else if(mRHPrem.containsKey(false))
					{
						System.debug('@@@ Entro a Lead Monto Deudas > 38 millones Ejecutivo NO Premiun :');
						sIdEjecServCte 		= mRHPrem.get(false).get(0).Usuario__c;
						sIdEjecServCteRH 	= mRHPrem.get(false).get(0).id;
						//JH-25-Abr-2016: Edwin Garduño(Negociacion y SC) solicita que la asignacion sea modificada para que se tome el campo
						//				  Total_Clientes__c el cual actualizado una vez al mes por el batch SchRHCamposACero_sch

						if(mapLeadSel.get(1).FechaDeposito__c.month() == Date.today().month())
						{
							System.debug('\n\n@@@ENTRA ACA---->\n\n');
							mRHPrem.get(false).get(0).Total_Clientes__c++;
						}
						
						System.debug('\n\n@@@mRHPrem----------> ' + mRHPrem + '\n\n');
						
						//Si la fecha de inicio del programa es el mes anterior se suma 1 a campo TotalClientesMesAnterior__c de RH
						//JH 4-Feb-2016: Edwin Garduño(Negociacion y SC) solicita que leads con fecha de deposito con mes anterior
						//				 se sumen a los leads de mes actual debido a que Allianz confirma saldos días despues
						//				 de la fecha de deposito y esto afecta la asignación de cliente a los ejecutivos de SC
						//JA 4-ene-2016  Se realiza ajuste en el calculo de las fechas para asegurar que cuando se requiera restar un mes a la fecha actual se tenga en cuenta cuando el mes es 1
						if ( mapLeadSel.get(1).FechaDeposito__c.month() == fechamesant.month())
						{
							system.debug('La fecha de deposito fue en el mes anterior . se sumara uno al total de clientes , mes a evaluar = ' + fechamesant.month());
							mRHPrem.get(false).get(0).Total_Clientes__c++;
						}
						//Agrega al usuario al mapa de mRHPremUpd para ser actualizado despues
						mRHPremUpd.put( mRHPrem.get(false).get(0).id, new RecursosHumanos__c(
										id = mRHPrem.get(false).get(0).id,
										Name = mRHPrem.get(false).get(0).Name
										,  Total_Clientes__c = mRHPrem.get(false).get(0).Total_Clientes__c));
					}
////////////////////////////////////////////////// FIN ASIGNACION DE REPARADORAS      /////////////////////////////////////

////////////////////////////////////////////////// CALCULO TotalDeudasActivas__c DE RH    /////////////////////////////////////
					// Se obtiene el Id del Negociador que va a ser asignado en el Reparadora
					// y se actualiza campo TotalDeudasActivas__c del Negociador con la cantidad de deudas oportunidad del lead
					if (!mRHNegAsig.isEmpty() )
					{
						for (RecursosHumanos__c objRh : mRHNegAsig.Values())
						{
							sIdNegAsig = objRh.id;
							if(objRh.TotalDeudasActivas__c != null)
								objRh.TotalDeudasActivas__c += mapLeadDeudas.get(mapLeadSel.get(1).Id).size();
							if(objRh.TotalDeudasActivas__c == null)
								objRh.TotalDeudasActivas__c = mapLeadDeudas.get(mapLeadSel.get(1).Id).size();
							if (mRHPremUpd.containsKey(objRh.id))
							    mRHPremUpd.get(objRh.id).TotalDeudasActivas__c = objRh.TotalDeudasActivas__c;
							if (!mRHPremUpd.containsKey(objRh.id))
							{
								mRHPremUpd.put(objRh.id,  new RecursosHumanos__c(
								id =  objRh.id,
								Name= objRh.Name
								, TotalDeudasActivas__c = objRh.TotalDeudasActivas__c));
							}//Fin si !mRHPremUpd.containsKey(objRh.id)
						}//Fin
					}// Fin si !mRHNegAsig.isEmpty()
					
					System.debug('\n\n@@@@MAPA--------> ' + mRHPremUpd + '\n\n');

////////////////////////////////////////////////// FIN CALCULO TotalDeudasActivas__c DE RH    /////////////////////////////////////

////////////////////////////////////////////////// GENERACION E INSERCION DE REPARADORAS    /////////////////////////////////////

					//Genera la reparadora de la cuenta creada anteriormente con su Negociador Asignado y su Ejecutivo de Servicio al Cliente
					lstRepNuevas.add(new Reparadora__c( Cliente__c = mapIdCtesNuevo.get(1)
									, CausaDejoPagar__c = mapLeadSel.get(1).CausaDejoPagar__c
									, Expediente__c =  'Indocumentado'
									, ApartadoMensual__c = mapLeadSel.get(1).CaratulaApartadoMensual__c
									, Referencia__c = mapLeadSel.get(1).Referencia__c
									, FechaInicioPrograma__c = mapLeadSel.get(1).FechaDeposito__c
									, Totalmontodepositadomesanterior__c = mapLeadSel.get(1).CaratulaApartadoMensual__c
									, Status__c = 'Activo'
									, DeudaInicialFija__c = mapLeadMonto.containsKey(mapLeadSel.get(1).id)
									    ? mapLeadMonto.get(mapLeadSel.get(1).id) : 0.00
									, VendedorAsignado__c = mapLeadSel.get(1).VendedorAsignado__c
									, NumeroReferenciador__c = !Test.isRunningTest()
									    ? mapLeadSel.get(1).RefRecomendado__c : '123456789'
									, OwnerId = sIdEjecServCte
                                    ,BeneficioEmpleado__c = mapLeadSel.get(1).BeneficioEmpleado__c  // JA 08-Feb-2017  se validará el BeneficioEmpleado para no crear mov de comision
									, EjecutivoAtencionClientes__c = !Test.isRunningTest() ? sIdEjecServCteRH : null
									, NegociadorAsignado__c = !Test.isRunningTest() ? sIdNegAsig : null
									, TotalDeudas__c = mapLeadMonto.containsKey(mapLeadSel.get(1).id)
									    ? mapLeadMonto.get(mapLeadSel.get(1).id) : 0.00
									, TotalDeudasActual__c = mapLeadMonto.containsKey(mapLeadSel.get(1).id)
									    ? mapLeadMonto.get(mapLeadSel.get(1).id) : 0.00
									, DiaDeposito__c = mapLeadSel.get(1).CaratulaDiaDeposito__c != null ?
                                    Decimal.valueOf(mapLeadSel.get(1).CaratulaDiaDeposito__c) : 0
                                    //04-04-2017 KC: Se llena el campo de tabla de repago con la Url de la oportunidad.
                                    //,URLTabla_Repago__c = mapLeadSel.get(1).URLTablaRepago__c
                                    ));
					//KC 04-04-2017: Se llena el mapa con el id del Lead y el id de la cuenta para reasignar el Id en el attachment
					mapCuentaRep.put(mapLeadSel.get(1).id, mapIdCtesNuevo.get(1));
					//strURLBase

				}//Fin si mapLeadMonto.containsKey(mapLeadSel.get(1).id)
			}//Fin Asignacion a Reparadora de Ejecutivo de SC Premiun o no Premiun

			//Inserta Reparadoras en BD
			if (!lstRepNuevas.isEmpty())
			{
				System.debug('@@@ lRepNuevas a insertar : ' + lstRepNuevas);
				//Reinicia
				iCntCtesNuevos = 1;
				RD_TriggerExecutionControl_cls.setAlreadyDone('TriggerReparadora');
				//Inserta las cuentas con un Database.insert(pLIST<SObject>, pBoolean)
				List<Database.Saveresult> lDtSV = Database.insert(lstRepNuevas, true);


				//Recorre la lista de resultados y ve cuales no tuvieron error
				for (Database.Saveresult objDtSV : lDtSV)
				{
					if (objDtSV.isSuccess())
					{
						mapIdRepNuevo.put(iCntCtesNuevos, objDtSV.getId());
						//KC 04-04-2017: Se llena el mapa con el id de la cuenta y el id de la reparadora para reasignar el Id en el attachment
						mapRepLead.put(mapIdCtesNuevo.get(1), mapIdRepNuevo.get(1));

					}
					iCntCtesNuevos++;
				}//Fin del for para la lista de lDtSV
				System.debug('@@ Cierre de Clientes Reparadoras insertadas mapIdRepNuevo: ' + mapIdRepNuevo);
				System.debug('@@ MapIdReparadora ' + mapIdRepNuevo.get(1));
				
				System.debug('\n\n@@@Final heap size: ' +  Limits.getHeapSize() + '\n' + 
					'@@@Limit------->' + Limits.getLimitHeapSize() + '\n\n');
				/*
				//KC 04-04-2017: Jira: RTD/Colombia: SC-570 - Duplica documentos del lead en la reparadora
				//Consulta los documentos que estan asociados a la oportunidad.
				List<Attachment> lstAttach = [select Id, SystemModstamp, ParentId, OwnerId, Name, LastModifiedDate, LastModifiedById, IsPrivate,
                      IsDeleted,  Description, CreatedDate, CreatedById, ContentType, BodyLength, Body from Attachment where ParentId =  :mLeadsAct.KeySet()];

				List<Attachment> attachments = new List<Attachment>();
				Reparadora__c updReparadora = new Reparadora__c (Id = mapIdRepNuevo.get(1));
                for(Attachment att : lstAttach)
                {
                	Attachment newAtt = att.clone();

                	if( mapCuentaRep.containsKey(att.ParentId) && mapCuentaRep.get(att.ParentId) != null
                		&& mapRepLead.containsKey(mapCuentaRep.get(att.ParentId)) && mapRepLead.get(mapCuentaRep.get(att.ParentId)) != null){
			            //KC: Asigna el id de la reparadora al archivo copiado de la oportunidad
			            newAtt.ParentId = mapRepLead.get(mapCuentaRep.get(att.ParentId));
			            String idAttach = '';

			            System.debug('idAttach---->' +idAttach);
			            //KC: compara el id del archivo conta la url del campo de la oportunidad para cambiar la descripcion asignando el nombre del campo
			            // para poderlo copiar al campo de la reparadora
			            if(mapLeadSel.get(1).CedulaURL__c != null)
			            {
			            	idAttach = mapLeadSel.get(1).CedulaURL__c.split('=')[1];
			            	if(idAttach == att.Id)
			            		newAtt.Description = 'CC Opp';
		            	}
		            	if(mapLeadSel.get(1).ComprobanteAtraso1URL__c != null)
			            {
			            	idAttach = mapLeadSel.get(1).ComprobanteAtraso1URL__c.split('=')[1];
			            	if(idAttach == att.Id)
			            		newAtt.Description = 'CA1 Opp';
		            	}

			            if(mapLeadSel.get(1).ComprobanteAtraso2URL__c != null)
			            {
			            	idAttach = mapLeadSel.get(1).ComprobanteAtraso2URL__c.split('=')[1];
			            	if(idAttach == att.Id)
			            		newAtt.Description = 'CA2 Opp';
		            	}
		            	if(mapLeadSel.get(1).ComprobanteAtraso3URL__c != null)
			            {
			            	idAttach = mapLeadSel.get(1).ComprobanteAtraso3URL__c.split('=')[1];
			            	if(idAttach == att.Id)
			            		newAtt.Description = 'CA3 Opp';
		            	}
		            	if(mapLeadSel.get(1).ComprobanteAtraso4URL__c != null)
			            {
			            	idAttach = mapLeadSel.get(1).ComprobanteAtraso4URL__c.split('=')[1];
			            	if(idAttach == att.Id)
			            		newAtt.Description = 'CA4 Opp';
		            	}
		            	if(mapLeadSel.get(1).ComprobanteAtraso5URL__c != null)
			            {
			            	idAttach = mapLeadSel.get(1).ComprobanteAtraso5URL__c.split('=')[1];
			            	if(idAttach == att.Id)
			            		newAtt.Description = 'CA5 Opp';
		            	}
		            	if(mapLeadSel.get(1).ReciboPublicoURL__c != null)
			            {
			            	idAttach = mapLeadSel.get(1).ReciboPublicoURL__c.split('=')[1];
			            	if(idAttach == att.Id)
			            		newAtt.Description = 'RP Opp';
		            	}
		            	if(mapLeadSel.get(1).ComprobanteAtraso6URL__c != null)
			            {
			            	idAttach = mapLeadSel.get(1).ComprobanteAtraso6URL__c.split('=')[1];
			            	if(idAttach == att.Id)
			            		newAtt.Description = 'CA6 Opp';
		            	}
		            	//Fin de comparar id del archivo


			        }
	                //Fin Duplica Documentos en la reparadora
			        attachments.add(newAtt);
			        System.debug('attachments-----> ' + attachments);
                }
                //KC: Crea los archivos en la reparadora.
                if(!attachments.isEmpty())
                	insert attachments;
                //KC 04-04-2017: Se asigna la url del archivo creado en el campo correspondiente de la reparadora.
                Boolean actualizarRepa = false;
                for(Attachment attach : attachments)
                {
                	if(attach.Description == 'CC Opp' )
		            {
		            	actualizarRepa = true;
		            	updReparadora.Cedula_URL__c						=  strURLBase+attach.Id;
		            }
		            if(attach.Description == 'CA1 Opp')
		            {
		            	actualizarRepa = true;
		            	updReparadora.URLComprobante_de_atraso_1__c  	= strURLBase+attach.Id;
		            }
		            if(attach.Description == 'CA2 Opp')
		            {
		            	actualizarRepa = true;
		            	updReparadora.URLComprobante_Atraso_2__c 			= strURLBase+attach.Id;
		            }
		            if( attach.Description == 'CA3 Opp')
		            {
		            	actualizarRepa = true;
		            	updReparadora.URL_Comprobante_de_Atraso_3__c		= strURLBase+attach.Id;
		            }
		            if(attach.Description == 'CA4 Opp')
		            {
		            	actualizarRepa = true;
		            	updReparadora.URLComprobante_de_Atraso_4__c 	= strURLBase+attach.Id;
		            }
		            if(attach.Description == 'CA5 Opp')
		            {
		            	actualizarRepa = true;
		            	updReparadora.URLComprobante_de_Atraso_5__c 		= strURLBase+attach.Id;
		            }
		            if(attach.Description == 'RP Opp')
		            {
		            	actualizarRepa = true;
		            	updReparadora.URLRecibo_Publico__c 				= strURLBase+attach.Id;
		            }
		            if(attach.Description == 'CA6 Opp')
		            {
		            	actualizarRepa = true;
		            	updReparadora.URLDeclaracion_de_Renta__c 		= strURLBase+attach.Id;
		            }

                }
                //FIn de valida la descripcion del archivo
                //KC 04-04-2017: Si entro a alguno de los campos de la reparadora, actualiza
                if(actualizarRepa)
                	update updReparadora;
				*/

				//Consulta las reparadoras para asignarles los nuevos movimientos
				for (Reparadora__c opbRep : [Select id, Negociadorasignado__c, Negociadorasignado__r.Usuario__c
						, FechaInicioPrograma__c, ApartadoMensual__c, Cliente__r.Oportunidad__r.MontoDepositado__c
						, Cliente__r.Oportunidad__r.AdeudoTotal__c,Referencia__c,ComisionMensual__c,BeneficioEmpleado__c
						From Reparadora__c Where id IN :mapIdRepNuevo.Values() ])
				{

                    system.debug('\n\n reparadora encontrada  '   + opbRep + '  \n\n Comision mensual ' + opbRep.ComisionMensual__c);
                    //Metela a la lista de mRepNuevasCons
					mRepNuevasCons.put(opbRep.id, opbRep);


					//Crea el movimiento de Tipo "Apartado Mensual" asociado a la reparadora
					lstMovNuevos.add( new Movimientos__c ( Reparadora__c = opbRep.id
							, Fecha__c = opbRep.FechaInicioPrograma__c
							, Tipo_de_movimiento__c = 'Apartado Mensual'
							, Monto__c = opbRep.Cliente__r.Oportunidad__r.MontoDepositado__c != null
							    ? opbRep.Cliente__r.Oportunidad__r.MontoDepositado__c : 0.00
							));
					//Crea el movimiento de Tipo "Comision Mensual" asociado a la reparadora
					//MP - 18/07/2016 - Se agrega validación (fecha de inicio en el programa) para calcular el valor del campo monto.
					//JA 08-Feb-2017 Crea el ingreso y  movimiento de Comision mensual solo si no esta marcado con el beneficio empleado
                    if(opbRep.BeneficioEmpleado__c == false)
                    {
                       // JA 08-Feb-2017 Crea los ingresos de Tipo "Mensualidad Colombia" asociado a la reparadora
                       lstIngrNuevo.add( new Ingresos__c ( Reparadora__c = opbRep.id
							,TipoIngreso__c = 'Mensualidad Colombia'
                            ,Monto__c = opbRep.ComisionMensual__c
                            ,FechaFacturacion__c = opbRep.FechaInicioPrograma__c
                            ,Status__c = 'Por Cobrar'
                             ));
                       system.debug('Ingresos_a_crear    ' +  lstIngrNuevo);

                       //Creación de movimientos de tipo comision mensual
                        lstMovNuevos.add( new Movimientos__c ( Reparadora__c = opbRep.id
							, Fecha__c = opbRep.FechaInicioPrograma__c
							, Tipo_de_movimiento__c = 'Comision Mensual'
							, Monto__c = opbRep.Cliente__r.Oportunidad__r.AdeudoTotal__c != null && opbRep.FechaInicioPrograma__c >= Date.newInstance(2015,07,01)
							    ? (opbRep.Cliente__r.Oportunidad__r.AdeudoTotal__c * 0.006)*-1 : (opbRep.Cliente__r.Oportunidad__r.AdeudoTotal__c * 0.0055)*-1//0.00
							));
                    }

					strIdReparadora = opbRep.id;
				}//Fin del for para la lista de reg de la reparadora
			}//Fin si !lstRepNuevas.isEmpty()

////////////////////////////////////////////////// FIN GENERACION E INSERCION DE REPARADORAS    /////////////////////////////////////

//////////////////////////////////////////////////   ACTUALIZACION DE RH Y GENERACION DEUDAS      /////////////////////////////////////
			if (!mapIdRepNuevo.isEmpty())
			{
				//Actualiza RH (Ejecutivos de SC y Negociador de duedas)
				if (!mRHPremUpd.isEmpty())
				{
					System.debug('@@@Cierre de Clientes RH a Actualizar mRHPremUpd.values(): ' + mRHPremUpd.values());
					RD_TriggerExecutionControl_cls.setAlreadyDone('TriggerRecursosHumanos');
					update mRHPremUpd.values();
				}

				System.debug('\n\n@@@@mRHPremUpd--------> ' + mRHPremUpd + '\n\n');

				//Generacion de Deudas
				//Crea las Deudas apartir de mapLeadMonto y del mapa de mapLeadDeudas
				for (String sIdOppD : mapLeadDeudas.KeySet() )
				{
					for (DeudaOportunidad__c objDeudaOppPaso : mapLeadDeudas.get( sIdOppD ) )
					{
						//JH 9-Ago2016: Se agrega campo copiado de campo Nro_Referencia__c de la Reparadora
						//				en campo texto para guardar respaldo de Nro de Referencia cuando se
						//				desvincula una deuda de la reparadora
						lstLeadDeudasIns.add(new Deudas__c( RTD__c = mapIdRepNuevo.get(1)
							, Nro_Referencia__c = mRepNuevasCons.get(mapIdRepNuevo.get(1)).Referencia__c
							, NumerodeTarjeta__c = '\''+String.valueOf(objDeudaOppPaso.NumeroCredito__c)
							, DeudaRESUELVE__c = objDeudaOppPaso.Monto__c
							, FechadeUltimoPago__c = objDeudaOppPaso.UltimoPago__c
							, Banco__c = objDeudaOppPaso.EntidadFinanciera__c
							, LimiteCredito__c = objDeudaOppPaso.LimiteCredito__c
							, EstadodelaDeuda__c = 'Negociaciones Preliminares'
							, PagoEstimadoalBanco__c = objDeudaOppPaso.PagoEstimadoBanco__c
							, FechaEstimadadeLiquidacion__c  = objDeudaOppPaso.FechaEstimadaLiquidacion__c
							, MaximoDescuentoOfrecido__c = 0.00
							, TipoProducto__c = objDeudaOppPaso.TipoProducto__c
							, SucursalDeAperturaDeObligacion__c = objDeudaOppPaso.SucursalDeAperturaDeObligacion__c  //AM  18-Jul-2016 agregó campo
							, MontoDeUltimoPago__c = objDeudaOppPaso.MontoDeUltimoPago__c							 //AM  18-Jul-2016 agregó campo
							, OwnerId = mRepNuevasCons.containsKey(mapIdRepNuevo.get(1))
									?  mRepNuevasCons.get(mapIdRepNuevo.get(1)).Negociadorasignado__r.Usuario__c
									: UserInfo.getUserId()
							, NegociadorAsignado__c = mRepNuevasCons.containsKey(mapIdRepNuevo.get(1))
									?  mRepNuevasCons.get(mapIdRepNuevo.get(1)).Negociadorasignado__c
									: UserInfo.getUserId()
								));
					}//Fin del for para
				}//Fin si mapOppMonto.containsKey(mapOppSel.get(iCnt))
			}//Fin si !mapIdRepNuevo.isEmpty() Actualizacion RH y Generacion de Deudas
			
			System.debug('\n\n@@@@lstLeadDeudasIns--------> ' + lstLeadDeudasIns + '\n\n');

////////////////////////////////////////////////// FIN ACTUALIZACION DE RH Y GENERACION DEUDAS      /////////////////////////////////////

////////////////////////////////////////////////// INSERCION DE MOVIMIENTOS,DEUDAS      /////////////////////////////////////

			//// JA 08-Feb-2017  Inserta los movimientos asociados a la reparadora creada
			if (!lstIngrNuevo.isEmpty())
			{
				System.debug('Ingresos_creados: ' + lstIngrNuevo);
				if (!Test.isRunningTest())
					insert lstIngrNuevo;
			}// Fin si !lstIngrNuevo.isEmpty()

            //Inserta los movimientos asociados a la reparadora creada
			if (!lstMovNuevos.isEmpty())
			{
				System.debug('@@@Cierre de Cliente MovsNuevos lstMovNuevos: ' + lstMovNuevos);
				//RD_TriggerExecutionControl_cls.setAlreadyDone('TriggerMovimientos');
				if (!Test.isRunningTest())
					insert lstMovNuevos;
			}// Fin si !lstMovNuevos.isEmpty()

			//Inserta deudas generadas
			if (!lstLeadDeudasIns.isEmpty())
			{
				System.debug('@@@Cierre de Cliente Deudas nuevas lOppDeudasIns: ' + lstLeadDeudasIns);
			    //RD_TriggerExecutionControl_cls.setAlreadyDone('TriggerDeuda');
			    if (!Test.isRunningTest())
			        insert lstLeadDeudasIns;
			}//Fin si !lstLeadDeudasIns.isEmpty()

////////////////////////////////////////////////// FIN INSERCION DE MOVIMIENTOS,DEUDAS      /////////////////////////////////////

////////////////////////////////////////////////// ACTUALIZACION DE LEADS CAMPO ClienteCerrado__c = true  /////////////////////////////////////

			//Finalmente actualiza los leads que cumplieron con la condición
			for (String sIdOpp : mLeadsAct.KeySet())
			{
				lstLeadUpd.add(new Lead( id = sIdOpp, ClienteCerrado__c = true ));
			}//Fin del for para las opp del mapa de mCtesAct

			if (!lstLeadUpd.isEmpty())
			{
				System.debug('@@@Cierre de Cliente Leads Actualizar ClienteCerrado__c = true lstLeadUpd: ' + lstLeadUpd);
				//RD_TriggerExecutionControl_cls.setAlreadyDone('TriggerLead_trg');
				if (!Test.isRunningTest())
					update lstLeadUpd;
			}//Fin si !lstLeadUpd.isEmpty()
			/*
			List<ContratoDigital__c> lstContratosDigitales = new List<ContratoDigital__c>();

			
			//MP - 11/01/2017 - Se pobla el campo "Reparadora" en el Contrato Digital al ejecutarse el cierre de clientes.
			for(ContratoDigital__c objContratoDig : [SELECT Id, Reparadora__c, CandidatoId__c FROM ContratoDigital__c WHERE CandidatoId__c IN :lstLeadUpd])
			{
				objContratoDig.Reparadora__c = strIdReparadora;
				lstContratosDigitales.add(objContratoDig);
			}
			
			if(!lstContratosDigitales.isEmpty())
				update lstContratosDigitales;
			//MP - 11/01/2017 - END
			*/
			
			System.debug('\n\n@@@Name------> ' + mRHPremUpd.get(sIdNegAsig).Name + '\n\n');
			
			String strErrorRegistro = '"'+intConsecutivo+'","'+lstLeadsScope[0].Id+'","'+mRHPremUpd.get(sIdEjecServCteRH).Name
			+'","'+mRHPremUpd.get(sIdEjecServCteRH).Total_Clientes__c
			+'","'+mRHPremUpd.get(sIdNegAsig).Name
			+'","'+mRHPremUpd.get(sIdNegAsig).TotalDeudasActivas__c+'","'
			+'Lead Cerrado Correctamente'+'"\n';
			strError+= strErrorRegistro;
			
			System.debug('\n\n@@@@strError------> ' + strError + '\n\n');
			
////////////////////////////////////////////////// FIN ACTUALIZACION DE LEADS CAMPO ClienteCerrado__c = true  /////////////////////////////////////
		}
		catch(Exception ex)
		{
			System.debug( '\n\n\t<<<<<<<<< CalloutExceptionType >>>>>>>>> \n\t\t@@--> getCause > ' + ex.getCause() + '\n\t\t@@--> getLineNumber > ' + ex.getLineNumber() + '\n\t\t@@--> getMessage > '+ ex.getMessage() + '\n\t\t@@--> getStackTraceString > '+ ex.getStackTraceString() + '\n\t\t@@--> getTypeName > ' + ex.getTypeName() + '\n\n' );
			System.debug(intConsecutivo + ' Error en Batch Cierre de Clientes ' + ex.getMessage() + ' Registro que genero error: \n'+ lstLeadsScope +'\n');
			String strErrorRegistro = '"'+intConsecutivo+'","'+lstLeadsScope[0].Id+'",,,,,"'+ex.getMessage()+'"\n';
			strError+= strErrorRegistro;
			Database.rollback(svP);
		}

		intConsecutivo++;
	}
	global void finish(Database.BatchableContext BC)
	{
		System.debug('::::Ingreso a Metodo Finish Cierre de clientes::::');
		Notificacion_Trabajos_Programados__c config = Notificacion_Trabajos_Programados__c.getInstance( 'BchCierreClientes_bch' );
		Datetime dtFechaHoraActual = Datetime.now();
		String strFechaHoraActual = dtFechaHoraActual.format('dd/MM/yyyy HH:mm:ss');
		Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
		blob csvBlob = Blob.valueOf(strError);
		String csvname= 'InformeCierreClientesRTDColombia' + dtFechaHoraActual.format('dd_MM_yyyy_HH_mm_ss') +'.csv';
		csvAttc.setFileName(csvname);
		csvAttc.setBody(csvBlob);
		Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
		String strCorreos = config.Correo_Notificacion__c;
		String[] toAddresses = strCorreos.split(',');
		toAddresses.add(UserInfo.getUserEmail());
		mail.setToAddresses(toAddresses);
		mail.setSubject(config.Asunto_Correo_Notificacion__c + ' ' + strFechaHoraActual);
		mail.setPlainTextBody('INFORME BATCH CIERRE DE CLIENTES RTD COLOMBIA \n\n'
		+'Fecha Hora de Ejecución: ' + strFechaHoraActual +'\n\n'
		+'Usuario que ejecuto el Batch: ' + UserInfo.getName() + ' ID: ' + UserInfo.getUserId()  +'\n\n'
		+ 'Por favor revisar el archivo adjunto');
		mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
		if (!Test.isRunningTest() )
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		System.debug('::::Termino Cierre de clientes::::');
	}

}