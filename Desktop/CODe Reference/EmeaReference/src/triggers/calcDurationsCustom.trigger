trigger calcDurationsCustom on case (after update) {
    //try {
        list<id> ownerIds = new list<id>();
        for (case c : trigger.old)
            ownerIds.add(c.ownerId);
        map<id,user> userMap = new map<id,user>([select id, department, manager.name from user where id in :ownerIds]);
    
        list<STOWD__Status_Ownership_Duration__c> durations = new list<STOWD__Status_Ownership_Duration__c>();
        set<string> trackedFields = new set<string> {'OwnerId', 'Status'};
        STOWD.API.CalculateDurations(durations, trackedFields, 'caseHistory', 'CaseId'); 
        for (STOWD__Status_Ownership_Duration__c d : durations) {
            case o = trigger.oldMap.get(d.stowd__parent__c);
            case n = trigger.newMap.get(d.stowd__parent__c);
            if (o.ownerId.getSobjectType() == Schema.User.SObjectType) {
                user u = userMap.get(o.ownerId);
                d.department__c = u.department;
                d.manager__c = u.manager.name;
            }
            else
                d.queue__c = true;
            if (o.status != n.status)
                d.new_status__c = n.status;
        }
        database.insert(durations, false);
    //}
    //catch (exception e) {}
}