/*******************************************************************************
Desarrollado por:   RTD
Autor:              Jeisson Hernandez
Proyecto:           Colombia III
Descripción:        Clase de prueba que probara la clase WSCamposSCNegociacionCierre_ws 

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		----------                ---------------------------     
    1.0     27-May-2016		Jeisson Hernandez(JH)     Creación de la Clase.
*******************************************************************************/

@isTest
private class WSCamposSCNegociacionCierre_tst 
{

	@isTest(seeAllData = true)
	static void testWSCamposSCNegociacionCierre_ws() 
	{
		Test.startTest();
			WSCamposSCNegociacionCierre_ws.poblarCamposSCNegCierre();
		Test.stopTest();
	}
}