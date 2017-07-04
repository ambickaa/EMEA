public without sharing class TriggerPDPCountryGroupUpdateHierarchy implements Triggers.Handler {


    public void handle() 
    {
        SET<String> CountryGroupsSet = new SET<String>();
        List<PDPOrgLineItem__c> PDPOrgLineItemToInsert= new List<PDPOrgLineItem__c>();
                            
        for(PDPCountryGroup__c  cg: Util.CountryGroups)
            {
                CountryGroupsSet.add(cg.Name);
            }
            
        if(trigger.isUpdate)
        {       

            MAP <ID,PDPCountryGroup__c> oldCG = new MAP <ID, PDPCountryGroup__c>();
            
            MAP <String,Boolean> cgChangedName = new MAP <String,Boolean>();
            MAP <String, String> oldNameNewName = new MAP <String, String>();
            Map <String, PDPCountryGroup__c> oldCGName = new Map<String, PDPCountryGroup__c>();
            Map <ID, PDPCountryGroup__c> oldCGNameId = new Map<ID, PDPCountryGroup__c>();
            
            List<PDPOrgLineItem__c> orgLinesToUpdate= new List<PDPOrgLineItem__c>();
            
            for(PDPCountryGroup__c cg:(List<PDPCountryGroup__c>)trigger.old)    
            {
                oldCG.put(cg.ID,cg);
                oldCGName.put(cg.Name,cg);
                oldCGNameId.put(cg.ID,cg);
            }
                
        
            for(PDPCountryGroup__c cg: (List<PDPCountryGroup__c>)trigger.new)
            {
            	 if(cg.Country_LVL_2__c==true && cg.Repeat_L2__c==true)
            	 {
            	 	cg.Repeat_L2__c.addError(System.label.PDP_ERROR_REPEATLVL2);  
            	 }    	
                 oldNameNewName.put(oldCG.get(cg.ID).Name,cg.Name);
            }
            
            
            for(PDPOrgLineItem__c oItem : [ 
                        SELECT Id,is_LVL_1_Line__c,is_LVL_2_Line__c,is_LVL_3_Line__c,is_LVL_4_Line__c,Name,
                        YPDP_L1__c,YPDP_L2_EXTRL_ID__c,YPDP_L3_EXTRL_ID__c,
                        YPDP_L4_EXTRL_ID__c,YPDP_ORG_DISCONTINUED_DATE__c,YPDP_ORG_DISCONTINUED__c,
                        YPDP_L2_EXTRL_ID_PC__c,YPDP_L3_EXTRL_ID_PC__c,YPDP_L4_EXTRL_ID_PC__c, 
                        YPDP_L2_EXTRL_ID_N__c,YPDP_L3_EXTRL_ID_N__c,YPDP_L4_EXTRL_ID_N__c,
                        outputData__c 
                        FROM PDPOrgLineItem__c 
                        WHERE YPDP_L1__C in: oldNameNewName.keyset()])
                    {
                        if(oItem.YPDP_L1__c==oItem.YPDP_L2_EXTRL_ID__c)
                        {
                            oItem.YPDP_L2_EXTRL_ID__c=oldNameNewName.get(oItem.YPDP_L1__c);                     
                        }
                        oItem.YPDP_L1__c=oldNameNewName.get(oItem.YPDP_L1__c);                      
                        
                        orgLinesToUpdate.add(oItem);
                    }
                    
            update (orgLinesToUpdate);
            
            
                        
            List<User> UsersToUpdate = new List<User>();
            
            
            for(User usr : [ 
                            SELECT ID, PDP_LVL_1__c
                            FROM User 
                            WHERE PDP_LVL_1__c in: oldCGName.keyset()])
            {
                usr.PDP_LVL_1__c=oldNameNewName.get(usr.PDP_LVL_1__c);  
                UsersToUpdate.add(usr); 
            }
            update(UsersToUpdate);
            
           List<String> cgLVL2toDelete = new List<String>();
           List<String> cgLvL2ToAdd = new List<String>();
           
           List<PDPOrgLineItem__c> orgToDelete = new List<PDPOrgLineItem__c>();
           List<PDPOrgLineItem__c> orgToAdd = new List<PDPOrgLineItem__c>();
                      
           for( PDPCountryGroup__c cg: (List<PDPCountryGroup__c>)trigger.new) 
           {
                if(cg.Country_LVL_2__c!=oldCGNameId.get(cg.ID).Country_LVL_2__c)
                {
                    if(oldCGNameId.get(cg.ID).Country_LVL_2__c==true)
                    {
                        cgLVL2toDelete.add(cg.Name);
                    }
                    else
                    {
                        cgLvL2ToAdd.add(cg.Name);                       
                    }
                }
           } 
           
           for(PDPOrgLineItem__c oli : [ 
                        SELECT Id,is_LVL_1_Line__c,is_LVL_2_Line__c,is_LVL_3_Line__c,is_LVL_4_Line__c,Name,
                        YPDP_L1__c,YPDP_L2_EXTRL_ID__c,YPDP_L3_EXTRL_ID__c,
                        YPDP_L4_EXTRL_ID__c,YPDP_ORG_DISCONTINUED_DATE__c,YPDP_ORG_DISCONTINUED__c,
                        YPDP_L2_EXTRL_ID_PC__c,YPDP_L3_EXTRL_ID_PC__c,YPDP_L4_EXTRL_ID_PC__c, 
                        YPDP_L2_EXTRL_ID_N__c,YPDP_L3_EXTRL_ID_N__c,YPDP_L4_EXTRL_ID_N__c,
                        outputData__c 
                        FROM PDPOrgLineItem__c 
                        WHERE YPDP_L1__C in: cgLVL2toDelete 
                        ] )                     
            {
                if(oli.YPDP_L1__C==oli.YPDP_L2_EXTRL_ID__c  && 
                    (oli.YPDP_L3_EXTRL_ID__c=='' || oli.YPDP_L3_EXTRL_ID__c==null)
                        && (oli.YPDP_L4_EXTRL_ID__c=='' || oli.YPDP_L4_EXTRL_ID__c==null))
                                orgToDelete.add(oli);           

            }   
            delete orgToDelete;
            
            for(String str: cgLvL2ToAdd)
            {
                orgToAdd.add(new PDPOrgLineItem__c(YPDP_L1__c=str,YPDP_L2_EXTRL_ID__c=str,is_LVL_2_Line__c=true,YPDP_ORG_DISCONTINUED__c='0',YPDP_ORG_DISCONTINUED_DATE__c='29991231'));                                    
            }
            insert orgToAdd;            
        }
            
    
        if(trigger.isInsert)
        {  
        	
            for(PDPCountryGroup__c cg:(List<PDPCountryGroup__c>)trigger.new)
            {
            	 if(cg.Country_LVL_2__c==true && cg.Repeat_L2__c==true)
            	 {
            	 	cg.Repeat_L2__c.addError(System.label.PDP_ERROR_REPEATLVL2); 
            	 }
                 if(CountryGroupsSet.contains((String)cg.Name))
                       cg.Name.addError(System.label.PDP_ERROR_COUNTRY_GROUP);   
                 else {
                    PDPOrgLineItemToInsert.add(new PDPOrgLineItem__c(YPDP_L1__c=cg.Name,is_LVL_1_Line__c=true,YPDP_ORG_DISCONTINUED__c='0',YPDP_ORG_DISCONTINUED_DATE__c='29991231'));                             
                    if(cg.Country_LVL_2__c==true)
                    {
                        PDPOrgLineItemToInsert.add(new PDPOrgLineItem__c(YPDP_L1__c=cg.Name,YPDP_L2_EXTRL_ID__c=cg.Name,is_LVL_2_Line__c=true,YPDP_ORG_DISCONTINUED__c='0',YPDP_ORG_DISCONTINUED_DATE__c='29991231'));                                  
                    }                   
                 } 
            }
            insert PDPOrgLineItemToInsert;
        }
        if(trigger.isDelete)
        {
            
            List<User> UsersCountry = new List<User>();
            boolean stopTrigger=false;
            
            List<PDPOrgLineItem__c>  PDPOrgLineItemToDelete = new  List<PDPOrgLineItem__c>();
            List<String> CountryGroupToDelete = new List<String>();
            for(PDPCountryGroup__c cg:(List<PDPCountryGroup__c>)trigger.old)
            {
                CountryGroupToDelete.add(cg.Name); 
            }
            
            for(User ucon: [ SELECT ID, PDP_LVL_1__c FROM User WHERE PDP_LVL_1__c in:CountryGrouptoDelete ])
            {
                stopTrigger=true;
            }
            /*for(PDPCountryGroup__c cg:(List<PDPCountryGroup__c>)trigger.old)
            {
                 // cg.Name.addError(System.label.PDP_COUNTRY_GROUP_DELETE);   
            }*/
            
            for( PDPOrgLineItem__c pdli: [SELECT ID FROM PDPOrgLineItem__c WHERE  YPDP_L1__c in: CountryGroupToDelete AND is_LVL_1_Line__c=true ])
            {
                PDPOrgLineItemToDelete.add(pdli);
            }
            for( PDPOrgLineItem__c pdli: [SELECT ID FROM PDPOrgLineItem__c WHERE  YPDP_L2_EXTRL_ID__c in: CountryGroupToDelete AND is_LVL_2_Line__c=true ])
            {
                PDPOrgLineItemToDelete.add(pdli);   
            }
            delete PDPOrgLineItemToDelete;
        }
        
    }

}