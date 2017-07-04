public with sharing class Case_Rating_Controller {
  
  public User currentUser {get {return Util.currentUser;} set;}
  public Case caseObject {get; set;}
  private List<Case> caseList;
  public boolean Empty {get; set;}
  public boolean Denied {get; set;}
  public boolean Submitted {get; set;}
  public boolean NotClosed {get; set;}
  
  public String CreatedDate {get; set;}
  public String ClosedDate {get; set;}
  
  public Case_Rating_Controller() {
  
    Id caseId = ApexPages.currentPage().getParameters().get('id');
    
    NotClosed = false;
    Submitted = false;
    Denied = false;
    Empty = false;
    caseObject = new Case();
    caseList = new List<Case>();
    
    if(caseId != null) {
    
        caseList = [SELECT Id, Subject, CaseNumber, PICK_RATING__c, TXT_RATING_COMMENTS__c, LKP_RATING_BY__r.Name,
                   Status, Priority, Contact.Name, Contact.Email, CreatedDate, ClosedDate
                   FROM Case WHERE Id = :caseId];
      
      if(caseList.size() > 0) {
        caseObject = caseList[0];
        
        CreatedDate = caseObject.CreatedDate.format('MMMM d,  yyyy');
        ClosedDate = caseObject.ClosedDate.format('MMMM d,  yyyy');
        
        if(caseObject.Status != 'Closed')
          NotClosed = true;
        if(caseObject.PICK_RATING__c != null && caseObject.LKP_RATING_BY__r.Name != 'Support Team' && caseObject.Status == 'Closed')
          Submitted = true;
      } else {
        Denied = true;
      }
    } else {
      Empty = true;
    }
  }
}