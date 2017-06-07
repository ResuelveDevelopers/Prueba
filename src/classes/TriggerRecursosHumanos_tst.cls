/*******************************************************************************
Desarrollado por:   Resuelve tu deuda
Autor:              Jeisson Hernandez
Proyecto:           Colombia
Descripción:        Clase de pruebas para TriggerRecursos Humanos

Cambios (Versiones)
-------------------------------------
    No.     Fecha           Autor                       Descripción
    ---     ---             ----------                  --------------------------      
    1.0     28-May-2015     Jeisson Hernandez (JH)      Creación de Clase.
        
*******************************************************************************/
@isTest(seeAllData = true)
public with sharing class TriggerRecursosHumanos_tst 
{
	static testMethod void crearRecursoHumano() 
	{
		Empresa__c objEmpresa = new Empresa__c();
		objEmpresa.Name = 'Empresa 1 ';
		insert objEmpresa;

		Sucursal__c objSucursal = new Sucursal__c();
		objSucursal.Name = 'Sucursal 1';
		insert objSucursal;
		
		Puesto__c objPuesto = new Puesto__c();
		objPuesto.Name= 'Puesto Prueba';
		insert objPuesto;
		
		Posicion__c objPosicion = new Posicion__c();
		objPosicion.Puesto__c = objPuesto.Id;
		insert objPosicion; 

		RecursosHumanos__c objRHDirector = new RecursosHumanos__c();
		objRHDirector.Name = 'UserPrueba Director' + DateTime.now();
		objRHDirector.SueldoFijo__c = 150.00;
		objRHDirector.Puesto__c = objPuesto.Id;
		objRHDirector.Posicion2__c = objPosicion.Id;
		insert objRHDirector;
		
		Test.startTest();
		RecursosHumanos__c RdRH = new RecursosHumanos__c();
		RdRH.Name = 'UserPrueba' + DateTime.now();
		RdRH.IdEmpresaMexico__c = objEmpresa.Id;
		RdRH.IdSucursalMexico__c = objSucursal.Id;
		RdRH.SueldoFijo__c = 100.00;
		RdRH.Puesto__c = objPuesto.Id;
		RdRH.Posicion2__c = objPosicion.Id;
		RdRH.Director__c = objRHDirector.Id;
		RdRH.IdDirectorMexico__c = objRHDirector.Id;
		RdRH.IdSubDirectorMexico__c = objRHDirector.Id; 
		RdRH.SubDirector__c = objRHDirector.Id;
		RdRH.IdSubdirectorAnteriorMexico__c = objRHDirector.Id;
		RdRH.SubdirectorAnterior__c = objRHDirector.Id;
		RdRH.IdGerenteMexico__c = objRHDirector.Id;
		RdRH.Gerente__c = objRHDirector.Id;
		RdRH.IdGerenteAnteriorMexico__c = objRHDirector.Id;
		RdRH.GerenteAnterior__c = objRHDirector.Id;
		RdRH.IdTeamLeaderMexico__c = objRHDirector.Id;
		RdRH.Team_Leader__c = objRHDirector.Id;
		RdRH.IdTeamLeaderAnteriorMexico__c = objRHDirector.Id;
		RdRH.TeamLeaderAnterior__c = objRHDirector.Id;		
		RdRH.IdTeamLeaderMexico__c = objRHDirector.Id;
		RdRH.Team_Leader__c = objRHDirector.Id;		
		RdRH.IdSupervisorMexico__c = objRHDirector.Id;
		RdRH.Supervisor__c = objRHDirector.Id;		
		RdRH.IdJefeDirectoMexico__c = objRHDirector.Id;
		RdRH.JefeDirecto__c = objRHDirector.Id;
		RdRH.NombreTipoRegistroMexico__c = 'Administrativo';
		insert RdRH;
		
		RdRH.IdSucursalMexico__c = null;
		RdRH.IdDirectorMexico__c = null;
		RdRH.IdSubDirectorMexico__c = null; 
		RdRH.IdSubdirectorAnteriorMexico__c = null;
		RdRH.IdGerenteMexico__c = null;
		RdRH.IdGerenteAnteriorMexico__c = null;
		RdRH.IdTeamLeaderMexico__c = null;
		RdRH.IdTeamLeaderAnteriorMexico__c = null;
		RdRH.IdTeamLeaderMexico__c = null;
		RdRH.IdSupervisorMexico__c = null;
		RdRH.IdJefeDirectoMexico__c = null;
		RdRH.NombreTipoRegistroMexico__c = 'Negociación';
		update RdRH;
		
		RdRH.NombreTipoRegistroMexico__c = 'Servicio al Clientes';
		update RdRH;
				
		RdRH.NombreTipoRegistroMexico__c = 'Ventas';
		update RdRH;
		
		RdRH.IdDirectorMexico__c = objRHDirector.Id;
		RdRH.IdSubDirectorMexico__c = objRHDirector.Id;
		RdRH.IdSubdirectorAnteriorMexico__c = objRHDirector.Id;
		RdRH.IdGerenteMexico__c = objRHDirector.Id;
		RdRH.IdGerenteAnteriorMexico__c = objRHDirector.Id;
		RdRH.IdTeamLeaderMexico__c = objRHDirector.Id;
		RdRH.IdTeamLeaderAnteriorMexico__c =objRHDirector.Id;
		RdRH.IdSupervisorMexico__c =objRHDirector.Id;
		RdRH.IdJefeDirectoMexico__c =objRHDirector.Id;
		RdRH.IdSucursalMexico__c = objSucursal.Id;
		RdRH.IdEmpresaMexico__c = objEmpresa.Id;
		update RdRH;

		Test.stopTest(); 
	}
}