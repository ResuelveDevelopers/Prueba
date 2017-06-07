/*****************************************************************************************************************************************
Desarrollado por:   Resuelve
Autor:              Angela Munévar(AM)
Proyecto:           Resuelve tu Deuda
Descripción:        Trigger que controla los eventos del objeto Flujos

Cambios (Versiones)
--------------------------------------------------------------------------------------------------------
    No.     Fecha               Autor                       Descripción
    ---     -----------         ------------------------    --------------------------      
    1.0     18-Abr-2016         Angela Munévar(AM)          Creación de la Clase 
    1.3     16-Ene-2016         Joe Ayala (JA)        		Se adiciona campo Porcentaje_de_IVA_Actual__c para controlar el porcentaje del calculo de IVA de los flujos 
    														basado en un rango de tiempo definido en una conf personalizada a partir de la fecha de Facturación,
	               											en caso de no tenerla se calculará con la fecha del dia en que crea o modifica y cada ves que se actualice evaluará estas condiciones.
******************************************************************************************************************************************/
trigger TriggerFlujo on Flujo__c (before insert, before update, after delete, after insert, after update) 
{
    

    if (Trigger.isBefore)
    {
        if (Trigger.isInsert || Trigger.isUpdate)
        {
            Set<ID> sIdDeudas = new Set<ID>();  // deudas a las que estan asociados los flujos
            Map<ID, Deudas__c> mDeudasFlujos = new Map<ID, Deudas__c>();  // deudas asociadas a los flujos
            List<Ingresos__c> lstIngresos = new List<Ingresos__c>();
            List<Movimientos__c> lstMovimientos = new list<Movimientos__c>();
            
            //JA 16-Ene-2017 Llamado al Metodo getlistValorActual el cual actualiza los valores de porcentaje de IVA para los flujos basado en la fecha de Facturación ,
	        //               en caso de ser null se calculará con la fecha del dia en que crea o modifica y cada ves que se actualice evaluará estas condiciones. 
            list<Flujo__c> lstflujo= new list<Flujo__c>();
            lstflujo = ConsultaVariablesPeriodicas.getlistValorActual('IVA','FechaFacturacion__c','TODAY',Trigger.new,'Porcentaje_de_IVA_Actual__c');           
            system.debug('\n\n lstflujo_antes de actualizar   ' + lstflujo);
            for (Flujo__c objFlujo : Trigger.new)	
            {
                 //Recorro los datos de la respuesta del método getlistValorActual para actualizar los valores en el trigger
                for(Flujo__c Flujoactualizado : lstflujo)
                {
                    objFlujo =  Flujoactualizado;                    
                }
            }
            
            //Recorre la lista y toma las deudas
            for (Flujo__c objFlujo : Trigger.new)	
            {
                if (objFlujo.Deuda__c != null)
                    sIdDeudas.add(objFlujo.Deuda__c);
            }
            

            //Consulta las deudas asociadas a los flujos
            if(!sIdDeudas.isEmpty())
            {
                for (Deudas__c objDeuda : [Select d.id, d.DeudaRESUELVE__c, d.MontoLiqBanco__c
                                            ,d.EstadodelaDeuda__c, d.StatusdelTramite__c, d.FechadeLiquidacion__c
                                            ,d.RTD__r.BeneficioEmpleado__c, d.RTD__c, d.ComisionRESUELVE__c 
                                            ,d.NumerodeTarjeta__c, d.NegociadorAsignado__c
                    From Deudas__c d  Where d.id IN :sIdDeudas])
                {
                    if (!mDeudasFlujos.containsKey(objDeuda.id))
                        mDeudasFlujos.put(objDeuda.id, objDeuda);
                }
            }
            
            //Consulta las deudas asociadas a los flujos y datos del cliente
            System.debug('ANTES DE CONSULTAR DATOS: ' + Trigger.new.get(0));
            
            //Recorre la lista de reg que se van a actualizar
            for (Flujo__c objFlujo : Trigger.new)
            {
                if(!mDeudasFlujos.isEmpty())
                {
                //Deuda total a pagar 
                    objFlujo.Deudatotalapagar__c = mDeudasFlujos.containsKey(objFlujo.Deuda__c)
                        ? mDeudasFlujos.get(objFlujo.Deuda__c).DeudaRESUELVE__c : 0.00;  
                        system.debug('+++ mDeudasFlujos '+mDeudasFlujos);
                        system.debug('+++ StatusFlujo__c '+objFlujo.StatusFlujo__c);
                        
                        //system.debug('+++ EstadodelaDeuda__c '+mDeudasFlujos.get(objFlujo.Deuda__c).EstadodelaDeuda__c);
                    // AM 19-Jul-2016  ajuste creación movimiento e ingreso    
                    if(objFlujo.StatusFlujo__c =='Pagado' && mDeudasFlujos.get(objFlujo.Deuda__c).EstadodelaDeuda__c== 'Liquidada' 
                        && mDeudasFlujos.get(objFlujo.Deuda__c).FechadeLiquidacion__c == null)    
                    {
                        Ingresos__c ObjIngresosLiquidacion = new Ingresos__c();
                        Movimientos__c ObjMovimientosBancos = new Movimientos__c();
                        Movimientos__c ObjMovimientosComision = new Movimientos__c();
                        // AM 05-sep-2016  ajuste fecha liquidación = fecha facturación del flujo
                        if(objFlujo.FechaFacturacion__c!= null)
                            mDeudasFlujos.get(objFlujo.Deuda__c).FechadeLiquidacion__c = objFlujo.FechaFacturacion__c;
                        else 
                            mDeudasFlujos.get(objFlujo.Deuda__c).FechadeLiquidacion__c = system.today();

                        
                        if(!mDeudasFlujos.get(objFlujo.Deuda__c).RTD__r.BeneficioEmpleado__c)
                        {
                            // se crea un ingreso de tipo liquidación
                            ObjIngresosLiquidacion.Reparadora__c        = mDeudasFlujos.get(objFlujo.Deuda__c).RTD__c;
                            ObjIngresosLiquidacion.TipoIngreso__c       = 'Liquidación Colombia';
                            ObjIngresosLiquidacion.Monto__c             =  mDeudasFlujos.get(objFlujo.Deuda__c).ComisionRESUELVE__c;
                            
                            ObjIngresosLiquidacion.FechaFacturacion__c  =  mDeudasFlujos.get(objFlujo.Deuda__c).FechadeLiquidacion__c;
                            ObjIngresosLiquidacion.Status__c            = 'Por Cobrar';
                            ObjIngresosLiquidacion.NumeroTarjeta__c     =  mDeudasFlujos.get(objFlujo.Deuda__c).NumerodeTarjeta__c;
                            ObjIngresosLiquidacion.Negociadorasignado__c = mDeudasFlujos.get(objFlujo.Deuda__c).NegociadorAsignado__c;
                            lstIngresos.add(ObjIngresosLiquidacion);

                            // se crea un movimiento de tipo Pago a Banco
                            ObjMovimientosBancos.Reparadora__c          = mDeudasFlujos.get(objFlujo.Deuda__c).RTD__c;
                            ObjMovimientosBancos.Tipo_de_movimiento__c  = 'Pago a Banco';
                            ObjMovimientosBancos.Fecha__c               = objFlujo.FechaFacturacion__c;
                            ObjMovimientosBancos.Monto__c               = mDeudasFlujos.get(objFlujo.Deuda__c).MontoLiqBanco__c != null ? ((mDeudasFlujos.get(objFlujo.Deuda__c).MontoLiqBanco__c)*-1):0;
                            lstMovimientos.add(ObjMovimientosBancos);

                            // se crea un movimiento de tipo Comision 15%
                            ObjMovimientosComision.Reparadora__c          = mDeudasFlujos.get(objFlujo.Deuda__c).RTD__c;
                            ObjMovimientosComision.Tipo_de_movimiento__c = 'Comision 15%';
                            ObjMovimientosComision.Fecha__c              =  objFlujo.FechaFacturacion__c;
                            ObjMovimientosComision.Monto__c              = (mDeudasFlujos.get(objFlujo.Deuda__c).ComisionRESUELVE__c)*-1;
                            lstMovimientos.add(ObjMovimientosComision);

                            mDeudasFlujos.get(objFlujo.Deuda__c).StatusdelTramite__c = 'Fondos Depositados en Cuenta del Cliente';
                        }
                    }
                }
            }
            system.debug('+++mDeudasFlujos '+mDeudasFlujos);
            if (!mDeudasFlujos.isEmpty()){
                update mDeudasFlujos.values();
            }//Fin si tiene algo mDeudas
            
            system.debug('+++lstIngresos '+lstIngresos);
            if(!lstIngresos.isEmpty())
            {
                insert lstIngresos;
            }
            system.debug('+++lstMovimientos '+lstMovimientos);
            if(!lstMovimientos.isEmpty())
            {
                insert lstMovimientos;
            }
        }
    }

         
    if (Trigger.isAfter)
    {

        if (Trigger.isInsert || Trigger.isUpdate)
        {
            String sSucPasoPrueba = '';
            String sDeudaPasoPrueba = '';           
            Map<ID, Flujo__c> mFlujos = Trigger.newMap;
            Map<ID, Deudas__c> mDeudas = new Map<ID, Deudas__c>();
            Set<ID> sIdDeuda = new set<ID>();
            Set<ID> sIdScu = new set<ID>(); // set para los id de las suc
            //Mapa para las deudas de fondeos actuales
            Map<ID, Deudas__c> mDeudasFlujosHoy = new Map<ID, Deudas__c>();
           
            
            System.debug('mFlujos.keySet() ' + mFlujos.keySet()); 
            System.debug('mFlujos ' + mFlujos); 

            //Recorre el mapa de mFlujos y mete los id de las suc
            for (ID idFlujo : mFlujos.keySet())
            {
                
                System.debug('AL PRINCIPIO' + sIdScu);               
                if (mFlujos.get(idFlujo).Sucursal__c != null ){
                    sIdScu.add(mFlujos.get(idFlujo).Sucursal__c);
                    
                }
                
                if (mFlujos.get(idFlujo).Deuda__c != null){
                    sIdDeuda.add(mFlujos.get(idFlujo).Deuda__c);
                    }
                 
            }

            
            //Ve si tiene algo sIdScu
            System.debug('AL PRINCIPIO' + sIdScu);          
            if (!sIdScu.isEmpty() || !sIdDeuda.isEmpty())
            {
                
                list<Flujo__c> listFlujoDeudas=new  list<Flujo__c>();
                if( !sIdDeuda.isEmpty())
                {
                    listFlujoDeudas=[Select Deuda__c, id,  Deuda__r.RecordTypeId, StatusFlujo__c 
                                        From Flujo__c 
                                        where Deuda__c IN :sIdDeuda
                                        ];
                }
                System.debug('listFlujoDeudas '+listFlujoDeudas);

                for(Flujo__c Flujotemp : listFlujoDeudas)
                {
                     
                    list<ID> recordtypelist=new list<ID>();
                    recordtypelist.add(Flujotemp.Deuda__r.RecordTypeId);

                    system.debug('+++Flujotemp.StatusFlujo__c '+Flujotemp.StatusFlujo__c);
                    system.debug('+++recordtypelist '+recordtypelist);
                    system.debug('+++Flujotemp.Deuda__c '+Flujotemp.Deuda__c);
                    // si el estado del flujo es pagado  
                                        
                    if(Flujotemp.StatusFlujo__c != 'Cancelado')
                    {
                        system.debug('Entro al if');
                        if (mDeudas.containsKey(Flujotemp.Deuda__c))
                        {
                            decimal FondeosRealizadosEstaDeuda=mDeudas.get(Flujotemp.Deuda__c).FondeosRealizadosEstaDeuda__c != null ? mDeudas.get(Flujotemp.Deuda__c).FondeosRealizadosEstaDeuda__c  : 0;
                            FondeosRealizadosEstaDeuda++;
                            mDeudas.get(Flujotemp.Deuda__c).FondeosRealizadosEstaDeuda__c = FondeosRealizadosEstaDeuda;
                        }
                        else
                        {
                            System.debug('+++entro al else');
                            mDeudas.put(Flujotemp.Deuda__c,new Deudas__c( id = Flujotemp.Deuda__c, FondeosRealizadosEstaDeuda__c = 1));
                        }
                    }
                }

                for(AggregateResult fondeosRealizadosHoy : [Select Deuda__c, Count(id) fondeosRealizadosHoy  
                                        From Flujo__c 
                                        Where Deuda__c IN :sIdDeuda
                                        and StatusCuentaCobrar__c ='Por Cobrar'
                                        and StatusFlujo__c ='En espera de Pago'
                                        and CreatedDate = today
                                        group By Deuda__c])
                {
                    String strIdDeudaFondosHoy = (String)fondeosRealizadosHoy.get('Deuda__c');
                    Decimal dfondeosHoy = (Decimal)fondeosRealizadosHoy.get('fondeosRealizadosHoy');

                    if (mDeudasFlujosHoy.containsKey( strIdDeudaFondosHoy ))
                        mDeudasFlujosHoy.get(strIdDeudaFondosHoy).FondeosRealizadosHoy__c = dfondeosHoy;
                    if (!mDeudasFlujosHoy.containsKey( strIdDeudaFondosHoy ))
                        mDeudasFlujosHoy.put( strIdDeudaFondosHoy, new Deudas__c( id = strIdDeudaFondosHoy, FondeosRealizadosHoy__c = dfondeosHoy));
                                                          
                }
                
                // Si no se encontraron flujos con la caracteristica anterior en las deudas se coloca su valor en cero
                for(Id idDeudas: sIdDeuda) 
                {
                    //system.debug('entro--> ' + idDeudas);
                    if(!mDeudasFlujosHoy.containsKey(idDeudas))
                       mDeudasFlujosHoy.put( idDeudas, new Deudas__c( id = idDeudas, FondeosRealizadosHoy__c = 0)); 
                }


                if (!mDeudasFlujosHoy.isEmpty())
                        update mDeudasFlujosHoy.values();

                if (!mDeudas.isEmpty())
                {
                    //Ve si tiene deudas que actualizar
                    if (mDeudas.values() != null)
                        update mDeudas.values();

                }
               
            }      
        }
        
        //****si se trata del evento delete
        if (Trigger.isDelete)
        {
            
            Map<ID, Flujo__c> mFlujos = Trigger.oldMap;
            
            Set<ID> sIdScu = new set<ID>(); //Un set para los id de las suc
            //Un mapa para las deudas 
            Map<ID, Deudas__c> mDeudas = new Map<ID, Deudas__c>();
            //Mapa para las deudas de fondeos actuales
            Map<ID, Deudas__c> mDeudasFlujosHoy = new Map<ID, Deudas__c>();
            //Un set para los id de las suc
            Set<ID> sIdDeuda = new set<ID>();
            
            //Recorre tu mapa de mFlujos y mete los toma los id de las suc
            System.debug('mFlujos: ' + mFlujos.keySet());           
            for (ID idFlujo : mFlujos.keySet()){
                //Ponlo en mDeudas
                if (mFlujos.get(idFlujo).Deuda__c != null)
                    sIdDeuda.add(mFlujos.get(idFlujo).Deuda__c);

            system.debug('+++sIdDeuda '+sIdDeuda);    
            }
            
           
            if (!sIdDeuda.isEmpty())
            {
                 
                System.debug('+++ objFlujo1 '+mFlujos);
                //Fondeos Realizados de Esta Deuda  FondeosRealizadosEstaDeuda__c
                System.debug('ANTES DE ELIMINAR ANTES PASO0 FLUJOS');               
                for(AggregateResult objFlujo : [Select Deuda__c, Count(id) FondeosRealEnEstaDeuda  
                                        From Flujo__c 
                                        Where Deuda__c IN :sIdDeuda
                                        and StatusFlujo__c !='Cancelado'
                                        group By Deuda__c])
                {
                    system.debug('objFlujo >>'+objFlujo);                    
                    //Ve si tiene algo el campo de Deuda__c
                    if ( (String)objFlujo.get('Deuda__c') != null )
                    {
                        System.debug('PASO0 FLUJOS');
                        String sIdDeudaPR = (String)objFlujo.get('Deuda__c');
                        Decimal dFondeosRealEnEstaDeuda = (Decimal)objFlujo.get('FondeosRealEnEstaDeuda');
                        //Muy bien metelos en el mapa de mDeudas
                        if (mDeudas.containsKey( sIdDeudaPR ))
                            mDeudas.get(sIdDeudaPR).FondeosRealizadosEstaDeuda__c = dFondeosRealEnEstaDeuda;
                        if (!mDeudas.containsKey( sIdDeudaPR ))
                            mDeudas.put( sIdDeudaPR, new Deudas__c( id = sIdDeudaPR, FondeosRealizadosEstaDeuda__c = dFondeosRealEnEstaDeuda));
                    }                                     
                }


                for(AggregateResult fondeosRealizadosHoy : [Select Deuda__c, Count(id) fondeosRealizadosHoy  
                                        From Flujo__c 
                                        Where Deuda__c IN :sIdDeuda
                                        and StatusCuentaCobrar__c ='Por Cobrar'
                                        and StatusFlujo__c ='En espera de Pago'
                                        and CreatedDate = today
                                        group By Deuda__c])
                {
                    String strIdDeudaFondosHoy = (String)fondeosRealizadosHoy.get('Deuda__c');
                    Decimal dfondeosHoy = (Decimal)fondeosRealizadosHoy.get('fondeosRealizadosHoy');

                    if (mDeudasFlujosHoy.containsKey( strIdDeudaFondosHoy ))
                        mDeudasFlujosHoy.get(strIdDeudaFondosHoy).FondeosRealizadosHoy__c = dfondeosHoy;
                    if (!mDeudasFlujosHoy.containsKey( strIdDeudaFondosHoy ))
                        mDeudasFlujosHoy.put( strIdDeudaFondosHoy, new Deudas__c( id = strIdDeudaFondosHoy, FondeosRealizadosHoy__c = dfondeosHoy));
                                                          
                }

                // Si no se encontraron flujos con la caracteristica anterior en las deudas se coloca su valor en cero
                for(Id idDeudas: sIdDeuda) 
                {
                    if(!mDeudasFlujosHoy.containsKey(idDeudas))
                       mDeudasFlujosHoy.put( idDeudas, new Deudas__c( id = idDeudas, FondeosRealizadosHoy__c = 0)); 
                }

                if (!mDeudasFlujosHoy.isEmpty())
                        update mDeudasFlujosHoy.values();
                
                //Si tiene algo el mapa de mDeudas
                if (!mDeudas.isEmpty() )
                {
                    //Ve si tiene deudas que actualizar
                    if (mDeudas.values() != null && !test.isRunningTest())
                       
                        update mDeudas.values();
                }
            }
        }//Fin si se trata de eliminar
    }//Fin si se trata de after
}