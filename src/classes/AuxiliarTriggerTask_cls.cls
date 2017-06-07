/*****************************************************************************************************
* Desarrollado por: RTD
* Autor:            Esteban Heredia (EH)
* Proyecto:         Colombia 
* Descripción:      Lógica de negocio para el trigger de tareas              
*
* Cambios (Versiones)
* -------------------------------------
*           No.     fecha           Autor                     Descripción
*           -----   ----------      ------------------------    ---------------
* @version  1.0     30-Mar-2016     Esteban Heredia (EH)        Creación de la clase           
*******************************************************************************************************/
public with sharing class AuxiliarTriggerTask_cls 
{
  public static string strApiObjeto;
  public static Map<String,List<Task>> mapTareaPorObjCandCont;
  public static Map<String,List<Task>> mapTareaPorObj;
  public static Map<Id, Reparadora__c> mapReparadoraById;


  public static void handlerAfterInsert(List<Task> lstNewRecords) 
  {
    //Se dividirá la lógica por cada objeto por aparte, para este objetivo se utilizará el método findObjectAPIName
    // Únicamente para los candidatos y contactos, dado que el campo que se llena al crear la tarea es whoId
    mapTareaPorObjCandCont = obtenerTareaObjetoCandCont(lstNewRecords); 
    // Para los demás objetos que tienen tareas, campo whatId
    mapTareaPorObj = obtenerTareaObjeto(lstNewRecords);

    /********OBJETO CANDIDATOS (Oportunidades)***************/
    //Empezamos por obtener las tareas relacionadas con candidatos
    List<Task> lstTareasCandidatos = listaTareasObjEsp('Lead',mapTareaPorObjCandCont);
    system.debug('\n\n lstTareasCandidatos--> ' + lstTareasCandidatos);
    if(!lstTareasCandidatos.isEmpty())
    {
      handlerTareasCandidatosAI(lstTareasCandidatos);
    }
    /****FIN OBJETO CANDIDATOS****/

    /********OBJETO REPARADORA***************/
    //Empezamos por obtener las tareas relacionadas con REPARADORAS
    List<Task> lstTareasReparadora = listaTareasObjEsp('Reparadora__c',mapTareaPorObj);
    system.debug('\n\n lstTareasReparadora--> ' + lstTareasReparadora);
    if(!lstTareasReparadora.isEmpty())
    {
      handlerTareasReparadorasAI(lstTareasReparadora);
    }
    /****FIN OBJETO REPARADORA****/
  }

  // Lógica de negocio AFTER INSERT reparadoras
  public static void handlerTareasReparadorasAI(List<Task> lstTareasReparadora)
  {
    
    // Creamos un mapa con la reparadora y su fecha máxima de promesa
    Map<String,Date>  mapFechaPromesaMaxPorReparadora =  crearMapafechaPromesa(mapReparadoraById.values());
    system.debug('\n\n mapFechaPromesaMaxPorReparadora--> ' + mapFechaPromesaMaxPorReparadora);

    for(Task objTasktemp: lstTareasReparadora) 
    {
      // se actualiza la fecha de último contacto únicamente cuando se localizó al cliente
      if(objTasktemp.Localizado__c == 'Si')
      { 
        mapReparadoraById.get(objTasktemp.whatId).FechaUltimoContacto__c = system.now().date();
      }
      // Vamos a actualizar la fecha de última promesa de apartado de la reparadora, con la última mayor que se coloco en las tareas
      if(mapReparadoraById.containsKey(objTasktemp.whatId) && mapFechaPromesaMaxPorReparadora.containsKey(objTasktemp.whatId))
      {
        // SOLO los siguientes asuntos cuentan como cambio del último contacto con el cliente
        if(objTasktemp.FechaPromesaApartado__c != null && objTasktemp.FechaPromesaApartado__c >= mapFechaPromesaMaxPorReparadora.get(objTasktemp.whatId)  && (objTasktemp.Subject == 'Llamada Telefonica Post Venta # 1' ||objTasktemp.Subject == 'Llamada por 30 días sin Contacto o Deposito' ||objTasktemp.Subject == 'Llamada por 60 días sin Contacto o Deposito' ||objTasktemp.Subject == 'Llamada por 90 días sin Contacto o Deposito' || objTasktemp.Subject =='Llamada Telefonica de Atencion al Cliente' || objTasktemp.Subject =='Respuesta a Correo Electrónico'))
        {
          mapReparadoraById.get(objTasktemp.whatId).FechaPromesaApartado__c = objTasktemp.FechaPromesaApartado__c.date();
        }
        else if(objTasktemp.FechaPromesaApartado__c != null && objTasktemp.FechaPromesaApartado__c < mapFechaPromesaMaxPorReparadora.get(objTasktemp.whatId)  && (objTasktemp.Subject == 'Llamada Telefonica Post Venta # 1' ||objTasktemp.Subject == 'Llamada por 30 días sin Contacto o Deposito' ||objTasktemp.Subject == 'Llamada por 60 días sin Contacto o Deposito' ||objTasktemp.Subject == 'Llamada por 90 días sin Contacto o Deposito' || objTasktemp.Subject =='Llamada Telefonica de Atencion al Cliente' || objTasktemp.Subject =='Respuesta a Correo Electrónico'))
        {
          mapReparadoraById.get(objTasktemp.whatId).FechaPromesaApartado__c = mapFechaPromesaMaxPorReparadora.get(objTasktemp.whatId);
        }
      }
    }
    if(!mapReparadoraById.values().isEmpty())
    {
      update mapReparadoraById.values();
    }
  }

  /**
     * Método utilizado para traer las reparadoras papás con su respectiva fecha de promesa máxima ( por si llegan a colocar una menor valdría la q ya existe)
     * @author EH
     * @param  lstAllTaskObjEsp: Todas las tareas
     * @return Lista de los papas relacionados a las tareas
     */
  public static Map<String,Date> crearMapafechaPromesa(List<Reparadora__c> lstIdReparadoraIn)
  {
    DateTime dtFechaPromesaMax;
    Map<String,Date> mapRepPorPromesaMax = new Map<String,Date>();
    for(Reparadora__c objReparadoraTemp: lstIdReparadoraIn) 
    {
      dtFechaPromesaMax = DateTime.newInstance(1970, 1, 01);
      for(Task objTaskTemporal:objReparadoraTemp.Tasks)
      {
        if(objTaskTemporal.FechaPromesaApartado__c != null && objTaskTemporal.FechaPromesaApartado__c > dtFechaPromesaMax)
        {
          dtFechaPromesaMax = objTaskTemporal.FechaPromesaApartado__c;
        }
        mapRepPorPromesaMax.put(objReparadoraTemp.id,dtFechaPromesaMax.date());
      }
    }
    return mapRepPorPromesaMax;
  }

  // Lógica de negocio AFTER INSERT candidatos
  public static void handlerTareasCandidatosAI(List<Task> lstTareasCandidatos)
  {
    //Creamos un set con todos los candidatos papás
    Set<Id> setIdLead = buscarPapasTareas(lstTareasCandidatos);
    //Traemos a sus candidatos papás
    Map<Id, Lead> mapLeadById = new Map<Id, Lead>([select Id,FechaUltiActVentas__c from Lead where Id IN :setIdLead]);
    system.debug('\n\n mapLeadById--> ' + mapLeadById);

    //Dividimos ahora el respectivo objeto en sus tipos de registro
    
    //**Inicio tipo de registro Actividad de Ventas**
    List<Task> lstTareasCandActVentas = obtenerTareasTipoRegEsp('Actividad de Ventas',lstTareasCandidatos);
    system.debug('\n\n lstTareasCandActVentas--> ' + lstTareasCandActVentas);
    if(!lstTareasCandActVentas.isEmpty())
    {
      handlerTareasCandActVentAI(lstTareasCandActVentas,mapLeadById);
    }
    //**Fin tipo de resgitro actividad de ventas**
  }

  public static void handlerTareasCandActVentAI(List<Task> lstTareasCandActVentas,Map<Id, Lead> mapLeadById)
  {
    // se actualizará el campo FechaUltiActVentas__c del objeto candidato, estó con la fecha de creación de la 
    // última actividad de ventas

    for(Task objTaskTemp : lstTareasCandActVentas) 
    {
      if(mapLeadById.containsKey(objTaskTemp.whoId))
      {
        mapLeadById.get(objTaskTemp.whoId).FechaUltiActVentas__c =  objTaskTemp.CreatedDate; 
      }
    }

    if(!mapLeadById.values().isEmpty())
    {
      update mapLeadById.values();
    }
  }

  
  public static void handlerAfterUpdate(List<Task> lstNewRecords) 
  {
    //Se dividirá la lógica por cada objeto por aparte, para este objetivo se utilizará el método findObjectAPIName
    // Para los objetos que tienen tareas, campo whatId
    mapTareaPorObj = obtenerTareaObjeto(lstNewRecords);
    /********OBJETO REPARADORA***************/
    //Empezamos por obtener las tareas relacionadas con reparadoras
    List<Task> lstTareasReparadora = listaTareasObjEsp('Reparadora__c',mapTareaPorObj);
    system.debug('\n\n lstTareasReparadora--> ' + lstTareasReparadora);
    // Los pápas(Reparadoras) ya fueron calculados en el before update para realizar un solo query
    if(!lstTareasReparadora.isEmpty())
    {
      //Creamos un set con todos las reparadoras papás
      Set<Id> setIdReparadora = buscarPapasTareas(lstTareasReparadora);
      traerReparadora(setIdReparadora);
      handlerReparadoraAU(lstTareasReparadora,mapReparadoraById);
    }
    /****FIN OBJETO REPARADORA****/
  }


  // Lógica de negocio AFTER UPDATE Reparadora
  public static void handlerReparadoraAU(List<Task> lstTareasReparadora, Map<Id, Reparadora__c>  mapReparadoraByIdIn)
  {
    
    // fecha fictisia para iniciar así la fecha del último contacto con el cliente
    Date dtTiempoInicial = Date.newInstance(1970, 1, 01);
    // Creamos un mapa con la reparadora y su fecha máxima de promesa
    Map<String,Date>  mapFechaPromesaMaxPorReparadora =  crearMapafechaPromesa(mapReparadoraByIdIn.values());
    system.debug('\n\n mapFechaPromesaMaxPorReparadoraAU--> ' + mapFechaPromesaMaxPorReparadora);
    
    // Colocamos como fecha último contacto la fecha de cierre de la tarea más reciente cerrada
    for(Task objTasktemp: lstTareasReparadora) 
    {
      // SOLO los siguientes asuntos cuentan como cambio del último contacto con el cliente
      if((objTasktemp.Subject == 'Llamada de Bienvenida' || objTasktemp.Subject == 'Llamada Telefonica Post Venta # 1' ||objTasktemp.Subject == 'Respuesta a Correo Electrónico' ||objTasktemp.Subject == 'Llamada por 30 días sin Contacto o Deposito' ||objTasktemp.Subject == 'Llamada por 60 días sin Contacto o Deposito' ||objTasktemp.Subject == 'Llamada por 90 días sin Contacto o Deposito' || objTasktemp.Subject =='Llamada Telefonica de Atencion al Cliente') )
      {
        if(mapReparadoraByIdIn.containsKey(objTasktemp.whatId))
        {
          // se actualiza la fecha de último contacto únicamente cuando se localizó al cliente
          if(objTasktemp.Localizado__c == 'Si')
          {
            // Si la fecha de último contacto no existe, colocamos una fecha muy anterior para asegurarnos que la fecha de cierre de las nuevas tareas sean mayor a la inicial
                //Date dtFechaUltimoContactCliente = mapReparadoraByIdIn.get(objTasktemp.whatId).FechaUltimoContacto__c !=null ? mapReparadoraByIdIn.get(objTasktemp.WhatId).FechaUltimoContacto__c : dtTiempoInicial;  
            mapReparadoraByIdIn.get(objTasktemp.whatId).FechaUltimoContacto__c = system.now().date();
            //lstRepUpd.add(mapReparadoraByIdIn.get(objTasktemp.whatId)); 
          }
          // Se actualiza la fecha de promesa siempre que se actualiza en alguna tarea
          if( mapReparadoraByIdIn.containsKey(objTasktemp.whatId) && mapFechaPromesaMaxPorReparadora.containsKey(objTasktemp.whatId))
          {
            // Vamos a actualizar la fecha de última promesa de apartado de la reparadora, con la última mayor que se coloco en las tareas
            if(objTasktemp.FechaPromesaApartado__c != null && objTasktemp.FechaPromesaApartado__c >= mapFechaPromesaMaxPorReparadora.get(objTasktemp.whatId))
            {
              mapReparadoraByIdIn.get(objTasktemp.whatId).FechaPromesaApartado__c = objTasktemp.FechaPromesaApartado__c.date();
              //lstRepUpd.add(mapReparadoraByIdIn.get(objTasktemp.whatId));
            }
            else if(objTasktemp.FechaPromesaApartado__c != null && objTasktemp.FechaPromesaApartado__c < mapFechaPromesaMaxPorReparadora.get(objTasktemp.whatId))
            {
              mapReparadoraByIdIn.get(objTasktemp.whatId).FechaPromesaApartado__c = mapFechaPromesaMaxPorReparadora.get(objTasktemp.whatId);
              //lstRepUpd.add(mapReparadoraByIdIn.get(objTasktemp.whatId));
            }
            
          }
        }
      }
    }
    if(!mapReparadoraByIdIn.values().isEmpty())
    {
      update mapReparadoraByIdIn.values();
    }
  }

  public static void handlerBeforeInsert(List<Task> lstNewRecords) 
  {
    //Se dividirá la lógica por cada objeto por aparte, para este objetivo se utilizará el método findObjectAPIName
    // Para los objetos que tienen tareas, campo whatId
    mapTareaPorObj = obtenerTareaObjeto(lstNewRecords);
    /********OBJETO REPARADORA***************/
    //Empezamos por obtener las tareas relacionadas con reparadoras
    List<Task> lstTareasReparadora = listaTareasObjEsp('Reparadora__c',mapTareaPorObj);
    system.debug('\n\n lstTareasReparadora--> ' + lstTareasReparadora);
    if(!lstTareasReparadora.isEmpty())
    {
        //Creamos un set con todos las reparadoras papás hasta que se realice està parte en el befor
        Set<Id> setIdReparadoras = buscarPapasTareas(lstTareasReparadora);
        // Creamos el mapa de reparadoras tanto para el before como after 
        traerReparadora(setIdReparadoras);
        Set<Task> setTareasReparadoras = new Set<Task>(lstTareasReparadora);
        // Mapa donde obtendremos los usuarios cuando se escale una tarea a administrador, en primer lugar recorremos el valor de los valores de la lista de selección
        set<String> setNombresAdmin = valoresCampoListaSeleccion('administrador_asignado__c'); // Traemos los valores del campo administrador asignado
        Map<string,string> mapIdByName = new Map<string,string>();
        List<User> lstUserAdmin = [Select Name,Id From User Where IsActive = true and Name IN: setNombresAdmin];
        system.debug('lstUserAdmin-->' + lstUserAdmin); // Colocamos los valores de los usurios en un mapa, para que cuando eligan el campo de administrador, nos podamos traer el usuario correspondiente
        for (User objUser : lstUserAdmin)
          {
              mapIdByName.put(objUser.Name, objUser.id);
          }

        //Traemos el horario de oficina de Colombia, con sus respectivos festivos
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name='FestivosColombia'];

        for(Task objTaskTemp: lstNewRecords) 
        {
            if(setTareasReparadoras.contains(objTaskTemp))
            {
                  if(objTaskTemp.Subject == 'Respuesta a Correo Electrónico')
                    objTaskTemp.Localizado__c = 'Si';

                // Si el campo “Fecha de Promesa” de la actividad no está vacío entonces “Fecha de vencimiento” será igual a “Fecha de promesa” + 2 días hábiles 
                  if(objTasktemp.FechaPromesaApartado__c != null)
                  {
                    Datetime fechaPromesa = objTasktemp.FechaPromesaApartado__c; 
                    Datetime dt = datetime.newInstanceGmt(fechaPromesa.date(), fechaPromesa.time());  // Para que quede en hora local
                    Datetime dtPrimerDia  =   BusinessHours.nextStartDate(bh.id, dt.addDays(1));
                    objTasktemp.ActivityDate  =   BusinessHours.nextStartDate(bh.id, dtPrimerDia.addDays(1)).date(); // Aumentar dos días habiles y validar festivos
                  }
                  else if(objTasktemp.FechadeUltimoIntentodeLocalizacion__c != null )
                  {
                    Date dtFechaUltimoIntentoLoc =  objTasktemp.FechadeUltimoIntentodeLocalizacion__c;
                    Datetime dt = DateTime.newInstanceGmt(dtFechaUltimoIntentoLoc, System.now().time()); // Para que quede en hora local
                    objTasktemp.ActivityDate  = BusinessHours.nextStartDate(bh.id ,dt.addDays(1)).date(); // Aumentar un día habiles y validar festivos
                  }
                  else if( objTasktemp.Subject == 'Llamada Telefonica de Atencion al Cliente')
                  {
                    objTasktemp.ActivityDate  = BusinessHours.nextStartDate(bh.id ,system.now().addDays(1)).date(); // Aumentar un día habiles y validar festivos
                  }

                  // se coloca la fecha de escalación a la fecha de hoy y el propoietario al que eligió el usuario, cuando el usuario selecciona escalación al negociador o administrador
                  if(objTaskTemp.Escalar_a_Negociador__c && mapReparadoraById.get(objTaskTemp.whatId).Negociadorasignado__r.Usuario__c != null)
                  {
                    objTasktemp.OwnerId = mapReparadoraById.get(objTaskTemp.whatId).Negociadorasignado__r.Usuario__c;
                    objTasktemp.FechaEscalacion__c= system.today();
                  }
                  else if (objTaskTemp.Escalar_a_Negociador__c && mapReparadoraById.get(objTaskTemp.whatId).Negociadorasignado__r.Usuario__c == null)
                    objTasktemp.addError(' No hay un negociador asociado a la reparadora (Usuario recursos humanos), no se puede escalar');
                  else if (objTaskTemp.Escalar_a_Administrador__c)
                  {
                    if( mapIdByName.containsKey(objTaskTemp.Administrador_Asignado__c))
                    {
                      objTasktemp.OwnerId = mapIdByName.get(objTaskTemp.Administrador_Asignado__c);
                      objTasktemp.FechaEscalacion__c= system.today();
                    }
                    else 
                      objTasktemp.addError(' El nombre del administrador ya no existe');  
                  }
                  if(objTaskTemp.Escalar_a_Administrador__c && objTaskTemp.Escalar_a_Negociador__c)
                    objTasktemp.addError(' Seleccione solo un escalamiento');
            }
        }
    }
    /****FIN OBJETO REPARADORA****/
  }


  public static void handlerBeforeUpdate(List<Task> lstNewRecords,Map<Id,Task> mapOldMap,Map<Id,Task> mapNewMap) 
  {
    //Se dividirá la lógica por cada objeto por aparte, para este objetivo se utilizará el método findObjectAPIName
    // Para los objetos que tienen tareas, campo whatId
    mapTareaPorObj = obtenerTareaObjeto(lstNewRecords);
    /********OBJETO REPARADORA***************/
    //Empezamos por obtener las tareas relacionadas con reparadoras
    List<Task> lstTareasReparadora = listaTareasObjEsp('Reparadora__c',mapTareaPorObj);
    system.debug('\n\n lstTareasReparadora--> ' + lstTareasReparadora);
    if(!lstTareasReparadora.isEmpty())
    {
      handlerReparadoraBU(lstTareasReparadora,mapOldMap,mapNewMap);
    }
    /****FIN OBJETO REPARADORA****/
  }

  // Lógica de negocio BEFORE UPDATE Tareas de Reparadora
  public static void handlerReparadoraBU(List<Task> lstTareasReparadora,Map<Id,Task> mapOldMap,Map<Id,Task> mapNewMap)
  {
    //Creamos un set con todos los candidatos papás
    Set<Id> setIdReparadora = buscarPapasTareas(lstTareasReparadora);
    // Mapa donde obtendremos los usuarios cuando se escale una tarea a administrador, en primer lugar recorremos el valor de los valores de la lista de selección
    set<String> setNombresAdmin = valoresCampoListaSeleccion('administrador_asignado__c'); // Traemos los valores del campo administrador asignado
    Map<string,string> mapIdByName = new Map<string,string>();
    List<User> lstUserAdmin = [Select Name,Id From User Where IsActive = true and Name IN: setNombresAdmin];
    system.debug('lstUserAdmin-->' + lstUserAdmin); // Colocamos los valores de los usurios en un mapa, para que cuando eligan el campo de administrador, nos podamos traer el usuario correspondiente
    for (User objUser : lstUserAdmin)
      {
          mapIdByName.put(objUser.Name, objUser.id);
      }
    // Creamos el mapa de reparadoras tanto para el before como after
    traerReparadora(setIdReparadora);
    //Traemos el horario de oficina de Colombia, con sus respectivos festivos
    BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name='FestivosColombia'];
    for(Task objTaskTemp: lstTareasReparadora) 
    {
      //Colocamos la fecha de cierre en el momento en que el estatus de la tarea es cerrado
      if(mapOldMap.get(objTaskTemp.id).Status == 'En Proceso' && objTaskTemp.Status == 'Cerrado')
        mapNewMap.get(objTaskTemp.id).Fecha_de_cierre__c = system.now();  

      // Si el campo “Fecha de Promesa” de la actividad no está vacío entonces “Fecha de vencimiento” será igual a “Fecha de promesa” + 2 días hábiles 
      if(mapOldMap.get(objTaskTemp.id).FechaPromesaApartado__c  != mapNewMap.get(objTaskTemp.id).FechaPromesaApartado__c )
      {
        Datetime fechaPromesa = mapNewMap.get(objTaskTemp.id).FechaPromesaApartado__c; 
        Datetime dt = datetime.newInstanceGmt(fechaPromesa.date(), fechaPromesa.time());  // Para que quede en hora local
        Datetime dtPrimerDia  =   BusinessHours.nextStartDate(bh.id, dt.addDays(1));
        mapNewMap.get(objTaskTemp.id).ActivityDate  =   BusinessHours.nextStartDate(bh.id, dtPrimerDia.addDays(1)).date(); // Aumentar dos días habiles y validar festivos
      }
      // En caso contrario al punto anterior “Fecha de vencimiento” será igual a “Fecha de Último intento de Localización” + 1 día hábil. 
      else if(mapOldMap.get(objTaskTemp.id).FechadeUltimoIntentodeLocalizacion__c  != mapNewMap.get(objTaskTemp.id).FechadeUltimoIntentodeLocalizacion__c)
      {
        Date dtFechaUltimoIntentoLoc =  mapNewMap.get(objTaskTemp.id).FechadeUltimoIntentodeLocalizacion__c;
        Datetime dt = DateTime.newInstanceGmt(dtFechaUltimoIntentoLoc, System.now().time()); // Para que quede en hora local
        mapNewMap.get(objTaskTemp.id).ActivityDate  = BusinessHours.nextStartDate(bh.id ,dt.addDays(1)).date(); // Aumentar un día habiles y validar festivos
      }
      else if( mapNewMap.get(objTaskTemp.id).Subject == 'Llamada Telefonica de Atencion al Cliente')
      {
        mapNewMap.get(objTaskTemp.id).ActivityDate  = BusinessHours.nextStartDate(bh.id ,system.now().addDays(1)).date(); // Aumentar un día habiles y validar festivos
      }

      // se coloca la fecha de escalación a la fecha de hoy y el propoietario al que eligió el usuario, cuando el usuario selecciona escalación al negociador o administrador
      if(mapOldMap.get(objTaskTemp.id).Escalar_a_Negociador__c == false && objTaskTemp.Escalar_a_Negociador__c && mapReparadoraById.get(objTaskTemp.whatId).Negociadorasignado__r.Usuario__c != null)
      {
        mapNewMap.get(objTaskTemp.id).OwnerId = mapReparadoraById.get(objTaskTemp.whatId).Negociadorasignado__r.Usuario__c;
        mapNewMap.get(objTaskTemp.id).FechaEscalacion__c= system.today();
      }
      else if (mapOldMap.get(objTaskTemp.id).Escalar_a_Negociador__c == false && objTaskTemp.Escalar_a_Negociador__c && mapReparadoraById.get(objTaskTemp.whatId).Negociadorasignado__r.Usuario__c == null)
        mapNewMap.get(objTaskTemp.id).addError(' No hay un negociador asociado a la reparadora (Usuario recursos humanos), no se puede escalar');
      else if (mapOldMap.get(objTaskTemp.id).Escalar_a_Administrador__c == false && objTaskTemp.Escalar_a_Administrador__c)
      {
        if( mapIdByName.containsKey(objTaskTemp.Administrador_Asignado__c))
        {
          mapNewMap.get(objTaskTemp.id).OwnerId = mapIdByName.get(objTaskTemp.Administrador_Asignado__c);
          mapNewMap.get(objTaskTemp.id).FechaEscalacion__c= system.today();
        }
        else 
          mapNewMap.get(objTaskTemp.id).addError(' El nombre del administrador ya no existe');  
      }
      if(objTaskTemp.Escalar_a_Administrador__c && objTaskTemp.Escalar_a_Negociador__c)
        mapNewMap.get(objTaskTemp.id).addError(' Seleccione solo un escalamiento');
    }
  }
  
  public static void traerReparadora(Set<Id> setIdReparadoraIn)
  {
    mapReparadoraById = new Map<Id, Reparadora__c>([select Id,FechaPromesaApartado__c,FechaUltimoContacto__c,Negociadorasignado__r.Usuario__c,
                            (SELECT Id,Subject,FechaPromesaApartado__c FROM Tasks WHERE (Subject = 'Llamada de Bienvenida' OR Subject = 'Llamada Telefonica Post Venta # 1' OR Subject = 'Llamada por 30 días sin Contacto o Deposito' OR Subject = 'Llamada por 60 días sin Contacto o Deposito' OR Subject = 'Llamada por 90 días sin Contacto o Deposito' OR Subject = 'Llamada Telefonica de Atencion al Cliente')) 
                            from Reparadora__c 
                            where Id IN :setIdReparadoraIn]);
    system.debug('\n\n mapReparadoraById2--> ' + mapReparadoraById);
  }


  /**
     * Método para encontrar los papas relacionados a las tareas
     * @author EH
     * @param  lstAllTaskObjEsp: Todas las tareas
     * @return Lista de los papas relacionados a las tareas
     */
  public static Set<id> buscarPapasTareas(List<Task> lstAllTaskObjEsp)
  {
    Set<Id> setIdLead = new Set<Id>();
    for(Task objTaskTemp : lstAllTaskObjEsp) 
    {
      setIdLead.add(objTaskTemp.WhoId);
      setIdLead.add(objTaskTemp.WhatId);  
    }
    return setIdLead;
  } 

  /**
     * Método para obtener las tareas de un tipo de registro específico
     * @author EH
     * @param  strNamerecordType: nombre del tipo de registro
     * @param  lstAllTaskObjEsp: La tareas a las cuales queremos filtrar por el tipo de registro
     * @return Lista de las tareas con el tipo de registro específico
     */
  public static List<Task> obtenerTareasTipoRegEsp(String strNamerecordType, List<Task> lstAllTaskObjEsp)
  {
    try 
    {
      List<Task> lstTaskRecordTypeEsp = new List<Task>();
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(strNamerecordType).getRecordTypeId();
        system.debug('\n\n recordTypeId--> ' + recordTypeId);
        //Encontramoslas tareas con el especifico tipo de registro
        for(Task objTasktemp: lstAllTaskObjEsp) 
        {
          if(objTasktemp.recordTypeId == recordTypeId)
            lstTaskRecordTypeEsp.add(objTasktemp);    
        }
          return lstTaskRecordTypeEsp;
    } catch(Exception e) 
    {
      for(Task objTasktemp: lstAllTaskObjEsp)
        objTasktemp.addError('Nombre de tipo de resgitro cambio, verificar el nombre correcto: ' + e.getMessage() + ' Line' + e.getLineNumber());
      return null;
    }
    }


  /**
     * Método para saber cuales tareas hacen referencia a un objeto específico
     * @author EH
     * @param  strAPIObject: nombre API del objeto en cuestión
     * @param  mapTareas: Mapa relacionando las tareas con sus respectivos objetos (Diferente para candidatos y contactos)
     * @return Lista de las tareas del objeto con APIName= strAPIObject
     */
  public static List<Task> listaTareasObjEsp(String strAPIObject, Map<String,List<Task>> mapTareas)
  {
    List<Task> lstTareasObjetoEsp = new List<Task>();
    //Recorremos todos los nombres de los objetos, para encontrar especificamente el de interés
    for(String strNameObject: mapTareas.keySet())
    {
      if(strNameObject == strAPIObject)
      {
        for(Task objTaskTemp : mapTareas.get(strNameObject))
        {
          lstTareasObjetoEsp.add(objTaskTemp);
        }
      }
    }   
    return  lstTareasObjetoEsp;
  }

  /**
     * Método para crear un mapa relacionando todas las tareas con su respectivo objeto
     * @author EH
     * @param  lstNewRecords: Lista de registros new
     * @return Mapa con la relación de las tareas con el nombre API del objeto corespondiente
     */
  public static Map<String,List<Task>> obtenerTareaObjetoCandCont(List<Task> lstNewRecords)
  {
    Map<String,List<Task>> mapTareaPorNombreObjeto = new Map<String,List<Task>>();
      Map<String,String> mapNombreAPIPorPrefijo = new Map<String,String>();
        String objectAPIName = '';
        String keyPrefix = '';
        // Recorremos la lista de todos los objetos de la instancia, para tener su prefijo correspondiente
        for( Schema.SObjectType obj : Schema.getGlobalDescribe().Values() )
        {
          mapNombreAPIPorPrefijo.put(obj.getDescribe().getKeyPrefix(),obj.getDescribe().getName());
        }
        for(Task objTaskTemp: lstNewRecords) 
        {
          if(objTaskTemp.whoId != null)
          {
            keyPrefix = String.valueOf(objTaskTemp.whoId).substring(0,3);
            if(mapTareaPorNombreObjeto.containsKey(mapNombreAPIPorPrefijo.get(keyPrefix)))
          {
            List<Task> lstMap = mapTareaPorNombreObjeto.get(mapNombreAPIPorPrefijo.get(keyPrefix));
            lstMap.add(objTaskTemp);
            mapTareaPorNombreObjeto.put(mapNombreAPIPorPrefijo.get(keyPrefix), lstMap);
          }
            else 
              mapTareaPorNombreObjeto.put(mapNombreAPIPorPrefijo.get(keyPrefix), new List<Task>{objTaskTemp});
          }
        }

         system.debug('\n\n mapTareaPorNombreObjetoCand--> ' + mapTareaPorNombreObjeto);
         return mapTareaPorNombreObjeto;
  } 

  /**
     * Método que devuelve las tareas con su correspondiente nombre de papa
     * @author EH
     * @param  recordId: El Id del registro, del cuál queremos saber de que objeto es
     * @return Nombre del objeto correspondiente
     */
  public static Map<String,List<Task>> obtenerTareaObjeto( List<Task> lstNewRecords )
    {
      Map<String,List<Task>> mapTareaPorNombreObjeto = new Map<String,List<Task>>();
      Map<String,String> mapNombreAPIPorPrefijo = new Map<String,String>();
        String objectAPIName = '';
        String keyPrefix = '';
        // Recorremos la lista de todos los objetos de la instancia, para tener su prefijo correspondiente
        for( Schema.SObjectType obj : Schema.getGlobalDescribe().Values() )
        {
          mapNombreAPIPorPrefijo.put(obj.getDescribe().getKeyPrefix(),obj.getDescribe().getName());
        }
        for(Task objTaskTemp: lstNewRecords) 
        {
          if(objTaskTemp.whatId != null)
          {
            keyPrefix = String.valueOf(objTaskTemp.whatId).substring(0,3);
            if(mapTareaPorNombreObjeto.containsKey(mapNombreAPIPorPrefijo.get(keyPrefix)))
          {
            List<Task> lstMap = mapTareaPorNombreObjeto.get(mapNombreAPIPorPrefijo.get(keyPrefix));
            lstMap.add(objTaskTemp);
            mapTareaPorNombreObjeto.put(mapNombreAPIPorPrefijo.get(keyPrefix), lstMap);
          }
            else 
              mapTareaPorNombreObjeto.put(mapNombreAPIPorPrefijo.get(keyPrefix), new List<Task>{objTaskTemp});
          }
        }

         system.debug('\n\n mapTareaPorNombreObjeto--> ' + mapTareaPorNombreObjeto);
         return mapTareaPorNombreObjeto;
    }

  // EH 19-Abr-2016: Metodo que retorna los valores de un campo tipo picklist del objeto Task
  public static Set<String> valoresCampoListaSeleccion(String strNombreCampo)
  {
    set<String> setNombresAdmin = new set<String>(); //set donde se guardan los valores de la lista
      
    Schema.sObjectType sobject_type = Task.getSObjectType(); // Traemos del esquema el objeto de tareas
    Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); // obtenemos los resultados descripción del sObject tareas
    Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //Creamos un mapa de los campos del objeto
    system.debug('field_map -->' + field_map );
    List<Schema.PicklistEntry> pick_list_values = field_map.get(strNombreCampo).getDescribe().getPickListValues(); //Obtenemos los valores del campo de lista de selección específico
    // Realizamos un ciclo con los valores del campo
    for (Schema.PicklistEntry a : pick_list_values) 
    { 
       setNombresAdmin.add(a.getValue()); 
    }
    system.debug('setNombresAdmin-->' + setNombresAdmin);
    return setNombresAdmin;
  }

}