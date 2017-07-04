public without sharing class TriggerOpportunityAutoInfoCreator implements Triggers.Handler {
            
   public void handle(){   
        //Get System settings indicating pricebooks per country and division and put them in a map
        Map<String, String> pricebookMap = new Map<String, String>();
        for(SystemSettings__c item : [Select name, value__c from systemSettings__c where name like 'Pricebook%'])
        {
        system.debug('inserta el '+item.name);
            pricebookMap.put(item.name, item.value__c);
        }

        //-------
        // Get pricing options indicating the options for pricing in turkey
        //---------
        Map<String,pricing_options__C> pricingOptionMap=new Map<String,pricing_options__c>();
        for(pricing_options__c item :[SELECT name,value__c,OPT__c,Fixed_value_date__c,Payment_Terms__c,Pricing_Date__c from pricing_options__c ]) 
        {
            pricingOptionMap.put(item.value__c, item);            
        }        
    
        User currentUser = Util.currentUser; 
        List<Id> listaOwners = new List<Id>();

        //--------------
        // Get sold-To SAP code values in order to put the correct name to turkey orders
        //-------------        
        Map<id,string> soldsToMap=new Map<id,string>();
        
        for(Opportunity item: (List<Opportunity>)Trigger.new) 
        {
            listaOwners.add(item.ownerId);
            soldsToMap.put(item.AccountId,'notaValueYet' );           
        }
        
        Map<Id, User> usMap = new Map<Id, User> ([SELECT  Country, TXT_Division__c, TXT_Sales_Org__c, TXT_Distribution_Channel__c, OrderPrefix_RSA__c FROM User where id in :listaOwners ]);
        for(account item : [SELECT GC_SAP_ID__C from account where id in : soldsToMap.keySet()])
        {
            soldsToMap.put(item.id,item.GC_SAP_ID__C);
        }
            
        Integer newNumber = 0;
        String initials;  
         
        initials = usMap.values()[0].OrderPrefix_RSA__c;
        if(Trigger.isInsert)     
        {
            try
            {
               //BEG TO MAKE TRIGGER ATOMIC
               Country__c co= [SELECT id from Country__c where Name=:Util.currentUser.Country FOR UPDATE];
               //END                 
               Opportunity opptnt = [SELECT Name FROM Opportunity WHERE name like '%-%' and OwnerId = :Util.currentUser.ID order by createddate desc limit 1];
               if (opptnt!=null)
               {
                  opptnt.Name = opptnt.Name.replace('(R)', '');
                  newNumber = Integer.valueOf(opptnt.Name.substringAfterLast('-')) + 1;
               }
            }  
            catch(Exception e)
            {
              // si da error es porque no hay registros, no hay problema
            }
        }            

                                 
            for (Opportunity opp : (List<Opportunity>)Trigger.new)
            {
                system.debug('Se ha creado una nueva order');
                string recordtypename = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(opp.recordtypeid).getname();
                
                    Opportunity oldOpportunity = new Opportunity();                   
                    if(Trigger.isUpdate)
                    {
                        oldOpportunity = ((Map<Id, Opportunity>)Trigger.oldMap).get(opp.Id);
                        
                        //Fill early discount number for Italy 
                        if(opp.PICK_Early_Discount__c!='--' && opp.PICK_Early_Discount__c!=null && oldOpportunity.PICK_Early_Discount__c!=opp.PICK_Early_Discount__c) opp.NUM_Early_Discount__c=double.valueOf(opp.PICK_Early_Discount__c.remove('%'));
                        
                        //Change name in case Transfer order changes to Organized
                        if(((oldOpportunity.CHK_Organized__c!=opp.CHK_Organized__c)||(oldOpportunity.TXT_DDT_Number__c!=opp.TXT_DDT_Number__c)) )
                        {
                            string dateOpp=string.valueOf(opp.CloseDate);
                            string[] parameters= dateOpp.split('-', -1);
                            string year= parameters[0].substring(2) ;
                            string month= parameters[1];
                            string day= parameters[2];
                            
                            //if(opp.CHK_Organized__c)opp.Name= '(T)'+initials+'_DDT'+opp.TXT_DDT_Number__c+'-'+ opp.Name.split('-')[1]; //170316 Change PO Number construction for organized transfer, remove DDT
                            if(opp.CHK_Organized__c)opp.Name= '(T)'+initials+'_'+opp.TXT_DDT_Number__c+'-'+ opp.Name.split('-')[1];
                            else{ 
                                opp.Name= opp.Name.split('_')[0]+'_'+ day+month+year+'-'+ opp.Name.split('-')[1];
                                opp.TXT_DDT_Number__c='';
                            }
                        }
                        if(oldOpportunity.PICK_Status__c=='Pending Manager' && opp.PICK_Status__c=='Approved' && (opp.TXTA_Sales_Org__c=='FR24' || opp.TXTA_Sales_Org__c=='BG01')&& recordTypeName =='Sales Order FR')
                           {
                              ExportOrderData.futureConvertOrders(opp.id) ;
                           }
                    }
                    
                    //Try to find pricebook match from map
                    //If there's no match, try to get value from custom lkp
                    system.debug('Intenta buscar el: '+'Pricebook_'+usMap.get(opp.ownerId).TXT_Sales_Org__c+'_'+usMap.get(opp.ownerId).TXT_Division__c);
                    if(pricebookMap!=null && pricebookMap.get('Pricebook_'+usMap.get(opp.ownerId).TXT_Sales_Org__c+'_'+usMap.get(opp.ownerId).TXT_Division__c)!=null)
                    {
                        system.debug('le pone el valor: '+pricebookMap.get('Pricebook_'+usMap.get(opp.ownerId).TXT_Sales_Org__c+'_'+usMap.get(opp.ownerId).TXT_Division__c));
                        opp.pricebook2Id = pricebookMap.get('Pricebook_'+usMap.get(opp.ownerId).TXT_Sales_Org__c+'_'+usMap.get(opp.ownerId).TXT_Division__c);
                    }
                    else if(opp.LKP_Price_Book__c!=null)                                                               
                    {
                         opp.pricebook2Id = opp.LKP_Price_Book__c;    
                    }
                    
                    //--------------
                    //  Pricing Options fields filled by custom Setting 'Pricing Options'
                    //--------------
                    if(opp.Pricing_Option__c!=null && pricingOptionMap!=null && pricingOptionMap.get(opp.Pricing_Option__c)!=null)
                    {
                        opp.TXT_payment_terms__C=pricingOptionMap.get(opp.Pricing_option__c).Payment_Terms__c;
                        opp.DATE_Pricing_Date__c=pricingOptionMap.get(opp.Pricing_option__c).Pricing_Date__c;
                        opp.DATE_fixed_value__c=pricingOptionMap.get(opp.Pricing_option__c).Fixed_value_date__c;
                    }
                    if(Trigger.isInsert )
                    {    
                        if(opp.PICK_Early_Discount__c!=null && opp.PICK_Early_Discount__c!='--')opp.NUM_Early_Discount__c=double.valueOf( opp.PICK_Early_Discount__c.remove('%'));
                        
                        opp.Name = String.valueOf(newNumber++);
                        while (opp.Name.length () < 5){
                                opp.Name = '0' + opp.Name;
                        }

                        if(recordTypeName=='Transfer Order')
                        {
                            string dateOpp=string.valueOf(opp.CloseDate);
                            string[] parameters= dateOpp.split('-', -1);
                            string year= parameters[0].substring(2) ;
                            string month= parameters[1];
                            string day= parameters[2];
                            if(!opp.CHK_Organized__c )opp.Name=+'(T)'+ initials+'_'+day+month+year+'-'+opp.name;
                            //else if(opp.CHK_Organized__c )opp.Name='(T)'+ initials+'_DDT'+opp.TXT_DDT_Number__c+'-'+opp.name; //170316 Change PO Number construction for organized transfer, remove DDT
                            //else opp.Name='DDT-'+opp.TXT_DDT_Number__c+'_'+ day+month+year; //170316 Change PO Number construction for organized transfer, remove DDT
                            else if(opp.CHK_Organized__c )opp.Name='(T)'+ initials+'_'+opp.TXT_DDT_Number__c+'-'+opp.name;
                            else opp.Name='-'+opp.TXT_DDT_Number__c+'_'+ day+month+year;                          
                        }                      
                        else if(recordTypeName=='Sales Order CP Italy'){
                            String discount=String.valueOf(opp.PICK_Early_Discount__c);
                            if (discount=='--')discount='';                                                       
                            string dateOpp=string.valueOf(Date.today());
                            string[] parameters= dateOpp.split('-', -1);
                            string year= parameters[0].substring(2) ;
                            string month= parameters[1];                            
                            opp.Name=discount.remove('%')+initials +year +month+'-'+opp.name;
                        }
                        else
                        {
                            if(usMap.get(opp.ownerId).TXT_Sales_Org__c=='TR01'){opp.Name=soldsToMap.get(opp.AccountId) +'-'+opp.FRML_Get_FY__c+'-'+initials+'-'+opp.Name;}
                            else opp.Name = initials + '-' + opp.Name;
                             
                            if (opp.StageName=='Fast warehouse' && usMap.get(opp.ownerId).TXT_Sales_Org__c!='TR01' )
                            {
                                opp.Name = opp.Name + '(R)';
                            }
                        }
                     }
                     if(Trigger.isInsert || (Trigger.isUpdate && opp.ownerId != oldOpportunity.ownerId))
                     { 
                          if(usMap.get(opp.ownerId).TXT_Division__c!=null)   opp.TXTA_Division__c = usMap.get(opp.ownerId).TXT_Division__c;
                         if(usMap.get(opp.ownerId).TXT_Sales_Org__c!=null)   opp.TXTA_Sales_Org__c = usMap.get(opp.ownerId).TXT_Sales_Org__c;
                          if(usMap.get(opp.ownerId).TXT_Distribution_Channel__c!=null)   opp.TXT_Distribution_Channel__c = usMap.get(opp.ownerId).TXT_Distribution_Channel__c;
                     }
                    
           }                              
   }     
}