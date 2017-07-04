public with sharing class TriggerCountrySharingController implements Triggers.Handler
{
    public void handle()
    {
        
        List<Country__c> aCountryList = [SELECT (SELECT id FROM Accounts__r) FROM Country__c WHERE ID IN :trigger.newMap.keyset()];
        

        Set<Account> anAccountSet = new Set<Account>();
        List<Account> anAccountList = new List<Account>();
        for (Country__c aCountry : aCountryList)
        {
            if(((Country__c)trigger.oldMap.get(aCountry.id)).DE_EnableAccountSharing__c != ((Country__c)trigger.newMap.get(aCountry.id)).DE_EnableAccountSharing__c && ((Country__c)trigger.newMap.get(aCountry.id)).DE_EnableAccountSharing__c)
            {
                anAccountSet.addAll(aCountry.Accounts__r);
                

                AccountFarmUpdateBatchable AccountUpdateBatch= new AccountFarmUpdateBatchable();
                AccountUpdateBatch.SharingUpdate=true;
                AccountUpdateBatch.CountryId=aCountry.ID;
                Database.executeBatch(AccountUpdateBatch,50);

            }
        }
     
    }
}