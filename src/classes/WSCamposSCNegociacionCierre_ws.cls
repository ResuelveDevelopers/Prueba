global class WSCamposSCNegociacionCierre_ws 
{
    webservice static void poblarCamposSCNegCierre()
    {
        SchCamposSCNegociacionCierre_sch objSchCampos= new SchCamposSCNegociacionCierre_sch();
        objSchCampos.execute(null); 
    }
}