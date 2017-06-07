/*******************************************************************************
Desarrollado por:   RTD
Autor:              Jeisson Hernandez
Proyecto:           Colombia III
Descripción:        Clase de prueba que probara la clase WSAsignacionOportunidades_ws 

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		----------                ---------------------------     
    1.0     09-Nov-2015		Jeisson Hernandez(JH)     Creación de la Clase.
*******************************************************************************/

@isTest
private class WSAsignacionOportunidades_tst 
{

	@isTest(seeAllData = true)
	static void testWSAsignacionOportunidades() 
	{
		Test.startTest();
			WSAsignacionOportunidades_ws.asignarOportunidades();
		Test.stopTest();
	}
}