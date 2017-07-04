@isTest
private class REST_LeadCampaignValidate_Test
{
    static testmethod void CampaignId()
    {
        
        //Getting Monsanto Event RecordType Id
        Id recTypeId = Util.recordType.get('Campaign:Monsanto_Event');
        //--------------------
        // Inserting new campaign
        //--------------------
        Campaign c = new Campaign();
        c.Name = 'Winter events - Test';
        c.DAT_Event_Start__c = DateTime.Now();
        c.DAT_Event_End__c = DateTime.Now().addMonths(1);
        c.RecordTypeId = recTypeId;
        insert c;
        
        DateTime startDt = c.DAT_Event_Start__c;
        DateTime endDt = c.DAT_Event_End__c;
        
        REST_LeadCampaignValidate.CampaignWrapper request = new REST_LeadCampaignValidate.CampaignWrapper();
        request.campaignId = c.Id;
        
        String JSON_request = JSON.serialize(request);
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/LeadCampaignValidate';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSON_request);
        RestContext.request = req;
        RestContext.response = res;
        
        REST_LeadCampaignValidate.CampaignWrapper response = new REST_LeadCampaignValidate.CampaignWrapper();
        response = REST_LeadCampaignValidate.LeadCampaignValidate(request);
        System.assertEquals(response.campaignId, c.Id);
        System.assertEquals(response.campaignName,c.Name);
        System.assertEquals(response.startDate,Date.newInstance(startDt.year(),startDt.Month(),startDt.day()));
        System.assertEquals(response.endDate,Date.newInstance(endDt.year(),endDt.Month(),endDt.day()));
        
        Test.stopTest();
    }
}