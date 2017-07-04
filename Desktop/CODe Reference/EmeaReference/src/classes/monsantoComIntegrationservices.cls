/* 
Class Name: monsantoComIntegrationservices
Created By: Accenture IDC
Usage: Global class Used by the Custom Button "Get Credit Info" to call this webservice 
*/
global class monsantoComIntegrationservices{

    webservice static string getmonsantoComIntegration(String accountID ){             
        Account acct =[Select Id , GC_SAP_ID__c, Credit_Lmt_Amt__c from Account where Id=:accountID Limit 1];
        Integer i;
        string CreditExposureDate =  Label.CreditLimit_CreditExposureDate;      
        string CreditControlArea= Label.CreditLimit_CreditControlArea;
        string CustomerNumber =   acct.GC_SAP_ID__c;
        
        /*List<BrandName__c> mcs = BrandName__c.getall().values();

        for(i=0;i< mcs.size();i++)
         {
         if(acct.Brand_Group_Name__c==mcs[i].name)
        CreditControlArea=mcs[i].Credit_Control_Area__c;
         }
        System.debug('Brand name' + CreditControlArea);*/
        
        monsantoComIntegrationservicesCredita.CreditExposurePort  capcExPort = new  monsantoComIntegrationservicesCredita.CreditExposurePort();   
        capcExPort.endpoint_x = Label.CreditLimitServiceURL;
        capcExPort.clientCertName_x = Label.CreditLimitServiceCert;
        capcExPort.timeout_x = 120000;
        try{
            monsantoComIntegrationservicesCredita.CreditExposureResponse_element result   = capcExPort.GetCreditExposure(CreditExposureDate,CreditControlArea,CustomerNumber);  
            System.debug(result);
        If(decimal.valueOf(result.EDeltaToLimit)< 0.00)
        {
        acct.Credit_Lmt_Amt__c = 0.00;
        }
        else if(decimal.valueOf(result.EDeltaToLimit) > decimal.valueOf(result.ECreditlimit))
        {
        acct.Credit_Lmt_Amt__c =  decimal.valueOf(result.ECreditlimit) ;
        }
        else
        {
        acct.Credit_Lmt_Amt__c =  decimal.valueOf(result.EDeltaToLimit) ;
        }
        acct.Allocated_Credit__c =  decimal.valueOf(result.ECreditlimit);
        
        if(result.ECustomerCreditDetails!=null && result.ECustomerCreditDetails.size()>0){
            if(result.ECustomerCreditDetails[0].blockedFlag=='X'){
            acct.Credit_Block__c='Yes';
            }
            else{
            acct.Credit_Block__c= result.ECustomerCreditDetails[0].blockedFlag;
            }
        }else{
            acct.Credit_Block__c= 'None';
        }                                    
        database.update(acct); 
        
         return 'true'; 
         
        }catch(Exception ex){
            return ex.getMessage();
            
        }    
    } 
}