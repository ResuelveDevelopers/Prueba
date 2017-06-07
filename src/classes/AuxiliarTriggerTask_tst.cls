/*****************************************************************************************************
* Desarrollado por: RTD
* Autor:            Esteban Heredia (EH)
* Proyecto:         Colombia 
* Descripción:      Clase de prueba para el trigger de tareas              
*
* Cambios (Versiones)
* -------------------------------------
*           No.     fecha          	Autor 		               	Descripción
*           -----   ----------      ------------------------   	---------------
* @version  1.0     31-Mar-2016     Esteban Heredia (EH)        Creación de la clase 
* @version  1.1     12-Abr-2016     Esteban Heredia (EH)        Subir cobertura con las mod. de la clase original           
*******************************************************************************************************/
@isTest
private class AuxiliarTriggerTask_tst 
{
	public static Task objTarea;
	public static Task objTarea2;
	public static Task objTarea3;
	public static Task objTarea4;
	public static Task objTarea5;
	public static Lead objCandidato;
	public static Sucursal__c objSucursal;
	public static RecursosHumanos__c objRecursoshumanos;
	public static Reparadora__c objReparadora;

	public static void createData()
	{
		objRecursoshumanos 					= TestCreaObjetos.CrearRHs(1,'test','test').get(0);
		objRecursoshumanos.Usuario__c		= UserInfo.getUserId();
		update objRecursoshumanos;
		objSucursal 						= new Sucursal__c();
		objSucursal.Name  					= 'Bogotá';
		insert objSucursal;
		objCandidato 						= TestCreaObjetos.CrearLeads(1).get(0);
		Id recordTypeId 					= Schema.SObjectType.Task.getRecordTypeInfosByName().get('Actividad de Ventas').getRecordTypeId();
		objReparadora						= TestCreaObjetos.CrearReparadoras(1,null,false).get(0);
		objReparadora.NegociadorAsignado__c	= objRecursoshumanos.id;
		insert objReparadora;
		objTarea 							= TestCreaObjetos.CrearTareas(1, objCandidato.Id, null, recordTypeId, true).get(0);
		objTarea2 							= TestCreaObjetos.CrearTareas(1, null, objReparadora.id, recordTypeId, false).get(0);
		objTarea3 							= TestCreaObjetos.CrearTareas(1, null, objReparadora.id, recordTypeId, false).get(0);
		objTarea4 							= TestCreaObjetos.CrearTareas(1, null, objReparadora.id, recordTypeId, true).get(0);
		objTarea5 							= TestCreaObjetos.CrearTareas(1, null, objReparadora.id, recordTypeId, true).get(0);

	}
	@isTest static void test_method_one() 
	{
		createData();

		List<Task> lstTareas = new List<Task>();
		List<Task> lstTareasUpd = new List<Task>();
		objTarea2.WhatId = objReparadora.id;
		objTarea2.Status = 'Cerrado';
		objTarea2.FechadeUltimoIntentodeLocalizacion__c  = system.today();
		objTarea2.FechaPromesaApartado__c = system.now();
		objTarea2.Escalar_a_Negociador__c = true;
		objTarea2.Subject = 'Llamada por 60 días sin Contacto o Deposito';
		lstTareas.add(objTarea2);
		objTarea3.WhatId = objReparadora.id;
		objTarea3.FechadeUltimoIntentodeLocalizacion__c  = system.today();
		objTarea3.FechaPromesaApartado__c = system.now().addDays(-1);
		objTarea3.Escalar_a_Negociador__c = true;
		objTarea3.Subject = 'Llamada por 90 días sin Contacto o Deposito';
		
		lstTareas.add(objTarea3);
		insert lstTareas;
		objTarea2.FechadeUltimoIntentodeLocalizacion__c  = null;
		objTarea2.FechaPromesaApartado__c = system.now();
		objTarea2.Subject  = 'Llamada de Bienvenida';
		objTarea2.Escalar_a_Administrador__c  = true;
		objTarea2.Escalar_a_Negociador__c = false;
		set<String> setNombresAdmin	= new set<String>(); //set donde se guardan los valores de la lista
      
		Schema.sObjectType sobject_type = Task.getSObjectType(); // Traemos del esquema el objeto de tareas
		Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); // obtenemos los resultados descripción del sObject tareas
		Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //Creamos un mapa de los campos del objeto
		system.debug('field_map -->' + field_map );
		List<Schema.PicklistEntry> pick_list_values = field_map.get('Administrador_Asignado__c').getDescribe().getPickListValues(); //Obtenemos los valores del campo de lista de selección específico
		
		objTarea2.Administrador_Asignado__c = pick_list_values.get(0).getValue();
		objTarea2.Localizado__c  = 'Si';
		objTarea2.Fecha_de_cierre__c = system.now().addDays(100);
		lstTareasUpd.add(objTarea2);
		objTarea4.FechaPromesaApartado__c = system.now().addDays(-1);
		objTarea4.Status = 'Cerrado';
		objTarea4.Subject = 'Llamada por 90 días sin Contacto o Deposito';
		lstTareasUpd.add(objTarea4);
		update lstTareasUpd;
		objTarea5.FechadeUltimoIntentodeLocalizacion__c =system.today();
		objTarea5.FechaPromesaApartado__c =null;
		update objTarea5;
	}

		
}