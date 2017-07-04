public with sharing class TriggerUserPDP implements Triggers.Handler
{

     List<PDPOrgLineItem__c> PDPLineItemToInsert= new List<PDPOrgLineItem__c>();
     List<PDPOrgLineItem__c> PDPLineItemToDelete = new List<PDPOrgLineItem__c>();
     
     LIST<ID> ManagersID = new LIST<ID>();
     List<ID> ManagersManagerId = new List<ID>();
     MAP<ID, User> ManagersInfo= new Map<ID, User>();
     MAP<ID, User> ManagerManagersInfo= new Map<ID, User>();
     
     Map<ID,User> oldUsers = new Map<ID,User> ();
            
     List<String> L2toDelete = new List<String>();
     List<String> L3toDelete = new List<String>();
     List<String> L4toDelete = new List<String>();
     
     Map<String,String> oldALIASMap = new Map<String,String>();
     
     MAP<String, PDPCountryGroup__c> countryGroups = new MAP<String, PDPCountryGroup__c> ();
     
     public TriggerUserPDP ()
     {
            for (User u: (List<User>)Trigger.new)
            ManagersID.add(u.PDP_Manager__c);
            
        
            for(User u: [SELECT ID, LastName, ALIAS, SAP_Partner_Code__c,PDP_Manager__c,PDP_Level__c FROM User WHERE ID in:ManagersID])
                {
                    ManagersInfo.put(u.ID,u);
                    ManagersManagerId.add(u.PDP_Manager__c);
                }
            for(User u: [SELECT ID, LastName, ALIAS, SAP_Partner_Code__c,PDP_Level__c  FROM User WHERE ID in: ManagersManagerId])
                {
                    ManagerManagersInfo.put(u.ID,u);
                }       
                
            for(PDPCountryGroup__c cg: [SELECT ID, Name, Repeat_L1__c, Repeat_L2__c, Repeat_L3__c, Country_LVL_2__c, Grouping__c FROM PDPCountryGroup__c])//Util.countryGroups)   
            {
                countryGroups.put(cg.Name,cg);              
            }  
             

     }
    public void handle()
    { 
        if(trigger.isInsert)
        {
        	try{
				createHierarchy();	
        	}
			catch(Exception e)
			{
				
			}		                         
        }else if(trigger.isUpdate)
        {
            
            for(User u: (List<User>)Trigger.old)
            {
                oldUsers.put(u.ID,u);
            }
            Boolean needRefresh=false;
            Boolean UsernameChanged=false;
                        
            for(User u : (List<User>)Trigger.new)
            {
	    	//FIX error MARK
            	if(oldUsers.get(u.ID).Username!=u.Username)
            	{ 
            		UsernameChanged=true;
            	}
            	
                if( oldUsers.get(u.ID).SAP_Partner_Code__c != u.SAP_Partner_Code__c ||
                    oldUsers.get(u.ID).PDP_LEVEL__c != u.PDP_LEVEL__c ||
                    oldUsers.get(u.ID).PDP_Manager__c != u.PDP_Manager__c ||
                    oldUsers.get(u.ID).LastName != u.LastName ||
                    oldUsers.get(u.ID).ALIAS != u.ALIAS ||
                    oldUsers.get(u.ID).PDP_ORG_DISC__c != u.PDP_ORG_DISC__c ||
                    oldUsers.get(u.ID).PDP_ORG_DISC_DATE__c != u.PDP_ORG_DISC_DATE__c ||
                    oldUsers.get(u.ID).PDP_LVL_1__c != u.PDP_LVL_1__c )
                {
                    needRefresh=true;
                    if(UsernameChanged)
                    {
                    	//u.Username.addError(System.label.PDP_Username);
                    	
                    }
                }
                
                
            } 
            
            if(needRefresh)
            {
            	try{
					createHierarchy();	
	        	}
				catch(Exception e)
				{					
				}		          	
            }
        }     
}

    public void createHierarchy()
    {
    	
    	List<PDPOrgLineItem__c> pdpHierarchyLines = new List<PDPOrgLineItem__c>();
    	List<PDPOrgLineItem__c> pdpLineItems = new List<PDPOrgLineItem__c>();
    	Map<String,PDPCountryGroup__c> pdpCountryGroups = new Map<String, PDPCountryGroup__c>();
    	Map<Id,User> userMap = new Map<Id,User>();
    	List<PDPOrgLineItem__c> PDPLineItemToUpsert = new List<PDPOrgLineItem__c>();
    	Set<Id> UsersToUpsert = new Set<Id>();
    	
    	for(PDPCountryGroup__c cg: [SELECT ID, Name, Repeat_L1__c, Repeat_L2__c, Repeat_L3__c, Country_LVL_2__c, Grouping__c FROM  PDPCountryGroup__c])
    	{
    		pdpCountryGroups.put(cg.Name, cg);
    	}
    	    	
    	
    	for(User usr: [SELECT ID, ALIAS, LastName, Name, SAP_Partner_Code__c, PDP_Level__c, PDP_LVL_1__c, PDP_Manager__c, PDP_ORG_DISC__c FROM User 
    					WHERE PDP_Level__c!=null AND PDP_Level__c!='No PDP Level' AND SAP_Partner_Code__c!=null AND PDP_LVL_1__c!=null ])
    	{
			userMap.put(usr.Id,usr);	
    	}
    	
    	for(Id userId : userMap.keyset() )
    	{
    		       if(userMap.get(userId).PDP_LEVEL__c=='PDP Level 2')
                   {
                           PDPLineItemToUpsert.add(new PDPOrgLineItem__c(
                           YPDP_L1__c=userMap.get(userId).PDP_LVL_1__c,
                           YPDP_L2_EXTRL_ID__c=userMap.get(userId).ALIAS,
                           YPDP_L3_EXTRL_ID__c='',
                           YPDP_L4_EXTRL_ID__c='',
                           YPDP_L2_EXTRL_ID_PC__c=userMap.get(userId).SAP_Partner_Code__C,
                           YPDP_L3_EXTRL_ID_PC__c='',
                           YPDP_L4_EXTRL_ID_PC__c='',
                           YPDP_L2_EXTRL_ID_N__c=(String)userMap.get(userId).LastName,
                           YPDP_L3_EXTRL_ID_N__c='',
                           YPDP_L4_EXTRL_ID_N__c='', 
                           YPDP_ORG_DISCONTINUED__c=(userMap.get(userId).PDP_ORG_DISC__c == true?'1':'0'),                      
                           User__c=userId,
                           External_Id__c=(String)userId,                          
                           is_LVL_2_Line__c=true));
                           UsersToUpsert.add(userId);
                   }else if(userMap.get(userId).PDP_LEVEL__c=='PDP Level 3' && pdpCountryGroups.get(userMap.get(userId).PDP_LVL_1__c).Country_LVL_2__c==true)
                   {
                   			
                           PDPLineItemToUpsert.add(new PDPOrgLineItem__c(
                           YPDP_L1__c=userMap.get(userId).PDP_LVL_1__c,
                           YPDP_L2_EXTRL_ID__c=userMap.get(userId).PDP_LVL_1__c,
                           YPDP_L3_EXTRL_ID__c=userMap.get(userId).ALIAS,
                           YPDP_L4_EXTRL_ID__c='',
                           YPDP_L2_EXTRL_ID_PC__c=userMap.get(userId).PDP_LVL_1__c,
                           YPDP_L3_EXTRL_ID_PC__c=userMap.get(userId).SAP_Partner_Code__C,
                           YPDP_L4_EXTRL_ID_PC__c='',   
                           YPDP_L2_EXTRL_ID_N__c=userMap.get(userId).PDP_LVL_1__c,
                           YPDP_L3_EXTRL_ID_N__c=(String)userMap.get(userId).LastName,
                           YPDP_L4_EXTRL_ID_N__c='', 
                           YPDP_ORG_DISCONTINUED__c=(userMap.get(userId).PDP_ORG_DISC__c == true?'1':'0'),                      
                           User__c=userId, 
                           External_Id__c=(String)userId,                                                     
                           is_LVL_3_Line__c=true));
                           UsersToUpsert.add(userId);                           
                   }
                   else if(userMap.get(userId).PDP_LEVEL__c=='PDP Level 3' && pdpCountryGroups.get(userMap.get(userId).PDP_LVL_1__c).Country_LVL_2__c!=true)
                   {
                   		   if(userMap.get(userMap.get(userId).PDP_Manager__c).ALIAS!=null)
                           {
	                           PDPLineItemToUpsert.add(new PDPOrgLineItem__c(
	                           YPDP_L1__c=userMap.get(userId).PDP_LVL_1__c,
	                           YPDP_L2_EXTRL_ID__c=userMap.get(userMap.get(userId).PDP_Manager__c).ALIAS,
	                           YPDP_L3_EXTRL_ID__c=userMap.get(userId).ALIAS,
	                           YPDP_L4_EXTRL_ID__c='',
	                           YPDP_L2_EXTRL_ID_PC__c=userMap.get(userMap.get(userId).PDP_Manager__c).SAP_Partner_Code__C,
	                           YPDP_L3_EXTRL_ID_PC__c=userMap.get(userId).SAP_Partner_Code__C,
	                           YPDP_L4_EXTRL_ID_PC__c='',   
	                           YPDP_L2_EXTRL_ID_N__c=(String)userMap.get(userMap.get(userId).PDP_Manager__c).LastName,
	                           YPDP_L3_EXTRL_ID_N__c=(String)userMap.get(userId).LastName,
	                           YPDP_L4_EXTRL_ID_N__c='', 
	                           YPDP_ORG_DISCONTINUED__c=(userMap.get(userId).PDP_ORG_DISC__c == true?'1':'0'),                      
	                           User__c=userId, 
	                           External_Id__c=(String)userId,                                                     
	                           is_LVL_3_Line__c=true)); 
	                           UsersToUpsert.add(userId);   
                           }                                       
                   }
				  else if(userMap.get(userId).PDP_LEVEL__c=='PDP Level 4' && pdpCountryGroups.get(userMap.get(userId).PDP_LVL_1__c).Country_LVL_2__c!=true)
                       { 
                           if(userMap.get(userMap.get(userMap.get(userId).PDP_Manager__c).PDP_Manager__c).ALIAS!=null
                           && userMap.get(userMap.get(userId).PDP_Manager__c).ALIAS!=null )
                           {
	                           	PDPLineItemToUpsert.add(new PDPOrgLineItem__c(
	                            YPDP_L1__c=userMap.get(userId).PDP_LVL_1__c,
	                            YPDP_L2_EXTRL_ID__c=userMap.get(userMap.get(userMap.get(userId).PDP_Manager__c).PDP_Manager__c).ALIAS,
	                            YPDP_L3_EXTRL_ID__c=userMap.get(userMap.get(userId).PDP_Manager__c).ALIAS,
	                            YPDP_L4_EXTRL_ID__c=userMap.get(userId).ALIAS,
	                            
	                            YPDP_L2_EXTRL_ID_PC__c=userMap.get(userMap.get(userMap.get(userId).PDP_Manager__c).PDP_Manager__c).SAP_Partner_Code__C,
	                            YPDP_L3_EXTRL_ID_PC__c=userMap.get(userMap.get(userId).PDP_Manager__c).SAP_Partner_Code__C,
	                            YPDP_L4_EXTRL_ID_PC__c=userMap.get(userId).SAP_Partner_Code__C,
	                            
	                            YPDP_L2_EXTRL_ID_N__c=(String)userMap.get(userMap.get(userMap.get(userId).PDP_Manager__c).PDP_Manager__c).LastName,
	                            YPDP_L3_EXTRL_ID_N__c=(String)userMap.get(userMap.get(userId).PDP_Manager__c).LastName,
	                            YPDP_L4_EXTRL_ID_N__c=(String)userMap.get(userId).LastName,
	                            
	                            YPDP_ORG_DISCONTINUED__c=(userMap.get(userId).PDP_ORG_DISC__c == true?'1':'0'),                      
	                            User__c=userId,  
	                            External_Id__c=(String)userId,                                                                          
	                            is_LVL_4_Line__c=true));
	                            UsersToUpsert.add(userId);
                           }
                       }
                        else if(userMap.get(userId).PDP_LEVEL__c=='PDP Level 4' && pdpCountryGroups.get(userMap.get(userId).PDP_LVL_1__c).Country_LVL_2__c==true)
                       { 
                           if(userMap.get(userMap.get(userId).PDP_Manager__c).ALIAS!=null)
                           {
	                           PDPLineItemToUpsert.add(new PDPOrgLineItem__c(
	                            YPDP_L1__c=userMap.get(userId).PDP_LVL_1__c,
	                            YPDP_L2_EXTRL_ID__c=userMap.get(userId).PDP_LVL_1__c,
	                            YPDP_L3_EXTRL_ID__c=userMap.get(userMap.get(userId).PDP_Manager__c).ALIAS,
	                            YPDP_L4_EXTRL_ID__c=userMap.get(userId).ALIAS,
	                            
	                            YPDP_L2_EXTRL_ID_PC__c=userMap.get(userId).PDP_LVL_1__c,
	                            YPDP_L3_EXTRL_ID_PC__c=userMap.get(userMap.get(userId).PDP_Manager__c).SAP_Partner_Code__C,
	                            YPDP_L4_EXTRL_ID_PC__c=userMap.get(userId).SAP_Partner_Code__C,
	                            
	                            YPDP_L2_EXTRL_ID_N__c=userMap.get(userId).PDP_LVL_1__c,
	                            YPDP_L3_EXTRL_ID_N__c=(String)userMap.get(userMap.get(userId).PDP_Manager__c).LastName,
	                            YPDP_L4_EXTRL_ID_N__c=(String)userMap.get(userId).LastName,
	                            
	                            YPDP_ORG_DISCONTINUED__c=(userMap.get(userId).PDP_ORG_DISC__c == true?'1':'0'),                      
	                            User__c=userId, 
	                            External_Id__c=(String)userId,                                                                          
	                            is_LVL_4_Line__c=true));
	                           UsersToUpsert.add(userId);
                           }   
                       }                                             
    	}
    	
    	
    	pdpHierarchyLines= [SELECT ID,User__c FROM PDPOrgLineItem__c WHERE User__c!=null AND User__c NOT in: UsersToUpsert];
    	
    	delete pdpHierarchyLines; 
    	upsert PDPLineItemToUpsert External_Id__c;
 		
		}

}