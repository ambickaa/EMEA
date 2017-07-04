/**
    Delete all TMUs we pass. Delete the shared users in the account and turn the processed to on for this TMUs
    Support Team
***/

global without sharing class TerritoryMgtUserDelAccountBatch implements Database.Batchable<sObject>
{
  String userEmail;
  Integer numAccounts;
  Set<ID> TMsIds;
  Boolean del;
  
  global TerritoryMgtUserDelAccountBatch(String email, Set<ID> TMs,Boolean delet) // We pass the email of the user and the TMs where we have deleted TMUs to update and if we are deleting TMUs
  {
    this.userEmail = email;
    this.TMsIds = TMs;
    this.del = delet;//If del is true means that the trigger must search for the accounts, and the userTerr has the TMS to update
  }
  
  //Select all accounts with the territory key that is necesary to update because we have deleted TMUs on them
  global Database.QueryLocator start(Database.BatchableContext theContext)
  {
      return Database.getQueryLocator('SELECT id from Account WHERE DE_Territory_Key__c IN :TMsIds LIMIT 9999');//Select all the TMU that are pending without the processed for the TM that are passed form the trigger
  }
  
  global void execute(Database.BatchableContext theContext, List<sObject> objList)
  { 
    
    //Update the accounts where its territory key is equal to the TM of the TMUs to delete
    triggerAccountSharingManager.forceUpdate = true; // Whit this field we put to TRUE the ""doesNeedSharingCalculation" in the ""TriggerAccountSharingManager" in order to update the Sharing Users in the account            
    System.debug ('Accounts to delete:' + objList);
    update objList;
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