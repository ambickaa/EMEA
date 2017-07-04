public without sharing class TriggerOppAllocationStatusUpdate implements Triggers.Handler
{
    // Retrieve the list of Opportunity Lines sent.
    // For each Line, create an AllocationLog register with the User+Product+SAP Order number's information. 
    // Build the allocation management's external Id so that it can be linked to the AllocationConsumedLog's line.
    // Save/insert the new AllocationConsumedLog lines to Salesforce.
    public void handle()
    {        
        //Initialize both lists Opportunity&oLineItem
        list<Opportunity> listOpportunities = new list<Opportunity>();
        list<Opportunity> listOpportunitiesUpdateStatus = new list<Opportunity>();
        set<String> setRemoveConsLog = new set<String>();
        list<Allocation_Consume_Log__c> listACL = new list<Allocation_Consume_Log__c>();
        
        //Query to recover UserId Sap Code
        set<id> setUserId = new set<Id>();
        map<id, user> Map_UserInfo = new map<id, user>();    // Contains users' ids and full users.
        map<id, user> mapUs = new map<id, user>();    // Contains opp's ids and their owner's full user.
        
        for(Opportunity o: (List<Opportunity>)Trigger.new)
        {
            setUserId.add(o.ownerId);
        }
        
        for(User u : [SELECT Name, ID, SAP_Partner_Code__c FROM User WHERE ID in:setUserId])
        {
            Map_UserInfo.put(u.Id, u);
        }
        
        for(Opportunity itemNew :  (List<Opportunity>)Trigger.new)
        {           
            Opportunity itemOld = (Opportunity)Trigger.oldMap.get(itemNew.id);
            
            mapUs.put(itemNew.Id, Map_UserInfo.get(itemNew.ownerId));
            
            Id rtCharged = Util.recordtype.get('Opportunity:Sales_Italy_Charged');
            Id rtFoc = Util.recordtype.get('Opportunity:Sales_Italy_FOC');
            Id rtSubmitted = Util.recordtype.get('Opportunity:Sales_Submitted');

            if(((itemNew.PICK_Status__c == 'Submitted' && itemOld.PICK_Status__c!='Submitted') || (itemNew.TXT_SAP_status_description__c!=null && itemNew.TXT_SAP_status_description__c.contains('Error trying to connect to the server') && (itemOld.TXT_SAP_status_description__c==null || !itemOld.TXT_SAP_status_description__c.contains('Error trying to connect to the server')))) && (( itemNew.RecordtypeId == rtCharged || itemNew.RecordtypeId == rtFoc ) || ( itemOld.RecordtypeId == rtSubmitted && itemOld.TXT_SAP_Order_number__c == null && itemNew.TXT_SAP_Order_number__c != null)))
            { 
                if(!String.isBlank(itemNew.TXT_SAP_Order_number__c))
                {
                    setRemoveConsLog.add(itemNew.id);    
                }
                else
                {
                    Opportunity item = new Opportunity(id=itemNew.id);
                    listOpportunitiesUpdateStatus.add(item);
                }
                listOpportunities.add(itemNew);
            }
         } 

        Allocation_Consume_Log__c ACL;
        Allocation__c al;

        for(OpportunityLineItem oppLine: [select id, product2id, opportunity.TXT_SAP_Order_number__c, opportunity.id, opportunity.name, opportunity.ownerId, productCode, pricebookentry.productcode, quantity
            from opportunityLineItem
            where opportunityid in :listOpportunities ])
        {
            string ExternalId;      
            al = new Allocation__c(
            	txt_external_id__c = String.valueOf(oppLine.opportunity.ownerId).substring(0,15) + '-' + String.valueOf(oppLine.product2id).substring(0,15) + '-' + Util.currentYear.name);
            
            ACL = new Allocation_Consume_Log__c (
            	LKP_User__c = mapUs.get(oppLine.opportunity.Id).Id,
            	LKP_Product__c= oppLine.product2id,
            	MD_Allocation__r = al,
                TXT_SKU_SAP__c = oppLine.productCode, 
                TXT_User_SAP__c = mapUs.get(oppLine.opportunity.Id).SAP_Partner_Code__c,
                TXT_Order_SAP__c = oppLine.opportunity.TXT_SAP_Order_number__c,
                NUM_Qty__c = oppLine.quantity,
                TXT_External_ID__c = mapUs.get(oppLine.opportunity.id).SAP_Partner_Code__c + '-' + (!String.isBlank(oppLine.opportunity.TXT_SAP_Order_number__c) ? oppLine.opportunity.TXT_SAP_Order_number__c : oppLine.opportunity.name) + '-' + oppLine.productCode,
                LKP_Opportunity__c = oppLine.opportunity.id);                                                              
            
            listACL.add(ACL); 
        }
        
        
        if(setRemoveConsLog.size() > 0)
        {
            List<Allocation_Consume_log__c> listDelAlloc = [SELECT id FROM allocation_consume_log__c WHERE (TXT_Order_SAP__c = null OR TXT_Order_SAP__c = '') AND LKP_Opportunity__c in :setRemoveConsLog];
            
            if(listDelAlloc.size() > 0)
            {
                try
                {
                    delete listDelAlloc;
                }
                catch(DmlException e)
                {
                    for(Integer i = 0; i < e.getNumDml(); i++)
                    {
                        system.debug(e.getDmlMessage(i));
                    }                   
                }
            }
        }     
        if(listOpportunitiesUpdateStatus.size()>0)
        {
            for(Opportunity item : listOpportunitiesUpdateStatus)
            {
                item.pick_status__c='Review by Customer Services';
            }
            try
            {
                update listOpportunitiesUpdateStatus;
            }
            catch(DmlException e)
            {
                for(Integer i = 0; i < e.getNumDml(); i++)
                {
                    system.debug(e.getDmlMessage(i));
                }               
            }            
        }
        try
        {
            upsert listACL txt_external_id__c;
        }
        catch(DmlException e)
        {
            for(Integer i = 0; i < e.getNumDml(); i++)
            {
                system.debug(e.getDmlMessage(i));
            }
        } 
    } 
} //   A F T E R  U P D A T E