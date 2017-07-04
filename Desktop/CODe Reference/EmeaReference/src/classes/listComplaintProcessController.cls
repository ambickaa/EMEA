public with sharing class listComplaintProcessController  {
    
    Public listComplaintProcessController(case controller){}
    Public id recordId{get;set;}
    public string mode{get;set;}   

    Public List<cProcess> listcProcess{get;set;}    
    Public List<cProcess> newlistcProcess{get;set;}    

    Public listComplaintProcessController(ApexPages.StandardController stdController)
    {
        recordId = ApexPages.currentPage().getParameters().get('Id');
        //listProcess=new List<Complaint_Process__c>();
        //newlistProcess=new list<Complaint_Process__c>();
        
        listcProcess=new List<cProcess>();
        newlistcProcess=new List<cProcess>();
        
        
        for(Complaint_Process__c item :[Select id, NUM_Dosis_HA__c, PCK_Process__c, TXT_Stage__c, PCK_Status__c, DAT_Date__c from Complaint_Process__c where LKP_Complaint__c=:recordId])
        {
            //listProcess.add(item);
            listcProcess.add(new cProcess(item));
        }
        
        /*
        listProcess=[Select id, NUM_Dosis_HA__c, PCK_Process__c, TXT_Stage__c, PCK_Status__c, DAT_Date__c from Complaint_Process__c where LKP_Complaint__c=:recordId];
        listcProcess=[Select id, NUM_Dosis_HA__c, PCK_Process__c, TXT_Stage__c, PCK_Status__c, DAT_Date__c from Complaint_Process__c where LKP_Complaint__c=:recordId];
        */
        mode='view';
    }
    public List<SelectOption> getProcesses()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult =
            Complaint_Process__c.PCK_Process__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    public List<SelectOption> getStatus()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult =
            Complaint_Process__c.PCK_Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    public void newRow()
    {
        mode='edit' ;
        Complaint_Process__c newPr=new Complaint_Process__c(LKP_Complaint__c=RecordID);
        
        listcProcess.add(new cProcess(newPr));
    }
    public void edit()
    {
        mode='edit' ;
        
    }
    public void cancel()
    {
        mode='view' ;
        listcProcess=new List<cProcess>();        
        for(Complaint_Process__c item :[Select id, NUM_Dosis_HA__c, PCK_Process__c, TXT_Stage__c, PCK_Status__c, DAT_Date__c from Complaint_Process__c where LKP_Complaint__c=:recordId])
        {
         
            listcProcess.add(new cProcess(item));
        }
        
        /*
        listProcess=[Select id, NUM_Dosis_HA__c, PCK_Process__c, TXT_Stage__c, PCK_Status__c, DAT_Date__c from Complaint_Process__c where LKP_Complaint__c=:recordId];
        listcProcess=[Select id, NUM_Dosis_HA__c, PCK_Process__c, TXT_Stage__c, PCK_Status__c, DAT_Date__c from Complaint_Process__c where LKP_Complaint__c=:recordId];
        */
    }    
    
    public void del()
{
    list<Complaint_Process__c> toDel=new list<Complaint_Process__c>();
    
    for(cProcess item:listcProcess)
    {
        if(item.selected)
        {
            toDel.add(item.comProc);
            
        }
            
    }
    delete toDEl;
    listcProcess=new list<cProcess>();
    for(Complaint_Process__c item :[Select id, NUM_Dosis_HA__c, PCK_Process__c, TXT_Stage__c, PCK_Status__c, DAT_Date__c from Complaint_Process__c where LKP_Complaint__c=:recordId])
        {
            
            listcProcess.add(new cProcess(item));
        }
}    
    
    
    public void save()
    {
        mode='view' ;
        
        if(listcProcess!=null || listcProcess.size()>0){
            list<Complaint_Process__c> toUps=new list<Complaint_Process__c>();
            for(cProcess i:listcProcess)
            {
                toUps.add(i.comProc);
            }
            try {
                upsert toUps;
            } catch(dmlException e )
            {
                
                
                apexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.ERROR,e.getDMLMessage(0)));
                
            }
            
        }
        listcProcess=new list<cProcess>();
        for(Complaint_Process__c item :[Select id, NUM_Dosis_HA__c, PCK_Process__c, TXT_Stage__c, PCK_Status__c, DAT_Date__c from Complaint_Process__c where LKP_Complaint__c=:recordId])
        {
            //listProcess.add(item);
            listcProcess.add(new cProcess(item));
        }
        /*
        listProcess=[Select id, NUM_Dosis_HA__c, PCK_Process__c, TXT_Stage__c, PCK_Status__c, DAT_Date__c from Complaint_Process__c where LKP_Complaint__c=:recordId];
        listcProcess=[Select id, NUM_Dosis_HA__c, PCK_Process__c, TXT_Stage__c, PCK_Status__c, DAT_Date__c from Complaint_Process__c where LKP_Complaint__c=:recordId];
        */
    }
    
    
    
       public class cProcess{
        public Complaint_Process__c comProc {get; set;}
        public Boolean selected {get; set;}
    
    public cProcess (Complaint_Process__c c){
        comProc = c;
        selected=false;        
    }}
            
}