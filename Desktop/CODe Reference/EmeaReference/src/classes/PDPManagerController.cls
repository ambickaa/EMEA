public with sharing class PDPManagerController{
 
    public List<PDPCountryGroup__C> countryGroups {get;set;}
    public List<countryGroupWrapper> cgWrapper {get;set;}
    public List<String> groupings {get;set;}
    public List<countryGroupWrapper> cgw {get;set;} 
    public List<countryGroupWrapper> cgw2 {get;set;} 
    
    public Integer lastSelected  {get;set;}  
    public List<PDPOrgLineItem__c> hierarchyLineItemList {get;set;} 
    public Boolean hasResult {get;set;}  
    public String CreateExcelURL;
    public PageReference downloadUrl {get;set;}
            
    public PDPManagerController()
    {
        init();
        lastSelected=0;
    }
    public PageReference launcher2()
    {
    	return null;
    }

    public PageReference launcher()
    {
        Integer currentSelected=0;
        String SelectedGroup;
        for(countryGroupWrapper cg: cgw)
        {
            if(cg.selected==true)
            {
                    currentSelected++;          }   
        }
        
        if(currentSelected>=lastSelected)
        {
        
            for(countryGroupWrapper cg: cgw)
            {
                if(cg.selected==true)
                {
                    SelectedGroup=cg.cg.Grouping__c;
                    break;
                }   
            }
            for (countryGroupWrapper cg: cgw)
            {
                if(cg.cg.Grouping__c==SelectedGroup)
                {
                    cg.selected=true;
                    cg.disabled=false;
                    lastSelected++;
                }else
                {
                    cg.selected=false;
                    cg.disabled=true;
                }
            }
        }
        else
        {
            for (countryGroupWrapper cg: cgw)
            {
                    cg.selected=false;
                    cg.disabled=true;
                
            }
            currentSelected=0;
            lastSelected=0;
        }
            
    return null;
    }

    public Boolean getAnySelected ()
    {
        for(countryGroupWrapper citer: cgw)
        {
            if(citer.selected==true)
            {
                return true;
                break;
            }   
    
        } 
        return false;
    }

    public String groupOption;
    
    public String getgroupOption() { 
        if(groupOption==null) groupOption='A';
        return groupOption;
    }
            
    public void setgroupOption(String groupOption) {
        this.groupOption= groupOption;
    }

    public List<selectOption> GroupOptions;
    
    public List<SelectOption> getGroupOptions() {
    
        List<SelectOption> options = new List<SelectOption>();
        
        for(PDPCountryGroup__c cg:  countryGroups) 
        {           
                    options.add(new SelectOption('ch.Grouping__c','New Order'));    
        }

        return options;
    }

    
    private void init()
    {
        countryGroups  = [SELECT Id,Name,Repeat_L1__c,Repeat_L2__c,Repeat_L3__c,Grouping__c,Description__c,Country_LVL_2__c FROM PDPCountryGroup__c WHERE Grouping__c!='Inactive' Order By Description__c ];
        
        cgw = new List<countryGroupWrapper>();
        for(PDPCountryGroup__C cg : countryGroups)
        {
            cgw.add(new countryGroupWrapper(cg,false,true));

        }
  
    }                
    public PageReference test()
    {
        hasResult=true;             
        
        return null;
    }
    
	
     public String getCreateAliasURL(){
    	
    	String name='ALIAS____';
    	for(countryGroupWrapper cgwItem: cgw)
    	{
    		String namePart='';	
    		if(cgwItem.selected==true)
    		{
    			namePart=cgwItem.cg.Name+'0';
    			if(cgwItem.cg.Repeat_L1__c==true)
    				namePart=namePart+'L1';
				if(cgwItem.cg.Repeat_L2__c==true)
    				namePart=namePart+'L2';
	    		if(cgwItem.cg.Repeat_L3__c==true)
	    				namePart=namePart+'L3';
	    		namePart=namePart+'__';
    		    		
    		}
		   name=name+namePart;
    	}
    	 	 		  	
		return ('/apex/PDP_TabTxtFile?Param='+name);
	}
    
     public String getCreateSAPCodeURL(){
    	
    	String name='SAPCODE____';
    	for(countryGroupWrapper cgwItem: cgw)
    	{
    		String namePart='';	
    		if(cgwItem.selected==true)
    		{
    			namePart=cgwItem.cg.Name+'0';
    			if(cgwItem.cg.Repeat_L1__c==true)
    				namePart=namePart+'L1';
				if(cgwItem.cg.Repeat_L2__c==true)
    				namePart=namePart+'L2';
	    		if(cgwItem.cg.Repeat_L3__c==true)
	    				namePart=namePart+'L3';
	    		namePart=namePart+'__';
    		    		
    		}
		   name=name+namePart;
    	}
		return ('/apex/PDP_TabTxtFile?Param='+name);
	}
     public String getCreateNameURL(){
    	
    	String name='Name____';
    	for(countryGroupWrapper cgwItem: cgw)
    	{
    		String namePart='';	
    		if(cgwItem.selected==true)
    		{
    			namePart=cgwItem.cg.Name+'0';
    			if(cgwItem.cg.Repeat_L1__c==true)
    				namePart=namePart+'L1';
				if(cgwItem.cg.Repeat_L2__c==true)
    				namePart=namePart+'L2';
	    		if(cgwItem.cg.Repeat_L3__c==true)
	    				namePart=namePart+'L3';
	    		namePart=namePart+'__';
    		    		
    		}
		   name=name+namePart;
    	}
		return ('/apex/PDP_TabTxtFile?Param='+name);
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

	  private static void generateBackupDocument(String documentName, String url, String descri){

	    	PageReference tabdoc;
        	String tabdocName;

			tabdoc = Page.PDP_TabTxtFile;  
			tabdoc.getParameters().put('Param',url);
			tabdoc.setRedirect(true);
			Blob docBody = tabdoc.getContent();
	   	    
	   	    list<Folder> destFolder = [SELECT Id FROM Folder WHERE DeveloperName = 'PDP' AND Type = 'Document' AND AccessType = 'Public'];
	   	    if (destFolder.size() == 1) 
	   	    {
	   	    	Document doc= new Document(Name = documentName , Description=descri, body=docBody,developerName=documentName, IsPublic = true, FolderId=destFolder[0].Id, contentType='application/txt',type='txt' );
	   	    	insert doc;
	   	    }
    } 

 }