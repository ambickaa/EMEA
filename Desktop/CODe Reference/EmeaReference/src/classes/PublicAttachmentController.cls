public with sharing class PublicAttachmentController
{
	public Attachment currentAttachment {get; set;}
	public String attachmentData {get; set;}
	public List<Attachment> attachmentList {get; set;}
	
	public PublicAttachmentController()
	{
		attachmentList = [Select a.ParentId, a.Owner.Name, a.Owner.Id, a.OwnerId,
							a.Name, a.LastModifiedDate, a.Id, a.ContentType, a.BodyLength, a.Body
							From Attachment a where id = '00PM0000000ax8HMAQ'];
		if (!attachmentList.isEmpty())
		{
			currentAttachment = attachmentList[0];
			attachmentData = EncodingUtil.base64Encode(currentAttachment.Body);
			//attachmentData = currentAttachment.Body.toString();
		}
	}
}