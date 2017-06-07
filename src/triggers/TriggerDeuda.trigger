/********************************************************************************************************
Desarrollado por:   Resuelve
Autor:              Angela Munévar(AM)
Proyecto:           Resuelve tu Deuda
Descripción:        Trigger que controla los eventos del objeto Deudas

Cambios (Versiones)
--------------------------------------------------------------------------------------------------------
    No.     Fecha               Autor                       Descripción
    ---     -----------         ------------------------    --------------------------      
    1.0     17-Abr-2016         Angela Munévar(AM)          Creación de la Clase 
    1.1     25-Ago-2016         Marwin Pineda (MP)          Ajuste para calcular la sumatoria del importe de deudas y la cantidad de deudas bonificadas 
    1.2     21-Nov-2016         Esteban Heredia (EH)        Ajuste ocultar sección Trámite post pago (Tipo de registro) y colocar correos electrónicos 
    1.3     16-Ene-2016         Joe Ayala (JA)        		Se adiciona campo Porcentaje_de_IVA_Actual__c para controlar el porcentaje del calculo de IVA de la deuda 
    														basado en un rango de tiempo definido en una conf personalizada a partir de la fecha de liquidación,
	               											en caso de no tenerla se calculará con la fecha del dia en que crea o modifica y cada ves que se actualice evaluará estas condiciones. 
***************************************************************************************/
trigger TriggerDeuda on Deudas__c (before insert, before update, after insert, after update ) 
{
	public Boolean blnExecuteTrigger = true;    

    if( Trigger.isUpdate || Trigger.isInsert) 
       blnExecuteTrigger = !RD_TriggerExecutionControl_cls.hasAlreadyDone('TriggerDeuda');

    if(blnExecuteTrigger)
    { 
	    if (Trigger.isBefore)
	    {  
	        Id DeudaNegociacionFlujosRT = Schema.SObjectType.Deudas__c.getRecordTypeInfosByName().get('Deuda Negociación con Flujos').getRecordTypeId();
	        Id DeudaTramitePostPagoRT = Schema.SObjectType.Deudas__c.getRecordTypeInfosByName().get('Deuda Tramite Post - Pago').getRecordTypeId();
	
	        if (Trigger.isInsert || Trigger.isUpdate)
	        {
	            Set<Id> setIdReparadoras = new Set<Id>();
	            for (Deudas__c objDeuda : Trigger.new)
	            {
	                setIdReparadoras.add(objDeuda.RTD__c);
	            }
	
	            Map<Id, Reparadora__c> mapRepById = new Map<Id, Reparadora__c>([select Id,Cliente__r.PersonEmail,Cliente__r.Correo_electronico2__c from Reparadora__c where id in :setIdReparadoras]);
	
	            //JA 16-Ene-2017 Llamado al Metodo getlistValorActual el cual actualiza los valores de porcentaje de IVA para las Deudas basado en la fecha de liquidación ,
                //               en caso de ser null se calculará con la fecha del dia en que crea o modifica y cada ves que se actualice evaluará estas condiciones. 
                list<Deudas__c> lstdeudas= new list<Deudas__c>();
                lstdeudas = ConsultaVariablesPeriodicas.getlistValorActual('IVA','FechadeLiquidacion__c','TODAY',Trigger.new,'Porcentaje_de_IVA_Actual__c');           
                system.debug('\n\n lstdeudas_antes de actualizar   ' + lstdeudas);
                for (Deudas__c objDeuda : Trigger.new)	
                {
                     //Recorro los datos de la respuesta del método getlistValorActual para actualizar los valores en el trigger
                    for(Deudas__c Deudaactualizada : lstdeudas)
                    {
                        objDeuda =  Deudaactualizada;                    
                    }
                }
                
                for (Deudas__c objDeuda : Trigger.new)
	            {
	                
	                String EstadoDeuda = '';
	                // TotalaPagar__c
	                system.debug('\n Monto Liquidacion \n'+objDeuda.MontodeLiquidacion__c);
	                if (objDeuda.MontodeLiquidacion__c != null)
	                {
	                    objDeuda.TotalaPagar__c = 
	                                            (objDeuda.MontodeLiquidacion__c == 0)  // si monto de liquieación = 0 
	                                              ? (objDeuda.MontoLiqBanco__c != null ? objDeuda.MontoLiqBanco__c : 0) 
	                                              + (objDeuda.ComisionRESUELVE__c != null  ? objDeuda.ComisionRESUELVE__c : 0) 
	                                              + (objDeuda.IVA__c != null ? objDeuda.IVA__c : 0) 
	                                            : (objDeuda.MontodeLiquidacion__c != null ? objDeuda.MontodeLiquidacion__c : 0) 
	                                                + (objDeuda.ComisionRESUELVE__c != null ? objDeuda.ComisionRESUELVE__c : 0) 
	                                                + (objDeuda.IVA__c != null ? objDeuda.IVA__c : 0);
	                    system.debug('\n Objeto deuda \n'+objDeuda);
	
	                }  
	
	                //EstadodelaDeuda__c
	               /* EstadoDeuda = 
	                      objDeuda.LiquidadaFueraPrograma__c ? 'Liquidada Fuera del Programa'
	                    : objDeuda.FechadeLiquidacion__c == null ? (objDeuda.MontodeLiquidacion__c == 1 ? 'Fuera del Programa' 
	                                                                  : objDeuda.MontodeLiquidacion__c > 0? 'En Tramite de Liquidacion' 
	                                                                  : objDeuda.MaximoDescuentoOfrecido__c == 0 ? 'Negociaciones Preliminares' 
	                                                                  : objDeuda.MaximoDescuentoOfrecido__c < 0.41 ? 'En Negociacion' 
	                                                                  : objDeuda.SaldoEnCuenta__c > objDeuda.TotalaPagar__c ? 'Finalizando Negociacion' // APMD 14/04/2016 en espera respuesta
	                                                                  : 'En espera de Fondos')
	                    : 'Liquidada';
	
	                objDeuda.EstadodelaDeuda__c = EstadoDeuda;
	                
	                */
	                
	                // tipo de Registro
	                system.debug('+++EstadoDeuda '+objDeuda.EstadodelaDeuda__c); 
	                system.debug('+++StatusdelTramite__c '+objDeuda.StatusdelTramite__c);  
	                system.debug('+++MontodeLiquidacion__c '+objDeuda.MontodeLiquidacion__c);  
	                system.debug('+++FondeosRealizadosEstaDeuda__c '+ objDeuda.FondeosRealizadosEstaDeuda__c);
	                if(objDeuda.StatusdelTramite__c != null)
	                {
	                    if(objDeuda.EstadodelaDeuda__c == 'En Trámite de Liquidación' )
	                    {
	                        if(objDeuda.StatusdelTramite__c == 'Convenio Confirmado por el Banco'       
	                            && (objDeuda.FondeosRealizadosEstaDeuda__c == 0 || objDeuda.FondeosRealizadosEstaDeuda__c == null))
	                        {
	                            system.debug('+++entro al primer if');
	                            objDeuda.RecordTypeId = DeudaNegociacionFlujosRT;
	                        }
	                        // AM 18-Jun-2016 Ajuste para Pagos estructurados
	                        else 
	                            if(objDeuda.StatusdelTramite__c.contains('Pagos Estructurados'))
	                            {
	                                system.debug('+++entro al segundo if');
	                                objDeuda.RecordTypeId = DeudaNegociacionFlujosRT;
	                            }
	                    }
	                    /*if(objDeuda.MontodeLiquidacion__c >0 && (objDeuda.StatusdelTramite__c == 'Convenio Confirmado por el Banco'|| objDeuda.StatusdelTramite__c == 'Fondos Depositados en Cuenta del Cliente') 
	                        && objDeuda.EstadodelaDeuda__c == 'Liquidada')
	                    {
	                        system.debug('+++entro al tercer if');
	                        objDeuda.RecordTypeId = DeudaTramitePostPagoRT;
	                    }*/
	                    // EH 24-Nov-2016 Cambio tipo de registro y llenado campos correo electrónico cliente para enviar correos regla de flujo de trabajo de proyecto postpago
	                    if( Trigger.isUpdate 
	                        &&  (Trigger.oldMap.get(objDeuda.Id).MontodeLiquidacion__c <= 0 || Trigger.oldMap.get(objDeuda.Id).FechadeLiquidacion__c == null || Trigger.oldMap.get(objDeuda.Id).EstadodelaDeuda__c != 'Liquidada') 
	                        && objDeuda.MontodeLiquidacion__c >0 && objDeuda.FechadeLiquidacion__c != null 
	                        && objDeuda.EstadodelaDeuda__c == 'Liquidada')
	                    {
	                        system.debug('+++entro al tercer if');
	                        objDeuda.RecordTypeId = DeudaTramitePostPagoRT;
	                        if(mapRepById.containsKey(objDeuda.RTD__c))
	                            objDeuda.CorreoElectronicoCliente__c = mapRepById.get(objDeuda.RTD__c).Cliente__r.PersonEmail;
	                        if(mapRepById.containsKey(objDeuda.RTD__c))
	                            objDeuda.CorreoElectronicoAlterno__c = mapRepById.get(objDeuda.RTD__c).Cliente__r.Correo_electronico2__c;
	                    }
	                    // EH 29-Nov-2016: Colocar el check para enviar correo por los comprobantes de liquidación
	                    if(Trigger.isUpdate 
	                        && (Trigger.oldMap.get(objDeuda.Id).ComprobanteLiquidacion2__c != objDeuda.ComprobanteLiquidacion2__c || Trigger.oldMap.get(objDeuda.Id).ComprobanteLiquidacion3__c != objDeuda.ComprobanteLiquidacion3__c
	                            || Trigger.oldMap.get(objDeuda.Id).ComprobanteLiquidacion4__c != objDeuda.ComprobanteLiquidacion4__c || Trigger.oldMap.get(objDeuda.Id).ComprobanteLiquidacion5__c != objDeuda.ComprobanteLiquidacion5__c
	                            || Trigger.oldMap.get(objDeuda.Id).ComprobanteLiquidacion6__c != objDeuda.ComprobanteLiquidacion6__c || Trigger.oldMap.get(objDeuda.Id).ComprobanteLiquidacion7__c != objDeuda.ComprobanteLiquidacion7__c
	                            || Trigger.oldMap.get(objDeuda.Id).ComprobanteLiquidacion8__c != objDeuda.ComprobanteLiquidacion8__c))
	                    {
	                        objDeuda.ComprobanteLiquidacionCorreo__c = true;
	                    }
	                }
	            }
	
	        }
	    }
	    
	    /**
	     *@author:      Marwin Pineda (MP)
	     *@date:        25/08/2016
	     *@Description: Llamado a clase auxiliar en donde se hacen los cálculos para poblar los siguientes campos en la Reparadora
	     *              (Total Importe Bonificado en Deudas, Deudas Bonificadas, Deudas Liquidadas, Fecha de Última Liquidación, Número de Deudas).
	     */
	    
	    if(Trigger.isAfter)
	    {
	        if(Trigger.isInsert || Trigger.isUpdate)
	        {
	            AuxiliarTriggerDeuda_cls.handlerAfter(Trigger.new);            
	        }
	    }
	}
}