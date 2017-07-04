public without sharing class TriggerAttachmentNameUpdate implements Triggers.Handler {
    
    public void handle()
    {
        list<Attachment> attachs=[Select Id,name,parent.Name from Attachment where parentId IN 
                                  (SELECT Id from Opportunity where RecordType.Name='Transfer Order') 
                                  and Id IN: (List<Attachment>)Trigger.new ];
        for(Attachment attach:attachs)
        {
            attach.name=attach.parent.Name;
        }
        update attachs;
    }
}