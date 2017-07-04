@istest
public class Test_REST_SendLogicalEntityEvent 
{
  
  public static testmethod void CreateEvent()
  {                 
      Test_REST_DataFactoryEvent.createOneRESTLead(); 
      Test_REST_DataFactoryEvent.createOneRESTAccount();
      Test_REST_DataFactoryEvent.createOneRESTContact();
      Test_REST_DataFactoryEvent.createOneRESTSurveyAnswer();
      Test_REST_DataFactoryEvent.createOneRESTFeedback();
      Test_REST_DataFactoryEvent.createOneRESTEvent();
      Test_REST_DataFactoryEvent.SetSystemSettings('all'); 
      REST_SendLogicalEntityEvent.REST_EventObject eventT=  Test_REST_DataFactoryEvent.eventForTest;
      
      REST_SendLogicalEntityEvent.sendActivities(eventT);
      Test_REST_DataFactoryEvent.SetSystemSettings('Exception');
      REST_SendLogicalEntityEvent.REST_EventObject eventT2= Test_REST_DataFactoryEvent.eventForTest;

      REST_SendLogicalEntityEvent.sendActivities(eventT2);

      /* Testing error log*/
      Blob body = Blob.valueOf('test');
      REST_SendLogicalEntityEvent.REST_EventObject eventError =  Test_REST_DataFactoryEvent.eventForTest;
      Attachment att = new Attachment(name='test', parentId=eventError.eventId, body=body );
      insert att;
      eventError.accounts[0].account.AccountNumber='1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
      eventError.backupFileId=att.Id;
      REST_SendLogicalEntityEvent.sendActivities(eventError);
      
  }
    
    

}