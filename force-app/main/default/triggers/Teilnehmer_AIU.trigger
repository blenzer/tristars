trigger Teilnehmer_AIU on Teilnehmer__c (after insert, after update) 
{

    list<String> lsT = new list<String>();
    for (Teilnehmer__c oT:trigger.new)
    {
        if (oT.TN_automatisch_zuordnen__c 
        && oT.Status__c == 'Bestätigt'
        && (trigger.isinsert 
        || (trigger.isupdate && (trigger.oldmap.get(oT.Id).TN_automatisch_zuordnen__c == false
        || trigger.oldmap.get(oT.Id).Status__c != 'Bestätigt'))))
        {
            lsT.add(oT.Id);            
        }
    }
    
    if (lsT.size() > 0)
    {
        Teilnehmer_Utilities.doDistributeTN(null, lsT);
    }

}