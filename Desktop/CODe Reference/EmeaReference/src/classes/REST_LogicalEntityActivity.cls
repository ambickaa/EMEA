@RestResource(urlMapping='/getLogicalEntity/Activity/*') 
global with sharing class REST_LogicalEntityActivity{
  
    @HttpPost
    global static REST_LogicalEntity_Activity getActivities(REST_Request paramInfo){
      
      REST_LogicalEntity_Activity returned = new REST_LogicalEntity_Activity(paramInfo.timestamp);
      
      returned.tasks= [ SELECT Id,
                OwnerId,
                CallDurationInSeconds,
                CallObject,
                CallDisposition,
                CallType,
                Description,
                CreatedById,
                ActivityDate,
                //Email,
                LastModifiedById,
                lastmodifieddate,
                WhoId,
                Who.Name,
                //Phone,
                Priority,
                WhatId,
                NPSFollowUp__c, 
                What.Name,
                Status,
                Subject,
                RecordTypeId,
                Type,
                TXT_COMMENTS_COPY__c,
                IdDevice__c,
                Realized__c,
                TaskReminderTime__c,
                NPSScore__c,
                LKP_TOUCHPOINT_PROG__c
            FROM Task
            WHERE OwnerId=:Util.currentUser.Id
            AND lastModifiedDate > :paramInfo.pagetimestamp
            AND  (lastModifiedDate > :Date.today().addMonths(-1*(Integer.valueof(systemSettings__c.getvalues('NUM_MONTHS_EVENTS_IPAD').value__c))) or activitydate >  :Date.today().addMonths(-1*(Integer.valueof(systemSettings__c.getvalues('NUM_MONTHS_EVENTS_IPAD').value__c))))
            order by lastmodifieddate desc];
            
    returned.events = [SELECT Id,
                IsAllDayEvent,
                OwnerId,
                CreatedById,
                ActivityDate,
                Description,
                DurationInMinutes,
                //Email,
                EndDateTime,
                RecordTypeId,
                LastModifiedById,
                lastmodifieddate,
                Location,
                WhoId,
                Who.Name,
                //Phone,
                IsPrivate,
                WhatId,
                What.Name,
                StartDateTime,
                Subject,
                ActivityDateTime,
                Type,
                NUM_ATTENDEES__c,
                TaskReminderTime__c,
                TXT_COMMENTS_COPY__c,
                IdDevice__c,
                Realized__c,
                NPSScore__c,
                LKP_TOUCHPOINT_PROG__c,
                Plan__c,
                Agreed__c,
                Completed__c
            FROM Event
            WHERE OwnerId=:Util.currentUser.Id
            AND lastModifiedDate > :paramInfo.pagetimestamp
            AND  lastModifiedDate > :Date.today().addMonths(-1*(Integer.valueof(systemSettings__c.getvalues('NUM_MONTHS_EVENTS_IPAD').value__c)))
            order by lastModifiedDate desc];
              
    returned.cases = [SELECT Id,
                AccountId,
                Account.Name,
                CaseNumber,
                OwnerId,
                Reason,
                RecordTypeId,
                //ContactEmail,
                //ContactFax
                //ContactMobile,
                ContactId,
                Contact.FirstName,
                Contact.LastName,
                //ContactPhone,
                CreatedById,
                ClosedDate,
                CreatedDate,
                LastModifiedById,
                lastmodifieddate,
                Status,
                Subject,
                Type,
                IdDevice__c,
                NPS_CAMPAIGN__c,
                NPS_TXT_INTERVIEW_END__c,
                NPS_TXT_INTERVIEW_START__c,
                NPS_TXT_LANGUAGE__c,
                NPS_TXT_STATUS__c,
                NPS_TIME_OF_PREFERENCE__c,
                NPS_EXT_RESPONSEID__c,
                NPS_RESULT_ADD_COMMENTS__c,
                NPS_RESULT_Q1__c,
                NPS_RESULT_Q21__c,
                NPS_RESULT_Q22__c,
                NPS_RESULT_Q31__c,
                NPS_RESULT_Q32__c,
                NPS_RESULT_Q4__c
            FROM Case
            WHERE OwnerId=:Util.currentUser.Id
            AND lastModifiedDate > :paramInfo.pagetimestamp
            order by lastModifiedDate desc];
            
    //Calculate timestamp
        returned.timestamp=paraminfo.maxtimestamp;
        if(returned.cases != null && returned.cases.size() > 0 && returned.cases[0].lastmodifieddate > returned.timestamp)
            returned.timestamp = returned.cases[0].lastmodifieddate;
        if(returned.events != null && returned.events.size() > 0 && returned.events[0].lastmodifieddate > returned.timestamp)
            returned.timestamp = returned.events[0].lastmodifieddate;
        if(returned.tasks != null && returned.tasks.size() > 0 && returned.tasks[0].lastmodifieddate > returned.timestamp)
            returned.timestamp = returned.tasks[0].lastmodifieddate;    
      
      return returned;      
    }
    
    global class REST_LogicalEntity_Activity{
        global List<Task> tasks {get;set;}
        global List<Event> events {get;set;}
        global List<Case> cases {get;set;}
        global DateTime timestamp {get;set;}
        
        public REST_LogicalEntity_Activity(Datetime timeReference){
            this.tasks=new List<Task>();
            this.events=new List<Event>();
            this.cases=new List<case>();
            this.timestamp=timereference;
        }
    }
    
}