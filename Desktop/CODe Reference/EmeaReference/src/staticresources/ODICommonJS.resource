function fnOpenSubtab(id,name) {
    recordId = id;
    recordName = name;
    if (sforce.console.isInConsole()){
        sforce.console.getEnclosingPrimaryTabId(openSubtab);
    }else{
        window.open('/' + id,'_blank');
    }
}
var openSubtab = function openSubtab(result) {
    //Now that we have the primary tab ID, we can open a new subtab in it
    var primaryTabId = result.id;
    sforce.console.openSubtab(primaryTabId,'/'+recordId,true,recordName,null,'salesforceSubtab'); 
}; 
function switchMenu(obj,obj1,obj2) {
    var el = document.getElementById(obj);
    if (el.style.display != 'none') {
        el.style.display = 'none';
    }else{
        el.style.display = '';
    }
    var e2 = document.getElementById(obj1);
    if (e2.style.display != 'none') {
        e2.style.display = 'none';
    }else{
        e2.style.display = '';
    }
    var e3 = document.getElementById(obj2);
    if(e3.style.display != 'none') {
        e3.style.display = 'none';
    }else{
        e3.style.display = '';
    }
}