public with sharing class TriggerLeadConfirmed implements Triggers.Handler {
    
    map<Id, String> mapLeadCountry = new map<Id, String>();
    map<Id, Id> mapLeadCountry2 = new map<Id, Id>();
    map<String, Country__c> mapNameCountry = new map<String, Country__c>();
    map<Id, String> mapLeadPostalCode = new map<Id, String>();
    map<String, TerritoryManagement__c> mapCountryCpTerritory = new map<String, TerritoryManagement__c>();
    map<String, Lead_Country_Fields__c> mapLeadCountryFields = new map<String, Lead_Country_Fields__c>();
    list<Lead> leads = new list<Lead>();
    list<String> postalCodes = new list<String>();
    list<TerritoryManagement__c> territories;  
    
    public void handle()
    {
        //----------------------------------------
        // 08.09.2016 - eCIP Support Team
        // Initializing list of campaign members
        //----------------------------------------
        list<CampaignMember> listMembers = new list<CampaignMember>();
        
        // BEGIN update duplicate leads owner to match master leads
        List<ID> dupeLeads = new List<ID>();
         for(Lead l : (list<Lead>)trigger.new)
            {
                if(l.status == 'Already a Lead')
                    dupeLeads.add(l.LKP_masterLead__c);
            }
        if(dupeLeads.size() > 0)    
        {
            Map<Id, Lead> mapMasterLeads = new Map<ID, Lead>([SELECT ID, OwnerId from lead where id in :dupeLeads]);
            for(Lead l : (list<Lead>)trigger.new)
            {
                if(l.status == 'Already a Lead')
                {
                    l.OwnerId = mapMasterLeads.get(l.LKP_masterLead__c).OwnerId;
                
		            //----------------------------------------
		            // 08.09.2016 - eCIP Support Team
		            // If campaignId is filled when the Lead is "Already a Lead",
		            // a new campaign member should be inserted with the Id of its parent
		            //----------------------------------------
		            if(l.LKP_Campaign__c != null)
		            {
		            	listMembers.add(new CampaignMember(CampaignId=l.LKP_Campaign__c, LeadId=l.LKP_masterLead__c));
		            	l.LKP_Campaign__c = null;
		            }
                }
            }
        }
        // END update duplicate leads owner to match master leads
        
        for(Lead l : (List<Lead>)trigger.new)
        {        	
            //Status Confirmed
            if(l.Status == 'Confirmed' && ((Map<Id, Lead>)trigger.oldMap).get(l.Id).Status != l.Status)
            {
                //If Lead Country == NULL no change Owner
                if(l.Country != null)                                                   //Map<Lead, Country>
                {
                    leads.add(l);
                    mapLeadCountry.put(l.id, l.Country); 
                    mapLeadCountry2.put(l.id, l.LKP_Country__c); 
                }                                   
                if(l.PostalCode != null) mapLeadPostalCode.put(l.id, l.PostalCode);     //Map<Lead, PostalCode>
                
                //----------------------------------------
                // 08.09.2016 - eCIP Support Team
                // If campaignId is filled when the Lead becomes
                // confirmed, a new campaign member will be inserted
                //----------------------------------------
                if(l.LKP_Campaign__c != null)
                {
                	listMembers.add(new CampaignMember(CampaignId=l.LKP_Campaign__c, LeadId=l.Id));
                	l.LKP_Campaign__c = null;
                }
                
            }
            
            territories = [SELECT Id, DE_CountryRef__r.Name, DE_CP__c, 
                                                            (SELECT DE_UserRef__c, DE_DivisionGroup__c
                                                                FROM TerritoryManagementUsers__r                                                                
                                                            ) 
                                                        FROM TerritoryManagement__c
                                                        WHERE DE_CountryRef__c IN :mapLeadCountry2.values()
                                                        AND DE_primarykey__c like :l.PostalCode + '%'
                                                        ];
        }

        //----------------------------------------
        // 08.09.2016 - eCIP Support Team
        // Inserting campaign members
        //----------------------------------------
        try {
        	insert listMembers;
        } catch(DmlException e) {
        	for(Integer i = 0; i < e.getNumDml(); i++)
    			system.debug('DML Error: ' + e.getDmlMessage(i));
        }
        
        //Select Lead Countries
        for(Country__c c : [SELECT Id, Name FROM Country__c WHERE Name IN :mapLeadCountry.values()])
        {
            mapNameCountry.put(c.Name, c);
        }
        
        //Select Lead Country Fields
        for(Lead_Country_Fields__c lcf : [SELECT id, LKP_Country__c, PICK_Lead_Source__c, LKP_Default_Lead_Owner__c, PICK_Assignment_method__c from Lead_Country_Fields__c])
        {
            mapLeadCountryFields .put(lcf.LKP_Country__c + '-' + lcf.PICK_Lead_Source__c, lcf);
        }
        
        //Map<Country-PostalCode, TerritoryManagement>                                          
        for(TerritoryManagement__c t : territories)
        {
            String key = t.DE_CountryRef__r.Name + '-' + t.DE_CP__c;
            mapCountryCpTerritory.put(key, t);
        }
                
        for(Lead l : leads)
        {   
            if(l.status != 'Already a Lead')
            {
                if(!mapLeadCountry.isEmpty() && !mapNameCountry.isEmpty())
                {       
                    //Country
                    if(mapLeadCountryFields.get(l.LKP_Country__c + '-' + l.LeadSource) != null)
                    {
                        if(mapLeadCountryFields.get(l.LKP_Country__c + '-' + l.LeadSource).PICK_Assignment_method__c == 'Country')           
                        {
                                if(l.FRML_Division_Group__c == 'S&T'   || l.FRML_Division_Group__c == 'CP') //DEKALB & WidMa
                             {                          
                                 if(mapLeadCountryFields.get(l.LKP_Country__c + '-' + l.LeadSource) != null)
                                 	l.OwnerId = (mapLeadCountryFields.get(l.LKP_Country__c + '-' + l.LeadSource)).LKP_Default_Lead_Owner__c;
                             }
                          
                             //Lead Owner changed
                             if(l.OwnerId != ((Map<Id, Lead>)trigger.oldMap).get(l.Id).OwnerId)
                             {
                                Task t = new Task();
                                t.WhoId = l.Id;
                                t.OwnerId = l.OwnerId;
                                t.Subject = 'New Lead assigned';
                                t.Status = 'Not Started';
                                t.Priority = 'Normal';
                                t.ActivityDate = System.Today();
                                insert t;                   
                             }
                            
                        }
                    
                        //Territory
                        if((mapLeadCountryFields.get(l.LKP_Country__c + '-' + l.LeadSource)).PICK_Assignment_method__c == 'Territory')                   
                        {
                            if(!mapLeadPostalCode.isEmpty())
                            {       
                                TerritoryManagement__c territory = mapCountryCpTerritory.get(mapLeadCountry.get(l.id) + '-' + mapLeadPostalCode.get(l.id));
                                if(territory != null)
                                {
                                    if(territory.TerritoryManagementUsers__r.size() > 0)
                                    {
                                        //Compare Territory Management User Division
                                        Integer i = 0;
                                        boolean encontrado = false;
                                        while(i < territory.TerritoryManagementUsers__r.size() && !encontrado)
                                        {
                                            if(l.FRML_Division_Group__c == territory.TerritoryManagementUsers__r[i].DE_DivisionGroup__c) 
                                            {
                                                if(territory.TerritoryManagementUsers__r[i].DE_UserRef__c != null)
                                                {
                                                    l.OwnerId = territory.TerritoryManagementUsers__r[i].DE_UserRef__c;
                                                    encontrado = true;
                                                    //Lead Owner changed
                                                     if(l.OwnerId != ((Map<Id, Lead>)trigger.oldMap).get(l.Id).OwnerId)
                                                     {
                                                        Task t = new Task();
                                                        t.WhoId = l.Id;
                                                        t.OwnerId = l.OwnerId;
                                                        t.Subject = 'New Lead assigned';
                                                        t.Status = 'Not Started';
                                                        t.Priority = 'Normal';
                                                        t.ActivityDate = System.Today();
                                                        insert t;                   
                                                     }                                      
                                                }                                       
                                            }
                                            i ++;
                                        }
                                        if(!encontrado)
                                        {
                                            if(l.FRML_Division_Group__c == 'S&T' || l.FRML_Division_Group__c == 'CP')
                                            {   
                                                if(mapLeadCountryFields.get(l.LKP_Country__c + '-' + l.LeadSource) != null) l.OwnerId = (mapLeadCountryFields.get(l.LKP_Country__c + '-' + l.LeadSource)).LKP_Default_Lead_Owner__c;
                                            }
                                            
                                            //Lead Owner changed
                                             if(l.OwnerId != ((Map<Id, Lead>)trigger.oldMap).get(l.Id).OwnerId)
                                             {
                                                Task t = new Task();
                                                t.WhoId = l.Id;
                                                t.OwnerId = l.OwnerId;
                                                t.Subject = 'New Lead assigned';
                                                t.Status = 'Not Started';
                                                t.Priority = 'Normal';
                                                t.ActivityDate = System.Today();
                                                insert t;                   
                                             }                                                                         
                                        }                              
                                    }
                                }
                                //No Territory Management (Country + PostalCode)
                                else
                                {
                                    if(l.FRML_Division_Group__c == 'S&T' || l.FRML_Division_Group__c == 'CP')
                                    {    
                                        if(mapLeadCountryFields.get(l.LKP_Country__c+'-'+l.LeadSource) != null) l.OwnerId = (mapLeadCountryFields.get(l.LKP_Country__c+'-'+l.LeadSource)).LKP_Default_Lead_Owner__c;                                    
                                    }                           
                                    
                                    //Lead Owner changed
                                     if(l.OwnerId != ((Map<Id, Lead>)trigger.oldMap).get(l.Id).OwnerId)
                                     {
                                        Task t = new Task();
                                        t.WhoId = l.Id;
                                        t.OwnerId = l.OwnerId;
                                        t.Subject = 'New Lead assigned';
                                        t.Status = 'Not Started';
                                        t.Priority = 'Normal';
                                        t.ActivityDate = System.Today();
                                        insert t;                   
                                     }          
                                } 
                            }
                            else
                            {
                                if(l.FRML_Division_Group__c == 'S&T' || l.FRML_Division_Group__c == 'CP')
                                {    
                                    if(mapLeadCountryFields.get(l.LKP_Country__c+'-'+l.LeadSource) != null) l.OwnerId = (mapLeadCountryFields.get(l.LKP_Country__c+'-'+l.LeadSource)).LKP_Default_Lead_Owner__c;                                    
                                }                           
                                    
                                //Lead Owner changed
                                 if(l.OwnerId != ((Map<Id, Lead>)trigger.oldMap).get(l.Id).OwnerId)
                                 {
                                    Task t = new Task();
                                    t.WhoId = l.Id;
                                    t.OwnerId = l.OwnerId;
                                    t.Subject = 'New Lead assigned';
                                    t.Status = 'Not Started';
                                    t.Priority = 'Normal';
                                    t.ActivityDate = System.Today();
                                    insert t;                   
                                 }
                                
                            }   
                        }
                    }
                    else l.addError(Label.SLC_site_confirm_KO1);
                }
            }   
        }
    }
}