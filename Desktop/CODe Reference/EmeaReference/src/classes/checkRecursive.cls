/*
Class name  - checkRecursive
Description-  Helper class  to avoid recursion
Created By - Accenture IDC
*/
public Class checkRecursive{
    private static boolean run=true;
    private static boolean run1 = true;
    private static boolean run2 = true;
    private static boolean run3 = true;
    public static boolean run4 = true;
    public static boolean run5 = true;
    private static boolean runBefore = true;
    public static boolean runOnce(){
    if(run){
     run=false;
     return true;
    }else{
        return run;
    }
    }
   /* public static boolean runOnceBefore(){
    if(runBefore ){
     runBefore =false;
     return true;
    }
    else{
        return runBefore ;
    }
}*/

  public static boolean runOnce1(){
    if(run1 ){
     run1 =false;
     return true;
    }
    else{
        return run1 ;
    }
}
public static boolean runOnce2(){
    if(run2 ){
     run2 =false;
     return true;
    }
    else{
        return run2 ;
    }
}
public static boolean runOnce3(){
    if(run3 ){
     run3 =false;
     return true;
    }
    else{
        return run3 ;
    }
}
}