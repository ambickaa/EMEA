public class TriggerHybridPK implements Triggers.Handler {   

    public SystemSettings__c settings = SystemSettings__c.getValues('IgnoreTriggers_PKHybrid');
    
    public void handle(){      
        
        String Ignore = 'false';
        if(settings <> null) Ignore = settings.Value__c;
        
        if(Ignore =='false' || (Ignore =='true' && !UserInfo.getUserId().contains('005D0000002FcQu'))){
        
           for(Hybrid__c hyb: (List<Hybrid__c>)trigger.new){
                if(trigger.isUpdate){      
                    hyb.Name=(String)Trigger.oldMap.get(hyb.id).get('Name');        
                    hyb.ProductCatalogRef__c=(ID)Trigger.oldMap.get(hyb.id).get('ProductCatalogRef__c');        
                    hyb.UserRef__c=(ID)Trigger.oldMap.get(hyb.id).get('UserRef__c');    
                    hyb.OwnerId=(ID)Trigger.oldMap.get(hyb.id).get('OwnerId');                                                  
                }       
                hyb.PK__c=hyb.Name+'-'+hyb.UserRef__c+'-'+hyb.ProductCatalogRef__c;
           }
        }          
    }       

}