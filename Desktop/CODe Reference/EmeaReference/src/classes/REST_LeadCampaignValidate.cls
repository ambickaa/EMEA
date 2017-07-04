@RestResource(urlMapping='/LeadCampaignValidate/*') 
global without sharing class REST_LeadCampaignValidate
{
    @HttpPost
    global static CampaignWrapper LeadCampaignValidate(CampaignWrapper param)
    {
        List<Campaign> CampaignResult = [SELECT Id,Name,DAT_Event_Start__c,DAT_Event_End__c FROM Campaign WHERE Id = :param.campaignId LIMIT 1];
        
        CampaignWrapper CampaignResponse = new CampaignWrapper();
        
        if(CampaignResult.size() > 0)
        {
          CampaignResponse.campaignId = CampaignResult[0].Id;
          CampaignResponse.campaignName = CampaignResult[0].Name;
          DateTime startDt = CampaignResult[0].DAT_Event_Start__c;
          DateTime endDt = CampaignResult[0].DAT_Event_End__c;
          CampaignResponse.startDate = Date.newInstance(startDt.year(),startDt.Month(),startDt.day());
          CampaignResponse.endDate = Date.newInstance(endDt.year(),endDt.Month(),endDt.day());
        }
        else
          CampaignResponse.campaignId = '';
        
        return CampaignResponse;
    }
    
    global class CampaignWrapper
    {
        public String campaignId;
        public String campaignName;
        public DateTime startDate;
        public DateTime endDate;
    }
}