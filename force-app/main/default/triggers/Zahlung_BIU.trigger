trigger Zahlung_BIU on Zahlung__c (before insert, before update) 
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

    for (Zahlung__c oZ:trigger.new)
    {
        oZ.Name = 'Z: ' + mOP.get(oZ.Organisationspunkt__c) + ' - ' + mTN.get(oZ.Teilnehmer__c);    
    }
}