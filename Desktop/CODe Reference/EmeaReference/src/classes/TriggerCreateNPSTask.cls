/**
* Trigger on the case to create a new Task related to the Contact of the Survey Result used for NPS Campaigns
* on after insert
*
* Author: Mark Kirgis
*/
public without sharing class TriggerCreateNPSTask implements Triggers.Handler
{
    public void handle()
    {
        Date TaskDueDate = system.today().adddays(+7);
        
        //Get the RecordTypeID for "Survey Result" on Case Object
        string recordtype = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Survey Result').getRecordTypeId();
        
        List<Task> taskList = new List<Task>();
        List<Id> AccountIds= new List<Id>();
        List<Id> CampaignIds = new List<Id>();
        
        for (Case cc : (List<Case>)Trigger.new)   
        {
          AccountIds.add(cc.AccountId);
          CampaignIds.add(cc.NPS_CAMPAIGN__c);
        }
        
          
          Map<id, id> mapAc = new Map<id, id>();
          for (Account a: [Select id, ownerid FROM Account WHERE id =: AccountIds]){
              mapAc.put(a.id,a.ownerid);
          }
          
          Map<Id, Campaign> mapCampaigns = new Map<Id,Campaign>([SELECT Id, Name, DivisionRef__r.Name, YearV2__r.Name, CountryRef__r.Name, TXT_Wave__c, TXT_Farm_Size__c, TXT_Segment__c FROM Campaign WHERE Id IN :CampaignIds]);
          
         for (Case c : (List<Case>)Trigger.new){   
         Task newtask= new Task();
             if(c.ContactId != null){         
                 //Only create a Task for Cases "Survey Result" and Q4="YES"
                 if( (c.RecordTypeId == recordtype) && c.NPS_RESULT_Q4__c != null && (c.NPS_RESULT_Q4__c.toLowerCase().equals('yes')) ){ 
                                  
                     newtask.WhatId = c.AccountId;
                     newtask.WhoId = c.ContactId;
                     newtask.Subject = 'NPS: Customer Call';
                     newtask.Status = 'Not Started';
                     newtask.OwnerId= mapAc.get(c.AccountId);
                     newtask.Priority = 'High';
                     newtask.ActivityDate = TaskDueDate;
                     newtask.LKP_Campaign__c = c.NPS_CAMPAIGN__c;
                     newtask.NPS_INTERVIEW_START__c = c.NPS_INTERVIEW_START__c;
                     newtask.LKP_NPS_Case__c = c.Id;
                     
                     //Campaign Information
                     newTask.TXT_Division__c = (mapCampaigns.get(c.NPS_CAMPAIGN__c)).DivisionRef__r.Name;
                     newTask.TXT_Year__c = (mapCampaigns.get(c.NPS_CAMPAIGN__c)).YearV2__r.Name;                    
                     newTask.TXT_Wave__c = (mapCampaigns.get(c.NPS_CAMPAIGN__c)).TXT_Wave__c;
                     newTask.TXT_Farm_size__c = (mapCampaigns.get(c.NPS_CAMPAIGN__c)).TXT_Farm_Size__c;
                     newTask.TXT_Segment__c = (mapCampaigns.get(c.NPS_CAMPAIGN__c)).TXT_Segment__c;
                     
                     taskList.add(newtask);
                 }
             }
         }
       
         if(taskList.size() > 0){
           insert taskList;
         }         
    }
}