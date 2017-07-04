@isTest
/**
* Tests CampaignTriggerHelper
*/
private class CampaignTriggerHelperTest
{
    /**
    * tests summary fields on Campaing from CLI.
    * TotalAllocatedBudget__c summ of all Quantity__c from CLI.
    */
    static testMethod void testCLISummary()
    {
        Map<String, Object> aCornMap = new Map<String, Object> {'Name' => 'Corn Camp', 'StatusCode__c' => 200};
        Campaign aCampaign = (Campaign) SmartFactory.createSObject('Campaign', aCornMap);
        insert aCampaign;
        
        Map<String, Object> aBasicCLIMap = new Map<String, Object> {'RecordTypeId' => Util.recordType.get('CampaignLineItem__c:Sales'),
                  'Status__c' => 'Confirmed', 'CampaignRef__c' => aCampaign.Id, 'POG__c' => 10, 'Agreed__c' => 20, 'Forecast__c' => 30};
        //Create 3 Campaign Line Items and test them.
        Test.startTest();
        CampaignLineItem__c aCornCLI1 = (CampaignLineItem__c) SmartFactory.createSObject('CampaignLineItem__c', aBasicCLIMap);
        aBasicCLIMap.put('Status__c','Forecast');
        aBasicCLIMap.put('POG__c', 100);
        aBasicCLIMap.put('Agreed__c', 200);
        aBasicCLIMap.put('Forecast__c', 300);
        CampaignLineItem__c aCornCLI2 = (CampaignLineItem__c) SmartFactory.createSObject('CampaignLineItem__c', aBasicCLIMap);
        insert new List<CampaignLineItem__c> {aCornCLI1, aCornCLI2};
        Campaign aTestCamp = (Campaign) Database.query(new al.SoqlBuilder().selectx('TotalAllocatedBudget__c').fromx('Campaign')
                  .wherex(new al.FieldCondition('Id', aCampaign.Id)).toSOQL()).get(0);
        //TODO : @Alex Test Error
        //System.assertEquals(aCornCLI1.POG__c + aCornCLI2.Forecast__c, aTestCamp.TotalAllocatedBudget__c, 'Wrong TotalAllocatedBudget__c');
        Test.stopTest();
    }
}