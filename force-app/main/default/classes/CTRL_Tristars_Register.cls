Public with sharing class CTRL_Tristars_Register
{
    public Reise__c oReise {get;set;}
    public Teilnehmer__c oTN {get;set;}
    public String sMessage {get;set;}
  
  
    //Constructor
    public CTRL_Tristars_Register ()
    {
        list<Reise__c> lR = [Select Id, Name, Start__c, Ende__c from Reise__c where Registration__c = true];
        if (lR!= null && lR.size() > 0)
        {
            oReise = lR[0];
            oTN = new Teilnehmer__c();
            oTN.Reise__c = oReise.Id;
            sMessage = '';
        }else
        {
            sMessage = 'Keine Reise zur Registrierung gefunden.';
        }  
    }
    
    
    public pagereference noNew()
    {
        oTN = new Teilnehmer__c();
        oTN.Reise__c = oReise.Id;
        return null;
    }
    
    public pagereference doSave()
    {
        try
        {
            insert oTN;
            sMessage = 'Teilnehmer registriert';
        }catch(exception e)
        {
            sMessage = e.getmessage();
        }
        return null;
    }
    
    
    public pagereference doCancel()
    {
        return null;
        
    }
}