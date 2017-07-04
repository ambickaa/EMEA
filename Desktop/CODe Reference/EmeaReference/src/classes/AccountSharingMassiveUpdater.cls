/*
	This batch updates sharing records related to Account sons.
*/
public without sharing class AccountSharingMassiveUpdater implements Database.Batchable<sObject> {
	
	public final String country; 
	public Set<Id> toUpdate;
	
	public AccountSharingMassiveUpdater(String coun){ 
		this.country=Coun;
		this.toUpdate=new Set<Id>();
	}
	
    public Database.QueryLocator start(Database.BatchableContext theContext)
    {     
        return Database.getQueryLocator([SELECT Id FROM Account WHERE CountryRef__r.Name=:country AND (RecordType.Name='Group/Farm/Site' OR RecordType.Name='Dist./Ret./PoS' )]);
    }
    
    public void execute(Database.BatchableContext theContext, List<sObject> theList)
    {
        for (Account acc : (List<Account>)theList){
        	toUpdate.add(acc.id);
        }
        try{
       		 AccountSharingManager.updateChildrenSharing(toUpdate);
        }catch(Exception e){
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	        List<String> emailRecipients=(System.label.AdminUtilities).split(','); 
	        mail.setSenderDisplayName('Massive Sharing Update');
	        mail.setSubject('AMassive Sharing Update Process');
	        mail.setPlainTextBody('An error occured during the Massive Sharing Update: '+e.getMessage());
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    	}        
    }	
    public void finish(Database.BatchableContext BC)
    {

    }
}