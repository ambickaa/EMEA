global class BatchUpdateAccountsOnChangeYear implements Database.Batchable<sObject>, Database.Stateful{

/*Support Team 18/09/2014

This batch update the accounts and distributors to current year. 
- Before execute this batch is necessary create the Maps with the fields to update some like this:

    fieldsNamesForChangeCY.put('GC_is_Visited__c',false); === > account.GC_is_Visited__c=false;
    fieldsNamesForChangePY.put('Visited_PY__c','GC_is_Visited__c'); === > account.Visited_PY__c=account.GC_is_Visited__c;
    fieldsNamesPPY.put('CHK_Visited_PPY__c','Visited_PY__c'); === > account.CHK_Visited_PPY__c=account.Visited_PY__c;
    
- If the batch go back to previous year. If necessary inform the fieldsNamesForChangeCY with the names of Previous previous year.
Inputs:
    record: This record type select between Farms or Distributors.
    country: country that year will be changed.
    fieldsNamesForChangePY: this map cointains the field name and the new value of previous year.
    fieldsNamesForChangePY: this map cointains the field name and the new value of current year.
    fieldsNamesPPY: list of security copy field names, the Previous Previous year(PPY).
    nextYear: This flag shows if the year advance or go back.
*/
    global String query;
    global boolean isFarm{get;set;}
    global boolean isDistributor{get;set;}
    global final String recordType{get;set;}
    global final Country__c country{get;set;}
    global final String countryId{get;set;}
    global final boolean nextYear;
    global final Map<String, String> fieldsNamesPPY{get;set;}
    global final Map<String, String> fieldsNamesForChangePY{get;set;}// field name previous Year VS field name Current year
    global final Map<String, Object> fieldsNamesForChangeCY{get;set;}
    

    global BatchUpdateAccountsOnChangeYear(String record, Country__c country,Map<String, String> fieldsNamesForChangePY,Map<String, Object> fieldsNamesForChangeCY, Map<String, String> fieldsNamesPPY,boolean nextYear){
        if (record== Util.recordType.get('Account:DistRetPoS')){ 
            isDistributor = true; 
            isFarm=false;
            recordType=Util.recordType.get('Account:DistRetPoS');
            }
        else if (record== Util.recordType.get('Account:GroupFarmSite')){ 
            isDistributor = true; 
            isFarm=false;
            recordType=Util.recordType.get('Account:GroupFarmSite');
        }else{
            
        }
        this.country = country;
        countryId=country.Id;
        this.nextYear =nextYear;
        this.fieldsNamesForChangePY = fieldsNamesForChangePY;
        this.fieldsNamesForChangeCY = fieldsNamesForChangeCY;
        this.fieldsNamesPPY = fieldsNamesPPY;
    }

    global Database.QueryLocator start(Database.BatchableContext theContext){
        

        query = 'SELECT ID,';
            List<String> names = new List<String>(fieldsNamesForChangePY.keySet());
            names.addAll(fieldsNamesPPY.keySet());
            names.addAll(fieldsNamesForChangeCY.keySet());
            for( String name: names){
                query+= name+',';
            }
            query = query.substring(0, query.length()-1); //delete the las character.
        query+=' FROM Account WHERE RecordTypeId=:recordType AND CountryRef__c=:countryId'; //Generate query
        
        
        System.debug('______QUERY:'+query);
        System.debug('_______Recor:'+recordType);
        System.debug('_______country:'+countryId);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext theContext, List<sObject> theList)
    {
        List<Account> Accounts = (List<Account>)theList;
        Map<Id, Account> AccountUpdateMap = new Map<Id, Account>();
        Set<ID> accountsList = new Set<ID>();
        Set<String> fieldsName;
        Map<String, Schema.SObjectField> t = Schema.SObjectType.Account.fields.getMap();
        for (Account account: accounts)
        {
            
            if(nextYear){
                fieldsName = fieldsNamesPPY.keySet();
                for( String field: fieldsName){
                    String fieldNamePY = fieldsNamesPPY.get(field);//String with the name of the field (Previous Year)
                    Object fieldValuePY = account.get(fieldNamePY);// Geting value of the field(Previous Year)
                    if(t.get(field).getDescribe().getType()==Schema.DisplayType.Boolean)// if we don't put this code, method put detect the booleans fields as a String
                        account.put(field, (boolean)fieldValuePY);//Seting a security copy of previous year value
                    else 
                        account.put(field, fieldValuePY);
                    
                }
                fieldsName = fieldsNamesForChangePY.keySet();
                for( String field: fieldsName){
                    String fieldNameCY = fieldsNamesForChangePY.get(field);//String with the name of the field (Current Year)
                    Object fieldValueCY = account.get(fieldNameCY);// Geting value of the field(Current Year)
                    if(t.get(field).getDescribe().getType()==Schema.DisplayType.Boolean)
                        account.put(field, (boolean)fieldValueCY);
                    else 
                        account.put(field, fieldValueCY);//Seting a value from current year to previous year 
                    
                }
                
                fieldsName = fieldsNamesForChangeCY.keySet();
                for( String field: fieldsName){
                    Object ValueCY = fieldsNamesForChangeCY.get(field);
                    if(t.get(field).getDescribe().getType()==Schema.DisplayType.Boolean)
                        account.put(field, (boolean)ValueCY);
                    else 
                        account.put(field, ValueCY);
                    
                    
                }
                AccountUpdateMap.put(account.ID, account);
                accountsList.add(account.ID);
            }else{
                
                fieldsName = fieldsNamesForChangePY.keySet();
                for( String field: fieldsName){
                    String fieldNamePY = fieldsNamesForChangePY.get(field);//String with the name of the field (Previous Year)
                    Object fieldValuePY = account.get(fieldNamePY);// Geting value of the field(Previous Year)
                    if(t.get(field).getDescribe().getType()==Schema.DisplayType.Boolean)
                        account.put(field, (boolean)fieldValuePY);//Seting a value from previous year to current year
                    else 
                        account.put(field, fieldValuePY);
                }
                fieldsName = fieldsNamesPPY.keySet();
                for( String field: fieldsName){
                    String fieldNamePPY = fieldsNamesPPY.get(field);//String with the name of the field (Previous Previous Year)
                    Object fieldValuePPY = account.get(fieldNamePPY);// Geting value of the field(Previous Previous Year)
                    if(t.get(field).getDescribe().getType()==Schema.DisplayType.Boolean)
                        account.put(field, (boolean)fieldValuePPY);//Seting security copy to previous year value
                    else 
                        account.put(field, fieldValuePPY);
                }
                AccountUpdateMap.put(account.ID, account);
                accountsList.add(account.ID);
            }
        }
        update AccountUpdateMap.values();
        AccountTriggerHelper.updateSummaryAcreages(accountsList);
        AccountTriggerHelper.updateSummaryCampaignLineItem(accountsList);
    }   
    global void finish(Database.BatchableContext BC)
    {
    }

}