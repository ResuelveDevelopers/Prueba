/*******************************************************************************
Desarrollado por:   RTD
Autor:              Jeisson Hernandez
Proyecto:           Colombia III Cierre de Clientes
Descripción:        Clase Scheduler para programar Batch de Cierre de Clientes

Cambios (Versiones)
-------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		----------                --------------------------      
    1.0     03-Sep-2015		Jeisson Hernandez(JH)   Creación de la Clase.
    1.1		21-Dic-2016		Joe Ayala(JA)			Se realiza filtro para asegurar que en la consulta solamente se recojan    
    												los  leads que se encuentren  En revisión de Contrato	

*******************************************************************************/

global with sharing class  SchCierreClientes_sch implements Schedulable
{
	global void execute(SchedulableContext SC)
	{
		String strQuery='';
		Id strecordtype = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('En revisión de Contrato').getRecordTypeId();
		
		strQuery='Select Id, CaratulaApartadoMensual__c, MontoDepositado__c, ' +
		' LastName, ApellidoM__c, PrimerNombre__c, SegundoNombre__c, PrimerApellido__c, SegundoApellido__c, '+
		' FechaNacimiento__c , Domicilio__c,' +
		' Departamento__c, Cedula__c, CiudadMunicipio__c, TelefonoCasa__c, ' +
		' TelefonoCelular__c, TelefonoTrabajo__c,Email, CaratulaAniosResidencia__c, ' +
		' PersonasCargo__c, TVPaga__c, TipoVivienda__c, EstadoCivil__c, ' +
		' NivelAcademico__c, CaratulaIngresoBruto__c, CaratulaIngresoNeto__c, ' +
		' CausaDejoPagar__c, Referencia__c,' +
		' FechaDeposito__c, VendedorAsignado__c, RefRecomendado__c, CaratulaDiaDeposito__c, ' +
		' Genero__c, EmpleoCaratula__c, BeneficioEmpleado__c, AdeudoTotal__c, ' +
		' FechaExpedicion__c, LugarExpedicion__c, TipoDocAfiliado__c, ' +
    	' ReciboPublico__c, ComprobanteAtraso6__c, ComprobanteAtraso1__c,ComprobanteAtraso2__c, ' +
    	' ComprobanteAtraso3__c, ComprobanteAtraso4__c, ComprobanteAtraso5__c, ' +
    	' CedulaDoc__c, TablaRepago__c, URLTablaRepago__c, ' +
    	' CedulaURL__c, ComprobanteAtraso1URL__c, ComprobanteAtraso2URL__c, ' +
        ' ComprobanteAtraso3URL__c, ComprobanteAtraso4URL__c, ComprobanteAtraso5URL__c, ' +
        ' ReciboPublicoURL__c, ComprobanteAtraso6URL__c ' +
		' From Lead Where ClienteCerrado__c = false And PorcentajeMontoDepositado__c >= 95 ' +
		' AND RecordTypeId = \''+strecordtype+'\' ';//JA 21-Dic-2016:  Se adiciona condicion para filtrar por el recordtype	
		if (Test.isRunningTest() )		
			strQuery= strQuery + ' Limit 1';
        system.debug('este_es_mi_query' + strQuery);
		BchCierreClientes_bch bchCierreClientes = new BchCierreClientes_bch(strQuery);
		Id batchProcessId = Database.executeBatch(bchCierreClientes, 1);
	} 
}