global class AccountFarmUpdateBatchable implements Database.Batchable<Account>
{
    public Boolean toYear=false;
    public Boolean toMigrateRSA=false;
    public Boolean SharingUpdate=false;
    public ID CountryID {get; set;}

    global List<Account> start(Database.BatchableContext theContext)
    {
        
     if(!toYear) 
     { 
        if(!toMigrateRSA)       
        {   if(!SharingUpdate)
            {
            return (List<Account>) Database.query(new al.SoqlBuilder().selectx('Id').fromx('Account')
                      .wherex(new al.FieldCondition('RecordTypeId', Util.recordType.get('Account:GroupFarmSite'))).toSoql());
            }
            else
            {
             return (List<Account>) Database.query(new al.SoqlBuilder().selectx('Id').fromx('Account')
                      .wherex(new al.FieldCondition('CountryRef__c', CountryID )).toSoql());
            }  
        }else
        
        {
            ID FarmType=Util.recordType.get('Account:GroupFarmSite');
            String countryRSA='South Africa';
            return (List<Account>) Database.query('SELECT ID, Buyer_RSA__r.Name, BankAccountHolder_RSA__c, GC_Email_Address__c from Account where CountryRef__r.Name=:countryRSA AND RecordTypeID=:FarmType AND BankAccountHolder_RSA__c=null AND Buyer_RSA__c!=null');
             //      return (List<Account>) Database.query('SELECT ID,Visited_PY__c,GC_is_Visited__c from Account where CountryRef__r.Name=:countryRSA AND RecordTypeID=:FarmType');

        }
     }else
     {
            ID FarmType=Util.recordType.get('Account:GroupFarmSite'); 
            ID DistType=Util.recordType.get('Account:DistRetPoS'); 
            String everis='everis.salesforce@gmail.com';                                   
            List<String> UATCountries = new List<String> {'South Africa', 'Hungary', 'Russia', 'Ukraine', 'Romania','Turkey','Bulgaria'};
            return (List<Account>) Database.query('SELECT ID,GC_Email_Address__c from Account where CountryRef__r.Name in:UATCountries  AND ( RecordTypeID=:FarmType OR RecordTypeId=:DistType) And (GC_Email_Address__c!=null AND GC_Email_Address__c!=:everis) LIMIT 49000');
   
     }
    }
    
    global void execute(Database.BatchableContext theContext, List<Account> theList)
    {
        Set<Id> anAccsList = new Set<ID>();
        
        if(!toYear)
        {
            if(!toMigrateRSA)       
            {
                if(!SharingUpdate) 
                {        
                    for (Account anAcc: theList)
                    {
                        anAccsList.add(anAcc.Id);
                    }        
                    AccountTriggerHelper.updateSummaryAcreages(anAccsList);
                    AccountTriggerHelper.updateSummaryCampaignLineItem(anAccsList);
                }
                else
                {
                     triggerAccountSharingManager.forceUpdate = true;
                     update theList;
                }
            }
            else
            {
                List<Account> anAccountList = new List<Account>();
                MAP<ID,String> Buyers= new MAP<ID,String>();
                List<ID> BuyersID = new List<ID>();
                
                
                for (Account acc : theList)
                {
                   acc.BankAccountHolder_RSA__c=acc.Buyer_RSA__r.Name;
                   anAccountList.add(acc);
                }
                update anAccountList;
            }
        }
         else
         {
                /*Map<Id, Account> anAccountUpdateMap = new Map<Id, Account>();
                for (Account anAccount: theList)
                {
                    //If current Year was changed   
                        anAccount.Visited_PY__c = anAccount.GC_is_Visited__c;
                        anAccount.GC_is_Visited__c = false;
                        anAccountUpdateMap.put(anAccount.Id, anAccount);
                
                    anAccsList.add(anAccount.Id);
                }
                
                update anAccountUpdateMap.values();
                
                AccountTriggerHelper.updateSummaryAcreages(anAccsList);
                AccountTriggerHelper.updateSummaryCampaignLineItem(anAccsList);*/
                
                /*List<Account> AccountToUpdate = new List<Account>();
                
                 for (Account acc: theList)
                {
                    acc.GC_Email_Address__c='everis.salesforce@gmail.com';
                     AccountToUpdate.add(acc);
                }
               
                update(AccountToUpdate);*/
         }  
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
    }
}