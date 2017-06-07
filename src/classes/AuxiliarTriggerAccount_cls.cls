public with sharing class AuxiliarTriggerAccount_cls 
{
	
	public static void handlerAfter(List<Account> lstNewAccounts, Map<Id,Account> mapCuentasOld) 
    {
        obtenerCuentas(lstNewAccounts,mapCuentasOld);
    }
    
    public static void obtenerCuentas(List<Account> lstNewAccounts, Map<Id,Account> mapCuentasOld)
    {
    	List<Account> lstCuentasActualizar = new List<Account>(); 
    	
    	System.debug('\n\n@@@mapCuentasOld------> ' + mapCuentasOld + '\n' + 
    		'@@@lstNewAccounts------> ' + lstNewAccounts + '\n\n');
    		
    	for(Account objAccount :lstNewAccounts)
    	{
    		String strOldPhone 				= mapCuentasOld.get(objAccount.Id).Phone;
    		String strNewPhone				= objAccount.Phone;
    		String strOldMobile				= mapCuentasOld.get(objAccount.Id).Telefono_celular__c;
    		String strNewMobile				= objAccount.Telefono_celular__c;
    		String strOldOfficePhone		= mapCuentasOld.get(objAccount.Id).Telefono_oficina__c;
    		String strNewOfficePhone		= objAccount.Telefono_oficina__c;
    		String strOldPersonEmail		= mapCuentasOld.get(objAccount.Id).PersonEmail;
    		String strNewPersonEmail		= objAccount.PersonEmail;
    		String strOldAlternativeEmail	= mapCuentasOld.get(objAccount.Id).Correo_electronico2__c;
    		String strNewAlternativeEmail	= objAccount.Correo_electronico2__c;
    		
    		/*System.debug('\n\n@@@strOldPhone---------> ' + strOldPhone + '\n');
    		System.debug('@@@strNewPhone---------> ' + strNewPhone + '\n');
    		System.debug('@@@strOldMobile---------> ' + strOldMobile + '\n');
    		System.debug('@@@strNewMobile---------> ' + strNewMobile + '\n');
    		System.debug('@@@strOldOfficePhone---------> ' + strOldOfficePhone + '\n');
    		System.debug('@@@strNewOfficePhone---------> ' + strNewOfficePhone + '\n');
    		System.debug('@@@strOldPersonEmail---------> ' + strOldPersonEmail + '\n');
    		System.debug('@@@strNewPersonEmail---------> ' + strNewPersonEmail + '\n');
    		System.debug('@@@strOldAlternativeEmail---------> ' + strOldAlternativeEmail + '\n');
    		System.debug('@@@strNewAlternativeEmail---------> ' + strNewAlternativeEmail + '\n\n');*/
    		
    		if(String.isNotEmpty(strOldPersonEmail) || String.isNotEmpty(strOldPhone) || String.isNotEmpty(strOldMobile) || String.isNotEmpty(strOldOfficePhone) || String.isNotEmpty(strOldAlternativeEmail))
    		{
				if(strNewPhone != strOldPhone)
	    		{
	    			objAccount.Modificacion_Datos_Contacto__c	= true;
	    			objAccount.Antiguo_Telefono_Casa__c			= strOldPhone;
	    		}
	    		if(strNewMobile != strOldMobile)
	    		{
	    			objAccount.Modificacion_Datos_Contacto__c 	= true;
	    			objAccount.Antiguo_Telefono_Celular__c		= strOldMobile;
	    		}
	    		if(strNewOfficePhone != strOldOfficePhone)
	    		{
	    			objAccount.Modificacion_Datos_Contacto__c 	= true;
	    			objAccount.Antiguo_Telefono_Oficina__c		= strOldOfficePhone;
	    		}
	    		if(strNewPersonEmail != strOldPersonEmail)
	    		{
	    			objAccount.Modificacion_Datos_Contacto__c	= true;
	    			objAccount.Antiguo_Correo_Electronico__c	= strOldPersonEmail;
	    		}
	    		if(strNewAlternativeEmail != strOldAlternativeEmail)
	    		{
	    			objAccount.Modificacion_Datos_Contacto__c	= true;
	    			objAccount.Antiguo_Correo_Alternativo__c	= strOldAlternativeEmail;
	    		}    			
    		}
    	}
    } 
}