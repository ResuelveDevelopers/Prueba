@RestResource(urlMapping='/fetchAccounts/*')
global with sharing class MyRestResource {
 
    @HttpGet
    global static List<Records> doGet() {
        RestRequest req = RestContext.request;
        system.debug('+++req '+req);
        RestResponse res = RestContext.response;
        String accountName = req.params.get('name');
        system.debug('+++accounName '+accountName);
        Account objAcc = new Account();
        List<Reparadora__c> lst_caseRecords = new List<Reparadora__c>();
        List<Records> list_Records = new List<Records>();
        Records objRecord = new Records();
       
        List<Account> lst_accountRecords = new List<Account>();
        List<Id> lst_accountIds = new List<Id>();
       
        lst_accountRecords = [SELECT Id, Name, AccountNumber, Type, Telefono_celular__c, Website FROM Account where Name =: accountName];
       
        if(!lst_accountRecords.IsEmpty() || lst_accountRecords != NULL)
        {
            for(Account objAccount : lst_accountRecords)
            {
                lst_accountIds.add(objAccount.Id);
               
                objRecord = new Records();
                objRecord.AccId = objAccount.Id;
                objRecord.AccName = objAccount.Name;
                objRecord.AccountNumber = objAccount.AccountNumber;
                objRecord.AccType = objAccount.Type;
                objRecord.AccPhone = objAccount.Telefono_celular__c;
                objRecord.AccWebsite = objAccount.Website;
                list_Records.add(objRecord);
            }
        }
        if(!lst_accountIds.IsEmpty() || lst_accountIds != NULL)
        {
        	lst_caseRecords = [SELECT ApartadoMensual__c,Id,Name,Referencia__c,NumeroApartadosRealizados__c,Status__c FROM Reparadora__c WHERE Cliente__c in: lst_accountIds ];
        }
       
        if(!lst_caseRecords.IsEmpty() || lst_caseRecords != NULL)
        {
            for(Reparadora__c objCase : lst_caseRecords)
            {
                objRecord = new Records();
               
                objRecord.CseId = objCase.Id;
                objRecord.Referencia = objCase.Referencia__c;
                objRecord.ApartadoMensual = objCase.ApartadoMensual__c;
                objRecord.apaStatus = objCase.Status__c;
                objRecord.Nombre = objCase.Name;
                list_Records.add(objRecord);
            }
        }
        System.debug('list_Records----------->' + list_Records);
        return list_Records;       
    }
    
    
    @HttpPost
    global static list<Account> updateCaseFields(String strPhone, String strTelAcc, string strNameAcc, string strNumAcc, string strSitioAcc) {
        system.debug('valores: '+strPhone+' '+strTelAcc+' '+strNameAcc+' '+strNumAcc+''+strSitioAcc);
        RestRequest request = RestContext.request;
        String strName = request.params.get('name');
        system.debug('+++request '+request);
        //String strPhone = request.params.get('Phone');
        list<Account> lstAccount = [SELECT Id,  AccountNumber, Type, Telefono_celular__c, Website FROM Account where name =: strName];
        // Get request parameters and set Case fields
        Map<String, String> params = request.params;
        // Iterate through each parameter field and value
        if(strPhone!= '')
        {
	        for (Account objacc: lstAccount)
	        {
	        	objacc.Telefono_celular__c = strPhone;
	        }
        }
        if(strNameAcc != '') 
        {
        	account objacco = new account(); 
        	objacco.Telefono_celular__c = strTelAcc;
        	objacco.name = strNameAcc;
        	objacco.AccountNumber = strNumAcc;
        	objacco.Website = strSitioAcc;
        	lstAccount.add(objacco);
        }
        
        upsert lstAccount;
        system.debug('+++ lstAccount: '+lstAccount);
        
        return lstAccount;
    }  
    
    @HttpPut
    global static list<Account> updateCaseFields(String strTelAcc, string strNameAcc, string strNumAcc, string strSitioAcc) {
        system.debug('valores: '+strTelAcc+' '+strNameAcc+' '+strNumAcc+''+strSitioAcc);
        RestRequest request = RestContext.request;
        String strName = request.params.get('name');
        system.debug('+++request '+request);
        //String strPhone = request.params.get('Phone');
        list<Account> lstAccount = [SELECT Id,  AccountNumber, Type, Telefono_celular__c, Website FROM Account where name =: strName];
        // Get request parameters and set Case fields
        Map<String, String> params = request.params;
        // Iterate through each parameter field and value
        if(strNameAcc != '') 
        {
        	account objacco = new account(); 
        	objacco.Telefono_celular__c = strTelAcc;
        	objacco.name = strNameAcc;
        	objacco.AccountNumber = strNumAcc;
        	objacco.Website = strSitioAcc;
        	lstAccount.add(objacco);
        }
        
        update lstAccount;
        system.debug('+++ lstAccount: '+lstAccount);
        
        return lstAccount;
    }    
    
   @HttpDelete
    global static void deleteCase() {
        RestRequest request = RestContext.request;
        String strName = request.params.get('name');
        list<Account> lstAcc = [SELECT Id FROM Account where name =: strName];
        delete lstAcc;
    } 
   
    global class Records
    {
        public String AccID{get; set;}
        public String AccName{get; set;}
        public String AccountNumber{get; set;}
        public String AccType{get;set;}
        public String AccPhone{get; set;}
        public String AccWebsite{get; set;}
       
        public String CseId{get; set;}
        public String Referencia{get; set;}
        public Decimal ApartadoMensual{get; set;}
        public String apaStatus{get;set;}
        public String Nombre{get; set;}
    }   
}