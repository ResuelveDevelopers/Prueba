/*******************************************************************************
Desarrollado por:   RTD
Autor:              Esteban Heredia
Descripción:        Clase de prueba ProgramarClases_ctr 

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha           Autor                       Descripción
    ---     -----------     ----------                  ---------------------------     
    1.0     24-May-2016     Esteban Heredia(EH)         Clase de prueba ProgramarClases_ctr
*******************************************************************************/
@isTest
private class ProgramarClases_tst 
{
	@isTest static void test_method_one() 
	{
		Test.startTest();
			ProgramarClases_ctr programarClases = new ProgramarClases_ctr();
			programarClases.meses = '1';
			programarClases.horas = '6';
			programarClases.minutos = '10';
			programarClases.dia = '20';
			programarClases.clase = 'SchAsignacionOportunidades_sch';
			List<SelectOption> lstClasesProgramadastst = programarClases.lstClasesProgramadas;
			List<SelectOption> lstMesestst = programarClases.lstMeses;
			List<SelectOption> lstHorastst = programarClases.lstHoras;
			List<SelectOption> lstMinutostst = programarClases.lstMinutos;
			List<SelectOption> lstDiastst = programarClases.lstDias;
			programarClases.ProgramarClase();
		Test.stopTest();
	}

	@isTest static void test_method_two() 
	{
		Test.startTest();
			ProgramarClases_ctr programarClases = new ProgramarClases_ctr();
			programarClases.meses = '10';
			programarClases.horas = '6';
			programarClases.minutos = '10';
			programarClases.dia = '20';
			programarClases.clase = 'SchAsignacionOportunidades_sch';
			programarClases.anioCompleto = true;
			programarClases.ProgramarClase();
		Test.stopTest();
	}
}