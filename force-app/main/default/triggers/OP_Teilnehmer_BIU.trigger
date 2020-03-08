trigger OP_Teilnehmer_BIU on OP_Teilnehmer__c (before insert, before update) 
{
    map<String,String> mTN = new map<String,String>();
    map<String,String> mOP = new map<String,String>();
    for (Organisationspunkt__c oP:[Select Id, Name from Organisationspunkt__c])
    {
        mOP.put(oP.Id, oP.Name);
    }
    for (Teilnehmer__c oTN: [Select Id, Name from Teilnehmer__c])
    {
        mTN.put(oTN.Id, oTN.Name);
    }

    for (OP_Teilnehmer__c oPT:trigger.new)
    {
        oPT.Name = 'KV: ' + mOP.get(oPT.Organisationspunkt__c) + ' - ' + mTN.get(oPT.Teilnehmer__c);    
    }
}