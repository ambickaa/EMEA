global with sharing class BatchCampaignSalesUpdate implements Database.batchable<sObject>, Database.Stateful {

    private String query = '';
    private List<String> List_years;
    
    global List<Campaign> cToUpdate = new List<Campaign>();
    global Map<Id, Integer> cAction = new Map<Id, Integer>();
    
    private SystemSettings__c triggersOff {
        get {
            return SystemSettings__c.getInstance('IgnoreTriggers_Campaign');
            }
        set;
    }
    
    global BatchCampaignSalesUpdate()
    {
        Integer currentYear = system.today().year();
        
        List_years = new List<String>();
        List_years.add(String.valueof(currentYear - 4));
        List_years.add(String.valueof(currentYear - 3));
        List_years.add(String.valueof(currentYear - 2));
        List_years.add(String.valueof(currentYear - 1));
        List_years.add(String.valueof(currentYear));
        
        query = 'SELECT Id, Name, StartDate, EndDate, ArchiveDate__c, StatusCode__c, IsActive';
        query+= ' FROM Campaign WHERE RecordTypeId = \'' + Util.recordType.get('Campaign:Sales_camp') + '\' AND YearV2__r.Name IN :List_years';
        query+= ' ORDER BY Name ASC';
    }

    global Database.QueryLocator start(Database.BatchableContext theContext)
    {
        triggersOff.Value__c = 'true';
        update triggersOff;
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext theContext, List<Campaign> List_Campaigns)
    {    
        for(Campaign c : List_Campaigns) {
            
            Integer StatusCode_tmp = c.StatusCode__c != null ? Integer.valueOf(c.StatusCode__c) : 0;
            Boolean IsActive_tmp = c.IsActive;
            
            Integer cAction_Code = 0;
            
            if(c.StartDate > Date.today()) {
                c.StatusCode__c = 100;
                c.IsActive = false;
            }
            if(c.StartDate <= Date.today() && c.EndDate > Date.today()) {
                c.StatusCode__c = 200;
                c.IsActive = true;
            }
            if(c.EndDate <= Date.today() && c.ArchiveDate__c > Date.today()) {
                c.StatusCode__c = 300;
                c.IsActive = false;
            }
            if(c.ArchiveDate__c <= Date.today()) {
                c.StatusCode__c = 400;
                c.IsActive = false;
            }
            
            if(StatusCode_tmp != Integer.valueOf(c.StatusCode__c) || IsActive_tmp != c.IsActive) {
                cToUpdate.add(c);
                
                // --------------------------
                // 77: Both fields updated
                // 66: Only StatusCode__c updated
                // 55: Only IsActive updated
                // --------------------------
                cAction_Code = (StatusCode_tmp != Integer.valueOf(c.StatusCode__c) && IsActive_tmp != c.IsActive) ? 77 : cAction_Code;
                cAction_Code = (cAction_Code == 0 && StatusCode_tmp != Integer.valueOf(c.StatusCode__c)) ? 66 : cAction_Code;
                cAction_Code = (cAction_Code == 0 && IsActive_tmp != c.IsActive) ? 55 : cAction_Code;
                
                cAction.put(c.Id, cAction_Code);
            }
        }
        
        if(cToUpdate.size() > 0)
            update cToUpdate;

    }

    global void finish(Database.BatchableContext BC)
    {
        triggersOff.Value__c = 'false';
        update triggersOff;
        
        if(cToUpdate.size() > 0) {
    
            // --------------------------
            // Sending email only if there are updated campaigns
            // --------------------------
            Messaging.reserveSingleEmailCapacity(2);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'ecip.support@monsanto.com'};
            String[] ccAddresses = new String[] {'everis.salesforce@gmail.com'};
            
            mail.setToAddresses(toAddresses);
            mail.setCcAddresses(ccAddresses);
            
            mail.setReplyTo('ecip.support@monsanto.com');
            mail.setSenderDisplayName('eCIP Support Team');
            mail.setSubject('A scheduled batch has updated ' + cToUpdate.size() + ' campaigns');
            
            String tMessage = '---------------\r\n---------------\r\n';
            String cMessage = '<style type="text/css">table tr:nth-child(even) {background-color: #f1f1f1;}</style>';
            cMessage+= '<table style="width:100%; border-collapse: collapse; font-family: Arial, sans-serif; font-size: 13px;">';
            cMessage+= '<thead><tr>';
            cMessage+= '<th style="border: 1px solid #ddd; padding: 4px;"><b>Campaign</b></th>';
            cMessage+= '<th style="border: 1px solid #ddd; padding: 4px;"><b>Action</b></th>';
            cMessage+= '<th style="border: 1px solid #ddd; padding: 4px;"><b>Status</b></th>';
            cMessage+= '</tr></thead>';
            cMessage+= '<tbody>';
            
            for(Campaign c : cToUpdate) {
                
                Integer cAction_Code = cAction.containsKey(c.Id) ? cAction.get(c.Id) : 0;
                
                cMessage+= '<tr><td style="border: 1px solid #ddd; padding: 4px;"><b>' + c.Name + '</b></td><td style="border: 1px solid #ddd; padding: 4px;">';
                
                if(cAction_Code == 77 || cAction_Code == 55)
                    cMessage+= c.IsActive ? 'Enabled</td><td style="border: 1px solid #ddd; padding: 4px;">' + c.StatusCode__c : (c.StatusCode__c == 300 ? 'Closed</td><td style="border: 1px solid #ddd; padding: 4px;">300' : (c.StatusCode__c == 400 ? 'Archived</td><td style="border: 1px solid #ddd; padding: 4px;">400' : 'Disabled</td><td style="border: 1px solid #ddd; padding: 4px;">' + c.StatusCode__c));
                if(cAction_Code == 66)
                    cMessage+= 'Fixed</td><td style="border: 1px solid #ddd; padding: 4px;">' + c.StatusCode__c;
                
                cMessage+= '</td></tr>';
                
                tMessage+= c.Name + '\r\n IsActive = ' + c.IsActive + ' (' + c.StatusCode__c + ')\r\n---------------\r\n';
            }
            
            cMessage+= '</tbody>';
            cMessage+= '</table>';
            tMessage+= '\r\n';
            
            mail.setHtmlBody(cMessage);
            mail.setPlainTextBody(tMessage);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}