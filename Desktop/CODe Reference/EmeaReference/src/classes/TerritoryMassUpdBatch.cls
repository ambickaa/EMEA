global without sharing class TerritoryMassUpdBatch implements Database.Batchable<sObject>
{
    String userEmail;
    global TerritoryMassUpdBatch (String email)
    {
        this.userEmail = email;
    }
    
    global Database.QueryLocator start(Database.BatchableContext theContext)
    {       
        return Database.getQueryLocator([SELECT ID FROM Account WHERE DE_Territory_Key__c != '' AND DE_Territory_Key__c in (SELECT DE_TerritoryManagementRef__c from TerritoryManagementUser__c)]);
    }
    
    global void execute(Database.BatchableContext theContext, List<sObject> theList)
    {
        List<Account> listAcc = (List<Account>)theList;
        triggerAccountSharingManager.forceUpdate = true;              
        Database.update(theList);
    }
    
    global void finish(Database.BatchableContext BC)
    {
        //Method to send email to userEmail indicating numAccounts
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {userEmail});
        mail.setSenderDisplayName('Mass update Territory Management Process');
        mail.setSubject('Mass Update Territory Management Processing');
        mail.setPlainTextBody('The Mass Update of Territory Management Processing has finished correctly.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}