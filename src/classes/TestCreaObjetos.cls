/*******************************************************************************
Desarrollado por:   RTD
Autor:              Jeisson Hernandez
Proyecto:           Colombia III
Descripción:        Clase utilitaria que genera registros de pruebas para las clases de pruebas de las cuales sea invocada

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha      		Autor                   Descripción
    ---     ---        		----------                ---------------------------     
    1.0     10-Sep-2015		Jeisson Hernandez(JH)     Creación de la Clase.
    1.1     13-Abr-2016		Esteban Heredia  (EH)     Más objetos.
*******************************************************************************/
public with sharing class TestCreaObjetos 
{
	public static DateTime dtFechaHoraHoy = DateTime.now();
	public static String strNamePrueba = 'UserPrueba ' + dtFechaHoraHoy;
	public static String strLastNamePrueba = 'ApellidoPrueba ' + dtFechaHoraHoy.millisecondGmt();

	public static List<Sucursal__c > CrearSucursales(Integer noRdSuc)
	{
		//La lista para las Sucursales 
		List<Sucursal__c > lRdSuc = new List<Sucursal__c>();

		//Crea las Sucursales
		for (Integer cnt=0; cnt < noRdSuc; cnt++)
		{
		  Sucursal__c RdSuc = new Sucursal__c();
		  RdSuc.Name = strNamePrueba;
		  lRdSuc.add(RdSuc);
		}//Fin del for 
		
		//Inserta los registros 
		insert lRdSuc;
		
		//Regresa la lista de Sucursales
		return lRdSuc;
  	}


	public static List<RecursosHumanos__c > CrearRHs(Integer noRdRH, String sPuesto, String sArea)
	{
		Empresa__c objEmpresa = new Empresa__c();
		objEmpresa.Name = 'Empresa 1 ';
		insert objEmpresa;
		
		List<RecursosHumanos__c > lRdRH = new List<RecursosHumanos__c>();
		List<Sucursal__c > lstSucursales=CrearSucursales(1);
		for (Integer cnt = 0; cnt < noRdRH; cnt++)
		{
			RecursosHumanos__c RdRH = new RecursosHumanos__c();
			RdRH.Name = strNamePrueba;
			RdRH.SueldoFijo__c = 100.00;
			RdRH.IdPuestoMexico__c = sPuesto != null ? sPuesto : null;
			RdRH.Area__c = sArea != null ? sArea : null;
			RdRH.Usuario__c = UserInfo.getUserId();
			RdRH.AsignarOportunidades__c = true;
			RdRH.NoAsignarClientes__c = false;
			RdRH.Sucursal__c=lstSucursales[0].id;
			RdRH.Empresa__c = objEmpresa.id;
			RdRH.UnidadNegocio__c = 'RTD Colombia';
			RdRH.TotalDeudasActivas__c = 0;
			RdRH.Total_Clientes__c = 0;
			RdRH.Status__c='Activo';
			//Agregar a lRdRH
			lRdRH.add(RdRH);
		}//Fin del for

		//Inserta los registros 
		insert lRdRH;
		//Regresa la lista de RH Creados
		return lRdRH;
	}
	
	public static List<Lead> CrearLeads(Integer nroLeads)
	{
		String strTRLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
		List<Lead> lstleads = new List<Lead>();
		Date dtFechahoy = Date.today();
		Date dtFechaNac = Date.newInstance(1988, 7, 21);
		
		for(Integer i=0;i < nroLeads; i++)
		{
			Lead objLead = new Lead();
			objLead.FirstName = 'Lead ' + i;
			objLead.LastName = 'Apellido Lead ' + i;
			objLead.PrimerApellido__c = 'Apellido Lead ' + i;
			objLead.SegundoApellido__c = '2do Apellido Lead ' + i;
			objLead.PrimerNombre__c ='Lead ' + i;
			objLead.SegundoNombre__c ='SNombre Lead ' + i;
			objLead.FechaNacimiento__c = dtFechaNac;
			objLead.Domicilio__c = 'Domicilo lead ' + i;
			objLead.Departamento__c ='Bogotá';
			objLead.CiudadMunicipio__c = '1';
			objLead.Cedula__c = 'CC'+i;
			objLead.TelefonoCasa__c = ''+i+ (i+1) + (i+2) ;
			objLead.TelefonoCelular__c = '300'+i+ (i+1) + (i+2);
			objLead.TelefonoTrabajo__c = ''+i+ (i+1) + (i+2);
			objLead.Genero__c = 'Masculino';
			objLead.EmpleoCaratula__c = 'Empleado IP';
			objLead.Email = 'lead'+i+'@lead.com';
			objLead.CaratulaAniosResidencia__c = '27';
			objLead.PersonasCargo__c = '1';
			objLead.TVPaga__c = 'Si';
			objLead.TipoVivienda__c= 'Familiar';
			objLead.EstadoCivil__c = 'Soltero';
			objLead.NivelAcademico__c = 'Posgrado';
			objLead.CaratulaIngresoBruto__c = 1500000;
			objLead.CaratulaIngresoNeto__c = 1000000;
			objLead.BeneficioEmpleado__c = false;
			objLead.CausaDejoPagar__c = 'Enfermedad';
			objLead.Referencia__c= 'REF'+i;
			objLead.FechaDeposito__c=dtFechahoy;
			objLead.FechaExpedicion__c = dtFechaNac;
			objLead.LugarExpedicion__c = 'Bogota DC';
			objLead.CaratulaDiaDeposito__c = '8';
			objLead.TipoDocAfiliado__c ='Cédula de Ciudadania';
			objLead.RecordTypeId = strTRLead;
			lstleads.add(objLead);
		}
		
		insert lstleads;
		return lstleads;
	}

	public static List<Account> CrearCuenta(Integer nroCuentas)
	{
	   	List<Account> lstAcc = new List<Account>();

	   	List<RecordType> lstRT = new List<RecordType>();
		lstRT=ConsultaRT('Account', 'Cliente Colombia');
		for (Integer i=0; i<nroCuentas; i++)
		{
		    
		    Account objAccount = new Account();
		    objAccount.FirstName='TEST';
		    objAccount.LastName ='NAME';
		    objAccount.recordtype = lstRT.get(0);
			objAccount.PersonMailingStreet='test@yahoo.com';
			objAccount.PersonMailingPostalCode='12345';
			objAccount.PersonMailingCity='SFO';
			objAccount.PersonEmail='test@yahoo.com';
			objAccount.PersonHomePhone='1234567';
			objAccount.PersonMobilePhone='12345678' ;
			lstAcc.add(objAccount);
		}   
	    insert lstAcc;
	    return lstAcc;
  	}
	
	public static List<DeudaOportunidad__c> CrearDeudasOportunidad(Integer nroDeudasOportundidad,String strIdLead,Decimal dcMonto, String strBanco)
	{
		List<DeudaOportunidad__c> lstDeudasOp = new List<DeudaOportunidad__c>();
		Date dtFechahoy = Date.today();
		Date dtFechaNac = Date.newInstance(1988, 7, 21);
		
		for(Integer i=0;i < nroDeudasOportundidad; i++)
		{
			DeudaOportunidad__c objDeudaOp = new DeudaOportunidad__c();
			objDeudaOp.EntidadFinanciera__c = strBanco !=null ? strBanco : 'Banco 1';
			objDeudaOp.NumeroCredito__c = ''+i+Math.random();
			objDeudaOp.OportunidadLead__c = strIdLead != null ? strIdLead : null;
			objDeudaOp.TipoProducto__c = 'TipoProducto 1';
			objDeudaOp.Monto__c = dcMonto != null ? dcMonto : 0;
			lstDeudasOp.add(objDeudaOp);
		}
		
		insert lstDeudasOp;
		return lstDeudasOp;
	}

	public static List<Task> CrearTareas(Integer nroTareas,String whoId,String whatId,String recordtypeId, boolean doInsert)
	{
		List<Task> lstTareas = new List<Task>();
		
		for(Integer i=0;i < nroTareas; i++)
		{
			Task objTask = new Task();
			objTask.whoId = whoId;
			objTask.whatId = whatId;
			objTask.Status = 'En Proceso';
			objTask.FechaPromesaApartado__c = system.now();
			objTask.recordtypeId = recordtypeId != null ? recordtypeId : Schema.SObjectType.Task.getRecordTypeInfosByName().get('Actividad de Ventas').getRecordTypeId();
			lstTareas.add(objTask);
		}
		
		if(doInsert == true)
		insert lstTareas;

		return lstTareas;
	}

	public static List<Reparadora__c> CrearReparadoras(Integer nroReparadoras,String idCliente, boolean doInsert)
	{
		List<Reparadora__c> lstReparadoras = new List<Reparadora__c>();
		
		for(Integer i=0;i < nroReparadoras; i++)
		{
			Reparadora__c objReparadora = new Reparadora__c();
			objReparadora.cliente__c 	= idCliente;
			objReparadora.Status__c 	= 'Activo';
			lstReparadoras.add(objReparadora);
		}
		
		if(doInsert == true)
		insert lstReparadoras;

		return lstReparadoras;
	}

	public static List<Movimientos__c> CrearMovimientos(Integer nroMovimientos,String idReparadora, boolean doInsert)
	{
		List<Movimientos__c> lstMovimientos = new List<Movimientos__c>();
		
		for(Integer i=0;i < nroMovimientos; i++)
		{
			Movimientos__c objMovimiento 			= new Movimientos__c();
			objMovimiento.Reparadora__c				= idReparadora;
			objMovimiento.Tipo_de_movimiento__c		= 'Apartado Mensual';
			objMovimiento.Monto__c					= 100000;
			objMovimiento.Fecha__c					= system.today();
			lstMovimientos.add(objMovimiento);
		}
		
		if(doInsert == true)
		insert lstMovimientos;

		return lstMovimientos;
	}
	
	public static void crearNotificacionTrabajosProgramados (String strNombreBatch, String strAsuntoCorreo,String strCorreosNotificar)
	{
		System.debug('Parametros crearNotificacionTrabajosProgramados: ');
		System.debug('strNombreBatch:  ' + strNombreBatch);
		System.debug('strAsuntoCorreo:  ' + strAsuntoCorreo);
		System.debug('strCorreosNotificar:  ' + strCorreosNotificar);
		
		Notificacion_Trabajos_Programados__c objConfNotificacion = new Notificacion_Trabajos_Programados__c();
		objConfNotificacion.Name = strNombreBatch;
		objConfNotificacion.Asunto_Correo_Notificacion__c = strAsuntoCorreo;
		objConfNotificacion.Correo_Notificacion__c = strCorreosNotificar;
		insert objConfNotificacion;
	}

	public static void crearConfPersPerfilesAsignacionLeadsLandingPages (String strNombrePerfil)
	{
		PerfilesAsignacionLeadsLandingPages__c objConf = new PerfilesAsignacionLeadsLandingPages__c();
		objConf.Name = strNombrePerfil;
		insert objConf;
	}	

	public static void crearConfPersPerfilesAsignacionVendedorAsignado (String strNombrePerfil)
	{
		PerfilesAsignacionVendedorAsignado__c objConf = new PerfilesAsignacionVendedorAsignado__c();
		objConf.Name = strNombrePerfil;
		insert objConf;
	}	
	//Genera los objetos para SolicitudesDeFondos__c 
	public static List<SolicitudesDeFondos__c > CreaRdSolFondos(Integer noRdSolFondos, String sIdDeuda)
	{
	    //La lista para los SolicitudesDeFondos__c 
	    List<SolicitudesDeFondos__c > lRdSolFondos = new List<SolicitudesDeFondos__c>();
	        
	    //Crea los SolicitudesDeFondos__c 
	    for (Integer cnt=0; cnt < noRdSolFondos; cnt++)
	    {
		    SolicitudesDeFondos__c RdSolFondos = new SolicitudesDeFondos__c();
		    RdSolFondos.Deuda__c = sIdDeuda;      
		              
		    //Insertalo en lRdSolFondos
		    lRdSolFondos.add(RdSolFondos);
	    }//Fin del for para los noRdSolFondos
	    
	    //Inserta los registros 
	    insert lRdSolFondos;
	    
	    //Regresa la lista de RdSolFondos
	    return lRdSolFondos;
	}

	public static List<Deudas__c > CreaRdDeudas(Integer noRdDeudas, string IdReparadora){
    //La lista para los Deuda__c 
    List<Deudas__c > lRdDeudas = new List<Deudas__c>();
        
    //Crea los Deuda__c 
    for (Integer cnt=0; cnt < noRdDeudas; cnt++)
    {
        Deudas__c RdDeudas = new Deudas__c();
        RdDeudas.TotalaPagar__c = 100000;
        RdDeudas.MontodeLiquidacion__c   = 100000;
        RdDeudas.DiasdePago__c  = 10000; 
        RdDeudas.MontoPagoInicial__c = 100000;
        RdDeudas.NegociadorAsignado__c  = null;
        RdDeudas.EstadodelaDeuda__c  = 'En Negociacion';
        RdDeudas.UltimoMontodeLiquidacion__c  = 50000;
        RdDeudas.MontoLiqBanco__c = 50000;
		if (IdReparadora != null)
        	RdDeudas.RTD__c = IdReparadora;
        
      //Insertalo en lRdDeudas
      lRdDeudas.add(RdDeudas);
    }//Fin del for para los noRdDeudas
    
    //Inserta los registros 
    insert lRdDeudas;
    
    //Regresa la lista de RdDeudas
    return lRdDeudas;
  }

  	public static List<ActividaddeNegociacion__c>  CrearActivadNegociacion(Integer cantActividades, string IdDeuda )
  	{
  		List<ActividaddeNegociacion__c > ListActNeg = new List<ActividaddeNegociacion__c>();

  		for (Integer i=0; i < cantActividades; i++)
  		{
  			ActividaddeNegociacion__c ObjActNeg = new ActividaddeNegociacion__c();
  		
  			if(IdDeuda != null)
  				ObjActNeg.Deuda__c = IdDeuda;

  			ObjActNeg.DescuentoOfrecidoalaFecha__c = 50;
  			ListActNeg.add(ObjActNeg);
  		}
  		insert ListActNeg;
  		return ListActNeg;
  	} 

  	//Consulta los RecordTypes 'Deuda__c' 'Deuda Negociación' 
  	public static List<RecordType> ConsultaRT(String sSobjectType, String sName)
  	{

    	List<RecordType> lRT = new List<RecordType>();
    
    	for (RecordType objRecordType : [Select r.id, r.SobjectType, r.Name, r.Description From RecordType r
        	where r.SobjectType = :sSobjectType
        	and Name = :sName LIMIT 1]){

      		lRT.add(objRecordType);
    	}
    	return lRT; 

  	}

  	//Genera los objetos para SolicitudesDeFondos__c 
	public static List<SolicitudesDeFondos__c > CreaRdSolFondos(Integer noRdSolFondos, String sIdDeuda, string RecTy)
	{
	    //La lista para los SolicitudesDeFondos__c 
	    List<SolicitudesDeFondos__c > lRdSolFondos = new List<SolicitudesDeFondos__c>();
	    List<RecordType> lstRT = new List<RecordType>();    
	    //Crea los SolicitudesDeFondos__c 
	    for (Integer cnt=0; cnt < noRdSolFondos; cnt++)
	    {
	    	SolicitudesDeFondos__c RdSolFondos = new SolicitudesDeFondos__c();
	      	RdSolFondos.Deuda__c = sIdDeuda;     

	      	lstRT=ConsultaRT('SolicitudesDeFondos__c', RecTy); 
	      	//RdSolFondos.RecordTypeId =  lstRT.get(0).id;

	      	lRdSolFondos.add(RdSolFondos);
	    }
	    
	    insert lRdSolFondos;
	    return lRdSolFondos;
	}

  	public static Solicitud_Fondeos__c CreaSolicitudFondeo( String idDeuda, string RecTy)
	{
	    List<RecordType> lstRT = new List<RecordType>();
	    Solicitud_Fondeos__c Sol_Fondeos = new Solicitud_Fondeos__c();
	    Sol_Fondeos.Deuda__c = idDeuda;
	    lstRT=ConsultaRT('Solicitud_Fondeos__c', RecTy);
	    Sol_Fondeos.recordtype = lstRT.get(0);
	    Sol_Fondeos.Status__c = 'Aceptado';

	    insert Sol_Fondeos;
	    return Sol_Fondeos;
	}

	//Genera los objetos para Flujo__c 
  	public static List<Flujo__c > CreaFlujo(Integer noRdFlujo)
  	{
	    //La lista para los Flujo__c 
	    List<Flujo__c > lstFlujo = new List<Flujo__c>();
	        
	    //Crea los Flujo__c 
	    for (Integer cnt=0; cnt < noRdFlujo; cnt++)
	    {
		    Flujo__c ObjFlujo = new Flujo__c();
		    ObjFlujo.FormaPago__c = 'Cheque';
		    ObjFlujo.StatusFlujo__c  = 'En espera de pago';

		    lstFlujo.add(ObjFlujo);
	    }
	    
	    insert lstFlujo;
	    system.debug('+++flujoscreados: '+lstFlujo);
	    return lstFlujo;
  	}

  	//Genera los objetos para ReceptoresDePagos__c 
  	public static List<Sucursal__c > CreaSucursal(Integer noRdSuc)
  	{
	    List<Sucursal__c > lRdSuc = new List<Sucursal__c>();
	   
	    for (Integer cnt=0; cnt < noRdSuc; cnt++)
	    {
	      Sucursal__c RdSuc = new Sucursal__c();
	      RdSuc.Name = 'Sucursal';

	      lRdSuc.add(RdSuc);
	    }

	    insert lRdSuc;

    	return lRdSuc;
  	}

  	//Genera los objetos para Ingresos__c 
    public static List<Ingresos__c > CreaIngresos(Integer noRdIngresos, String sIdCta)
    {
        List<Ingresos__c > lRdIngresos = new List<Ingresos__c>();
        //Crea los Ingresos__c 
        for (Integer cnt=0; cnt < noRdIngresos; cnt++)
        {
          Ingresos__c RdIngresos = new Ingresos__c();
          RdIngresos.TipoIngreso__c = 'Mensualidad Colombia';
          RdIngresos.Reparadora__c = sIdCta;
          RdIngresos.Status__c = 'Cobrado';  
          RdIngresos.Monto__c  = 250000;
          //Insertalo en lRdIngresos
          lRdIngresos.add(RdIngresos);
        }//Fin del for para los noRdIngresos
        
        //Inserta los registros 
        insert lRdIngresos;
 
        return lRdIngresos;
    }

    public static CredencialesAmazon__c creaConfCredencialesAmazon()
    {
    	CredencialesAmazon__c  confCredAmaz = new CredencialesAmazon__c();
    	confCredAmaz.name = 'Credenciales';
    	confCredAmaz.BucketName__c = 'bucketNameTest';
    	confCredAmaz.Key__c = 'KeyTest';
    	confCredAmaz.Secret__c = 'SecretTest';
    	insert confCredAmaz;
    	return confCredAmaz;
    }

   /* public static List<ContratoDigital__c > CreaContratoDigital(Integer noContrato)
    {
    	//La lista para los ContratoDigital__c 
	    List<ContratoDigital__c > lstContrato = new List<ContratoDigital__c>();
	        
	    //Crea los ContratoDigital__c 
	    for (Integer i=0; i < noContrato; i++)
	    {
		    ContratoDigital__c ObjContrato = new ContratoDigital__c();
		    ObjContrato.Estado__c = 'Enviado';
		    ObjContrato.FechaEnvio__c  = Date.newInstance(2016, 7, 21);
		    ObjContrato.FechaGeneracion__c = Date.newInstance(2016, 8, 21);
		    ObjContrato.NumeroRadicacioAutentic__c = '123';
		    ObjContrato.FechaFirmaRechazo__c = Date.newInstance(2016, 9, 21);
		    lstContrato.add(ObjContrato);
	    }
	    
	    insert lstContrato;
	    return lstContrato;
    }

     public static List<DocumentoDigital__c > CreaDocumentoDigital(Integer noDocumentos)
    {
    	//La lista para los DocumentoDigital__c 
	    List<DocumentoDigital__c > lstDocumento = new List<DocumentoDigital__c>();
	    List<ContratoDigital__c> lstCont = CreaContratoDigital(1);
	    //Crea los DocumentoDigital__c 
	    for (Integer i=0; i < noDocumentos; i++)
	    {
		    DocumentoDigital__c ObjDocumento = new DocumentoDigital__c();
		    ObjDocumento.TipoDocumento__c = 'Carta Poder';
		    ObjDocumento.URLDocumentoEnviado__c  = 'http://prueba.com';
		    ObjDocumento.ContratoDigitalId__c = lstCont[0].id;
		    lstDocumento.add(ObjDocumento);
	    }
	    
	    insert lstDocumento;
	    return lstDocumento;
    }*/
}