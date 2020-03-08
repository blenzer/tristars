trigger organisationspunkt_AIU on Organisationspunkt__c (after insert, after update) 
{    
    static Boolean hasrun = false;
    if (trigger.isupdate)
    {        
        if (!hasrun)
        {
            hasrun = true;
            map<String,Integer> mTNCount = new map<String,Integer>();
            map<String,list<OP_Teilnehmer__c>> mOPT = new map<String,list<OP_Teilnehmer__c>>();
            list<OP_Teilnehmer__c> lOPTUpdate = new list<OP_Teilnehmer__c>();
            
            for (OP_Teilnehmer__c oPT:[Select Id, Organisationspunkt__c from OP_Teilnehmer__c where Organisationspunkt__c in: trigger.new])
            {
                Integer nTemp = 0;
                if (mTNCount.get(oPT.Organisationspunkt__c) != null)
                {
                    nTemp  = mTNCount.get(oPT.Organisationspunkt__c);
                }
                nTemp ++;
                mTNCount.put(oPT.Organisationspunkt__c,nTemp);
                
                list<OP_Teilnehmer__c> lTemp = new list<OP_Teilnehmer__c>();
                if (mOPT.get(oPT.Organisationspunkt__c) != null)
                {
                    lTemp = mOPT.get(oPT.Organisationspunkt__c);
                }
                lTemp.add(oPT);
                mOPT.put(oPT.Organisationspunkt__c, lTemp);
            }
            
            for (Organisationspunkt__c oP:trigger.new)
            {
                if (oP.Distribute__c)
                {
                    if (mTNCount.get(oP.Id) != null && mTNCount.get(oP.Id) > 0)
                    {
                        Decimal nPlan = 0;
                        if (oP.Plankosten__c != null)
                        {
                            nPlan = oP.Plankosten__c / mTNCount.get(oP.Id);
                        }
                        Decimal nIst = 0;
                        if (oP.Istkosten__c != null)
                        {
                            nIst =  oP.Istkosten__c / mTNCount.get(oP.Id); 
                        }
                        for (OP_Teilnehmer__c oPT: mOPT.get(oP.Id))
                        {
                            oPT.Anteilige_Istkosten__c = nIst;
                            oPT.Anteilige_Plankosten__c = nPlan;
                            lOPTUpdate.add(oPT);
                        }   
                    }   
                }else
                {
                    if (mOPT != null && mOPT.size() > 0)
                    {
                        for (OP_Teilnehmer__c oPT: mOPT.get(oP.Id))
                        {
                            oPT.Anteilige_Istkosten__c = 0;
                            oPT.Anteilige_Plankosten__c = 0;
                            lOPTUpdate.add(oPT);
                        }     
                    }
                }
            }
            if (lOPTUpdate.size() > 0)
            {
                database.update(lOPTUpdate, false);
            }
        }
    }
    
    
    list<String> lsOP = new list<String>();
    for (Organisationspunkt__c oP:trigger.new)
    {
        if (oP.TN_automatisch_zuordnen__c && (trigger.isinsert || (trigger.isupdate && trigger.oldmap.get(oP.Id).TN_automatisch_zuordnen__c == false)))
        {
            lsOP.add(oP.Id);            
        }
    }
    
    if (lsOP.size() > 0)
    {
        Teilnehmer_Utilities.doDistributeTN(lsOP, null);
    }
}