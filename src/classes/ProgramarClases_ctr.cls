/*******************************************************************************
Desarrollado por:   RTD
Autor:              Esteban Heredia
Descripción:        Programar clases tanto en un mes específico, así como en cada día en un mes en todo el año actual 

Cambios (Versiones)
---------------------------------------------------------------------------------
    No.     Fecha           Autor                       Descripción
    ---     -----------     ----------                  ---------------------------     
    1.0     19-May-2016     Esteban Heredia(EH)         Programar clases en días hábiles
*******************************************************************************/
public with sharing class ProgramarClases_ctr 
{
    public String meses {get; set;}
    public String horas {get; set;}
    public String minutos {get; set;}
    public String dia {get; set;}
    public String clase {get; set;}
    public Boolean anioCompleto {get; set;}


    public List<SelectOption> lstClasesProgramadas
    {
        get
        {
            List<ApexClass> lstClasesProg = [SELECT Id,Name FROM ApexClass WHERE Name LIKE '%sch'];
            List<SelectOption> options = new List<SelectOption>();

            for(ApexClass clase: lstClasesProg)
            {
                options.add(new SelectOption(clase.Name,clase.Name));
            }
            return options;
        } 
        set;
    }

    public List<SelectOption> lstMeses
    {
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('1','Enero'));
            options.add(new SelectOption('2','Febrero'));
            options.add(new SelectOption('3','Marzo'));
            options.add(new SelectOption('4','Abril'));
            options.add(new SelectOption('5','Mayo'));
            options.add(new SelectOption('6','Junio'));
            options.add(new SelectOption('7','Julio'));
            options.add(new SelectOption('8','Agosto'));
            options.add(new SelectOption('9','Septiembre'));
            options.add(new SelectOption('10','Octubre'));
            options.add(new SelectOption('11','Noviembre'));
            options.add(new SelectOption('12','Diciembre'));
            return options;
        } 
        set;
    }

    public List<SelectOption> lstHoras
    {
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            for(Integer i = 0; i < 24; i++) 
            {
                options.add(new SelectOption(string.valueof(i),string.valueof(i)));
            }
            return options;
        } 
        set;
    }

    public List<SelectOption> lstMinutos
    {
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            integer i = 0;
            while(i<51)
            {
                options.add(new SelectOption(string.valueof(i),string.valueof(i)));
                i+=10;
            }
            return options;
        } 
        set;
    }

    public List<SelectOption> lstDias
    {
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            for(Integer i = 1; i < 22; i++) 
            {
                options.add(new SelectOption(string.valueof(i),string.valueof(i)));
            }
            return options;
        } 
        set;
    }

    public List<SelectOption> lstDiasEsp
    {
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            for(Integer i = 1; i < 32; i++) 
            {
                options.add(new SelectOption(string.valueof(i),string.valueof(i)));
            }
            return options;
        } 
        set;
    }

    public ProgramarClases_ctr()
    {
        anioCompleto = false; 
    }

    public void ProgramarClase() 
    {
        //  Para programar el trabajo en un día específicado por el usuario
        if(!anioCompleto)
        {
            //CronJobDetail ct = [SELECT Id,JobType,Name FROM CronJobDetail WHERE Name = 'Primera programación'];
            //system.debug('\n\n ct--> ' + ct);
            //System.abortJob('Primera programación');
            try 
            {
                system.debug('\n\n mes actual--> ' + system.today().month());
                String strSch = '0 ' + minutos + ' ' + horas + ' ' + dia + ' ' + meses + ' ?';
                system.debug('\n\n strSch--> ' + strSch);
                String strAnio = string.valueof(system.today().year());
                if(system.today().month() > integer.valueof(meses))
                    strAnio = string.valueof(system.today().addYears(1).year());
                Type t = Type.forName(clase);
                if(!Test.isRunningTest())
                String jobID = system.schedule(clase + ': ' + dia + '/' + meses + '/' + strAnio ,strSch,(Schedulable)t.newInstance());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.confirm,'Clase ' + clase + ' Programada para el ' + dia + '/' + meses + '/' + strAnio));
            }
            catch(Exception e) 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'La clase no se puede programar en esta fecha, error: ' + '\n\n\t<<<<<<<<< CalloutExceptionType >>>>>>>>> \n\t\t@@--> getCause > ' + e.getCause() + '\n\t\t@@--> getLineNumber > ' + e.getLineNumber() + '\n\t\t@@--> getMessage > '+ e.getMessage() + '\n\t\t@@--> getStackTraceString > '+ e.getStackTraceString() + '\n\t\t@@--> getTypeName > ' + e.getTypeName() + '\n\n'));
            }
        } // Si quieren programar el trabajo todo el año actual
        else 
        {
            Integer intMeses = 0;
            String strMensaje = '';
            DateTime dttDiaSeleccionado;
            Datetime dtDiaHabil;
            String strDiaHabil = '';
            String strMesHabil = '';
            String strAnioHabil = '';

            try 
            {
                BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
                dttDiaSeleccionado = DateTime.newInstance(system.today().year(), system.today().month(), 1);
                dtDiaHabil  =   BusinessHours.nextStartDate(bh.id, dttDiaSeleccionado);
                //system.debug('\n\n dttDiaSeleccionado--> ' + dttDiaSeleccionado); integer.valueof(dia)
                //Obtenemos el día hábil
                for(Integer j = 1; j < integer.valueof(dia); j++) 
                {
                    dtDiaHabil  =   BusinessHours.nextStartDate(bh.id, dtDiaHabil.addDays(1));
                }
                // Comprobamos que la fecha actual sea menor a la dicha por el usuario (Para ver si se puede programar desde el mismo mes)
                if(system.today().day() < dtDiaHabil.day() || (system.today().day() == dtDiaHabil.day() && system.now().hour() < integer.valueof(horas) && system.now().minute() <= integer.valueof(minutos)) || (system.today().day() == dtDiaHabil.day() && system.now().hour() == integer.valueof(horas) && system.now().minute() < integer.valueof(minutos)))
                    intMeses = system.today().month();
                else
                    intMeses = system.today().addMonths(1).month(); 
                    
                for(Integer i = intMeses; i <= 12; i++) 
                {
                    dttDiaSeleccionado = DateTime.newInstance(system.today().year(), i, 1);
                    dtDiaHabil  =   BusinessHours.nextStartDate(bh.id, dttDiaSeleccionado);
                    //system.debug('\n\n dttDiaSeleccionado--> ' + dttDiaSeleccionado); integer.valueof(dia)
                    //Obtenemos el día hábil
                    for(Integer j = 1; j < integer.valueof(dia); j++) 
                    {
                        dtDiaHabil  =   BusinessHours.nextStartDate(bh.id, dtDiaHabil.addDays(1));
                    }
                    
                    strDiaHabil =   string.valueof(dtDiaHabil.day());
                    strMesHabil =   string.valueof(dtDiaHabil.month());
                    strAnioHabil =  string.valueof(dtDiaHabil.year());
                    //system.debug('\n\n strMesHabil--> ' + strMesHabil);
                    //system.debug('\n\n meses--> ' + meses);
                    if(integer.valueof(strMesHabil) == i)
                    {
                        //system.debug('\n\n strDiaHabil--> ' + strDiaHabil);
                        String strSch = '0 ' + minutos + ' ' + horas + ' ' + strDiaHabil + ' ' + strMesHabil +  ' ?' + ' ' + strAnioHabil;
                        //Crear un tipo de la clase seleccionada (El tipo es de esa clase)
                        Type t = Type.forName(clase);
                        if(!Test.isRunningTest())
                        String jobID = system.schedule(clase + ': ' + strDiaHabil + '/' + strMesHabil + '/' + strAnioHabil ,strSch,(Schedulable)t.newInstance());
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.confirm,'Clase ' + clase + ' Programada para el ' + strDiaHabil + '/' + strMesHabil + '/' + strAnioHabil + ' a las ' + horas + ':' + minutos));           
                    }
                    else 
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Clase ' + clase + ' no pudo ser programada porque el día hábil ' + dia +  ' supera los dias hábiles del mes: ' + i));          
                    }
                }
            }
            catch(Exception e) 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'La clase no se puede programar en esta fecha, error: ' + e));
            }
        }
        
    }
}