Global class BatchArticleUpdateCase implements Database.Batchable<sObject>
{
    Private String query='' ;

    Global BatchArticleUpdateCase(){
        Datetime dt = Datetime.newInstanceGmt(System.today(), System.now().time());
        dt = dt.addHours(-2); 
        query = 'select id,GC_CaseArticle_Text__c from Case where recordtypeid = \''+System.Label.ServicecaseRTId+'\' AND LastModifiedDate >='+ dt.format('YYYY-MM-dd\'T\'hh:mm:ss.SSSZ') ;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Datetime dt = Datetime.newInstanceGmt(System.today(), System.now().time());
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> cScope)
    {
        List<Case> caseList =  new List<Case>();
        List<Case> caseList1 =  new List<Case>();
        List<CaseArticle> caseArticleList =  new List<CaseArticle>();
        Set<ID> caseIds = new Set<ID>();
        
        for(Case c:cScope){
            caseIds.add(c.id); 
        }
        
        caseList = [select id,GC_CaseArticle_Text__c,(select CaseId,Id,KnowledgeArticleId from case.CaseArticles) from Case where id in :caseIds];  
        
        for(Case c:caseList)
        {
            if(c.caseArticles.size()>0)
            {
                c.GC_CaseArticle_Text__c ='True';
                caseList1.add(c);
            }
            else{
                c.GC_CaseArticle_Text__c ='False';
                caseList1.add(c);
            }
        }
        database.update(caseList1,false);              
    }
    
    global void finish(Database.BatchableContext BC)
    {}
}