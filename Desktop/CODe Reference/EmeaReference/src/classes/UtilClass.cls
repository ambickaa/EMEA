public with sharing class UtilClass 
{
    // List contains the mailaddress of admin group.
    public static List<String> mailToAddresses = new List<String>();

    //Method to handle the exceptions - Calling this method will insert the exception into the error log
    public static void logException(String className, String methodName, Exception ex)
    {
        List<Exception_Log__c> listOfErrorLogs = new List<Exception_Log__c>();     
        
        Exception_Log__c log;
        
        set<ID> recordIDs = new set<ID>();
        
        if(ex.getTypeName() == 'System.DmlException')
        {
            for(integer i=0; i< ex.getNumDml(); i++)
            {                          
                log = new Exception_Log__c();
                log.Error_Record_Id__c = ex.getDmlId(i);               
                log.Class_Name__c = className;
                log.Method_Name__c = methodName;
                log.Error__c = ex.getStackTraceString();
                log.Error_Details__c = ex.getMessage();
                log.Type_Name__c = ex.getTypeName(); 
                log.Line_Number__c = ex.getLineNumber(); 
                log.Number_of_Failed_Rows__c = ex.getNumDml();
                listOfErrorlogs.add(log);
                recordIDs.add(ex.getDmlId(i)); 
            }
        }
        else
        {      
            log = new Exception_Log__c();
            
            log.Class_Name__c = className;
            log.Method_Name__c = methodName;
            log.Error__c = ex.getStackTraceString();
            log.Error_Details__c = ex.getMessage();
            log.Type_Name__c = ex.getTypeName(); 
            log.Line_Number__c = ex.getLineNumber();
            if(ex.getTypeName() == 'System.DMLException' || ex.getTypeName() == 'System.TypeException')   
            log.Number_of_Failed_Rows__c = ex.getNumDml();  
            listOfErrorlogs.add(log);      
        }

        try
        {
            if(listOfErrorlogs.size() > 0)
            {
                insert listOfErrorlogs;
                sendExceptionEmail(className, methodName, ex, recordIDs);
                
            }
        }
        catch(DMLException e)
        {
            System.debug('Error while inserting the exception'+e);    
        }
        
    }

    public static Organization getOrgDetails()
    {
        Organization org = [select Id, Name from Organization LIMIT 1];
        return org;
    }

    //Method to send batch job status to admin group.
    public Static  void sendExceptionEmail(String className, String methodName, Exception ex, set<ID> recordIDs)
    {
        
        Organization org = getOrgDetails();
        
        // custom setting to get mail id of Admin group
       List<AdminEmailGroup__c> bacthEmail = AdminEmailGroup__c.getAll().Values();
       for(AdminEmailGroup__c btchEmail : bacthEmail){
           mailToAddresses.add(String.valueOf(btchEmail.Email__c));
       }
                
        if(mailToAddresses != NULL && mailToAddresses.size() > 0)
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(mailToAddresses);
            mail.setSubject('Developer script exception from '+ org.Name+ ': '+ex.getTypeName()+' caused by '+className+'.'+methodName);
            String plainTextBody = '';
            if(recordIds.size() > 0)
            {
                plainTextBody += 'Exception by user/organization: '+ UserInfo.getUserId()+ '/'+ org.ID +'\n\n'+ 
                                 ex.getStackTraceString() +'\n\n'+
                                 'caused by: '+ex.getTypeName()+' '+ex.getMessage() +'\n\n'+
                                 ex.getNumDml()+ ' records failed due to the above exception.'+'\n\n';
            }
            else
            {
                plainTextBody += 'Exception by user/organization: '+ UserInfo.getUserId()+ '/'+ org.ID +'\n\n'+
                                 ex.getStackTraceString() +'\n\n'+
                                 'caused by: '+ex.getTypeName()+' '+ex.getMessage() +'\n\n';
            }
            plainTextBody += 'Thanks,\n';
            plainTextBody += 'Monsanto Dev Team.';
            mail.setPlainTextBody(plainTextBody);
              
            Messaging.sendEmail(new Messaging.Email[] { mail });
        }
    }

}