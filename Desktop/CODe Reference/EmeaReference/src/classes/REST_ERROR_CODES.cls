global abstract class REST_ERROR_CODES{
    public static Integer ERROR_ATTEMPT_TO_CHANGE_FROZEN_FIELDS = 101;
    public static Integer ERROR_REASON_NEEDED_FOR_DISCRETIONARY_DISCOUNT = 102;
    public static Integer ERROR_NO_STOCK_ASSOCIATED = 103;
    public static integer ERROR_NO_STOCK_LEFT = 104;
    public static Integer ERROR_STATUS_CHANGE_NOT_ALLOWED = 105;
    public static Integer ERROR_SIGNATURE_NOT_FOUND = 106;
    
    public static Integer ERROR_TIMESTAMP_MISMATCH = 200;
    public static Integer ERROR_RECORD_PREVIOUSLY_DELETED = 201;
    public static Integer ERROR_USER_HAS_NO_RIGHTS = 202;
    
    public static Integer ERROR_NOT_PROCESSED = 998;
    public static Integer ERROR_UNKNOWN = 999;
    
    public static String getErrorDescription(Integer paramError){
        if(paramError == REST_ERROR_CODES.ERROR_ATTEMPT_TO_CHANGE_FROZEN_FIELDS) return 'Attempt to Change frozen fields';
        if(paramError == REST_ERROR_CODES.ERROR_REASON_NEEDED_FOR_DISCRETIONARY_DISCOUNT) return 'A reason is needed if any Discretionary Discount is applied';
        if(paramError == REST_ERROR_CODES.ERROR_NO_STOCK_ASSOCIATED) return 'There is no Stock Associated to the Product';
        if(paramError == REST_ERROR_CODES.ERROR_NO_STOCK_LEFT) return 'There is no Stock Left for the Product';
        if(paramError == ERROR_STATUS_CHANGE_NOT_ALLOWED) return 'You are not allowed to change Status field';
        if(paramError == ERROR_SIGNATURE_NOT_FOUND) return 'Signature is required in an Order'; 
        
        
        if(paramError == REST_ERROR_CODES.ERROR_TIMESTAMP_MISMATCH) return 'Record was updated on the server before sync';
        if(paramError == REST_ERROR_CODES.ERROR_RECORD_PREVIOUSLY_DELETED) return 'Record was deleted on the server before sync';
        if(paramError == ERROR_USER_HAS_NO_RIGHTS) return 'This user does not have enougth rights to perform this operation';
        
        if(paramError == REST_ERROR_CODES.ERROR_NOT_PROCESSED) return 'Item Not Processed or no Error Found';
        if(paramError == REST_ERROR_CODES.ERROR_UNKNOWN) return 'Unknown Error: ';
        
        return 'Unknown Error2: ';
    }
    
    public class REST_Exception extends Exception{
    	private Integer errorCode=999;
    	
    	public REST_Exception(Integer codeError, Id targetObject){
    		errorCode = codeError;
    		setMessage('id '+targetObject+';'+getErrorDescription(errorCode));
    	}
    	
    	public integer getErrorCode(){
    		return errorCode;
    	}
    }
    
    public static testMethod void testHandle(){
        try{
            
            REST_ERROR_CODES.getErrorDescription(101);
            REST_ERROR_CODES.getErrorDescription(102);
            REST_ERROR_CODES.getErrorDescription(103);
            REST_ERROR_CODES.getErrorDescription(104);
            REST_ERROR_CODES.getErrorDescription(105);
            REST_ERROR_CODES.getErrorDescription(106);
            REST_ERROR_CODES.getErrorDescription(200);
            REST_ERROR_CODES.getErrorDescription(201);
            REST_ERROR_CODES.getErrorDescription(202);
            REST_ERROR_CODES.getErrorDescription(998);
            REST_ERROR_CODES.getErrorDescription(999);
            
           
        }catch(Exception e){}
    }
}