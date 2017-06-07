/*****************************************************************************************************
* Desarrollado por: RTD
* Autor:            Esteban Heredia (EH)
* Proyecto:         Colombia V
* Descripción:      Trabajo programado para crear ingresos en las reparadoras            
*
* Cambios (Versiones)
* -------------------------------------
*           No.     fecha           Autor                       Descripción
*           -----   ----------      ------------------------    ---------------
* @version  1.0     25-Jul-2016     Esteban Heredia (EH)        Creación de la clase           
*******************************************************************************************************/
global class BchComisionesMensuales_bch implements Database.Batchable<sObject> 
{
	
	String query;
	
	global BchComisionesMensuales_bch() 
	{
		//Calculamos la fecha del último día del mes anterior
		Integer diasMesAnterior = date.daysInMonth(system.now().year(), system.now().month() - 1);
		//system.debug('\n\n diasMesAnterior--> ' + diasMesAnterior);
		Date fechaMesAnterior = Date.newInstance(system.now().year(), system.now().month() - 1, diasMesAnterior);
		//system.debug('\n\n fechaMesAnteriorstring--> ' + string.valueOf(fechaMesAnterior));
		//Calculamos la fecha del primer día del mes siguiente
		Date fechaMesSiguiente = date.newInstance(system.now().year(), system.now().month() + 1, 1);

		Query =   'SELECT Id, ComisionMensual__c, (SELECT Id FROM Ingresos__r WHERE FechaFacturacion__c = THIS_MONTH AND TipoIngreso__c = \'Mensualidad Colombia\') ';
		Query += 'FROM Reparadora__c WHERE FechaInicioPrograma__c <= ' + string.valueOf(fechaMesAnterior)  + ' AND (Status__c = \'Activo\' '; 
		Query += 'OR (Status__c LIKE \'%baja%\' AND FechaBajaGraduacion__c >= ' + string.valueOf(fechaMesSiguiente) + ')) '; 
		Query += 'AND BeneficioEmpleado__c = false AND (NOT NombreCompleto__c like \'%prueba%\') '; 

	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		system.debug('\n\n query--> ' + query);
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) 
   	{
   		// Obtenemos el scope (los registros obtenidos en el proceso start)
     	List<Reparadora__c> lstReparadorasScope = scope;
     	//system.debug('\n\n lstReparadorasScope--> ' + lstReparadorasScope);
     	Ingresos__c objIngresoNuevo;
     	// Calculamos el último día del mes en curso
     	Integer diasMesActual = date.daysInMonth(system.now().year(), system.now().month());
		Date fechaMesActual = Date.newInstance(system.now().year(), system.now().month(), diasMesActual);
     	List<Ingresos__c> lstIngresos = new List<Ingresos__c>();

     	for(Reparadora__c objReparadoraTemp : lstReparadorasScope)
     	{
     		// si esiste ya n movimiento con estas características, no debe crear más
     		if(!objReparadoraTemp.Ingresos__r.IsEmpty())
     			continue;

     		// Creamos el ingreso en la reparadora
     		objIngresoNuevo = new Ingresos__c(); 
     		objIngresoNuevo.Reparadora__c = objReparadoraTemp.Id;
     		objIngresoNuevo.FechaFacturacion__c = fechaMesActual;
     		objIngresoNuevo.Monto__c = objReparadoraTemp.ComisionMensual__c;
     		objIngresoNuevo.Status__c = 'Por Cobrar';
     		objIngresoNuevo.TipoIngreso__c = 'Mensualidad Colombia';
     		lstIngresos.add(objIngresoNuevo);
     	}
     	insert lstIngresos;
	}
	
	global void finish(Database.BatchableContext BC) 
	{
		
	}
	
}