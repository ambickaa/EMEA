public class TriggerUserPDPValidateFields implements Triggers.Handler
{
  public static boolean fromCountryGroupTrigger=false;
  public static boolean fromTest=false;
  
  public void handle()
  {
    
    SET<ID> PDPManagers = new SET<ID>();
    
    for(User u :[ SELECT ID, PDP_Manager__c FROM USER ])
    {
        PDPManagers.add(u.PDP_Manager__c);      
    }
        
    List<ID> UserIds = new List<ID>();
    MAP<ID,User> ManagersInfo = new Map<ID,User> ();
    for(User u : (List<User>)trigger.new)
    {
         UserIds.add(u.PDP_Manager__c);
    }
    
    for(User u : [ SELECT ID, ALIAS, SAP_Partner_Code__c, PDP_Level__c FROM User WHERE ID in:UserIds ])
    {
        ManagersInfo.put(u.ID,u);
    }
  
    SET<String> CountryNames = new SET<String>();
    Map<String, PDPCountryGroup__c> cgMap = new Map<String, PDPCountryGroup__c>();
    
    Integer counter=1;
    String CountryNamesString='';
    for(PDPCountryGroup__c cg: Util.CountryGroups)
    {
                CountryNames.add(cg.Name);
                CountryNamesString=CountryNamesString+String.valueoF(counter++)+'.['+(String)cg.Name+'] ';
                cgMap.put(cg.Name,cg);
    }
    
    if(!fromTest)
    {
    for(User u : (List<User>)trigger.new)
    {
       if((u.PDP_LVL_1__C==null || u.PDP_LVL_1__C=='')  && (u.PDP_Level__c=='PDP Level 2' ||  u.PDP_Level__c=='PDP Level 3' || u.PDP_Level__c=='PDP Level 4' ))
            u.PDP_LVL_1__C.addError(System.label.PDP_ERROR_LVL1);
        if(u.PDP_Manager__c!=null && (u.PDP_Level__c!='PDP Level 3' && u.PDP_Level__c!='PDP Level 4'))
           u.PDP_Manager__c.addError(System.label.PDP_ERROR_MANAGER);
        if(u.PDP_LVL_1__c!=null && !CountryNames.contains(u.PDP_LVL_1__c) && !fromCountryGroupTrigger)
           u.PDP_LVL_1__c.addError(System.label.PDP_ERROR_COUNTRY_GROUP2 +CountryNamesString);
        if(u.PDP_Manager__c!=null && (u.PDP_Level__c!='PDP Level 3' && u.PDP_Level__c!='PDP Level 4'))
           u.PDP_Manager__c.addError(System.label.PDP_ERROR_MANAGER);
        if(u.PDP_Manager__c==null && ( u.PDP_Level__c=='PDP Level 4'))
           u.PDP_Manager__c.addError(System.label.PDP_ERROR_MANAGER2);
        if(u.PDP_Manager__c==null && (u.PDP_Level__c=='PDP Level 3') && (cgMap.get(u.PDP_LVL_1__c).Country_LVL_2__c!=true))
           u.PDP_Manager__c.addError(System.label.PDP_ERROR_MANAGER2);        
    //   if(u.PDP_ORG_DISC_DATE__c==null && (u.PDP_Level__c=='PDP Level 2' || u.PDP_Level__c=='PDP Level 3' || u.PDP_Level__c=='PDP Level 4'))
    //        u.PDP_ORG_DISC_DATE__c.addError(System.label.PDP_ERROR_DISC_DATE);
       if((u.SAP_Partner_Code__c==null || u.SAP_Partner_Code__c=='') && (u.PDP_Level__c=='PDP Level 2' || u.PDP_Level__c=='PDP Level 3' || u.PDP_Level__c=='PDP Level 4'))
                u.SAP_Partner_Code__c.addError(System.label.PDP_ERROR_SAP_CODE);
   /*   if(u.PDP_Manager__c!=null)
      {
           if(ManagersInfo.get(u.PDP_Manager__c).SAP_Partner_Code__c==null || ManagersInfo.get(u.PDP_Manager__c).SAP_Partner_Code__c=='')
              u.SAP_Partner_Code__c.addError(System.label.PDP_ERROR_MANAGER3);
          else if(u.PDP_Level__c=='PDP Level 3')
              if(ManagersInfo.get(u.PDP_Manager__c).PDP_Level__c!='PDP Level 2')
                  u.PDP_Manager__c.addError(System.label.PDP_ERROR_MANAGER4);
           else if(u.PDP_Level__c=='PDP Level 4')   
           {    
               if(ManagersInfo.get(u.PDP_Manager__c).PDP_Level__c!='PDP Level 3')
                  u.PDP_Manager__c.addError(System.label.PDP_ERROR_MANAGER5);       
          }       
      }
      if((u.PDP_Level__c!='PDP Level 2' || u.PDP_Level__c!='PDP Level 3') && PDPManagers.contains(u.ID) )
           u.PDP_Level__c.addError('You cannot remove a user from ORG which is Manager from other users');  */      
    }
  }
  }
}