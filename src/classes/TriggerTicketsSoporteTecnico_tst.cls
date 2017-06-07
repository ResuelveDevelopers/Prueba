/*******************************************************************************
Desarrollado por:   Resuelve tu deuda
Autor:              Jeisson Hernandez
Proyecto:           Colombia
Descripción:        Clase de pruebas para TriggerTicketsSoporteTecnico que evita la creación de casos en los horarios establecidos por RTD

Cambios (Versiones)
-------------------------------------
    No.     Fecha           Autor                       Descripción
    ---     ---             ----------                  --------------------------      
    1.0     25-May-2015     Jeisson Hernandez (JH)      Creación de Trigger.
    1.1     23-Mar-2016     Esteban Heredia (EH)        Modificación clase original-actualización con configuración personalizada    
*******************************************************************************/
@isTest
private class TriggerTicketsSoporteTecnico_tst 
{
    public static TicketsSoporteTecnico__c objSoporteTecnico;

    public static void createData()
    {
        RestriccionSoporteTecnico__c    objHorarioService  = new RestriccionSoporteTecnico__c();
        objHorarioService.Name = 'Incidente';
        objHorarioService.Activo__c = true;
        objHorarioService.Hora_Fin_L_J__c = 9;
        objHorarioService.Hora_Fin_V__c = 17;
        objHorarioService.Hora_Inicio_L_J__c = 9;
        objHorarioService.Hora_Inicio_V__c = 7;
        objHorarioService.Minuto_Fin_L_J__c = 0;
        objHorarioService.Minuto_Fin_V__c = 0;
        objHorarioService.Minuto_Inicio_L_J__c = 0;
        objHorarioService.Minuto_Inicio_V__c = 0;
        insert objHorarioService;
        RestriccionSoporteTecnico__c    objHorarioService2  = new RestriccionSoporteTecnico__c();
        objHorarioService2.Name = 'Recursos Humanos';
        objHorarioService2.Activo__c = true;
        objHorarioService2.Hora_Fin_L_J__c = 9;
        objHorarioService2.Hora_Fin_V__c = 17;
        objHorarioService2.Hora_Inicio_L_J__c = 9;
        objHorarioService2.Hora_Inicio_V__c = 7;
        objHorarioService2.Minuto_Fin_L_J__c = 0;
        objHorarioService2.Minuto_Fin_V__c = 0;
        objHorarioService2.Minuto_Inicio_L_J__c = 0;
        objHorarioService2.Minuto_Inicio_V__c = 0;
        insert objHorarioService2;


    }

    static testMethod void crearTicketsSoporteTecnico() 
    {
        Test.startTest();
            createData();
            Id SoporteTecnicoRecordTypeId = Schema.SObjectType.TicketsSoporteTecnico__c.getRecordTypeInfosByName().get('Soporte Técnico').getRecordTypeId();
            TicketsSoporteTecnico__c objCaso = new TicketsSoporteTecnico__c();
            objCaso.RecordTypeId = SoporteTecnicoRecordTypeId;
            objCaso.Asunto__c = 'Test Horarios Trigger';
            objCaso.Estado__c = 'Abierto';
            objCaso.OrigenCaso__c = 'Salesforce';
            objCaso.NombretiporegistroMexico__c = 'Incidente';
            insert objCaso;
            objCaso.NombretiporegistroMexico__c = 'Recursos Humanos';
            update objCaso;
        Test.stopTest(); 
    }
}