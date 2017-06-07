/*****************************************************************************************************
* Desarrollado por: RTD
* Autor:            Esteban Heredia (EH)
* Proyecto:         Colombia 
* Descripción:      Lógica de negocio para el trigger de Movimientos              
*
* Cambios (Versiones)
* -------------------------------------
*           No.     fecha          	Autor 		               	Descripción
*           -----   ----------      ------------------------   	---------------
* @version  1.0     11-Abr-2016     Esteban Heredia (EH)        Creación de la clase  
*           1.1     27-Abr-2016     Angela Munévar(AM)          Cración metodo LLenarResumenMovientos
			1.2     05-May-2016     Esteban Heredia (EH)        Contador de movimientos en la reparadora   
			1.2     16-Ene-2016     Joe Ayala (JA)		        Se adiciona método ActualizarIva para controlar el porcentaje del calculo de IVA del movimiento 
    														    basado en un rango de tiempo definido en una conf personalizada a partir de la fecha de creación,
*******************************************************************************************************/

public with sharing class AuxiliarTriggerMovimientos_cls 
{
	public static set<Id> setIdReparadoras;
	public static Map<Id,Reparadora__c> mapReparadorasById;
    
	public static void handlerAfterInsert(List<Movimientos__c> lstNewRecords) 
	{
		colocarDiasSinDepositar(lstNewRecords); // Se crea el mapa de las reparadoras papas, no hay que volverlo a crear pq es global
		LLenarResumenMovientos();
		contMovComMensual(); 
    }

	public static void handlerAfterUpdate(List<Movimientos__c> lstNewRecords) 
	{
		colocarDiasSinDepositar(lstNewRecords); // Se crea el mapa de las reparadoras papas, no hay que volverlo a crear pq es global
		LLenarResumenMovientos();
		contMovComMensual();
    }

	public static void handlerAfterDelete(List<Movimientos__c> lstOldRecords) 
	{
		colocarDiasSinDepositar(lstOldRecords); // Se crea el mapa de las reparadoras papas, no hay que volverlo a crear pq es global
		LLenarResumenMovientos();
		contMovComMensual(); 
	}


	 /**
     * Metodo que realiza un conteo de las comisiones mensuales de cada reparadora
     * @author Esteban Heredia EH
     * @param Sin parametros
     * @return No tiene retorno
     */
  	public static void contMovComMensual()
  	{
  		// Creamos una set con los id de las reparadoras que realmente tienen comisión mensual, para las q no colocarle su valor en cero
  		Set<Id> idRepComMen = new Set<id>();
  		// Traemos los movimientos que sean comisión mensual:
		List<AggregateResult> lstobjMovsComMensual = [Select Reparadora__c, Count(Id) NumeroMovimientos 
                                            					From Movimientos__c 
                                           						Where Tipo_de_movimiento__c =: 'Comision Mensual'
                                            					And Reparadora__c IN :setIdReparadoras
                                            					group By Reparadora__c];
		// Colocamos en cada reparadora la fecha de último deposito
		for(AggregateResult objMovs : lstobjMovsComMensual)
		{ 
        	Integer intMovComMensuales = (Integer)(objMovs.get('NumeroMovimientos'));
          	mapReparadorasById.get((String)objMovs.get('Reparadora__c')).MovDeComMen__c = intMovComMensuales;
          	idRepComMen.add((String)objMovs.get('Reparadora__c'));
        }
        // Si no encuentra un valor, colocamos el número de movimientos en cero, reinicio del campo
        for(String idReparadora: setIdReparadoras)
        {
        	if(!idRepComMen.contains(idReparadora))
        		mapReparadorasById.get(idReparadora).MovDeComMen__c = 0;
        }
  		 // Actualizamos los valores de las reparadoras solo si encontro movimientos con las características adecuadas
        update mapReparadorasById.values();
  	}

	// Para llenar el campo días sin depositar se llenrá el campo FechaUltimoDeposito__c, para que se pueda calcular la fórmula
	// Esto se realiza cuando se inserta, actualiza o eliminan los movimientos (Si se eliminan o actualizan se irá colocando la fecha más reciente)
	// En caso que no existan movimientos tampocó existira una fecha de último deposito
	public static void colocarDiasSinDepositar(List<Movimientos__c> lstNewRecords)
	{
		setIdReparadoras = new Set<Id>();
		// set de las reparadoras que sus movimientos de apartado mensual tienen fechas
		Set<Id> setReparadorasMovFechas = new Set<Id>();
		//Creamos un mapa de los pápas(Reparadoras)
		for(Movimientos__c objMovTemp: lstNewRecords) 
		{
			if(objMovTemp.Reparadora__c != null)
				setIdReparadoras.add(objMovTemp.Reparadora__c);
		}
		// Traemos a los pápas
		mapReparadorasById = new Map<Id,Reparadora__c>([SELECT Id FROM Reparadora__c WHERE Id IN: setIdReparadoras]);
		system.debug('\n\n mapReparadorasById--> ' + mapReparadorasById);

		// Traemos la fecha más reciente en que se hizo un movimiento de apartado mensual:
		List<AggregateResult> lstobjMovsFechaUltimoDeposito = [Select Reparadora__c, MAX(Fecha__c) FechaUltimoDeposito 
                                            					From Movimientos__c 
                                           						Where Tipo_de_movimiento__c =: 'Apartado Mensual'
                                            					And Reparadora__c IN :setIdReparadoras
                                            					group By Reparadora__c];
		// Colocamos en cada reparadora la fecha de último deposito
		for(AggregateResult objMovs : lstobjMovsFechaUltimoDeposito)
		{ 
        	DateTime dtFechaUltimoDeposito = (DateTime)(objMovs.get('FechaUltimoDeposito'));
          	mapReparadorasById.get((String)objMovs.get('Reparadora__c')).FechaUltimoDeposito__c = Date.valueOf(dtFechaUltimoDeposito);
        	setReparadorasMovFechas.add((String)objMovs.get('Reparadora__c'));
        }
        //Se va a actualizar las reparadoras que por alguna razón los movimientos ya no tienen fecha, es decir
        // De todos los movimientos que están en reparadoras vamos a ver que todos contengan sus fechas, sino
        // su campo FechaUltimoDeposito__c se volvera a nulo.
        for(Reparadora__c objReparadoraTemp: mapReparadorasById.values()) 
        {
        	if(!setReparadorasMovFechas.contains(objReparadoraTemp.Id))
        		mapReparadorasById.get(objReparadoraTemp.Id).FechaUltimoDeposito__c = null;
        }
   	}
    
    

	// AM 27/04/2016  Cración metodo LLenarResumenMovientos 
	public static Void LLenarResumenMovientos()
	{

		Set<String> sResumenMovimientos  = new Set<String>{'Devolución','Addendum'};
		list<Reparadora__c> lstRep= new list<Reparadora__c>();
		//Actualiza el campo Resumen_Movimientos con la sumatoria de los totales de los movimientos
        for(AggregateResult objMovs : [Select Reparadora__c, SUM(Total__c) ResumenMovimientos 
                        From Movimientos__c 
                        Where Tipo_de_movimiento__c NOT IN :sResumenMovimientos
                        And Reparadora__c IN :setIdReparadoras
                        group By Reparadora__c])
        {                                          
            Decimal dResumenMovimientos = (Decimal)(objMovs.get('ResumenMovimientos'));                     
            mapReparadorasById.get((String)objMovs.get('Reparadora__c')).ResumenMovimientos__c = dResumenMovimientos;   
            lstRep.add(mapReparadorasById.get((String)objMovs.get('Reparadora__c'))) ;           
        }
        update lstRep;
	}
    
    /* JA 16-Ene-2016  ActualizarVarperiodica
       Metodo que realiza el llamado a la clase ConsultaVariablesPeriodicas para controlar el porcentaje del
       calculo de IVA del movimiento basado en un rango de tiempo definido en una conf personalizada a partir de la fecha de creación,
	*/
    public static List<Movimientos__c> ActualizarVarperiodica(List<Movimientos__c> lstRecords)   
    {
        //JA 16-Ene-2017 Llamado al Metodo getlistValorActual el cual actualiza los valores de porcentaje de IVA para las Deudas basado en la fecha de liquidación ,
        // en caso de ser null se calculará con la fecha del dia en que crea o modifica y cada ves que se actualice evaluará estas condiciones. 
        List<Movimientos__c> lstmovact = new List<Movimientos__c>();
        lstmovact = ConsultaVariablesPeriodicas.getlistValorActual('IVA','CreatedDate','TODAY',lstRecords,'Porcentaje_de_IVA_Actual__c');           
        system.debug('\n\n lstmovact_antes de actualizar   ' + lstmovact);
                
        return lstmovact;
    }
    
    
    
}