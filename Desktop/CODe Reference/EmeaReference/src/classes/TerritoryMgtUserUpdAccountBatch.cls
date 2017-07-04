/**
    Update all TMUs that are not processed. Update the shared users in the account and turn the processed to on for this TMUs
    Support Team 
***/

global without sharing class TerritoryMgtUserUpdAccountBatch implements Database.Batchable<sObject>
{
  String userEmail;
  Integer numAccounts;
  Set<ID> userTerrIds;
  Boolean del;
  
  global TerritoryMgtUserUpdAccountBatch(String email, Set<ID> userTerr, Boolean delet) //We pass the email of the user, the TMUs to process and if we are deleting them or not
  {
    this.userEmail = email;
    this.userTerrIds = userTerr;
    this.del = delet;//If del is true means that the trigger must search for the accounts, and the userTerr has the TMS to update
  }
  
  //Select all TMUs that are being updating or inserting and appear in the trigger.old.
  global Database.QueryLocator start(Database.BatchableContext theContext)
  {
    this.numAccounts = 0;
    return Database.getQueryLocator('SELECT DE_TerritoryManagementRef__c from TerritoryManagementUser__c WHERE id IN: userTerrIds And processed__c = false');//Select all the TMU that are passed form the trigger
  }
  
  global void execute(Database.BatchableContext theContext, List<sObject> objList)
  { 
    System.debug('TMUs to processed: ' +objList);  
    List<TerritoryManagementUser__c> terrList = new List<TerritoryManagementUser__c>();
    //Create a list of TMUs id that we have passed from the class
    for(sObject item : objList)
    {
      TerritoryManagementUser__c itemTerr = (TerritoryManagementUser__c)item;
      terrList.add(itemTerr);
    }
    
    //Select and update the accounts where its territory key is equal to the TM of the TMUs to update
    List<Account> accns = [SELECT ID FROM Account WHERE DE_Territory_Key__c in (SELECT DE_TerritoryManagementRef__c from TerritoryManagementUser__c where id in :terrList)];
    triggerAccountSharingManager.forceUpdate = true; // Whit this field we put to TRUE the ""doesNeedSharingCalculation" in the ""TriggerAccountSharingManager" in order to update the Sharing Users in the account            
    System.debug ('Accounts to update :' + accns);
    update accns;
    
    //Change the TMUs to processed
    for(TerritoryManagementUser__c itemTerr : terrList)
    {
      itemTerr.processed__c = true;
    }
    
    //Put the TriggerTerritoryManagementUser a field for not reupdate the TMU again
    TriggerTerritoryManagementUser.forceUpdate = false;
    //Update the TMUs that we have processed
    update terrList;
  
  }
  
  //Send an e-mail to the user indicating the state of the TMUs that are needed to upload
  global void finish(Database.BatchableContext BC)
  {
    //Method to send email to userEmail indicating numAccounts
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(new String[] {userEmail});
    mail.setSenderDisplayName('Territory Management Process');
    mail.setSubject('Territory Management Processing');
    mail.setPlainTextBody('The Territory Management Processing has finished correctly.');
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  }
}