/********************************************************************************************************
Desarrollado por:   Resuelve
Autor:              Angela Munévar(AM)
Proyecto:           Resuelve tu Deuda
Descripción:        Clase permite Realizar una solicitud de fondeo

Cambios (Versiones)
--------------------------------------------------------------------------------------------------------
    No.     Fecha               Autor                       Descripción
    ---     -----------         ------------------------    --------------------------      
    1.0     05-Abr-2016         Angela Munévar(AM)          Creación de la Clase 
***************************************************************************************/
public class SolicitudDeFondo_ctr {

        public boolean VerPerfilSofipoRecordtypes {get;set;}
        public boolean VerPerfilSofipo{get;set;}
        public boolean VerPagosEstruct{get;set;}
        public boolean VerPerfilSofipoE{get;set;}
        public boolean VerAlianz{get;set;}
        public boolean VerNotasAlianz{get;set;}
        public SolicitudesDeFondos__c Solicitud_fondos{get;set;}
        public boolean VerSofipo{get;set;}

    public SolicitudDeFondo_ctr(ApexPages.StandardController controller) 
    {
        if(controller!=null && controller.getRecord()!=null)
        {
            this.Solicitud_fondos = (SolicitudesDeFondos__c)controller.getRecord();
            system.debug('\n Solicitud_fondos '+ this.Solicitud_fondos);
            id PerfilId=UserInfo.getProfileId();
            Set<id> PrifilesValid = new Set<id>();

            Conf_IdsDesarrollos__c IdAdmin= Conf_IdsDesarrollos__c.getValues('PerfilAdministradorDeSistema');
            Conf_IdsDesarrollos__c IdGerenteFinanzas= Conf_IdsDesarrollos__c.getValues('PerfilGerenteDeFinanzas');
            System.debug('+++IdAdmin '+IdAdmin);

            VerAlianz = true;  // siempre se muestra
            VerSofipo = false;  // solo se muestra para Solicitud de Fondos RTFin
            
            // perfiles administrador y gerente finanzas
            if(IdAdmin != null )
                PrifilesValid.add(IdAdmin.Id__c);
            if(IdGerenteFinanzas != null)
                PrifilesValid.add(IdGerenteFinanzas.Id__c);

            if(PrifilesValid.contains(PerfilId))
            {
                    VerPerfilSofipoRecordtypes=true;  // muestra el campo Estatus__c
                    VerPerfilSofipo=true;
                    VerPagosEstruct = true;
                    VerNotasAlianz = true;
            }
            else 
            {
                System.debug('+++ entro al else');
                   VerPerfilSofipoRecordtypes=false;  
                   VerPerfilSofipo=false; 
                   VerPagosEstruct=false; 
                   VerNotasAlianz = false;
                   VerPerfilSofipoE = true;
            }
        }
                
    }



}