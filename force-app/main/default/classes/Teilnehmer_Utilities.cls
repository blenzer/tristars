global without sharing class Teilnehmer_Utilities
{

    webservice static void doDistributeTN(list<String> lsOP, list<String> lsT)
    {
        set<String> sExisting = new set<String>();
        String sSOQLOPT = 'Select Id, Organisationspunkt__c, Teilnehmer__c from OP_Teilnehmer__c WHERE Id != null ';
        if (lsT != null && lsT.size() > 0)
        {
            sSOQLOPT = sSOQLOPT + ' AND Teilnehmer__c in: lsT ';
        }
        if (lsOP!= null && lsOP.size() > 0)
        {
            sSOQLOPT = sSOQLOPT + ' AND Organisationspunkt__c in: lsOP';
        }
        for (OP_teilnehmer__c oPT: database.query(sSOQLOPT))
        {
            sExisting.add(oPT.Organisationspunkt__c + '|' + oPT.Teilnehmer__c);
        }
        
        String sSOQLOP = 'Select Id, TN_automatisch_zuordnen__c, reise__c from Organisationspunkt__c where TN_automatisch_zuordnen__c = true ';
        if (lsOP!= null && lsOP.size() > 0)
        {
            sSOQLOP = sSOQLOP + ' AND Id in: lsOP';
        }
        list<Organisationspunkt__c> lOP = database.query(sSOQLOP);
        
        STring sSOQLT = 'Select Id, Reise__c from Teilnehmer__c where TN_automatisch_zuordnen__c = true ';
        if (lsT != null && lsT.size() > 0)
        {
            sSOQLT = sSOQLT + ' AND Id in: lsT';
        }
        list<Teilnehmer__c> lT = database.query(sSOQLT);
        
        map<String, list<Teilnehmer__c>> mT = new map<String,list<Teilnehmer__c>>();
        for (Teilnehmer__c oT : lT)
        {
            list<Teilnehmer__c> lTemp = new list<Teilnehmer__c>();
            if (mT.get(oT.Reise__c) != null)
            {
                lTemp = mT.get(oT.Reise__c);
            }
            lTemp.add(oT);
            mT.put(oT.Reise__c, lTemp);        
        }
        
        list<OP_Teilnehmer__c> lOTInsert = new list<OP_Teilnehmer__c>();
        for (Organisationspunkt__c oP:lOP)
        {
            if (oP.TN_automatisch_zuordnen__c && mT.get(oP.Reise__c) != null)
            {
                for (Teilnehmer__c oT: mT.get(oP.Reise__c))
                {
                    String sCheck = oP.Id + '|' + oT.Id;
                    if (!sExisting.contains(sCheck))
                    {
                        OP_Teilnehmer__c oPT = new OP_Teilnehmer__c();
                        oPT.Organisationspunkt__c = oP.Id;
                        oPT.Teilnehmer__c = oT.Id;
                        lOTInsert.add(oPT);
                    }
                }
                
            }
        }
        
        if (lOTInsert.size() > 0)
        {
            database.insert(lOTInsert, false);
        }
    }

}