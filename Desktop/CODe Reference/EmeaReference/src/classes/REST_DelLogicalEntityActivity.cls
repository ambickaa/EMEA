@RestResource(urlMapping='/getDeletedLogicalEntity/Activity/*')
global with sharing class REST_DelLogicalEntityActivity{
  
    @HttpPost
    global static REST_DelLogicalEntity_Activity getDeletedActivities(REST_DelLogicalEntity_Activity paramInfo)
    {
        REST_DelLogicalEntity_Activity returned = new REST_DelLogicalEntity_Activity();
        returned.tasks = new List<Task>();
        returned.events = new List<Event>();
        returned.cases = new List <Case>();
        
        Map<ID,Task> paramInfoTask = new Map<ID,Task>(paramInfo.tasks);
        Set<ID> paramInfoTaskIDs = paramInfoTask.keySet();        
        
        Map<ID,Task> currentTasks = new Map<ID,Task>( [ SELECT Id 
        												FROM Task 
            											WHERE  (createddate > :Date.today().addMonths(-1*(Integer.valueof(systemSettings__c.getvalues('NUM_MONTHS_EVENTS_IPAD').value__c))) or activitydate > :Date.today().addMonths(-1*(Integer.valueof(systemSettings__c.getvalues('NUM_MONTHS_EVENTS_IPAD').value__c))))
        												AND Id IN :paramInfoTaskIDs]);
        Set<ID> currentTaskIDs = currentTasks.keySet();
        
        paramInfoTaskIDs.removeAll(currentTaskIDs);
    	for(ID id : paramInfoTaskIDs){ 
            returned.tasks.add(paramInfoTask.get(id));
        }
        
        Map<ID,Event> paramInfoEvent = new Map<ID,Event>(paramInfo.events);
        Set<ID> paramInfoEventIDs = paramInfoEvent.keySet();        
        
        Map<ID,Event> currentEvents = new Map<ID,Event>( [SELECT Id 
        												  FROM Event 
            											  WHERE  ActivityDate > :Date.today().addMonths(-1*(Integer.valueof(systemSettings__c.getvalues('NUM_MONTHS_EVENTS_IPAD').value__c)))
        												  AND Id IN :paramInfoEventIDs]);
        Set<ID> currentEventIDs = currentEvents.keySet();
        
        paramInfoEventIDs.removeAll(currentEventIDs);
    	for(ID id : paramInfoEventIDs){ 
            returned.events.add(paramInfoEvent.get(id));
        } 
        
        Map<ID,Case> paramInfoCase = new Map<ID,Case>(paramInfo.cases);
        Set<ID> paramInfoCaseIDs = paramInfoCase.keySet();        
        
        Map<ID,Case> currentCases = new Map<ID,Case>( [SELECT Id 
        												  FROM Case 
            											  WHERE Id IN :paramInfoCaseIDs]);
        Set<ID> currentCaseIDs = currentCases.keySet();
        
        paramInfoCaseIDs.removeAll(currentCaseIDs);
    	for(ID id : paramInfoCaseIDs){ 
            returned.cases.add(paramInfoCase.get(id));
        }                      
        return returned;
    }
    
    global class REST_DelLogicalEntity_Activity {
        public List<Task> tasks;
        public List<Event> events;
        public List<Case> cases;
    }   
}