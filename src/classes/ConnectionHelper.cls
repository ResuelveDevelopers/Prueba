/*******************************************************************************
Desarrollado por:   Resuelve tu deuda
Autor:              Jeisson Hernandez
Proyecto:           Colombia
Descripción:        Clase utilitaria para realizar la conexion via Salesforce to Salesforce

Cambios (Versiones)
-------------------------------------
    No.     Fecha           Autor                       Descripción
    ---     ---             ----------                  --------------------------      
    1.0     28-May-2015     Jeisson Hernandez (JH)      Creación de Clase.
        
*******************************************************************************/

public class ConnectionHelper 
{

    public static Id getConnectionId(String connectionName) {
    
        List<PartnerNetworkConnection> partnerNetConList =
           [Select id from PartnerNetworkConnection where connectionStatus = 'Accepted' and connectionName =:connectionName];
        
        if ( partnerNetConList.size()!= 0 ) {
            return partnerNetConList.get(0).Id;
        }
        
        return null;
    }
    
    public static Id getConnectionOwnerId(String connectionName) {
    
        List<PartnerNetworkConnection> partnerNetConList = 
          [Select createdById from PartnerNetworkConnection where connectionStatus = 'Accepted' and connectionName =:connectionName];
        
        if ( partnerNetConList.size()!= 0 ) {
            return partnerNetConList.get(0).createdById;
        }
        
        return null;
    }
}