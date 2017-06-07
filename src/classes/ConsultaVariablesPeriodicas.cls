/*******************************************************************************
Desarrollado por:   RTD
Autor:              Joe Ayala Rodriguez
Proyecto:           Parametrización del IVA Colombia
Descripción:        Clase que busca en la configuración personalizada 'Configuraciones Periodicas Salesforce' de acuerdo a un tipo de variable
					y un rango de fechas retorna el valor de la variable para ese periodo de tiempo.
					El objetivo es usarla desde cualquier objeto Sf para todas las variables del sistema que cambian en el tiempo (IVA, Comisiónes, bonificaciones etc..)
Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		----------                ---------------------------     
    1.0     11-ene-2017		Joe Ayala(JA)     		Creación de la Clase.
*******************************************************************************/
public class ConsultaVariablesPeriodicas 
{
    /*getmapValorActual
     * Metodo que recibe un map de todos los objetos que se esten actualizando y realiza el proceso una sola vez para todos con el fin de 
     * evitar errores con los limites de sf
     */
    public static List<Sobject> getlistValorActual(String Tipo, String campoFecha1, String campoFecha2, List<Sobject> objetos, String Campoactualizable) {
        
        List<Sobject> lstobjectactual = objetos;
        Date fec1,fec2;
        String 		nameobjeto;
        boolean  	enviarmail;
        String   	stremailenvio;
      
        //realizo la consulta de las variables periodicas que se encuentran activas en el sistema
        list<Configuraciones_Periodicas_Salesforce__c>lstConfPeriodicas = [SELECT   Activa__c,Fecha_Final__c,Fecha_inicial__c,Name,Sucursal_Pais__c,Tipo__c,Valor__c, 
                                                                           			Enviar_notificacion_por_correo__c,Notificar_a__c 
                                                                   			 FROM   Configuraciones_Periodicas_Salesforce__c 
                                                                            WHERE 	Tipo__c =:Tipo 
                                                                             AND 	Activa__c = true];
        enviarmail 		= lstConfPeriodicas[0].Enviar_notificacion_por_correo__c;
        stremailenvio 	= lstConfPeriodicas[0].Notificar_a__c;
        
        try{
              for(Sobject miobjeto:objetos)
                {
                    Schema.sObjectType Schemaobjeto = miobjeto.getSObjectType();
                    nameobjeto = Schemaobjeto.getDescribe().getName();
                    system.debug('objeto_Actual    '+Schemaobjeto.getDescribe().getName());
                    
                    //JA Se verifica si en los campos fec1 o fec2 viene la palabra clave today lo que indica que no se tomara un campo del objeto sino la fecha actual
                    if(campoFecha1 == 'TODAY')
                    {
                         fec1 = system.today();
                    }else
                    {     
                       //Obtengo todos los campos del objeto genérico
                       Schema.DescribeSObjectResult dr = Schemaobjeto.getDescribe();
                       for(Schema.Sobjectfield campos: dr.fields.getMap().values())
                            {
                                //Identifico si es el campo enviado en el método
                                if(campos.getDescribe().getName()==campoFecha1){
                                    Schema.DisplayType  camporelacionado = campos.getDescribe().getType();
                                    //Valido el tipo de dato del campo 
                                    if(camporelacionado == 	Schema.DisplayType.DateTime )
                                    {
                                        try{
                                             	DateTime fecdattime =  (DateTime)miobjeto.get(campoFecha1);
                                       			fec1 = fecdattime.date();
                                       			system.debug('\n campo_relacionado  '+ campos + ' es de tipo ' + camporelacionado + ' es una fecha ' + fec1 + '    anterior ' + fecdattime);
                                           }catch(exception ex){
                                            	//Si se generan problemas con la conversion por que el valor venia nul envio este valor al metodo getValorActual   
                                            	fec1 = null;
                                           }
                                    }else if(camporelacionado == Schema.DisplayType.Date )
                                    {
                                        fec1 = (Date)miobjeto.get(campoFecha1);
                                    }
                                }
                            }
                    }
                    
                    if(campoFecha2 == 'TODAY')
                    {
                       fec2 = system.today();
                    }else
                    {
                       //Obtengo todos los campos del objeto genérico
                       Schema.DescribeSObjectResult dr = Schemaobjeto.getDescribe();
                       for(Schema.Sobjectfield campos: dr.fields.getMap().values())
                            {
                                //Identifico si es el campo enviado en el método
                                if(campos.getDescribe().getName()==campoFecha2)
                                {
                                    Schema.DisplayType  camporelacionado = campos.getDescribe().getType();
                                    //Valido el tipo de dato del campo 
                                    if(camporelacionado == 	Schema.DisplayType.DateTime )
                                    {
                                        try{
                                             	DateTime fecdattime =  (DateTime)miobjeto.get(campoFecha2);
                                       			fec2 = fecdattime.date();
                                       			system.debug('\n campo_relacionado  '+ campos + ' es de tipo ' + camporelacionado + ' es una fecha2 ' + fec2 + '    anterior ' + fecdattime);
                                        }catch(exception ex){
                                            //Si se generan problemas con la conversion por que el valor venia null envio este valor al metodo getValorActual   
                                            fec2 = null;
                                        }
                                    }else if(camporelacionado == Schema.DisplayType.Date )
                                    {
                                        fec2 = (Date)miobjeto.get(campoFecha2);
                                    }
                                }
                            }//cierre for
                    }
                    
                   
                    Decimal valorfin = getValorActual(Tipo,fec1, fec2, nameobjeto,lstConfPeriodicas);
                    system.debug('valorfin   '  + valorfin );
                    //Actualizo el campo generico con el resultado del método getValorActual
                    Decimal campoant = (Decimal)miobjeto.put(Campoactualizable, valorfin);
                    system.debug('\n\n Se envia nuevo  ' + Campoactualizable + ' para el Objeto ' + miobjeto.getSObjectType() + ' con el valor  ' +  miobjeto.get(Campoactualizable) + ' pendiente guardar directamente desde el trigger');
                    
                }
              
        }catch(exception e){
            //JA En caso de fallo en el proceso por cualquier tema tecnicoo de permisos, se enviará mail notificando el error
            system.debug('\n\n Se presentó un fallo en la actualización de la variable '+ Campoactualizable + ' en el objeto '   + nameobjeto + ', error presentado: '+ e);
            if(enviarmail == true)
            {
                Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
                String strCorreos = stremailenvio;
                String[] toAddresses = strCorreos.split(',');
                mail.setToAddresses(toAddresses);
                mail.setSubject('Alerta! Error presentado en actualización de campo ' + Campoactualizable +' en el objeto '   + nameobjeto);
                mail.setPlainTextBody('buen dia; \n\n'
                                      + 'Se presentó un fallo en la actualización de la variable '+ Campoactualizable + ' en el objeto '   + nameobjeto + ', error presentado: '+ e
                                      + '\n\n Por favor verifique que los campos que intenta actualizar existen y tienen permiso de lectura y escritura'  );
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            
            
        } 
        
        
       return objetos; 
    }
    
    /*getValorActual Metodo que retorna un valor de la configuración personalizada Configuraciones Periodicas Salesforce  
      que cambia dependiendo del rango de tiempo en el que se encuentre
      recibe los siguientes valores:
      Tipo:			nombre de la variable que se va abuscar en la configuracion personalizada ej IVA
      Fecha1 		fecha inicial con la que se debe buscar el valor para un rango de tiempo determinado
      Fecha2    	Fecha opcional si la fecha inicial se encuentre nula con la cula se buscará l valor para un rango de tiempo determinado
      Nombreobjeto  nombre del objeto que invoca el metodo */
    public static  Decimal getValorActual(String Tipo, Date Fecha1, Date Fecha2, String Nombreobjeto,list<Configuraciones_Periodicas_Salesforce__c>lstConfPeriodicas ) {
        
       Decimal 	Valoractual;
       boolean 	Rangoinexistente = true;
       date   	Fechasinrango;
       String   stremailenvio;
       boolean  enviarmail; 
       
       for(Configuraciones_Periodicas_Salesforce__c varperiodica: lstConfPeriodicas)
        {
            enviarmail = varperiodica.Enviar_notificacion_por_correo__c;
            stremailenvio = varperiodica.Notificar_a__c;
            //Inicialmente valida el rango con la fecha definida para el objeto 
            If(Fecha1 <> null)
            {
                if(varperiodica.Fecha_inicial__c <=Fecha1 && varperiodica.Fecha_Final__c >=Fecha1 && varperiodica.Tipo__c == Tipo)
                {
                    Valoractual = varperiodica.Valor__c;
                    Rangoinexistente = false;
                }else
                {
                    Fechasinrango = Fecha1;
                }
                
                 // Si la fecha definida para el objeto es nula el metodo recibe una segunda fecha ej fecha de creación, para evitar 
                 // que se generen errores o no se realicen los calculos en el momento de la creacion o modificacion de un objeto  
            }else if(Fecha2 <> null)
            {
                if(varperiodica.Fecha_inicial__c <=Fecha2 && varperiodica.Fecha_Final__c >=Fecha2 && varperiodica.Tipo__c == Tipo)
                {
                    Valoractual = varperiodica.Valor__c;
                    Rangoinexistente = false;
                }else
                {
                    Fechasinrango = Fecha2;
                }
            }
        }
        
        if(Rangoinexistente == true)
        {
            Valoractual = 1;
            if(enviarmail == true)
            {
                Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
                String strCorreos = stremailenvio;
                String[] toAddresses = strCorreos.split(',');
                mail.setToAddresses(toAddresses);
                mail.setSubject('Alerta! Variable Periodica de tipo: ' + Tipo +' sin rango  ');
                mail.setPlainTextBody('buen dia; \n\n'
                                      + 'Se detectaron configuraciones Periodicas de tipo: ' + Tipo + ' sin rangos válidos para la fecha: ' + Fechasinrango  + ' en el objeto ' + Nombreobjeto
                                      + '\n\n Por favor actualice los rangos y los registros afectados, los cuales quedaran con un valor provisional de ' + Valoractual + '% en el campo porcentaje de ' + Tipo );
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            	
        }
        
        return Valoractual;
    }
    
}