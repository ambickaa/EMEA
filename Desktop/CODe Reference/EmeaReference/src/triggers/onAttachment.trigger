trigger onAttachment on Attachment (after delete, after insert, after undelete, 
after update, before delete, before insert, before update)
{
    new Triggers()
    
    .bind(Triggers.Evt.afterinsert, new TriggerAttachmentNameUpdate()) 
  
    .manage();
}