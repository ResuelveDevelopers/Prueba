/*****************************************************************************************************
* Desarrollado por: RTD
* Autor:            Marwin Pineda (MP)
* Proyecto:         Referenciados
* Descripción:      Lógica de negocio para el trigger de Deudas             
*
* Cambios (Versiones)
* -------------------------------------
*           No.     fecha           Autor                       Descripción
*           -----   ----------      ------------------------    ---------------
* @version  1.0     22-Ago-2016     Marwin Pineda (MP)          Actualización de la sección Información Recomendado cuando la oportunidad tiene un referenciador.           
*******************************************************************************************************/
public class AuxiliarTriggerDeuda_cls 
{
    
    /**
     * Método que hace el llamado al método obtenerDeudas 
     * @param: 	lstNewDebts. El parámetro lstNewDebts define la lista de deudas luego de la ejecución del TriggerDeuda
     * @author:	Marwin Pineda (MP)
     */
    
    public static void handlerAfter(List<Deudas__c> lstNewDebts) 
    {
        obtenerInfoDeudas(lstNewDebts);
    }
    
    /**
     * Método en donde se hacen los cálculos (Deuda) para obtener los valores de los siguientes campos de la Reparadora:
     * Total Importe Bonificado en Deudas, Deudas Bonificadas, Deudas Liquidadas, Fecha de Última Liquidación, Número de Deudas.
     * @param: 	lstNewDebts. El parámetro lstNewDebts define la lista de deudas luego de la ejecución del TriggerDeuda
     * @author:	Marwin Pineda (MP)
     */
    
    public static void obtenerInfoDeudas(List<Deudas__c> lstNewDebts)
    {
    	Set<String> setIdReparadoras 				= new Set<String>();
        Map<String,Reparadora__c> mapReparadoras 	= new Map<String,Reparadora__c>();
        List<Reparadora__c> lstReparadorasUpd 		= new List<Reparadora__c>();
  
        for(Deudas__c objDeuda :lstNewDebts)
        {
            setIdReparadoras.add(objDeuda.RTD__c);  
        }

        if(!setIdReparadoras.isEmpty())
	  	{
	  		/**
	         *Calcula la sumatoria del campo Importe Bonificar de cada deuda asociada a una Reparadora con el fin de llenar el campo 
	         *Total Importe Bonificado en Deudas de la Reparadora. 
	         *Además calcula la cantidad de deudas asociadas a una Reparadora para poblar el campo Número de Deudas (Reparadora).
	         */
	           
	        for(AggregateResult objARDeuda :[SELECT RTD__c,SUM(ImporteBonificar__c) totalImporte,COUNT(Id) cantidadDeudas
	                                     	FROM Deudas__c 
	                                        WHERE RTD__c IN :setIdReparadoras
	                                        GROUP BY RTD__c])
	        {
	        	if(String.valueOf(objARDeuda.get('RTD__c')) != null)
	            {
	            	Decimal decTotal	= (Decimal)(objARDeuda.get('totalImporte'));
	            	Decimal decCantidad	= (Decimal)(objARDeuda.get('cantidadDeudas'));
	            	
	            	if (mapReparadoras.containsKey( String.valueOf(objARDeuda.get('RTD__c'))))
			        {
			        	mapReparadoras.get((String)objARDeuda.get('RTD__c')).ImporteBonificableTotal__c = decTotal;
			        	mapReparadoras.get((String)objARDeuda.get('RTD__c')).NumeroDeudas__c 			= decCantidad;
			        }
			        if (!mapReparadoras.containsKey( String.valueOf(objARDeuda.get('RTD__c'))))
			        {
			        	mapReparadoras.put((String)objARDeuda.get('RTD__c'), new Reparadora__c(ImporteBonificableTotal__c = decTotal, NumeroDeudas__c = decCantidad));
			        }
	            }
	        }
	        
	        /**
	         *Consulta la fecha de liquidación de cada deuda asociada a una Reparadora y pobla el campo Fecha de Última Liquidación en
	         *la Reparadora
	         */
	         
	        for(AggregateResult objARDeuda : [SELECT RTD__c, MAX(FechadeLiquidacion__c) FechaUltimaLiquidacion 
	            								FROM Deudas__c 
	            								WHERE RTD__c IN :setIdReparadoras 
	            								GROUP BY RTD__c])
	      	{
	      		if ( String.valueOf(objARDeuda.get('RTD__c')) != null)
		        {
			    	Date dtFechaUltimaLiquidacion = (Date)(objARDeuda.get('FechaUltimaLiquidacion'));
			        if(mapReparadoras.containsKey( String.valueOf(objARDeuda.get('RTD__c'))))
			       		mapReparadoras.get((String)objARDeuda.get('RTD__c')).FechaUltimaLiquidacion__c = dtFechaUltimaLiquidacion;
			      	if(!mapReparadoras.containsKey( String.valueOf(objARDeuda.get('RTD__c')) ))
			        	mapReparadoras.put((String)objARDeuda.get('RTD__c'), new Reparadora__c(FechaUltimaLiquidacion__c = dtFechaUltimaLiquidacion));
		      	}
	    	}
	    	
	    	/**
	         *Consulta la cantidad de deudas bonificadas asociadas a una Reparadora y pobla el campo Deudas Bonificadas (Reparadora).
	         */
	    	for(AggregateResult objARDeuda : [SELECT RTD__c, COUNT(Id) CantDeudasBonificadas 
	            								FROM Deudas__c 
	            								WHERE RTD__c IN :setIdReparadoras
	            								AND DeudaBonificada__c = true  
	            								GROUP BY RTD__c])
	      	{
	      		if ( String.valueOf(objARDeuda.get('RTD__c')) != null)
		        {
			    	Decimal decCantDeudasBonificadas = (Decimal)(objARDeuda.get('CantDeudasBonificadas'));
			        
			        if(mapReparadoras.containsKey( String.valueOf(objARDeuda.get('RTD__c'))))
			       		mapReparadoras.get((String)objARDeuda.get('RTD__c')).DeudasBonificadas__c = decCantDeudasBonificadas;
			      	if(!mapReparadoras.containsKey( String.valueOf(objARDeuda.get('RTD__c')) ))
			        	mapReparadoras.put((String)objARDeuda.get('RTD__c'), new Reparadora__c(DeudasBonificadas__c = decCantDeudasBonificadas));
		      	}
	    	}
	    	
	    	/**
	         *Consulta la cantidad de deudas liquidadas asociadas a una Reparadora y pobla el campo Deudas Liquidadas (Reparadora).
	         */
	    	for(AggregateResult objARDeuda : [SELECT RTD__c, COUNT(Id) CantDeudasLiquidadas 
	            								FROM Deudas__c 
	            								WHERE RTD__c IN :setIdReparadoras
	            								AND EstadodelaDeuda__c = 'Liquidada'  
	            								GROUP BY RTD__c])
	      	{
	      		if ( String.valueOf(objARDeuda.get('RTD__c')) != null)
		        {
			    	Decimal decCantDeudasLiquidadas = (Decimal)(objARDeuda.get('CantDeudasLiquidadas'));
			    	
			        if(mapReparadoras.containsKey( String.valueOf(objARDeuda.get('RTD__c'))))
			       		mapReparadoras.get((String)objARDeuda.get('RTD__c')).DeudasLiquidadas__c = decCantDeudasLiquidadas;
			      	if(!mapReparadoras.containsKey( String.valueOf(objARDeuda.get('RTD__c')) ))
			        	mapReparadoras.put((String)objARDeuda.get('RTD__c'), new Reparadora__c(DeudasLiquidadas__c = decCantDeudasLiquidadas));
		      	}
	    	}
	    	
	        if(!mapReparadoras.isEmpty())
	        {
	        	for(String strIdReparadora :mapReparadoras.keySet())
	        	{
	        		lstReparadorasUpd.add(new Reparadora__c(
	        		Id 							= strIdReparadora,
	        		ImporteBonificableTotal__c 	= mapReparadoras.get(strIdReparadora).ImporteBonificableTotal__c 	!= null ? mapReparadoras.get(strIdReparadora).ImporteBonificableTotal__c 	: 0, 
	        		DeudasBonificadas__c		= mapReparadoras.get(strIdReparadora).DeudasBonificadas__c			!= null ? mapReparadoras.get(strIdReparadora).DeudasBonificadas__c			: 0,
	        		NumeroDeudas__c 			= mapReparadoras.get(strIdReparadora).NumeroDeudas__c 				!= null ? mapReparadoras.get(strIdReparadora).NumeroDeudas__c 				: 0,
	        		DeudasLiquidadas__c			= mapReparadoras.get(strIdReparadora).DeudasLiquidadas__c			!= null ? mapReparadoras.get(strIdReparadora).DeudasLiquidadas__c			: 0, 
	        		FechaUltimaLiquidacion__c	= mapReparadoras.get(strIdReparadora).FechaUltimaLiquidacion__c		!= null ? mapReparadoras.get(strIdReparadora).FechaUltimaLiquidacion__c		: null));	
	        	}
	        	if(!lstReparadorasUpd.isEmpty())
	        	{
	        		if(!Test.isRunningTest())
	        		{
	        			RD_TriggerExecutionControl_cls.setAlreadyDone('TriggerDeuda');
	        			update lstReparadorasUpd;
	        		}
	        	}
	        }
	 	}
	}//Cierre del método
}//Cierre de la clase AuxiliarTriggerDeuda_cls