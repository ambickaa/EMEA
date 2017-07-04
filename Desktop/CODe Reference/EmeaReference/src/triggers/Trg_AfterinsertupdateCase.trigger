trigger Trg_AfterinsertupdateCase on Case (after insert,after update, after delete) {
    Set<Id> ParentIds = new Set<Id>(); 
    map<id, case>  mapCases = new map<id, case>();
    
    if(checkRecursive.runOnce()){
            
        if ( Trigger.isInsert) 
        {
            HLPR_CreateCase.ProcessInsert(trigger.new);            
            HLPR_outOfOffice.processInsert(trigger.new);      
            
            //Passes only those cases that have parents ===Added by Anand for optimization
            for (Case cs:trigger.new)
            {
                if (cs.ParentId != null && cs.recordtypeid == System.Label.ServicecaseRTId)
                {
                    ParentIds.add(cs.ParentId); //create set of parentIds
                    mapCases.put(cs.ParentId, cs); //Prepare Map for reporting errors back 
                }
            }
            
            System.debug ('Inside Insert - ParentIds' + ParentIds);
            System.debug ('Inside Insert - mapCases' + mapCases);
            if (!ParentIds.isEmpty())
            {
                HLPR_GlobalCaseRollup.CountChildCases(ParentIds, mapCases);
            }
            ///===============================
        }
        
        if (Trigger.isUpdate) 
        {
            System.debug('trigger.old -' +  Trigger.old);
            System.debug('trigger.new -' +  Trigger.new);
            
            //Passes only those cases that have status changed or re-parenting has happened ===Added by Anand for optimization
            for (Id cid:Trigger.newMap.keySet())
            {
                System.debug('trigger.newMap.get(cid).ParentId -' + trigger.newMap.get(cid).ParentId);
                System.debug('trigger.oldmap.get(cid).ParentId -' + trigger.oldmap.get(cid).ParentId);    
                if(trigger.newMap.get(cid).recordtypeid == System.Label.ServicecaseRTId)
                {            
                    if( trigger.newMap.get(cid).ParentId != trigger.oldmap.get(cid).ParentId)
                    {
                        if(trigger.newmap.get(cid).ParentId != null )
                        {
                            ParentIds.add(trigger.newMap.get(cid).ParentId); //Add New Parent for Re-Calculation
                            mapCases.put(trigger.newMap.get(cid).ParentId, trigger.newMap.get(cid)); //Prepare Map for reporting errors back  for new parent    
                        }
                        if(trigger.oldmap.get(cid).ParentId != null)
                        {
                            ParentIds.add(trigger.oldMap.get(cid).ParentId); //Add Old Parent for Re-Calculation
                            mapCases.put(trigger.oldMap.get(cid).ParentId, trigger.newMap.get(cid)); //Prepare Map for reporting errors back  for old parent
                        }
                    }
                    else
                    {
                        System.debug('trigger.newMap.get(cid).status -' + trigger.newMap.get(cid).status);
                        System.debug('HLPR_GlobalCaseRollup.mapOldCases.get(cid).status -' + HLPR_GlobalCaseRollup.mapOldCases.get(cid).status);
                        if( trigger.newMap.get(cid).status != HLPR_GlobalCaseRollup.mapOldCases.get(cid).status)
                        {
                            ParentIds.add(trigger.newMap.get(cid).ParentId); //Add New Parent for Re-Calculation
                            mapCases.put(trigger.newMap.get(cid).ParentId, trigger.newMap.get(cid)); //Prepare Map for reporting errors back
                        }
                    }
                 }
              }
            System.debug ('Inside Update - ParentIds' + ParentIds);
            System.debug ('Inside Update - mapCases' + mapCases);            
            if (!ParentIds.isEmpty())
            {
                HLPR_GlobalCaseRollup.CountChildCases(ParentIds, mapCases);
            }
            ///===============================
        }
        
        if (Trigger.isDelete) 
        {   
            //Passes only those cases that have parents ===Added by Anand for optimization
            for (Case cs:trigger.old)
            {
                if (cs.ParentId != null && cs.recordtypeid == System.Label.ServicecaseRTId)
                {
                    ParentIds.add(cs.ParentId); //create set of parentIds
                    mapCases.put(cs.ParentId, cs); //Prepare Map for reporting errors back 
                }
            }
            System.debug ('Inside Delete - ParentIds' + ParentIds);
            System.debug ('Inside Delete - mapCases' + mapCases);               
            if (!ParentIds.isEmpty())
            {
                HLPR_GlobalCaseRollup.CountChildCases( ParentIds, mapCases);
            }
            ///===============================
        } 
    }
    
    if (Trigger.isUpdate)        
    {            
        AdditionalDataCaptureHelper.caseupdate(trigger.new,trigger.oldMap);        
    }
    
}