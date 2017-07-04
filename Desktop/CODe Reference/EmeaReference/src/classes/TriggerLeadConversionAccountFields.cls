public with sharing class TriggerLeadConversionAccountFields implements Triggers.Handler 
{
    
    public void handle()
    {      
        Map<String, Id> mapRecordtype = new Map<String, Id>();
        for(Recordtype rt : [select id, developername from recordtype where sobjecttype='Account'])
        {
            mapRecordtype.put(rt.developerName, rt.Id);
        }
        Map<Id, Account> mapAccounts =  new Map<Id, Account>([SELECT id, countryref__c, recordtypeid from account where createddate > : System.now().addMinutes(-1)]);
        Map<Id, Contact> mapContacts = new Map<Id, Contact>([SELECT Id, TXT_Company__c FROM Contact WHERE CreatedDate > : System.now().addMinutes(-1)]);
        List<Account> listAccountUpdate = new List<Account>();
        List<Contact> listContactUpdate = new List<Contact>();
        
        for(Lead l : (List<Lead>)Trigger.new)
        {
           Lead oldLead = ((Map<Id, Lead>)Trigger.oldMap).get(l.Id);
           if(l.isconverted && !oldLead.isConverted)
           {
               Account acc = mapAccounts.get(l.convertedAccountId);
               if(acc!= null)
               {
                   //BEGIN 13-01-2016 Mapping Lead address fields with Account address custom fields
                   acc.Street__c = l.Street;
                   acc.City__c = l.City;
                   acc.StateProvince__c = l.State;
                   acc.DE_ZIP_PLZ__c = l.PostalCode;
                   //END

                   //BEGIN 29-12-2015 For Germany use user category field as reference for account record type and fill S&T field
                   if(l.Country == 'Germany' && l.PICK_User_category__c != null)
                   {
                        if(l.PICK_User_category__c == 'farmer')
                            acc.recordtypeid=mapRecordtype.get('GroupFarmSite');
                        else
                        {   
                            if(l.PICK_User_category__c == 'contractor')
                                acc.recordtypeid=mapRecordtype.get('DistRetPoS');
                            else
                                acc.recordtypeid=mapRecordtype.get('Others');
                        }
                        acc.DE_IsSTCustomer__c = 'JA';
                        acc.Phone = '';
                        listAccountUpdate.add(acc);
                   }
                   else
                   {
                   //END
                       if(mapRecordtype.get(l.PICK_Converted_Account_RT__c) !=null)
                        {
                           acc.recordtypeid=mapRecordtype.get(l.PICK_Converted_Account_RT__c);
                           listAccountUpdate.add(acc);
                        }
                    }
               }
               Contact c = mapContacts.get(l.ConvertedContactId);
               if(c != null)
               {
                   c.TXT_Company__c = l.Company;

                   //BEGIN 13-01-2016 Mapping Lead address fields with Contact address custom fields
                   c.DE_PrivateStreet__c = l.Street;
                   c.DE_PrivateCity__c = l.City;
                   c.DE_Private_State_Province__c = l.State;
                   c.DE_PrivateZIP__c = l.PostalCode;
                   //END

                   //BEGIN 29-12-2015 For Germany fill S&T field and user farm usage to fill field Mais (picklist)
                   if(l.Country == 'Germany')
                   {
                        c.DE_PICK_ST__c = 'JA';

                        if(l.PICK_Farm_usage__c == 'grain')
                            c.DE_CORN_PICK__c = 'JA';
                        else
                        {
                          if(l.PICK_Farm_usage__c == 'silage biogas')
                            c.DE_OSR_PICK__c = 'JA';
                        }
                   }                    
                   //END

                   listContactUpdate.add(c);
               }
           }
        }    
        update listAccountUpdate;
        update listContactUpdate;    
    }     
}