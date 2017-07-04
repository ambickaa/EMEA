@RestResource(urlMapping='/leadLogin/*') 
global without sharing class REST_LeadLogin
{
    @HttpPost
    global static LeadWrapper leadLogin(LeadWrapper param)
    {
        
        list<Lead> leadCheck = [SELECT Id, isConverted FROM Lead WHERE Id =: param.elementId LIMIT 1];                        
        list<Contact> contactCheck = [SELECT Id FROM Contact WHERE Id =: param.elementId LIMIT 1];   
        
        LeadWrapper leadResponse = new LeadWrapper();
        
        //EXISTS
        if(leadCheck.size() > 0)
        {
            if(leadCheck[0].isConverted == false)
            {                        
                leadResponse.status = 'Lead found';
                leadResponse.elementId = leadCheck[0].Id;
            }
            else if(leadCheck[0].isConverted == true)
            {
                leadResponse.status = 'Lead converted';
                leadResponse.elementId = leadCheck[0].ConvertedContactId;
            }
        }
        else if(contactCheck.size() > 0)
        {                        
            leadResponse.status = 'Contact found';
            leadResponse.elementId = contactCheck[0].Id;
        }
        //NOT EXISTS      
        else
        {
            leadResponse.status = 'Not exists';
            leadResponse.elementId = null;
        }

        return leadResponse;
    }
    
    global class LeadWrapper
    {
        public String status;
        public Id elementId;
    }
}