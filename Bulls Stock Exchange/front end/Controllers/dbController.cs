using dbconnectivity_C.Models;
using System;
using System.Collections.Generic;
using System.Web.Mvc;

namespace WebApplication1.Controllers
{
    public class dbController : Controller
    {
        // -------------------- USER FUNCTIONALITIES BELOW ------------------------
        public ActionResult bullsinvestor()
        {
            return View();
        }
        public ActionResult logoutperson()
        {
            Session.Abandon();
            return View("signinperson");
        }
        public ActionResult myshares()
        {
            if (Session["email"] != null)
            {
                List<myshares> m = CRUD.myshares(Session["email"].ToString());
                return View(m);
            }
            else
            {
                return View("resultpage");
            }
        }
        public ActionResult buystocks()
        {
            return View();
        }
        
        public ActionResult matchthe()
        {
            return View();
        }
        
        public ActionResult matchthedeal(double r1, double r2, int n1, int n2, int shv1, int shv2)
        {
            List<myshares> m = CRUD.matchthedeal(r1, r2, n1, n2, shv1, shv2);
            return View(m);
        }

        public ActionResult buythedeal()
        {
            return View("bullsinvestor");
        }
        public ActionResult buyprimetime()
        {
            return View();
        }
        public ActionResult brokestocks()
        {
            return View();
        }
        public ActionResult brokerastock()
        {
            return View();
        }
        public ActionResult brokerastocks(String compname,int numberofshares,Double sharevalueoffered)
        {
            if (Session["email"].ToString() != null)
            {
                int result = CRUD.brokerastock(Session["email"].ToString(), compname, numberofshares, sharevalueoffered);
                if(result==1)
                {
                    String data = "Your Stock is broked, Chance of selling is high !";
                    return View("bullsinvestor", (object)data);
                }
                else if (result == 2)
                {
                    String data = "Your Stock is broked, Chance of selling is low !";
                    return View("bullsinvestor", (object)data);
                }
                else if(result==-1)
                {
                    String data = "Invalid Stocks, Kindly check your Shares !";
                    return View("bullsinvestor", (object)data);
                }
                else
                {
                    String data = "System Busy !";
                    return View("bullsinvestor", (object)data);
                }
            }
            else
            {
                return View("resultpage");
            }
        }
        public ActionResult sellprimetime()
        {
            if (Session["email"] != null)
            { 
            List<prime> m = CRUD.sellprimetime();
            return View(m);
            }
            else
            {
                return View("resultpage");
            }
        }
        // --------- investor functionalities above --------- 
        public ActionResult logout()
        {
            Session.Abandon();
            return View("Index");
        }
       // --------- company functionalities below --------- 
        public ActionResult bullscompany()
        {
            return View();
        }
        public ActionResult logoutcompany()
        {
            Session.Abandon();
            return View("companysignin");
        }
        public ActionResult myshareholders()
        {
            if (Session["compname"].ToString() != null)
            {
                List<myshareholderz> m = CRUD.myshareholders(Session["compname"].ToString());
                return View(m);
            }
            else
            {
                return View("resultpage");
            }
        }
        public ActionResult brokeipos()
        {
            if (Session["compname"].ToString() != null)
            {
                int result = CRUD.checksituation(Session["compname"].ToString());
                if (result == -1)
                {
                    return View("notfirstipo");
                }
                else if (result == 1)
                {
                    return View("firstipo");
                }
                else
                {
                    String data = "Server Busy !";
                    return View("bullscompany", (object)data);
                }
            }
            else
            {
                return View("resultpage");
            }
        }
        public ActionResult firstipo()
        {
            return View();   
        }
        public ActionResult firstipos(String companyname, int noofipos, Double priceofipo, Double dividend)
        {
            if (Session["compname"].ToString() != null)
            {
                int result = CRUD.firsteyepos(Session["compname"].ToString(), noofipos, priceofipo, dividend);
                if (result != 0)
                {
                    return View("totaliposshow", (object)result);
                }
                else
                {
                    String data = "Server Busy !";
                    return View("bullscompany", (object)data);
                }
            }
            else
            {
                return View("resultpage");
            }
        }
        public ActionResult notfirstipo()
        {
            return View();
        }
        public ActionResult notfirstipos(int noofipos)
        {
            if (Session["compname"].ToString() != null)
            {
                int result = CRUD.notfirsteyepos(Session["compname"].ToString(), noofipos);
                if (result != 0)
                {
                    return View("totaliposshow", (object)result);
                }
                else
                {
                    String data = "Server Busy !";
                    return View("bullscompany", (object)data);
                }
            }
            else
            {
                return View("resultpage");
            }
        }
        public ActionResult totaliposshow()
        {

            return View();
        }
        // -------------------- FUNCTIONALITIES FOR EVERYONE BELOW ------------------------
        public ActionResult markethappenings()
        {
            List<marketcapitals> m = CRUD.psxmarket();
            return View(m);
        }
        public ActionResult kse30()
        {
            kse30 k = CRUD.calculatekse30();
            return View(k);
        }
        public ActionResult marketcapital()
        {
            List<marketcapitals> m = CRUD.marketcapital();
            return View(m);
        }
        public ActionResult personcapital()
        {
            List<personcapitals> m = CRUD.personcapital();
            return View(m);
        }
        public ActionResult Index()
        {
            return View();
        }
        public ActionResult adminpage()
        {
            return View();
        }
        public ActionResult person()
        {
            return View();
        }
        public ActionResult company()
        {
            return View();
        }
        public ActionResult signupperson()
        {
            return View();
        }
        public ActionResult signinperson()
        {
            return View();
        }
        public ActionResult companysignin()
        {
            return View();
        }
        public ActionResult companysignup()
        {
            return View();
        }
        public ActionResult resultpage()
        {
            return View();
        }
        public ActionResult success()
        {
            return View();
        }
        // ----------- //
        // ----------- //
        // ----------- //
        /* ------------------------ ADMIN VIEWS ------------------------*/
        public ActionResult addbankpage()
        {
            return View();
        }
        public ActionResult addbankp(String bankname)
        {
            if ((bankname.Length) <= 50)
            {
                int result = CRUD.addbank(bankname);
                if (result == 0)
                {
                    String data = "Server Busy !";
                    return View("addbankpage", (object)data);
                }
                else if(result==-1)
                {
                    String data = "Bank Already Exists !";
                    return View("addbankpage", (object)data);
                }
                else
                {
                    return RedirectToAction("success");
                }
            }
            else
            {
                String data = "Invalid Bankname !";
                return View("addbankpage", (object)data);
            }
        }
        public ActionResult addbankaccount()
        {
            return View();
        }
        public ActionResult addbankacc(String cnic, String bankname, Double balance)
        {
            if (cnic.Length == 15)
            {
                if ((bankname.Length) <= 50)
                {
                    if (balance > 0)
                    {
                        int result = CRUD.addbankaccount(cnic, bankname, balance);
                        if (result == 0)
                        {
                            String data = "Server Busy !";
                            return View("addbankaccount", (object)data);
                        }
                        else if (result == -1)
                        {
                            String data = "Bank doesnot Exists !";
                            return View("addbankaccount", (object)data);
                        }
                        else if(result==-2)
                        {
                            String data = "Multiple Accounts not allowed !";
                            return View("addbankaccount", (object)data);
                        }
                        else
                        {
                            return RedirectToAction("success");
                        }
                    }
                    {
                        String data = "Invalid Balance !";
                        return View("addbankaccount", (object)data);
                    }
                }
                else
                {
                    String data = "Invalid Bankname !";
                    return View("addbankaccount", (object)data);
                }
            }
            else
            {
                String data = "Invalid CNIC !";
                return View("addbankaccount", (object)data);
            }
        }
        public ActionResult bankoptions()
        {
            return View();
        }
        public ActionResult psxpage()
        {
            return View();
        }
        public ActionResult psxoptions()
        {
            return View();
        }
        public ActionResult CheckPersonDeal()
        {
            return View();
        }
        //
        public ActionResult addpsxcompany()
        {
            return View();
        }
        public ActionResult addpsxcomp(String compname, String compgenre, Double faceval, Double dividend, String totalshares)
        {
            if ((compname.Length) <= 100)
            {
                int val = 0;
                Int32.TryParse(totalshares, out val);
                if (val >= 0)
                {
                   /* double val1 = 0;
                    Double.TryParse(faceval, out val1);*/
                    if (faceval > 0)
                    {
                       /* double tmp = 0;
                        Double.TryParse(dividend, out tmp);*/
                        if (dividend >= 0)
                        {
                            int result = CRUD.addpsxcompany(compname,compgenre,faceval,dividend,totalshares);
                            if (result == 0)
                            {
                                String data = "Server Busy !";
                                return View("addpsxcompany", (object)data);
                            }
                            else
                            {
                                return RedirectToAction("success");
                            }
                        }
                        else
                        {
                            String data = "Invalid dividend amount !";
                            return View("addpsxcompany", (object)data);
                        }
                    }
                    else
                    {
                        String data = "Invalid facevalue amount !";
                        return View("addpsxcompany", (object)data);
                    }
                }
                else
                {
                    String data = "Invalid no. of shares !";
                    return View("addpsxcompany", (object)data);
                }
            }
            else
            {
                String data = "Invalid Company Name";
                return View("addpsxcompany", (object)data);
            }
        }
        //
        public ActionResult addpsxperson()
        {
            return View();
        }
        public ActionResult addpsxper(string pcnic, string pername)
        {
            if ((pcnic.Length) == 15)
            {
                if (pername.Length <= 50)
                {
                    int result = CRUD.addpsxperson(pcnic, pername);
                    if (result == 0)
                    {
                        String data = "Server Busy !";
                        return View("addpsxperson", (object)data);
                    }
                    else if (result == -1)
                    {
                        String data = "Account already exist !";
                        return View("addpsxperson", (object)data);
                    }
                    else
                    {
                        return RedirectToAction("success");
                    }
                }
                else
                {
                    String data = "Invalid Name !";
                    return View("addpsxperson", (object)data);
                }
            }
            else
            {
                String data = "Invalid cnic";
                return View("addpsxperson", (object)data);
            }
        }
        //
        public ActionResult addpsxbroker()
        {
            return View();
        }
        public ActionResult addpsxbrok(string brokname,string cnicbroker)
        {
            if ((cnicbroker.Length) == 15)
            {
                if (brokname.Length <= 50)
                {
                    int result = CRUD.addpsxbroker(brokname, cnicbroker);
                    if (result == 0)
                    {
                        String data = "Server Busy !";
                        return View("addpsxbroker", (object)data);
                    }
                    else if (result == -1)
                    {
                        String data = "Broker already exists !";
                        return View("addpsxbroker", (object)data);
                    }
                    else
                    {
                        return RedirectToAction("success");
                    }
                }
                else
                {
                    String data = "Invalid Broker Name !";
                    return View("addpsxbroker", (object)data);
                }
            }
            else
            {
                String data = "Invalid cnic";
                return View("addpsxbroker", (object)data);
            }
        }
        //
        public ActionResult addpsxrecord()
        {
            return View();
        }

        public ActionResult addpsxrec(String psxaccno, String noofstocks, String compname, String priceofshare)
        {
            if ((compname.Length)<= 100)
            {
                int val = 0;
                Int32.TryParse(psxaccno, out val);
                if (val > 0)
                {
                    val = 0;
                    Int32.TryParse(noofstocks,out val);
                    if (val > 0)
                    {
                        double tmp = 0;
                        Double.TryParse(priceofshare,out tmp);
                        if (tmp > 0)
                        {
                            int result = CRUD.addpsxrecord(psxaccno, noofstocks, compname,priceofshare);
                            if (result == 0)
                            {
                                String data = "Server Busy !";
                                return View("addpsxrecord", (object)data);
                            }
                            else if (result == -1)
                            {
                                String data = "Company or no. of Stocks doesnot exist !";
                                return View("addpsxrecord", (object)data);
                            }
                            else if (result == -2)
                            {
                                String data = "Account doesnot exist !";
                                return View("addpsxrecord", (object)data);
                            }
                            else
                            {
                                return RedirectToAction("success");
                            }
                        }
                        else
                        {
                            String data = "Invalid price of share !";
                            return View("addpsxrecord", (object)data);
                        }
                    }
                    else
                    {
                        String data = "Invalid no. of stocks !";
                        return View("addpsxrecord", (object)data);
                    }
                }
                else
                {
                    String data = "Invalid psx acc. no. !";
                    return View("addpsxrecord", (object)data);
                }
            }
            else
            {
                String data = "Invalid Company Name";
                return View("addpsxrecord", (object)data);
            }
        }
        //
        public ActionResult updatepsxmarket()
        {
            return View();
        }
        public ActionResult updatepsxmark(string regno,string msvom)
        {
            int val = 0;
            Int32.TryParse(regno,out val);
            if (val>=0)
            {
                val = 0;
                Int32.TryParse(msvom, out val);
                if (val > 0)
                {
                    int result = CRUD.updatepsxmarket(regno, msvom);
                    if (result == 0)
                    {
                        String data = "Server Busy !";
                        return View("updatepsxmarket", (object)data);
                    }
                    else if (result == -1)
                    {
                        String data = "Company doesnot exist !";
                        return View("updatepsxmarket", (object)data);
                    }
                    else
                    {
                        return RedirectToAction("success");
                    }
                }
                else
                {
                    String data = "Invalid msvom !";
                    return View("updatepsxmarket", (object)data);
                }
            }
            else
            {
                String data = "Invalid Registration No.";
                return View("updatepsxmarket", (object)data);
            }
        }
        //
        public ActionResult CheckPersonDealsubmit(String regnobroker, String cnicp, String bankname, String compname, String sharevalue, String noofshares)
        {

            int val = 0;
            Int32.TryParse(regnobroker, out val);
            if (val > 0)
            {
                if (cnicp.Length == 15)
                {
                    if (bankname.Length <= 50)
                    {
                        if (compname.Length <= 100)
                        {
                            val = 0;
                            Int32.TryParse(sharevalue, out val);
                            if (val > 0)
                            {
                                val = 0;
                                Int32.TryParse(noofshares, out val);
                                if (val > 0)
                                {
                                    int result = CRUD.dealperson(regnobroker, cnicp, bankname, compname, sharevalue, noofshares);
                                    if (result == 0)
                                    {
                                        String data = "Server Busy, Try Again !";
                                        return View("CheckPersonDeal", (object)data);
                                    }
                                    if (result == -1)// broker issue
                                    {
                                        String data = "Incorrect Broker Details !";
                                        return View("CheckPersonDeal", (object)data);
                                    }
                                    else if(result==-2)// psx reg issue	
                                    {
                                        String data = "Incorrect psx Credentials !";
                                        return View("CheckPersonDeal", (object)data);
                                    }
                                    else if (result == -3)//stocks doesn't exist
                                    {
                                        String data = "Incorrect Stocks Details !";
                                        return View("CheckPersonDeal", (object)data);
                                    }
                                    else if (result == -4)//bank credentials issue
                                    {
                                        String data = "Incorrect Bank Details !";
                                        return View("CheckPersonDeal", (object)data);
                                    }
                                    else
                                    {
                                        Session["broker"] = regnobroker;
                                        return RedirectToAction("resultpage");
                                    }
                                }
                                else
                                {
                                    // no. of shares issue
                                    String data = "Invalid no. of shares !";
                                    return View("CheckPersonDeal", (object)data);
                                }
                            }
                            else
                            {
                                // share value issue
                                String data = "Invalid Share Value !";
                                return View("CheckPersonDeal", (object)data);
                            }
                        }
                        else
                        {
                            //company name issue
                            String data = "Invalid Company Name !";
                            return View("CheckPersonDeal", (object)data);
                        }
                    }
                    else
                    {
                        //bankname issue
                        String data = "Invalid Bankname !";
                        return View("CheckPersonDeal", (object)data);
                    }
                }
                else
                {
                    // cnic issue
                    String data = "Invalid cnic !";
                    return View("CheckPersonDeal", (object)data);
                }
            }
            else
            {
                // broker issue
                String data = "Invalid Broker !";
                return View("CheckPersonDeal", (object)data);
            }
        }
        public ActionResult CheckCompanyDeal()
        {
            return View();
        }
        public ActionResult CheckCompanyDealsubmit(String regnobroker, String compregno, String compname, String cnicbank, String bankname, String nipostosell)
        {
            int val = 0;
            Int32.TryParse(compregno,out val);
            if (val>=0)
            {
                val = 0;
                Int32.TryParse(regnobroker, out val);
                if (val > 0)
                {
                    if (compname.Length <= 100)
                    {
                        if (cnicbank.Length <= 15)
                        {
                            if (bankname.Length <= 50)
                            {
                                val = 0;
                                Int32.TryParse(regnobroker, out val);
                                if (val>0)
                                {
                                    int result = CRUD.dealcompany(regnobroker, compregno, compname, cnicbank, bankname, nipostosell);
                                    if(result==0)
                                    {
                                        String data = "Server Busy, Try Again !";
                                        return View("CheckCompanyDeal", (object)data);
                                    }
                                    if (result == -1)
                                    {
                                        String data = "Broker not Registered !";
                                        return View("CheckCompanyDeal", (object)data);
                                    }
                                    else if (result == -2)
                                    {
                                        String data = "Incorrect psx credentials !";
                                        return View("CheckCompanyDeal", (object)data);
                                    }
                                    else if (result == -3)
                                    {
                                        String data = "Incorrect bank credentials !";
                                        return View("CheckCompanyDeal", (object)data);
                                    }
                                    else
                                    {
                                        Session["broker"] = regnobroker;
                                        return RedirectToAction("resultpage");
                                    }
                                }
                                else
                                {
                                    String data = "Invalid no. of ipos !";
                                    return View("CheckCompanyDeal", (object)data);
                                }
                            }
                            else
                            {
                                String data = "Invalid bank name !";
                                return View("CheckCompanyDeal", (object)data);
                            }
                        }
                        else
                        {
                            String data = "Invalid cnic !";
                            return View("CheckCompanyDeal", (object)data);
                        }
                    }
                    else
                    {
                        String data = "Invalid company name !";
                        return View("CheckCompanyDeal", (object)data);
                    }
                }
                else
                {
                    String data = "Invalid registration no. broker";
                    return View("CheckCompanyDeal", (object)data);
                }
            }
            else
            {
                String data = "Incorrect psx registration no. !";
                return View("CheckCompanyDeal", (object)data);
            }
        }
        public ActionResult dealselection()
        {
            return View();
        }
        // ----------------------------------- AUTHENTICATIONS BELOW ----------------------------------------
        /*ADMIN VIEWS*/
        //static page
        /* [HttpGet]*/
        public ActionResult authenticateadmin()
        {
            return View();
        }
        /*  [HttpPost]*/
        public ActionResult authenticateadmine(String pass)
        {
            if ((pass.Length)==8)
            {
                int result = CRUD.adminverify(pass);
                if (result == -1)
                {
                    String data = "Incorrect Password";
                    return View("authenticateadmin", (object)data);
                }
                Session["password"] = pass;
                return RedirectToAction("adminpage");
            }
            else
            {
                String data = "Invalid Password";
                return View("authenticateadmin", (object)data);
            }
        }
        public ActionResult authenticatecompany(String companyname, String bankaccno)
        {
            int val = 0;
            Int32.TryParse(bankaccno, out val);
            if (val > 0)
            {
                if ((companyname.Length) <= 100)
                {
                    int result = CRUD.companysignin(companyname, bankaccno);
                    if (result == -1)
                    {
                        String data = "Sign-Up Required OR Incorrect Company Details";
                        return View("companysignin", (object)data);
                    }

                    Session["compname"] = companyname;
                    return RedirectToAction("bullscompany");
                }
                else
                {
                    String data = "Invalid Company Name";
                    return View("companysignin", (object)data);
                }
            }
            else
            {
                String data = "Invalid Bank account no.";
                return View("companysignin", (object)data);
            }
        }
        public ActionResult authenticateperson(String emailperson, String pass)
        {
            if ((emailperson.Length) <= 75)
            {
                    int result = CRUD.personsignin(emailperson, pass);
                    if (result == -1)
                    {
                        String data = "Incorrect Password";
                        return View("signinperson", (object)data);
                    }
                    else if (result != 1)
                    {
                        String data = "Sign Up Required or Incorrect Email";
                        return View("signinperson", (object)data);
                    }
                    Session["email"] = emailperson;
                    return RedirectToAction("bullsinvestor");
            }
            else
            {
                String data = "Invalid Email";
                return View("signinperson", (object)data);
            }
        } 
        public ActionResult addcompany(String compname, String compgenre, String psxregno, String iposleft,String cnicbank, String bankaccno, String bankname)
        {
            if (compname.Length <= 100)
            {
              
                int val = 0;
                Int32.TryParse(bankaccno, out val);
                if (val > 0)
                {
                    int vval = 0;
                    Int32.TryParse(psxregno, out vval);
                    if( val >= 0 )
                    {
                        val = 0;
                        Int32.TryParse(iposleft, out val);
                        if (val >= 0)
                        {
                            if ((val == 0 && vval == 0) || (val > 0 && vval > 0))
                            {
                                int result = CRUD.addingcompany(compname, compgenre, psxregno, iposleft, cnicbank, bankaccno, bankname);
                                if (result == 2)
                                {
                                    String data = "Incorrect Bank Details";
                                    return View("companysignup", (object)data);
                                }
                                else if (result == 3)
                                {
                                    String data = "Incorrect Psx Credentials";
                                    return View("companysignup", (object)data);
                                }
                                else if (result == -1)
                                {
                                    String data = "Incorrect Credentials";
                                    return View("companysignup", (object)data);
                                }
                                else if (result == -2)
                                {
                                    String data = "Company Already Exists, Sign in !";
                                    return View("companysignup", (object)data);
                                }
                                else
                                {
                                    Session["compname"] = compname;
                                    return RedirectToAction("bullscompany");
                                }
                            }
                            else
                            {
                                String data = "Invalid ipos or psxregno!";
                                return View("companysignup", (object)data);
                            }
                        }
                        else
                        {
                            String data = "Invalid ipos!";
                            return View("companysignup", (object)data);
                        }
                    }
                    else
                    {
                        String data = "PSX Account no. Invalid";
                        return View("companysignup", (object)data);
                    }
                }
                else
                {
                    String data = "Bank Account no. Invalid";
                    return View("companysignup", (object)data);
                }
            }
            else
            {
                String data = "Company Name Invalid";
                return View("companysignup", (object)data);
            }
        }
        public ActionResult addperson(String nameperson, String bdate, String cnic, String country, String email, String pass, String bankaccno, String bankname, String psxaccno)
        {
            if (nameperson.Length <= 50)
            {
                if (pass.Length == 8)
                {
                    if (cnic.Length == 15)
                    {
                        if (country.Length <= 25)
                        {
                            int val = 0;
                            Int32.TryParse(bankaccno, out val);
                            if (val > 0 && bankname.Length <= 50)
                            {
                                val = 0;
                                Int32.TryParse(psxaccno, out val);
                                if (val == 0 || val > 0)
                                {
                                    int result = CRUD.addingperson(nameperson, bdate, cnic, country, email, pass, bankaccno, bankname, psxaccno);
                                    if (result == 2)
                                    {
                                        //String data = "Cnic already taken";
                                        // EXCLUDED THE ABOVE STATMENT AS PER SECURITY
                                        String data = "Invalid CNIC";
                                        return View("signupperson", (object)data);
                                    }
                                    else if (result == 3)
                                    {
                                        //String data = "Use another Email/sign In";
                                        // EXCLUDED THE ABOVE STATMENT AS PER SECURITY
                                        String data = "Invalid Email";
                                        return View("signupperson", (object)data);
                                    }
                                    else if (result == 4)
                                    {
                                        String data = "Invalid Bank Credentials";
                                        return View("signupperson", (object)data);
                                    }
                                    else if (result == 5)
                                    {
                                        String data = "Invalid Psx Credentials";
                                        return View("signupperson", (object)data);
                                    }
                                    else if (result == 1)
                                    { 
                                        Session["email"] = email;
                                        return RedirectToAction("bullsinvestor");
                                    }
                                    else
                                    {
                                        String data = "Invalid Information Provided";
                                        return View("signupperson", (object)data);
                                    }
                                }
                                else
                                {
                                    String data = "Invalid PSX Information";
                                    return View("signupperson", (object)data);
                                }
                            }
                            else
                            {
                                String data = "Invalid Bank Details";
                                return View("signupperson", (object)data);
                            }
                        }
                        else
                        {
                            String data = "Country Name too long !";
                            return View("signupperson", (object)data);
                        }
                    }
                    else
                    {
                        String data = "CNIC Invalid";
                        return View("signupperson", (object)data);
                    }
                }
                else
                {
                    String data = "Invalid Password";
                    return View("signupperson", (object)data);
                }
            }
            else
            {
                String data = "Name too long !";
                return View("signupperson", (object)data);
            }
        }
    }
}