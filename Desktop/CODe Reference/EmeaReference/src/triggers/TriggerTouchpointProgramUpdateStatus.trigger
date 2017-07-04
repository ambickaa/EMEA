trigger TriggerTouchpointProgramUpdateStatus on Event (after insert, after update) {
    
    User usr = [Select id, name, CountryISOCode__c, Country  from User where id=:UserInfo.getUserId() Limit 1];
    
    system.debug('es null? '+ usr);
    
    string isocode = CountryISOFilter.ISOFilter(usr);
    string a = isocode +'_TPP_TRIGGER';
    system.debug('query: '+a);
    
    SystemSettings__c mcs = SystemSettings__c.getinstance(a);
    
	if(Test.isRunningTest() && mcs == null)
		mcs = new SystemSettings__c(Name = a, Value__c = '1#1#1');

    system.debug('custom:'+mcs.value__c);

    string [] values = mcs.value__c.split('\\#'); //[0]plan,[1]agreed,[2]completed
    system.debug('valores:'+values[0]+'\n'+values[1]+'\n'+values[2]);
    
    map<id,list<event>> mapEvent = new map<id,list<event>>();
    set<id> tppId = new set<id>();
    
    for(Event eNew : Trigger.new){
    
        //L�gica para TPs nuevos o aquellos con los CHECKs modificados: agreed, completed o plan.
        if (Trigger.isInsert || Trigger.oldMap.get(eNew.Id).Agreed__c != Trigger.newMap.get(eNew.Id).Agreed__c || Trigger.oldMap.get(eNew.Id).Completed__c!= Trigger.newMap.get(eNew.Id).Completed__c || Trigger.oldMap.get(eNew.Id).Plan__c != Trigger.newMap.get(eNew.Id).Plan__c ){
          
          //L�gica solo para TPs que tienen TPP en el lookUp
          if(eNew.LKP_TOUCHPOINT_PROG__c != null){
          
            if(mapEvent.containsKey(eNew.LKP_TOUCHPOINT_PROG__c)){
              mapEvent.get(eNew.LKP_TOUCHPOINT_PROG__c).add(eNew);
            }else{
              mapEvent.put(eNew.LKP_TOUCHPOINT_PROG__c, new List<event>{eNew});
            }

            tppId.add(eNew.LKP_TOUCHPOINT_PROG__c);
          }        
        }
    }
    
    List<Touchpoint_Program__c> tppUp = new List<Touchpoint_Program__c>();
    boolean recordUpdated=false;
    
    for(Touchpoint_Program__c TPP : [SELECT id, CHK_AGREED__c,CHK_COMPLETED__c,CHK_PLAN__c FROM Touchpoint_Program__c WHERE id in:tppId ]){
        for(Event e : mapEvent.get(TPP.id)){
            recordUpdated = false;
            if(values[0]=='1' && e.Plan__c==true && TPP.CHK_PLAN__c==false){ //plan update
                TPP.CHK_PLAN__c=true;
                recordUpdated = true;
                system.debug('entre en el plan');
            }
            if(values[1]=='1' && e.Agreed__c==true && TPP.CHK_AGREED__c==false){ //agreed update
                TPP.CHK_AGREED__c=true;
                recordUpdated = true;
                system.debug('entre en el agreed');
            }
    
            if(values[2]=='1' && e.Completed__c==true && TPP.CHK_COMPLETED__c==false){ //completed update
                TPP.CHK_COMPLETED__c=true;
                recordUpdated = true;
                system.debug('entre en el completed');
            }
            if(recordUpdated) tppUp.add(TPP);
        }    
    }
    
    Update tppUp;

}