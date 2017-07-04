public without sharing class TriggerContactAutoincrement implements Triggers.Handler
{
     public String LastContactAI='';
     public List<String> AIList=new List<String>();
     public Integer ContactNumber;
     public Boolean isGermany=false;
   
    public void handle()
    {
        for (Contact citem: (List<Contact>)Trigger.new)
        {
            if(citem.CountryRef__c=='a0CD000000PNdHHMA1')
            {
                isGermany=true;
                break;
            }             
        }
        if(isGermany)
        {
            List<AggregateResult> arList = [SELECT max(DE_MonsantoId__c) MonsantoID from contact where CountryRef__c='a0CD000000PNdHH' and DE_MonsantoId__c LIKE 'DE%' AND CreatedDate>2015-01-01T10:00:00Z ];
            if(arList != null && arList.size()>0){
                for(AggregateResult ar : arList)
                {
                    LastContactAI=string.valueof(ar.get('MonsantoID'));
                    AIList=LastContactAI.splitByCharacterType();
                    ContactNumber=Integer.valueof(AIList.get(1));
    
                    break;              
                }
            }
            
            for (Contact citem: (List<Contact>)Trigger.new)
            {
    
               if (citem.CountryRef__c=='a0CD000000PNdHHMA1')
               {
                       ContactNumber++;
                       if(ContactNumber>99999)
                           citem.DE_MonsantoId__c='DE'+String.valueof(ContactNumber);
                       else if(ContactNumber<99999 && ContactNumber>85000)
                           citem.DE_MonsantoId__c='DE0'+String.valueof(ContactNumber);      
                       else 
                          citem.DE_MonsantoId__c='DE0'+String.valueof('85000');      
               }
            }
        }
        
    }
}