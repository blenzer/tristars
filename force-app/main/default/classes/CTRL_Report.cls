Public with sharing class CTRL_Report
{
    public list<Teilnehmer__c> lTN {get;set;}
    public map<String,list<OP_Teilnehmer__c>> mCost {get;set;}
    public map<String,list<Zahlung__c>> mPay {get;set;}
    
    /*public class cReport
    {
        public Teilnehmer__c oTN {get;set;}
        public list<OP_Teilnehmer__c> lCost {get;set;}
        public list<Zahlung__c> lPay {get;set;}    
        public cReport()
        {
        }
    }
    
    public list<cReport> lReport {get;set;}
    */
  
    public CTRL_Report()
    {
        mCost = new map<String,list<OP_Teilnehmer__c>>();
        mPay = new map<String,list<Zahlung__c>>();
        lTN = [select Id, Name, Anzahlungsbetrag__c, Istkosten_Gesamt__c, Zahlungen_Gesamt__c, Vorschuss_gesamt__c, Saldo__c 
                                          from Teilnehmer__c 
                                          where Status__c = 'Bezahlt'
                                          order by Name];
        for (Teilnehmer__c oTN:lTN)
        {
            mCost.put(oTN.Id, new list<OP_Teilnehmer__c>()); 
            mPay.put(oTN.Id, new list<Zahlung__c>());     
        }
                                          
                                          
        for (OP_Teilnehmer__c oCost : [Select Id, Organisationspunkt__r.Name, Istkosten_Gesamt__c, Teilnehmer__c from OP_Teilnehmer__c order by Teilnehmer__c , Organisationspunkt__r.Name])
        {
            list<OP_Teilnehmer__c> lTemp = new list<OP_Teilnehmer__c>();
            if (mCost.get(oCost.Teilnehmer__c) != null)
            {
                lTemp = mCost.get(oCost.Teilnehmer__c);
            }
            lTemp.add(oCost);
            mCost.put(oCost.Teilnehmer__c,lTemp);
        }
        
        
        
        for (Zahlung__c oPay : [Select Id, Organisationspunkt__r.Name, Zahlbetrag__c, Vorschuss__c, Teilnehmer__c from Zahlung__c order by Teilnehmer__c , Organisationspunkt__r.Name])
        {
            list<Zahlung__c> lTemp = new list<Zahlung__c>();
            if (mPay.get(oPay.Teilnehmer__c) != null)
            {
                lTemp = mPay.get(oPay.Teilnehmer__c);
            }
            lTemp.add(oPay);
            mPay.put(oPay.Teilnehmer__c,lTemp);
        }       
    }
}