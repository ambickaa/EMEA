/*
Class name - HLPR_ArtcleUpdateCase
Description- Utility class for trigger Trg_beforeInsertUpdate
Created By - Accenture IDC
*/
public class HLPR_ArtcleUpdateCase{
/*
Method name - processRecords
Description - This method will find attched attached or not
*/
    public static void processRecords(List < Case > lstcase) {
   
         Set<Id> CasIds=new Set<Id>();
         Set<Id> CasArtIds=new Set<Id>();
  
    for(Case c:lstcase){
        if(c.id!=null && c.recordtypeid == System.Label.ServicecaseRTId){
            CasIds.add(c.id);
            }
    }
     
    List<CaseArticle> casArtLst = [Select CaseId,Id,KnowledgeArticleId from CaseArticle where CaseId IN: CasIds]; 
    
    if(casArtLst!=null)
    {
        for(CaseArticle Cas:casArtLst )
        {
             CasArtIds.add(cas.CaseId);
        } 
    }
    
        
    for(Case cc:lstcase)
    {
        if(CasArtIds.contains(cc.id))
        {
           cc.GC_CaseArticle_Text__c = 'True'; 
        }
        else
            cc.GC_CaseArticle_Text__c = 'False';                   
         }
    }
  
}