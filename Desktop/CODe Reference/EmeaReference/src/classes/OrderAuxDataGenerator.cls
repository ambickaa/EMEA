global with sharing class OrderAuxDataGenerator implements Database.batchable<sObject>,Database.AllowsCallouts{
    //Batch class to fill the auxiliar data for the orders,this data represents the relationship between the ships to and solds to and the users.
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query =' Select name,Primry_Acct_Integration_Key__c,Sales_Area_Integration_Key__r.name,Country_Name__c,Partner_SAP_ID__c,Partner_Function_Descr__c from Partner_Function__c ';
        query+= 'where (Partner_Function_DEscr__C=\'YB/Area Manager\' or Partner_Function_DEscr__C=\'YA/Sales Representative\' or Partner_Function_DEscr__C=\'WE/Ship-to Party\') ';
        //query+= 'and is_Marked_For_Del__c = false';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,list<Partner_Function__c> scope)
    {
    	map<string,user> userSAPcodes = new map<string,user>();
        set<Account> accsToUpd = new set<Account>();
        list<id> primAccIDs = new list<id>();
        
        for(user usr:[Select name, Id, SAP_Partner_Code__c from User where isActive = true])
        {
            if(usr.SAP_Partner_code__c != null)
            {
                string usrID = ('0000000000' + usr.SAP_Partner_code__c).right(10);
                userSAPcodes.put(usrId, usr);
            }
        }
        for (Partner_Function__c partner : scope)
        {
            if(partner.Primry_Acct_Integration_Key__c != null)
            {
            	primAccIds.add(partner.Primry_Acct_Integration_Key__c);
            }
        }
        map<Id,Account> primAccs = new map<Id,Account>([Select id,ownerId,TXT_Partners_Ids__c,GC_Cust_Account_Grp_Descr__c,GC_SAP_id__C,Name 
                                                      from Account where Id IN :primAccIds FOR UPDATE]);
        //-------------
        // Change Distributors owners for countries and divisions allowed by a custom settig 'Distributors Owner change'.
        //-------------
        map <string,boolean> salesAreaOwnersMap=new map <string,boolean>();
        for(Distributors_Owner_chage__c item : Distributors_Owner_chage__c.getall().values())
        {
            salesAreaOwnersMap.put(item.Name, item.value__c);
        }
        //system.debug(salesAreaOwnersMap);
        
        for (Partner_Function__c partner:scope)
        {
            if(partner.Country_Name__c!='Italy')
            {
                if(partner.Primry_Acct_Integration_Key__c != null && (partner.Partner_Function_Descr__c.equalsIgnoreCase('YB/Area Manager') || partner.Partner_Function_Descr__c.equalsIgnoreCase('YA/Sales Representative')) 
                   && primAccs.get(partner.Primry_Acct_Integration_Key__c).GC_Cust_Account_Grp_Descr__c != null
                   && primAccs.get(partner.Primry_Acct_Integration_Key__c).GC_Cust_Account_Grp_Descr__c.equalsIgnoreCase('Sold-to Party'))
                {
                    Account primAcc = primAccs.get(partner.Primry_Acct_Integration_Key__c);                   
                    
                    if(userSAPcodes.containsKey(partner.Partner_SAP_ID__c) && partner.Partner_Function_Descr__c.equalsIgnoreCase('YA/Sales Representative'))
                    {
                        if(salesAreaOwnersMap.containsKey(partner.Sales_Area_Integration_Key__r.name))
                        {
                           if(primAcc.OwnerId!=userSAPcodes.get(partner.Partner_SAP_ID__c).Id && 
                              salesAreaOwnersMap.get(partner.Sales_Area_Integration_Key__r.name)) 
                           {
                               primAcc.OwnerId=userSAPcodes.get(partner.Partner_SAP_ID__c).Id;
                               primAccs.put(primAcc.Id, primAcc);
                           }  
                        }
                    }
                    
                    if((primAcc.TXT_Partners_Ids__c == null || !primAcc.TXT_Partners_Ids__c.contains(partner.Partner_SAP_ID__c)) && userSAPcodes.containsKey(partner.Partner_SAP_ID__c))
                    { 
                        if(primAcc.TXT_Partners_Ids__c == null) primAcc.TXT_Partners_Ids__c = partner.Partner_SAP_ID__c + ';';                    
                        else if(primAcc.TXT_Partners_Ids__c.length() <= 245) primAcc.TXT_Partners_Ids__c += partner.Partner_SAP_ID__c + ';';
                        //system.debug(primAcc.TXT_Partners_Ids__c);
                        primAccs.put(primAcc.Id, primAcc);
                    }
                }                            
            }
        }
        if(primAccs.size() > 0) update primAccs.values();
        
        map<string,list<string>> shipsToRel=new map<string,list<string>>();
        list<string> shipsRel=new list<string>();
        //system.debug(scope);
        for (Partner_Function__c partner:scope)
        {
            //system.debug('El partner es: ' + partner.name + ' con Partner sap id: ' + partner.Partner_Sap_ID__c);
            //system.debug('La cuenta relacionada es:' + primAccs.get(partner.Primry_Acct_Integration_Key__c).name + ' con codigo SAP: ' + primAccs.get(partner.Primry_Acct_Integration_Key__c).gc_sap_id__c);
            if(partner.Country_Name__c == 'Italy')
            {
                if(partner.Primry_Acct_Integration_Key__c != null && partner.Partner_Function_Descr__c.equalsIgnoreCase('YA/Sales Representative' ))
                {
                    string sapCode = primAccs.get(partner.Primry_Acct_Integration_Key__c).GC_SAP_id__C;
                    sapCode = ('0000000000' + sapCode).right(10);
                   
                    if(shipsToRel.containsKey(sapCode))
                    {
                        shipsRel = shipsToRel.get(sapCode);
                        shipsRel.add(partner.Partner_SAP_ID__c);
                        
                        shipsToRel.put(sapCode,shipsRel);
                    }
                    else
                    {
                        shipsRel = new list<string>();
                        shipsRel.add(partner.Partner_SAP_ID__c);
                        
                        //system.debug('sapcodee: '+ sapcode);
                        
                        shipsToRel.put(sapCode,shipsRel);
                    }
                }
            }
        }
        //system.debug(shipsToRel);
        list<Partner_Function__c> shipsToR = [select TXT_Partners_Ids__c,Primry_Acct_Integration_Key__r.GC_SAP_id__C,Partner_SAP_ID__c  from Partner_Function__c where Partner_SAP_ID__c in: shipsToRel.keySet() 
                                            and Primry_Acct_Integration_Key__r.GC_Cust_Account_Grp_Descr__c='Sold-to party' and Partner_Function_Descr__c='WE/Ship-to Party'];
        //system.debug(shipsToR);
        
        list<id> primAccIDs2 = new list<id>();
        
        for (Partner_Function__c partner:shipsToR)
        {
            if(partner.Primry_Acct_Integration_Key__c != null)
            {
                primAccIds2.add(partner.Primry_Acct_Integration_Key__c);
            }
        }
        //system.debug(primAccIds2);
        map<Id,Account> primAccs2 = new map<Id,Account>([Select id,TXT_Partners_Ids__c,GC_Cust_Account_Grp_Descr__c,GC_SAP_id__C 
                                                       from account where id in :primAccIds2 FOR UPDATE]);
        
        map<id,Partner_Function__c> partToUpd=new map<id,Partner_Function__c>();                                          
        for(Partner_Function__c partner :shipsToR)
        {
            if(shipsToRel.containsKey(partner.Partner_SAP_ID__c))
            {
                list<string> managers=shipsToRel.get(partner.Partner_SAP_ID__c);
                for (string manager:managers)
                {
                    account primAcc2 =primAccs2.get(partner.Primry_Acct_Integration_Key__c);
                    //system.debug(primAcc2.TXT_Partners_Ids__c);  
                    
                    if((primAcc2.TXT_Partners_Ids__c == null || !primAcc2.TXT_Partners_Ids__c.contains(manager)) && userSAPcodes.containsKey(manager) )
                    { 
                        if(primAcc2.TXT_Partners_Ids__c == null) primAcc2.TXT_Partners_Ids__c = manager + ';';                    
                        else if(primAcc2.TXT_Partners_Ids__c.length() <= 245) primAcc2.TXT_Partners_Ids__c += manager + ';';
                        //system.debug(primAcc2.TXT_Partners_Ids__c);
                        primAccs2.put(primAcc2.Id, primAcc2);
                    }
                    if((partner.TXT_Partners_Ids__c == null || !partner.TXT_Partners_Ids__c.contains(manager)) && userSAPcodes.containsKey(manager) )
                    { 
                        if(partner.TXT_Partners_Ids__c==null)partner.TXT_Partners_Ids__c = manager + ';';                    
                        else IF(partner.TXT_Partners_Ids__c.length() <= 245) partner.TXT_Partners_Ids__c += manager + ';';
                        //system.debug(partner.TXT_Partners_Ids__c);
                        partToUpd.put(partner.Id, partner);
                    }                        
                } 
                
            }
        }
        //system.debug(primAccs2);
        if(primAccs2.size() > 0) update primAccs2.values();
        if(partToUpd.size() > 0) update partToUpd.values();
        
        list<Partner_Function__c> partnersToUpd = new list<Partner_Function__c>();
        for(list<Partner_Function__c> AllshipsTo: [select Primry_Acct_Integration_Key__r.name,Primry_Acct_name__c  from Partner_Function__c where Partner_Function_Descr__c='WE/Ship-to Party' and id in:scope ])        
        {
            for(Partner_Function__c partner: AllshipsTo)
            {
                if(partner.Primry_Acct_name__c==null || partner.Primry_Acct_name__c!=partner.Primry_Acct_Integration_Key__r.name)
                {
                    partner.Primry_Acct_name__c=partner.Primry_Acct_Integration_Key__r.name;
                    partnersToUpd.add(partner);
                }
            }
        }
        
        if(partnersToUpd.size() > 0) update partnersToUpd; 
        
    }
    global void finish(Database.BatchableContext BC)
    {
        
    }
}