public without sharing class TriggerPartnerIDtoAccount
{
    public TriggerPartnerIDtoAccount()
    {
    	/*
        set<Account> accsToUpd=new set<Account>();
        list<id> primAccIDs=new list<id>();
        map<string,user> userSAPcodes=new map<string,user>();
        for(user usr:[Select name,SAP_Partner_Code__c from user where isActive=True ])
            {
                if(usr.SAP_Partner_code__c!=null)
                {
                    string usrID=('0000000000' + usr.SAP_Partner_code__c).substring(usr.SAP_Partner_code__c.length());
                    userSAPcodes.put(usr.SAP_Partner_code__c, usr);
                }
            }
        for (Partner_Function__c partner:(list<Partner_Function__c>)trigger.new)
        {
            if(partner.Primry_Acct_Integration_Key__c!=null){primAccIds.add(partner.Primry_Acct_Integration_Key__c);}
        }
         map<Id,Account> primAccs=new map<Id,Account>([Select id,TXT_Partners_Ids__c,GC_Cust_Account_Grp_Descr__c,GC_SAP_id__C,Name 
                                                       from account where id in :primAccIds]);
        

            for (Partner_Function__c partner:(list<Partner_Function__c>)trigger.new)
            {
                    if(partner.Country_Name__c!='Italy')
                    {                
                        // account primAcc=new account();
                        if(partner.Primry_Acct_Integration_Key__c!=null && partner.Partner_Function_Descr__c.equalsIgnoreCase('YB/Area Manager') 
                           && primAccs.get(partner.Primry_Acct_Integration_Key__c).GC_Cust_Account_Grp_Descr__c.equalsIgnoreCase('Sold-to Party'))
                        {
                            account primAcc =primAccs.get(partner.Primry_Acct_Integration_Key__c);
                            system.debug(primAcc.TXT_Partners_Ids__c);  
                            
                            if((primAcc.TXT_Partners_Ids__c==null || !primAcc.TXT_Partners_Ids__c.contains(partner.Partner_SAP_ID__c))&& userSAPcodes.containsKey(partner.Partner_SAP_ID__c) )
                            { 
                                if(primAcc.TXT_Partners_Ids__c==null)primAcc.TXT_Partners_Ids__c= partner.Partner_SAP_ID__c+';';                    
                                else IF(primAcc.TXT_Partners_Ids__c.length() <= 245) primAcc.TXT_Partners_Ids__c+= partner.Partner_SAP_ID__c+';';
                                system.debug(primAcc.TXT_Partners_Ids__c);
                                primAccs.put(primAcc.Id, primAcc);
                            }
                        }                            
                    }
            }
            if(primAccs.size() >0)update primAccs.values();
        
        map<string,list<string>> shipsToRel=new map<string,list<string>>();
        list<string> shipsRel=new list<string>();
        system.debug((list<Partner_Function__c>)trigger.new);
             for (Partner_Function__c partner:(list<Partner_Function__c>)trigger.new)
            {
            system.debug('El partner es: '+ partner.name + ' con Partner sap id: '+ partner.Partner_Sap_ID__c);
            system.debug('La cuenta relacionada es:' + primAccs.get(partner.Primry_Acct_Integration_Key__c).name + ' con codigo SAP: ' + primAccs.get(partner.Primry_Acct_Integration_Key__c).gc_sap_id__c);
            if(partner.Country_Name__c=='Italy')
            {                
            
             if(partner.Primry_Acct_Integration_Key__c!=null && partner.Partner_Function_Descr__c.equalsIgnoreCase('YA/Sales Representative' ))
                {
                    string sapCode=primAccs.get(partner.Primry_Acct_Integration_Key__c).GC_SAP_id__C;
                    sapCode=('0000000000' + sapCode).substring(sapCode.length());
                    if(shipsToRel.containsKey(sapCode))
                    {
                        shipsRel=shipsToRel.get(sapCode);
                        shipsRel.add(partner.Partner_SAP_ID__c);
                        
                        shipsToRel.put(sapCode,shipsRel);
                    }else
                    {
                         shipsRel=new list<string>();
                        shipsRel.add(partner.Partner_SAP_ID__c);

                        system.debug('sapcodee: '+ sapcode);
                            
                        shipsToRel.put(sapCode,shipsRel);
                    }

                }
             }
             }
        system.debug(shipsToRel);
            list<Partner_Function__c> shipsToR=[select TXT_Partners_Ids__c,Primry_Acct_Integration_Key__r.GC_SAP_id__C,Partner_SAP_ID__c  from Partner_Function__c where Partner_SAP_ID__c in: shipsToRel.keySet() 
                                                    and Primry_Acct_Integration_Key__r.GC_Cust_Account_Grp_Descr__c='Sold-to party' and Partner_Function_Descr__c='WE/Ship-to Party' ];
           system.debug(shipsToR);
           
            list<id> primAccIDs2=new list<id>();
            
            for (Partner_Function__c partner:shipsToR)
            {
                if(partner.Primry_Acct_Integration_Key__c!=null)
                {
                    primAccIds2.add(partner.Primry_Acct_Integration_Key__c);
                    
                }

            }
            system.debug(primAccIds2);
             map<Id,Account> primAccs2=new map<Id,Account>([Select id,TXT_Partners_Ids__c,GC_Cust_Account_Grp_Descr__c,GC_SAP_id__C 
                                                           from account where id in :primAccIds2]);
             
             map<id,Partner_Function__c> partToUpd=new map<id,Partner_Function__c>();                                          
            for(Partner_Function__c partner :shipsToR)
            {
                if(shipsToRel.containsKey(partner.Partner_SAP_ID__c))
                {
                    list<string> managers=shipsToRel.get(partner.Partner_SAP_ID__c);
                    for (string manager:managers)
                    {
                    account primAcc2 =primAccs2.get(partner.Primry_Acct_Integration_Key__c);
                    system.debug(primAcc2.TXT_Partners_Ids__c);  
                    
                    if((primAcc2.TXT_Partners_Ids__c==null || !primAcc2.TXT_Partners_Ids__c.contains(manager))&& userSAPcodes.containsKey(manager) )
                    { 
                        if(primAcc2.TXT_Partners_Ids__c==null)primAcc2.TXT_Partners_Ids__c= manager+';';                    
                        else IF(primAcc2.TXT_Partners_Ids__c.length() <= 245) primAcc2.TXT_Partners_Ids__c+= manager+';';
                        system.debug(primAcc2.TXT_Partners_Ids__c);
                        primAccs2.put(primAcc2.Id, primAcc2);
                    }
                    if((partner.TXT_Partners_Ids__c==null || !partner.TXT_Partners_Ids__c.contains(manager))&&userSAPcodes.containsKey(manager) )
                    { 
                        if(partner.TXT_Partners_Ids__c==null)partner.TXT_Partners_Ids__c= manager+';';                    
                        else IF(partner.TXT_Partners_Ids__c.length() <= 245) partner.TXT_Partners_Ids__c+= manager+';';
                        system.debug(partner.TXT_Partners_Ids__c);
                        partToUpd.put(partner.Id, partner);
                    }                        
                    } 
                
                }
            }
            system.debug(primAccs2);
            if(primAccs2.size() >0)update primAccs2.values();
            if(partToUpd.size() >0)update partToUpd.values();
        
        */
    }
}