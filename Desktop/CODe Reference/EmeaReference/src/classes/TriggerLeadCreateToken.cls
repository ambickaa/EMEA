public with sharing class TriggerLeadCreateToken implements Triggers.Handler 
{
    
    public void handle()
    {
        Map<String,Id> mapaCountries = new Map<String,Id>();
        Map<String,Lead_Country_Fields__c > mapaLeadCountryFields = new Map<String,Lead_Country_Fields__c>();
        List<String> countryList = new List<String>();
        for(Lead l : (List<Lead>)Trigger.new)
        {
            countryList.add(l.country);
        }
        for(Country__c c : [SELECT id, name from country__c where name in : countryList])
        {
            mapaCountries.put(c.name, c.Id);
        }
        
        for(Lead_Country_Fields__c lcf : [SELECT id, LKP_Country__c, PICK_Lead_Source__c, PICK_Converted_Account_category__c, PICK_Converted_Account_RT__c from Lead_Country_Fields__c])
        {
            mapaLeadCountryFields .put(lcf.LKP_Country__c+'-'+lcf.PICK_Lead_Source__c, lcf);
        }
        
        
        for(Lead l : (List<Lead>)Trigger.new)
        {
            //Initialize lead fields for conversion to account / contact
            l.LKP_Country__c = mapaCountries.get(l.country);
            l.LKP_Country_Account__c = mapaCountries.get(l.country);
            Lead_Country_Fields__c lcf = mapaLeadCountryFields.get(l.LKP_Country__c+'-'+l.LeadSource);
            if(lcf!=null)
            {
                l.PICK_Converted_Account_category__c = lcf.PICK_Converted_Account_category__c;
                l.PICK_Converted_Account_RT__c = lcf.PICK_Converted_Account_RT__c;
            }            
            // Initialize Campaign Id
            if(l.TXT_CampaignId__c != null || l.TXT_CampaignId__c != ''){
                String campaignString = l.TXT_CampaignId__c;
                Id campaignId = campaignString;
                l.LKP_Campaign__c = campaignId;
            }

            if(l.Email != null)
            {
                l.TXT_Security_Token__c = generateGUID();
                if(l.Status != 'Confirmed')
                    l.Status = 'Pending confirmation';
            }           
        }
    }
    
    // Builds a GUID-like token
    public static string GenerateGUID() 
    {
        blob privateKey = crypto.generateAesKey(256);
        string randomString = EncodingUtil.base64Encode(crypto.generateMac('hmacSHA512',privateKey,privateKey));
        randomString = randomString.ReplaceAll('[^\\w]','');
        //White spaces
        if(randomString.length() < 80) randomString = GenerateGUID();
        randomString = randomString.ReplaceAll('\\s', '');
        return randomString.substring(0,80);
    }   

}