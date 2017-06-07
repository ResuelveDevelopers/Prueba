/*************************************************************************************
Desarrollado por:   Resuelve
Autor:              Angela Munévar(AM)
Proyecto:           Resuelve tu Deuda
Descripción:        Triger de objeto  ActividaddeNegociacion__c

Cambios (Versiones)
-------------------------------------
    No.     Fecha               Autor                       Descripción
    ---     -----------         ------------------------    --------------------------      
    1.0     14-Abr-2016         Angela Munévar(AM)          Creación de la Clase
    1.1		22-Ago-2016			Jeisson Hernandez (JH) 		Calculo de campos Saldo_Actual__c, UltimodescuentoOfrecido__c y UltimoMontodeLiquidacion__c de la Deuda
    														Calculo de campo de la Reparadora Dias desde Ultima Act. Negociación (API: Dias_desde_Ultima_Act_Negociacion__c)
    														Deprecada seccion de calculo de campo de Maximo descuento ofrecido debido a que se implemento Maestro-Detalle con deuda
    														para el objeto de actividades de negociacion
***************************************************************************************/
trigger TriggerActividadesNegociacion on ActividaddeNegociacion__c (before insert, after insert, after update, after delete) 
{
	if(Trigger.isAfter)
	{		
		//Si se trata de insert o update
		if(Trigger.isInsert || Trigger.isUpdate)
		{
			Set<ID> sActNegIdDeuda = new set<ID>();
			Map<ID, ActividaddeNegociacion__c > mapActNeg = Trigger.newMap;
			Map<ID, Deudas__c> mDeudasUpd = new Map<ID, Deudas__c>();
			Map<ID, Reparadora__c> mapReparadoras = new Map<ID, Reparadora__c>();
			Map<Id, Deudas__c> mapDeudasActNeg;
			Map<Id, Deudas__c> mapDeudasActualizar = new Map<Id, Deudas__c>(); 
			Date dtFechaHoy = Date.today();
			
			//Llenado de Set de Ids de Deudas de las Actividades de Negociacion
			for (ID idDeuda : mapActNeg.keySet())
			{
				if (mapActNeg.get(idDeuda).Deuda__c != null)
				{
				   sActNegIdDeuda.add(mapActNeg.get(idDeuda).Deuda__c);
				}
			}//Fin del for para las suc

			if (!sActNegIdDeuda.isEmpty())
			{
				system.debug('+++ sActNegIdDeuda '+sActNegIdDeuda);
				//JH 22-Ago-2016: Consulta de Deudas con 1ra Actividad de Negociacion Creada
				mapDeudasActNeg = new Map<Id, Deudas__c> ([SELECT Id,Name,
																(Select Id,
																		Name,
																		Deuda__c,
																		CreatedDate,
																		MontodeLiquidacion__c,
																		SaldoActual__c,
																		DescuentoOfrecidoalaFecha__c 
																From Actividades_de_Negociaci_n__r 
																Order By CreatedDate DESC Limit 1)  
									FROM Deudas__c Where Id IN :sActNegIdDeuda]);
				
				// JH 22-Ago-2016: Calculo de campos Saldo_Actual__c, UltimodescuentoOfrecido__c y UltimoMontodeLiquidacion__c de la Deuda
				for(Deudas__c objDeuda : mapDeudasActNeg.values())
				{
					for(ActividaddeNegociacion__c objActividad : objDeuda.Actividades_de_Negociaci_n__r)
					{
						if(!mapDeudasActualizar.containsKey(objActividad.Deuda__c))
							mapDeudasActualizar.put(objActividad.Deuda__c, new Deudas__c(Id = objActividad.Deuda__c, 
							Saldo_Actual__c = objActividad.SaldoActual__c,UltimodescuentoOfrecido__c =  objActividad.DescuentoOfrecidoalaFecha__c,
							UltimoMontodeLiquidacion__c = objActividad.MontodeLiquidacion__c));
					}
				}
				
				//JH 22-Ago-2016: Calculo de campo de la Reparadora Dias desde Ultima Act. Negociación (API: Dias_desde_Ultima_Act_Negociacion__c)     
				for(AggregateResult objActNeg : [Select Deuda__r.RTD__c, MAX(CreatedDate) FechaUltActNeg 
								From ActividaddeNegociacion__c  
								Where Deuda__c IN :sActNegIdDeuda
								group By Deuda__r.RTD__c])
				{
					if ( String.valueOf(objActNeg.get('RTD__c')) != null)
					{
						String strIdReparadora = String.valueOf(objActNeg.get('RTD__c'));
						DateTime dttFechaUltActNeg = (DateTime)(objActNeg.get('FechaUltActNeg'));
						Date dtFechaUltActNeg = dttFechaUltActNeg.date();
						if (mapReparadoras.containsKey( strIdReparadora ))
							mapReparadoras.get( strIdReparadora ).Dias_desde_Ultima_Act_Negociacion__c = dtFechaUltActNeg.daysBetween(dtFechaHoy);
						if (!mapReparadoras.containsKey( strIdReparadora ))
						mapReparadoras.put( strIdReparadora, new Reparadora__c(id = strIdReparadora, Dias_desde_Ultima_Act_Negociacion__c = dtFechaUltActNeg.daysBetween(dtFechaHoy) ));
					}//Fin si tiene RTD != null
				}//Fin del for de AggregateResult

				//JH 22-Ago-2016: Actualizacion de Reparadoras
				if (!mapReparadoras.isEmpty())
				{
					//Verifica si hay reparadoras para actualizar
					if (mapReparadoras.values() != null)
					{
						if (!Test.isRunningTest())
						{
							RD_TriggerExecutionControl_cls.setAlreadyDone('TriggerReparadora');                        	                  
							update mapReparadoras.values();
						}
					}
				}//Fin si tiene algo mapReparadoras
			
				//JH 22-Ago-2016: Ve si tiene algo mapDeudasActualizar
				if (!mapDeudasActualizar.isEmpty())
				{
					//Ve si tiene deudas y actualizalas
					if (mapDeudasActualizar.values() != null)
					{
						if (!Test.isRunningTest())
						{
							RD_TriggerExecutionControl_cls.setAlreadyDone('TriggerDeuda');
							update mapDeudasActualizar.values();
						}
					}
				}
			}
		}
	}
}