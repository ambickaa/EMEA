/**
* Trigger on the contact to copy several fields from the related account to the contact
* on before insert
*
* Author: PARX Werk AG 2012
*/
public without sharing class TriggerContact implements Triggers.Handler
{
    public void handle()
    {
        // gather all the related account ids
        Set<Id> aRelatedAccountIds = new Set<Id>();

        for (Contact c : (List<Contact>)Trigger.new)
        {
            aRelatedAccountIds.add(c.AccountId);
        }

        // query all the needed fiels from the related accounts
        Map<Id, Account> anAccountMap = new map<id, Account>
        ([SELECT DE_Territory_Key__c, DE_ZIP_PLZ__c, DE_PLZ__c, DE_Landkreis__c,
        		ZIPPostalCode__c, Street__c, City__c, StateProvince__c, Micro_Region__c, County__c, CountryRef__c
                FROM Account
                WHERE Id In :aRelatedAccountIds]
        );
        System.debug('************** Id Account ************** ' + aRelatedAccountIds);

        // iterate through all the contacts and copy the field values from the account
        for (Contact c : (List<Contact>)Trigger.new)
        {
            if (anAccountMap.containsKey(c.AccountId))
            {
                Account relAcc = anAccountMap.get(c.AccountId);
                
                c.DE_Territory_Key__c = c.DE_Territory_Key__c == null ? relAcc.DE_Territory_Key__c : c.DE_Territory_Key__c;
				c.ZIPPostalCode__c = c.ZIPPostalCode__c == null ? relAcc.ZIPPostalCode__c : c.ZIPPostalCode__c;
				c.DE_ZIP_PLZ__c = c.DE_ZIP_PLZ__c == null ? relAcc.DE_ZIP_PLZ__c : c.DE_ZIP_PLZ__c;
				c.Street__c = c.Street__c == null ? relAcc.Street__c : c.Street__c;
				c.City__c = c.City__c == null ? relAcc.City__c : c.City__c;
				c.StateProvince__c = c.StateProvince__c == null ? relAcc.StateProvince__c : c.StateProvince__c;
				c.Micro_Region__c = c.Micro_Region__c == null ? relAcc.Micro_Region__c : c.Micro_Region__c;
				c.DE_Landkreis__c = c.DE_Landkreis__c == null ? relAcc.DE_Landkreis__c : c.DE_Landkreis__c;
				c.County__c = c.County__c == null ? relAcc.County__c : c.County__c;
				c.CountryRef__c = c.CountryRef__c == null ? relAcc.CountryRef__c : c.CountryRef__c;
				
				c.DE_Private_Territory_Key__c = c.DE_Private_Territory_Key__c == null ? relAcc.DE_Territory_Key__c : c.DE_Private_Territory_Key__c;
				c.DE_PrivateZIP__c = c.DE_PrivateZIP__c == null ? relAcc.DE_ZIP_PLZ__c : c.DE_PrivateZIP__c;
				c.DE_PrivateStreet__c = c.DE_PrivateStreet__c == null ? relAcc.Street__c : c.DE_PrivateStreet__c;
				c.DE_PrivateCity__c = c.DE_PrivateCity__c == null ? relAcc.City__c : c.DE_PrivateCity__c;
				c.DE_Private_State_Province__c = c.DE_Private_State_Province__c == null ? relAcc.StateProvince__c : c.DE_Private_State_Province__c;
				c.DE_Private_Landkreis__c = c.DE_Private_Landkreis__c == null ? relAcc.DE_Landkreis__c : c.DE_Private_Landkreis__c;
				c.DE_PrivateCountry__c = c.DE_PrivateCountry__c == null ? relAcc.CountryRef__c : c.DE_PrivateCountry__c;
            }
        }
    }
}