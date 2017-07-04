public with sharing class PDP_TabTxtFileController{


    public List<PDPOrgLineItem__c> hierarchyLineItemList = new List<PDPOrgLineItem__c>();
    
    public PDPOrgLineItem__c oli= new PDPOrgLineItem__c();
    public String filename='';
    public List<countryGroupWrapper> countryGroupWrap {get;set;}  
    public Map<String,PDPCountryGroup__c> cgMap = new map<String,PDPCountryGroup__c>();
    public Set<String> ALIASinUse = new Set<String>();
    public Set<String> SAPinUse = new Set<String>();
    public PDP_TabTxtFileController()
    {
        for(PDPCountryGroup__c cg: Util.CountryGroups)
        {
            cgMap.put(cg.Name,cg); 
        }

    }

    public String getfilename()
    {
        String name='PDP_ORG_';
        Map<String,PDPCountryGroup__C> cgOpt = getCountryOptions();  
       
        Datetime currentDate = (system.now());    
        name=name+((String.valueof(currentDate)).replaceAll('_', '')).replaceAll('','')+'.txt';
        return name;
        
    }
    
  
    
    public Map<String,PDPCountryGroup__C> CountryOptions;
    
    public Map<String,PDPCountryGroup__C> getCountryOptions ()
    {   
       String Parameters='';
       Parameters=(String)ApexPages.currentPage().getParameters().get('Param');  
       List<String> CountryGroupOptString=(Parameters.substringAfter('____')).split('__');
       Map<String,PDPCountryGroup__C> cgMap= new Map<String,PDPCountryGroup__c>();
       
       for(String str: CountryGroupOptString)
       { 
            cgMap.put(str.substringBefore('0'),new PDPCountryGroup__c(Name=str.substringBefore('0'), Repeat_L1__c=str.contains('L1'),Repeat_L2__c=str.contains('L2'),Repeat_L3__c=str.contains('L3')));
       }
       return cgMap;
           
    }
     
    
    public List<PDPOrgLineItem__c> gethierarchyLineItemList()
    {
         String DataFormat=((String)ApexPages.currentPage().getParameters().get('Param')).subStringBefore('___');
         
         PDPOrgLineItem__c header = new PDPOrgLineItem__c ();
        // header.outputData__c='EA_L1'+'\t'+'EA_L2_EXTRL_ID'+'\t'+'EA_L3_EXTRL_ID'+'\t'+'EA_L4_EXTRL_ID'+'\t'+'EA_ORG_DISCONTINUED'+'\t'+'EA_ORG_DISCONTINUED_DATE'+'\r\n';         
          header.outputData__c=System.Label.PDP_L1+'\t'+System.Label.PDP_L2_EXTRL_ID+'\t'+System.Label.PDP_L3_EXTRL_ID+'\t'+System.Label.PDP_L4_EXTRL_ID+'\t'+System.Label.PDP_ORG_DISCONTINUED+'\t'+System.Label.PDP_ORG_DISCONTINUED_DATE+'\r\n';         

         hierarchyLineItemList.add(header);  
        
        Map<String,PDPCountryGroup__C> cgOpt = getCountryOptions();
            
           for(PDPOrgLineItem__c oli: [
            SELECT Id,is_LVL_1_Line__c,is_LVL_2_Line__c,is_LVL_3_Line__c,is_LVL_4_Line__c,Name,
            YPDP_L1__c,YPDP_L2_EXTRL_ID__c,YPDP_L3_EXTRL_ID__c,
            YPDP_L4_EXTRL_ID__c,YPDP_ORG_DISCONTINUED_DATE__c,YPDP_ORG_DISCONTINUED__c,
            YPDP_L2_EXTRL_ID_PC__c,YPDP_L3_EXTRL_ID_PC__c,YPDP_L4_EXTRL_ID_PC__c, 
            YPDP_L2_EXTRL_ID_N__c,YPDP_L3_EXTRL_ID_N__c,YPDP_L4_EXTRL_ID_N__c,
            outputData__c 
            FROM PDPOrgLineItem__c 
            WHERE YPDP_L1__C in: cgOpt.keyset() AND YPDP_ORG_DISCONTINUED__c='0'
            ORDER BY is_LVL_4_Line__c,is_LVL_3_Line__c,is_LVL_2_Line__c,YPDP_L1__c  DESC
        ])
        {
            
            if (oli.YPDP_L4_EXTRL_ID__c==null) oli.YPDP_L4_EXTRL_ID__c='';
            if (oli.YPDP_L3_EXTRL_ID__c==null) oli.YPDP_L3_EXTRL_ID__c='';
            if (oli.YPDP_L2_EXTRL_ID__c==null) oli.YPDP_L2_EXTRL_ID__c='';
            
            
            
            if(DataFormat=='ALIAS')
            {   	    
                if (oli.is_LVL_1_Line__c==true)
                {
                    if(cgOpt.get(oli.YPDP_L1__c).Repeat_L1__c==true && !ALIASinUse.contains(oli.YPDP_L1__c))
                    {    
                    	oli.outputData__c=oli.YPDP_L1__c+'\t'+oli.YPDP_L1__c+'\t'+oli.YPDP_L1__c+'\t'+oli.YPDP_L1__c+'\t'+oli.YPDP_ORG_DISCONTINUED__c+'\t'+'\r\n';
                    	ALIASinUse.add(oli.YPDP_L1__c);
                    }
                }
                else if (oli.is_LVL_2_Line__c==true)
                {
                    if(cgOpt.get(oli.YPDP_L1__c).Repeat_L2__c==true && !ALIASinUse.contains(oli.YPDP_L2_EXTRL_ID__c))
                    {
                    	 oli.outputData__c=oli.YPDP_L1__c+'\t'+oli.YPDP_L2_EXTRL_ID__c.toUpperCase()+'\t'+oli.YPDP_L2_EXTRL_ID__c.toUpperCase()+'\t'+oli.YPDP_L2_EXTRL_ID__c.toUpperCase()+'\t'+oli.YPDP_ORG_DISCONTINUED__c+'\t'+'\r\n';
                         ALIASinUse.add(oli.YPDP_L2_EXTRL_ID__c);
                    }
                    //else
                    //  oli.outputData__c=oli.YPDP_L1__c+'\t'+oli.YPDP_L2_EXTRL_ID__c+'\t'+oli.YPDP_L3_EXTRL_ID__c+'\t'+oli.YPDP_L4_EXTRL_ID__c+'\t'+oli.YPDP_ORG_DISCONTINUED__c+'\t'+'\r\n';                        
                }
                else if (oli.is_LVL_3_Line__c==true)
                {
                    if(cgOpt.get(oli.YPDP_L1__c).Repeat_L3__c==true && !ALIASinUse.contains(oli.YPDP_L3_EXTRL_ID__c))
                    {
                    	oli.outputData__c=oli.YPDP_L1__c+'\t'+oli.YPDP_L2_EXTRL_ID__c.toUpperCase()+'\t'+oli.YPDP_L3_EXTRL_ID__c.toUpperCase()+'\t'+oli.YPDP_L3_EXTRL_ID__c.toUpperCase()+'\t'+oli.YPDP_ORG_DISCONTINUED__c+'\t'+'\r\n';        
                        ALIASinUse.add(oli.YPDP_L3_EXTRL_ID__c);
                    }//else
                    //  oli.outputData__c=oli.YPDP_L1__c+'\t'+oli.YPDP_L2_EXTRL_ID__c+'\t'+oli.YPDP_L3_EXTRL_ID__c+'\t'+oli.YPDP_L4_EXTRL_ID__c+'\t'+oli.YPDP_ORG_DISCONTINUED__c+'\t'+'\r\n';            
                }
                else 
                {   if(!ALIASinUse.contains(oli.YPDP_L4_EXTRL_ID__c)) 
                	{
                		oli.outputData__c=oli.YPDP_L1__c+'\t'+oli.YPDP_L2_EXTRL_ID__c.toUpperCase()+'\t'+oli.YPDP_L3_EXTRL_ID__c.toUpperCase()+'\t'+oli.YPDP_L4_EXTRL_ID__c.toUpperCase()+'\t'+oli.YPDP_ORG_DISCONTINUED__c+'\t'+'\r\n';        
                        ALIASinUse.add(oli.YPDP_L4_EXTRL_ID__c);
                	
                	}
                }
            }
            else if(DataFormat=='SAPCode')
            {       
                if (oli.is_LVL_1_Line__c==true && !SAPinUse.contains(cgMap.get(oli.YPDP_L1__c).SAP_Country_Code__c))
                {
                    if(cgOpt.get(oli.YPDP_L1__c).Repeat_L1__c==true)
                    {    oli.outputData__c=oli.YPDP_L1__c+'\t'+cgMap.get(oli.YPDP_L1__c).SAP_Country_Code__c+'\t'+cgMap.get(oli.YPDP_L1__c).SAP_Country_Code__c+'\t'+cgMap.get(oli.YPDP_L1__c).SAP_Country_Code__c+'\t'+oli.YPDP_ORG_DISCONTINUED__c+'\t'+'\r\n';
                    	 SAPinUse.add(cgMap.get(oli.YPDP_L1__c).SAP_Country_Code__c);	 
                    }  
                }
                else if (oli.is_LVL_2_Line__c==true)
                {
                    if(cgOpt.get(oli.YPDP_L1__c).Repeat_L2__c==true && cgMap.get(oli.YPDP_L1__c).Country_LVL_2__c!=true && !SAPinUse.contains(oli.YPDP_L2_EXTRL_ID_PC__c) )
                    {
                        oli.outputData__c=oli.YPDP_L1__c+'\t'+oli.YPDP_L2_EXTRL_ID_PC__c+'\t'+oli.YPDP_L2_EXTRL_ID_PC__c+'\t'+oli.YPDP_L2_EXTRL_ID_PC__c+'\t'+oli.YPDP_ORG_DISCONTINUED__c+'\t'+'\r\n';               
                    	SAPinUse.add(oli.YPDP_L2_EXTRL_ID_PC__c);	 
                    
                    }
                    else if(cgOpt.get(oli.YPDP_L1__c).Repeat_L2__c==true && cgMap.get(oli.YPDP_L1__c).Country_LVL_2__c!=false  && !SAPinUse.contains(cgMap.get(oli.YPDP_L1__c).SAP_Country_Code__c))
                    {
                        oli.outputData__c=oli.YPDP_L1__c+'\t'+cgMap.get(oli.YPDP_L1__c).SAP_Country_Code__c+'\t'+cgMap.get(oli.YPDP_L1__c).SAP_Country_Code__c+'\t'+cgMap.get(oli.YPDP_L1__c).SAP_Country_Code__c+'\t'+oli.YPDP_ORG_DISCONTINUED__c+'\t'+'\r\n';                                     
                    	SAPinUse.add(cgMap.get(oli.YPDP_L1__c).SAP_Country_Code__c);	 
                    
                    }
                    //else
                    //  oli.outputData__c=oli.YPDP_L1__c+'\t'+oli.YPDP_L2_EXTRL_ID_PC__c+'\t'+oli.YPDP_L3_EXTRL_ID_PC__c+'\t'+oli.YPDP_L4_EXTRL_ID_PC__c+'\t'+oli.YPDP_ORG_DISCONTINUED__c+'\t'+'\r\n';                       
                }
                else if (oli.is_LVL_3_Line__c==true )
                {
                    if(cgOpt.get(oli.YPDP_L1__c).Repeat_L3__c==true && cgMap.get(oli.YPDP_L1__c).Country_LVL_2__c!=true && !SAPinUse.contains(oli.YPDP_L3_EXTRL_ID_PC__c))
                    {    oli.outputData__c=oli.YPDP_L1__c+'\t'+oli.YPDP_L2_EXTRL_ID_PC__c+'\t'+oli.YPDP_L3_EXTRL_ID_PC__c+'\t'+oli.YPDP_L3_EXTRL_ID_PC__c+'\t'+oli.YPDP_ORG_DISCONTINUED__c+'\t'+'\r\n';           
						 SAPinUse.add(oli.YPDP_L3_EXTRL_ID_PC__c);                    
                    }
                    else if (cgOpt.get(oli.YPDP_L1__c).Repeat_L3__c==true && cgMap.get(oli.YPDP_L1__c).Country_LVL_2__c!=false && !SAPinUse.contains(oli.YPDP_L3_EXTRL_ID_PC__c))
                    {    oli.outputData__c=oli.YPDP_L1__c+'\t'+cgMap.get(oli.YPDP_L1__c).SAP_Country_Code__c+'\t'+oli.YPDP_L3_EXTRL_ID_PC__c+'\t'+oli.YPDP_L3_EXTRL_ID_PC__c+'\t'+oli.YPDP_ORG_DISCONTINUED__c+'\t'+'\r\n';           
						 SAPinUse.add(oli.YPDP_L3_EXTRL_ID_PC__c);                    
                    }                    
                    //else
                    //  oli.outputData__c=oli.YPDP_L1__c+'\t'+oli.YPDP_L2_EXTRL_ID_PC__c+'\t'+oli.YPDP_L3_EXTRL_ID_PC__c+'\t'+oli.YPDP_L4_EXTRL_ID_PC__c+'\t'+oli.YPDP_ORG_DISCONTINUED__c+'\t'+'\r\n';               
                }
                else 
                {       if(cgMap.get(oli.YPDP_L1__c).Country_LVL_2__c!=true && !SAPinUse.contains(oli.YPDP_L4_EXTRL_ID_PC__c))
                        {
                            oli.outputData__c=oli.YPDP_L1__c+'\t'+oli.YPDP_L2_EXTRL_ID_PC__c+'\t'+oli.YPDP_L3_EXTRL_ID_PC__c+'\t'+oli.YPDP_L4_EXTRL_ID_PC__c+'\t'+oli.YPDP_ORG_DISCONTINUED__c+'\t'+'\r\n';           
                        	SAPinUse.add(oli.YPDP_L4_EXTRL_ID_PC__c);                    
                        
                        }
                        else if( !SAPinUse.contains(oli.YPDP_L4_EXTRL_ID_PC__c))
                        {
                            oli.outputData__c=oli.YPDP_L1__c+'\t'+cgMap.get(oli.YPDP_L1__c).SAP_Country_Code__c+'\t'+oli.YPDP_L3_EXTRL_ID_PC__c+'\t'+oli.YPDP_L4_EXTRL_ID_PC__c+'\t'+oli.YPDP_ORG_DISCONTINUED__c+'\t'+'\r\n';           
                        	SAPinUse.add(oli.YPDP_L4_EXTRL_ID_PC__c);                    
                        }
                }
            }
            else if(DataFormat=='Name')
            {       
                if (oli.is_LVL_1_Line__c==true)
                {
                    if(cgOpt.get(oli.YPDP_L1__c).Repeat_L1__c==true)
                        oli.outputData__c=oli.YPDP_L1__c+'\t'+oli.YPDP_L1__c+'\t'+oli.YPDP_L1__c+'\t'+oli.YPDP_L1__c+'\t'+oli.YPDP_ORG_DISCONTINUED__c+'\t'+'\r\n';
                }
                else if (oli.is_LVL_2_Line__c==true)
                {
                    if(cgOpt.get(oli.YPDP_L1__c).Repeat_L2__c==true)
                        oli.outputData__c=oli.YPDP_L1__c+'\t'+oli.YPDP_L2_EXTRL_ID_N__c+'\t'+oli.YPDP_L2_EXTRL_ID_N__c+'\t'+oli.YPDP_L2_EXTRL_ID_N__c+'\t'+oli.YPDP_ORG_DISCONTINUED__c+'\t'+'\r\n';
                //  else
                        //oli.outputData__c=oli.YPDP_L1__c+'\t'+oli.YPDP_L2_EXTRL_ID_N__c+'\t'+oli.YPDP_L3_EXTRL_ID_N__c+'\t'+oli.YPDP_L4_EXTRL_ID_N__c+'\t'+oli.YPDP_ORG_DISCONTINUED__c+'\t'+'\r\n';                        
                }
                else if (oli.is_LVL_3_Line__c==true)
                {
                    if(cgOpt.get(oli.YPDP_L1__c).Repeat_L3__c==true)
                        oli.outputData__c=oli.YPDP_L1__c+'\t'+oli.YPDP_L2_EXTRL_ID_N__c+'\t'+oli.YPDP_L3_EXTRL_ID_N__c+'\t'+oli.YPDP_L3_EXTRL_ID_N__c+'\t'+oli.YPDP_ORG_DISCONTINUED__c+'\t'+'\r\n';          
                //  else
                    //  oli.outputData__c=oli.YPDP_L1__c+'\t'+oli.YPDP_L2_EXTRL_ID_N__c+'\t'+oli.YPDP_L3_EXTRL_ID_N__c+'\t'+oli.YPDP_L4_EXTRL_ID_N__c+'\t'+oli.YPDP_ORG_DISCONTINUED__c+'\t'+'\r\n';              
                }
                else 
                {       oli.outputData__c=oli.YPDP_L1__c+'\t'+oli.YPDP_L2_EXTRL_ID_N__c+'\t'+oli.YPDP_L3_EXTRL_ID_N__c+'\t'+oli.YPDP_L4_EXTRL_ID_N__c+'\t'+oli.YPDP_ORG_DISCONTINUED__c+'\t'+'\r\n';          
                
                }
            }
            
            
            hierarchyLineItemList.add(oli);
            
        }

        return hierarchyLineItemList;
    }  

  
    public class countryGroupWrapper
    {
        public PDPCountryGroup__C cg{get; set;}
        public Boolean selected {get; set;}
        public Boolean disabled {get; set;}
              
        public countryGroupWrapper(PDPCountryGroup__C cg_aux, Boolean sel, Boolean dis)
        {
            cg = cg_aux;
            selected = sel;
            disabled=dis;
        }
    }
    
    
    

 
}