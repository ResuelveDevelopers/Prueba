/*************************************************************************************
Desarrollado por:   Resuelve
Autor:              Angela Munévar(AM)
Proyecto:           Resuelve tu Deuda
Descripción:        Triger de objeto  Ingresos

Cambios (Versiones)
-------------------------------------
    No.     Fecha               Autor                       Descripción
    ---     -----------         ------------------------    --------------------------      
    1.0     13-Jul-2016         Angela Munévar(AM)          Creación de la Clase 
***************************************************************************************/
trigger TriggerIngresos on Ingresos__c (after insert, after update, after delete) 
{
    Set<ID> sIdCtas = new set<ID>();
    Map<String, Reparadora__c> mapRep = new Map<String, Reparadora__c>();
    Map<String, Reparadora__c> mAccounts = new Map<String, Reparadora__c>();
    List<Reparadora__c> lstReparadora = new List<Reparadora__c>();

    if (Trigger.isAfter)
    {
        System.debug('EN EL TRIGGER DE Ingresos ' ); 
        if (Trigger.isInsert || Trigger.isUpdate)
        {
            Map<ID, Ingresos__c > mapIngresos = Trigger.newMap;
            //Recorre el mapa de mapIngresos y mete los toma los id de las suc !mapIngresos.get(idDeuda).CargaMasiva__c
            for (ID idDeuda: mapIngresos.keySet())
            {
                if (mapIngresos.get(idDeuda).Reparadora__c != null )
                    sIdCtas.add(mapIngresos.get(idDeuda).Reparadora__c);
            }
            if (!sIdCtas.isEmpty())
            {

                for (Reparadora__c objAcct : [Select id 
                                    , IngresosLiquidacionCobrar__c 
                                    , MensualidadesGeneradasporCobrar__c 
                                    From Reparadora__c Where id IN: sIdCtas])
                {
                //se inserta en el mapa de mapRep 
                    if (!mapRep.containsKey(objAcct.id))
                        mapRep.put(objAcct.id, objAcct);
                }


                //Obten el total del campo MensualidadesGeneradasporCobrar__c   //HECTOR: SE MIGRA  
                           
                for(AggregateResult objIngresos : [Select Reparadora__c, SUM(Monto__c) MensGeneradasPorCobrar 
                                        From Ingresos__c 
                                        Where Status__c = 'Por Cobrar'
                                        And TipoIngreso__c = 'Mensualidad Colombia'
                                        And Reparadora__c IN :sIdCtas
                                        group By Reparadora__c])
                {                                          
                    //se agregan en el mapa de mGastoMesAnterior
                    if ( String.valueOf(objIngresos.get('Reparadora__c')) != null)
                    {
                        Decimal dMensGeneradasPorCobrar = (Decimal)(objIngresos.get('MensGeneradasPorCobrar'));                     
                        if (mAccounts.containsKey( String.valueOf(objIngresos.get('Reparadora__c'))))
                            mAccounts.get((String)objIngresos.get('Reparadora__c')).MensualidadesGeneradasporCobrar__c = dMensGeneradasPorCobrar;
                        else
                            mAccounts.put((String)objIngresos.get('Reparadora__c'), new Reparadora__c(MensualidadesGeneradasporCobrar__c = dMensGeneradasPorCobrar));                            
                    }
                }

                //Obten el total del campo IngresosLiquidacionCobrar__c   
                for(AggregateResult objIngresos : [Select Reparadora__c, SUM(Monto__c) IngresosliqPorCobrar 
                                        From Ingresos__c 
                                        Where Status__c = 'Por Cobrar'
                                        And TipoIngreso__c = 'Liquidación Colombia'
                                        And Reparadora__c IN :sIdCtas
                                        group By Reparadora__c])
                {                                          
                    //se agregan en el mapa de mGastoMesAnterior
                    if ( String.valueOf(objIngresos.get('Reparadora__c')) != null){
                        Decimal dIngresosliqPorCobrar = (Decimal)(objIngresos.get('IngresosliqPorCobrar'));                     
                        if (mAccounts.containsKey( String.valueOf(objIngresos.get('Reparadora__c'))))
                            mAccounts.get((String)objIngresos.get('Reparadora__c')).IngresosLiquidacionCobrar__c = dIngresosliqPorCobrar;
                        else
                            mAccounts.put((String)objIngresos.get('Reparadora__c'), new Reparadora__c(IngresosLiquidacionCobrar__c = dIngresosliqPorCobrar));                            
                    }
                }

                //Obten el total del campo IngresosMensualidadCobrados__c
                for(AggregateResult objIngresos : [Select Reparadora__c, SUM(Monto__c) IngresosMensCobrados 
                                        From Ingresos__c 
                                        Where Status__c = 'Cobrado'
                                        And TipoIngreso__c = 'Mensualidad Colombia'
                                        And Reparadora__c IN :sIdCtas
                                        group By Reparadora__c])
                {                                          
                    //se agregan en el mapa de mGastoMesAnterior
                    if ( String.valueOf(objIngresos.get('Reparadora__c')) != null){
                        Decimal dIngresosMensCobrados = (Decimal)(objIngresos.get('IngresosMensCobrados'));                     
                        if (mAccounts.containsKey( String.valueOf(objIngresos.get('Reparadora__c'))))
                            mAccounts.get((String)objIngresos.get('Reparadora__c')).IngresosMensualidadCobrados__c = dIngresosMensCobrados;
                        else
                            mAccounts.put((String)objIngresos.get('Reparadora__c'), new Reparadora__c(IngresosMensualidadCobrados__c = dIngresosMensCobrados));                            
                    }
                }

                //Obten el total del campo IngresosLiquidacionCobrados__c  
                for(AggregateResult objIngresos : [Select Reparadora__c, SUM(Monto__c) IngresosliqCobradas 
                                        From Ingresos__c 
                                        Where Status__c = 'Cobrado'
                                        And TipoIngreso__c = 'Liquidación Colombia'
                                        And Reparadora__c IN :sIdCtas
                                        group By Reparadora__c]){                                          
                    //se agregan en el mapa de mGastoMesAnterior
                    if ( String.valueOf(objIngresos.get('Reparadora__c')) != null){
                        Decimal dIngresosliquidacionCobrados = (Decimal)(objIngresos.get('IngresosliqCobradas'));                       
                        if (mAccounts.containsKey( String.valueOf(objIngresos.get('Reparadora__c'))))
                            mAccounts.get((String)objIngresos.get('Reparadora__c')).IngresosLiquidacionCobrados__c = dIngresosliquidacionCobrados;
                        else
                            mAccounts.put((String)objIngresos.get('Reparadora__c'), new Reparadora__c(IngresosLiquidacionCobrados__c = dIngresosliquidacionCobrados));                            
                    }
                }

                if (!mAccounts.isEmpty())
                {
                    system.debug('+++ mapa: '+mAccounts);
                    for (String sCta : mAccounts.keySet())
                    {
                        lstReparadora.add(new Reparadora__c(id = sCta
                        , IngresosLiquidacionCobrar__c = mAccounts.get(sCta).IngresosLiquidacionCobrar__c != null ? mAccounts.get(sCta).IngresosLiquidacionCobrar__c : 0.00 
                        , MensualidadesGeneradasporCobrar__c = mAccounts.get(sCta).MensualidadesGeneradasporCobrar__c != null ? mAccounts.get(sCta).MensualidadesGeneradasporCobrar__c : 0.00 
                        , IngresosLiquidacionCobrados__c = mAccounts.get(sCta).IngresosLiquidacionCobrados__c != null ? mAccounts.get(sCta).IngresosLiquidacionCobrados__c : 0.00 
                        , IngresosMensualidadCobrados__c = mAccounts.get(sCta).IngresosMensualidadCobrados__c != null ? mAccounts.get(sCta).IngresosMensualidadCobrados__c : 0.00 
                        ));
                    }
                    if (!lstReparadora.isEmpty())
                    {
                        if (!Test.isRunningTest())
                        {
                            System.debug('En el tigger de TriggerIngresos after update o insert: ' + lstReparadora);
                            //ANTES DE ACTUALIZAR LOS REGISTROS PRENDE LA BANDERA PARA QUE NO
                            //SE EJECUTE EL TRIGGER DE TriggerReparadora_tgr EN EL EVENTO UPDATE ActividadesServicioClientedia15__c                         
                            RD_TriggerExecutionControl_cls.setAlreadyDone('TriggerReparadora_tgr');                                           
                            update lstReparadora;
                        }
                    }
                }

            }
            
        }
        //Si se trata de delete
        if (Trigger.isDelete)
        {
            Map<ID, Ingresos__c > mapIngresos = Trigger.oldMap;

            //Recorre tu mapa de mapIngresos y mete los toma los id de las suc
            for (ID idDeuda: mapIngresos.keySet()){
                if (mapIngresos.get(idDeuda).Reparadora__c != null)
                    sIdCtas.add(mapIngresos.get(idDeuda).Reparadora__c);
            }
            system.debug('+++sIdCtas '+sIdCtas);

            if (!sIdCtas.isEmpty())
            {
                system.debug('+++entro a '+sIdCtas);
                //Consulta todos los movimientos y ponlos en el mapa de mAccoMails        
                for (Reparadora__c objAcct : [Select id 
                                            , IngresosLiquidacionCobrar__c 
                                            , MensualidadesGeneradasporCobrar__c 
                                            From Reparadora__c Where id IN: sIdCtas])
                {
                    //se agrega al mapa de mapRep 
                    if (!mapRep.containsKey(objAcct.id))
                        mapRep.put(objAcct.id, objAcct);
                }

                //Obten el total del campo MensualidadesGeneradasporCobrar__c   //HECTOR: SE MIGRA  
                System.debug('EN EL TRIGGER DE Ingresos: ' );  
                system.debug(' query '+ [Select Reparadora__c ,TipoIngreso__c,Status__c
                                        From Ingresos__c 
                                        Where Reparadora__c IN :sIdCtas]);              
                for(AggregateResult objIngresos : [Select Reparadora__c, SUM(Monto__c) MensGeneradasPorCobrar 
                                        From Ingresos__c 
                                        Where Status__c = 'Por Cobrar'
                                        And TipoIngreso__c = 'Mensualidad Colombia'
                                        And Reparadora__c IN :sIdCtas
                                        group By Reparadora__c])
                {                                          
                    //Muy bien metelos en el mapa de mGastoMesAnterior
                    if ( String.valueOf(objIngresos.get('Reparadora__c')) != null)
                    {
                        Decimal dMensGeneradasPorCobrar = (Decimal)(objIngresos.get('MensGeneradasPorCobrar'));                     
                        if (mAccounts.containsKey( String.valueOf(objIngresos.get('Reparadora__c'))))
                            mAccounts.get((String)objIngresos.get('Reparadora__c')).MensualidadesGeneradasporCobrar__c = dMensGeneradasPorCobrar;
                        else
                            mAccounts.put((String)objIngresos.get('Reparadora__c'), new Reparadora__c(MensualidadesGeneradasporCobrar__c = dMensGeneradasPorCobrar));                            
                    }

                }
                system.debug('+++llego a '+sIdCtas);
                //Obten el total del campo IngresosLiquidacionCobrar__c   //HECTOR: SE MIGRA no se ha creado                
                for(AggregateResult objIngresos : [Select Reparadora__c, SUM(Monto__c) IngresosliqPorCobrar 
                                        From Ingresos__c 
                                        Where Status__c = 'Por Cobrar'
                                        And TipoIngreso__c = 'Liquidación Colombia'
                                        And Reparadora__c IN :sIdCtas
                                        group By Reparadora__c]){                                          
                    //se insertan en el mapa de mGastoMesAnterior
                    if ( String.valueOf(objIngresos.get('Reparadora__c')) != null){
                        Decimal dIngresosliqPorCobrar = (Decimal)(objIngresos.get('IngresosliqPorCobrar'));                     
                        if (mAccounts.containsKey( String.valueOf(objIngresos.get('Reparadora__c'))))
                            mAccounts.get((String)objIngresos.get('Reparadora__c')).IngresosLiquidacionCobrar__c = dIngresosliqPorCobrar;
                        else
                            mAccounts.put((String)objIngresos.get('Reparadora__c'), new Reparadora__c(IngresosLiquidacionCobrar__c = dIngresosliqPorCobrar));                            
                    }
                }
                system.debug('+++llego a 1'+sIdCtas);
                //Recorre la lista de sIdCtas y buscalas en el mapa de mAccounts
                for (String sIdRep : sIdCtas)
                {
                    system.debug('+++llego a 2'+sIdCtas);
                    if (!mAccounts.containsKey( sIdRep ))
                        mAccounts.put( sIdRep, new Reparadora__c(id = sIdRep
                        , IngresosLiquidacionCobrar__c = 0.00
                        , MensualidadesGeneradasporCobrar__c = 0.00
                        ));                   
                } //Fin del for para los id de las reparadoras
               
                if (!mAccounts.isEmpty())
                {
                    //Recorre el mapa de mAccounts 
                    for (String sCta : mAccounts.keySet())
                    {
                        lstReparadora.add(new Reparadora__c(id = sCta
                            , IngresosLiquidacionCobrar__c = mAccounts.get(sCta).IngresosLiquidacionCobrar__c != null ? mAccounts.get(sCta).IngresosLiquidacionCobrar__c : 0.00 //HECTOR: SE MIGRA no se ha creado
                            , MensualidadesGeneradasporCobrar__c = mAccounts.get(sCta).MensualidadesGeneradasporCobrar__c != null ? mAccounts.get(sCta).MensualidadesGeneradasporCobrar__c : 0.00 //HECTOR: SE MIGRA
                        ));                        
                    }
                    if (!lstReparadora.isEmpty())
                    {
                        if (!Test.isRunningTest())
                        {
                            System.debug('En el tigger de TriggerIngresos after delete: ' + lstReparadora);
                            // ANTES DE ACTUALIZAR LOS REGISTROS PRENDE LA BANDERA PARA QUE NO
                            //SE EJECUTE EL TRIGGER DE TriggerReparadora_tgr EN EL EVENTO UPDATE ActividadesServicioClientedia15__c                         
                            RD_TriggerExecutionControl_cls.setAlreadyDone('TriggerReparadora_tgr');                                           
                            update lstReparadora;
                        }//Fin si no es una prueba
                    }//Fin si tiene algo !lstReparadora.isEmpty()
                }
            }
        }
    }
}