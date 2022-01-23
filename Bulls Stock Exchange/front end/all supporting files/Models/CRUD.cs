using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using System.Collections;
using System.IO;

namespace dbconnectivity_C.Models
{
    public class kse30
    {
        public Double today { get; set; }
        public Double previousday { get; set; }
        public Double currentmonth { get; set; }
        public String comparison { get; set; }
    }
    public class marketcapitals
    {
        public Double amountofshareinmarket { get; set; } //no of stocks * max price of share
        public String compgenre { get; set; }
        public String compname { get; set; }
    }
    public class personcapitals
    {
        public Double amountofshareinmarket { get; set; } //no of stocks * max price of share
        public String pname { get; set; }

    }
    public class myshareholderz
    {
        public String pname { get; set; }
        public int noofstocks { get; set; }
    }
    public class myshares
    {
        public int noofstocks { get; set; }
        public String compname { get; set; }
        public double priceoshare { get; set; }
    }
    public class prime
    {
        public String compname { get; set; }
        public Double faceval { get; set; }
    }
    public class CRUD
    {
        public static string connectionString = @"Data Source=DESKTOP-NJ6QH8N;Initial Catalog=stockexchange;Integrated Security=True";

        // -------------------------------------------------person --------------------------------------------
        public static List<myshares> matchthedeal(double r1 , double r2 , int n1 , int n2 , int shv1 , int shv2 )
        {

            List<myshares> mm = new List<myshares>();
            SqlDataReader reader = null;
            String queryString = "SELECT stocksellercomp.nipostosell,stocksellercomp.compname,stocksellercomp.facevalue FROM stocksellercomp WHERE(((stocksellercomp.facevalue >= "+shv1+") and(stocksellercomp.facevalue <= "+shv2+")) and((stocksellercomp.nipostosell >= "+n1+") and("+n2+" >= stocksellercomp.nipostosell)) and((stocksellercomp.dividend >="+ r1+") and(stocksellercomp.dividend >= "+r2+")))";

        SqlConnection con = new SqlConnection(connectionString);
        SqlCommand cmd = new SqlCommand(queryString, con);
            try
            {
                con.Open();
                reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    int noofstocks = (int)reader["nipostosell"];
                    string compname = (string)reader["compname"];
                    double priceofshare = Convert.ToDouble(reader["facevalue"]);
                    myshares k = new myshares();
                    k.noofstocks = noofstocks;
                    k.compname = compname;
                    k.priceoshare = priceofshare;
                    mm.Add(k);
                }
            }
            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
                return null;
            }


            queryString = "SELECT buybrokercomp.nipostosell,buybrokercomp.compname,psxcompany.faceval FROM buybrokercomp inner join psxcompany on buybrokercomp.compregno = psxcompany.regno  WHERE((psxcompany.faceval >="+ shv1+") and (psxcompany.faceval <="+shv2+") and(buybrokercomp.nipostosell >="+ n1+") and (buybrokercomp.nipostosell >="+ n2+") and(psxcompany.dividend >= "+r1+") and (psxcompany.dividend >= "+r2+") ) ";
            con = new SqlConnection(connectionString);
            cmd = new SqlCommand(queryString, con);
            try
            {
                con.Open();
                while (reader.Read())
                {
                    int noofstocks = (int)reader["nipostosell"];
                    string compname = (string)reader["compname"];
                    double priceofshare = Convert.ToDouble(reader["faceval"]);
                    myshares k = new myshares();
                    k.noofstocks = noofstocks;
                    k.compname = compname;
                    k.priceoshare = priceofshare;
                    mm.Add(k);
                }
            }
            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
                return null;
            }


            queryString = "SELECT stockseller.sharevoffr,stockseller.nstockstosell,psxcompany.compname FROM stockseller inner join psxcompany on stockseller.compname = psxcompany.compname WHERE((stockseller.sharevoffr >= "+shv1+") and (stockseller.sharevoffr <= "+shv2+") and(stockseller.nstockstosell >= "+n1+") and (stockseller.nstockstosell >="+ n2+") and(psxcompany.dividend >="+ r1+") and (psxcompany.dividend >= "+r2+") )";
            con = new SqlConnection(connectionString);
            cmd = new SqlCommand(queryString, con);
            try
            {
                con.Open();
                while (reader.Read())
                {
                    int noofstocks = (int)reader["nstockstosell"];
                    string compname = (string)reader["compname"];
                    double priceofshare = Convert.ToDouble(reader["sharevoffr"]);
                    myshares k = new myshares();
                    k.noofstocks = noofstocks;
                    k.compname = compname;
                    k.priceoshare = priceofshare;
                    mm.Add(k);
                }
            }
            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
                return null;
            }
            queryString = "SELECT buybrokerperson.compname,buybrokerperson.sharevalue,buybrokerperson.noofshares  FROM buybrokerperson inner join psxcompany on psxcompany.compname = buybrokerperson.compname WHERE((buybrokerperson.sharevalue >="+ shv1+") and (buybrokerperson.sharevalue <= "+shv2+") and(buybrokerperson.noofshares >= "+n1+") and (buybrokerperson.noofshares >= "+n2+") and(psxcompany.dividend >= "+r1+") and (psxcompany.dividend >= "+r2+") )";
           con = new SqlConnection(connectionString);
            cmd = new SqlCommand(queryString, con);
            try
            {
                con.Open();
                while (reader.Read())
                {
                    int noofstocks = (int)reader["noofshares"];
                    string compname = (string)reader["compname"];
                    double priceofshare = Convert.ToDouble(reader["sharevalue"]);
                    myshares k = new myshares();
                    k.noofstocks = noofstocks;
                    k.compname = compname;
                    k.priceoshare = priceofshare;
                    mm.Add(k);
                }
            }
            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
                return null;
            }
            return mm;
        }
        public static List<prime> sellprimetime()
        {

            List<prime> mm = new List<prime>();
            SqlDataReader reader = null;
            String queryString = "select distinct pr.compname, pc.faceval from psxrecord as pr inner join psxcompany as pc on pr.compname = pc.compname join psxmarket as pm on pc.regno = pm.regno where pr.priceofshare < pm.msvom";
            SqlConnection con = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand(queryString, con);
            try
            {
                con.Open();
                reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    string compname = (string)reader["compname"];
                    double faceval = Convert.ToDouble(reader["faceval"]);
                    prime k = new prime();
                    k.faceval = faceval;
                    k.compname = compname;
                    mm.Add(k);
                }
            }
            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
                return null;
            }
            finally
            {
                con.Close();
            }
            return mm;

        }

        public static List<myshares> myshares(String email)
        {

            List<myshares> mm = new List<myshares>();
            SqlDataReader reader = null;
            String queryString = "SELECT psxrecord.noofstocks, psxrecord.compname, psxrecord.priceofshare FROM (person inner join psxperson on person.cnic= psxperson.cnic) inner join psxrecord on psxrecord.psxaccno=psxperson.psxaccno WHERE '" + email + "'=person.email";
            SqlConnection con = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand(queryString, con);
            try
            {
                con.Open();
                reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    int noofstocks = (int)reader["noofstocks"];
                    string compname = (string)reader["compname"];
                    double priceofshare = Convert.ToDouble(reader["priceofshare"]);
                    myshares k = new myshares();
                    k.noofstocks = noofstocks;
                    k.compname = compname;
                    k.priceoshare = priceofshare;
                    mm.Add(k);
                }
            }
            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
                return null;
            }
            finally
            {
                con.Close();
            }
            return mm;

        }
        public static int brokerastock(String email, String compname, int numberofshares, Double sharevalueoffered)
        {
            int result = 0;

            SqlConnection con = new SqlConnection(connectionString);
            con.Open();
            SqlCommand cmd;
            try
            {

                cmd = new SqlCommand("f8", con);

                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.Add("@email", SqlDbType.NVarChar, 75).Value = email;
                cmd.Parameters.Add("@companyname", SqlDbType.NVarChar, 100).Value = compname;
                cmd.Parameters.Add("@numberofshares", SqlDbType.Int).Value = numberofshares;
                cmd.Parameters.Add("@sharevalueoffered", SqlDbType.Real).Value = sharevalueoffered;
                cmd.Parameters.Add("@output", SqlDbType.Int).Direction = ParameterDirection.Output;



                cmd.ExecuteNonQuery();

                result = Convert.ToInt32(cmd.Parameters["@output"].Value);

            }



            catch (SqlException ex)

            {

                Console.WriteLine("SQL Error" + ex.Message.ToString());

                result = 0; //0 will be interpreted as "error while connecting with the database."

            }

            finally

            {

                con.Close();

            }

            return result;
        }
        // ----------------------------------------------- company ---------------------------------------------


        public static int notfirsteyepos(String companyname, int noofipos)
        {
            int result = 0;

            SqlConnection con = new SqlConnection(connectionString);
            con.Open();
            SqlCommand cmd;
            try

            {

                cmd = new SqlCommand("isnotfirsttime", con);

                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.Add("@compname", SqlDbType.NVarChar, 100).Value = companyname;
                cmd.Parameters.Add("@noofipos", SqlDbType.Int).Value = noofipos;
                cmd.Parameters.Add("@output", SqlDbType.Int).Direction = ParameterDirection.Output;



                cmd.ExecuteNonQuery();

                result = Convert.ToInt32(cmd.Parameters["@output"].Value);

            }



            catch (SqlException ex)

            {

                Console.WriteLine("SQL Error" + ex.Message.ToString());

                result = 0; //0 will be interpreted as "error while connecting with the database."

            }

            finally

            {

                con.Close();

            }

            return result;
        }


        public static int firsteyepos(String companyname,int noofipos , Double priceofipo, Double dividend)
        {
            int result = 0;

            SqlConnection con = new SqlConnection(connectionString);
            con.Open();
            SqlCommand cmd;
            try

            {

                cmd = new SqlCommand("isfirsttime", con);

                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.Add("@compname", SqlDbType.NVarChar, 100).Value = companyname;
                cmd.Parameters.Add("@noofipos", SqlDbType.Int).Value = noofipos;
                cmd.Parameters.Add("@priceofipo", SqlDbType.Real).Value = priceofipo;
                cmd.Parameters.Add("@dividend", SqlDbType.Real).Value = dividend;
                cmd.Parameters.Add("@output", SqlDbType.Int).Direction = ParameterDirection.Output;



                cmd.ExecuteNonQuery();

                result = Convert.ToInt32(cmd.Parameters["@output"].Value);

            }



            catch (SqlException ex)

            {

                Console.WriteLine("SQL Error" + ex.Message.ToString());

                result = 0; //0 will be interpreted as "error while connecting with the database."

            }

            finally

            {

                con.Close();

            }

            return result;
        }

        public static int checksituation(String companyname)
        {
            int result=0;

              SqlConnection con = new SqlConnection(connectionString);
            con.Open();
            SqlCommand cmd;
            try

            {

                cmd = new SqlCommand("checkfirsttime", con);

                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.Add("@compname", SqlDbType.NVarChar, 100).Value = companyname;

                cmd.Parameters.Add("@output", SqlDbType.Int).Direction = ParameterDirection.Output;



                cmd.ExecuteNonQuery();

                result = Convert.ToInt32(cmd.Parameters["@output"].Value);

            }



            catch (SqlException ex)

            {

                Console.WriteLine("SQL Error" + ex.Message.ToString());

                result = 0; //0 will be interpreted as "error while connecting with the database."

            }

            finally

            {

                con.Close();

            }

            return result;
        }
        public static List<myshareholderz> myshareholders(String companyname)
        {

            List<myshareholderz> mm = new List<myshareholderz>();
            SqlDataReader reader = null;
            String queryString = " SELECT psxperson.pname,psxrecord.noofstocks FROM psxrecord inner join psxperson on psxrecord.psxaccno=psxperson.psxaccno WHERE psxrecord.compname='"+companyname+"' order by psxrecord.noofstocks desc";
            SqlConnection con = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand(queryString, con);
            try
            {
                con.Open();
                reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    int noofstocks = (int)reader["noofstocks"];
                    string personname = (string)reader["pname"];
                    myshareholderz k = new myshareholderz();
                    k.noofstocks = noofstocks;
                    k.pname = personname;
                    mm.Add(k);
                }
            }
            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
                return null;
            }
            finally
            {
                con.Close();
            }
            return mm;

        }

        // ------------------------------------------------------------------------------------------------------------
        public static List<personcapitals> personcapital()
        {
            List<personcapitals> mm = new List<personcapitals>();
            SqlDataReader reader = null;
            String queryString = "select top 10 b.personcapital, b.pname from( select a.pname, sum(a.personcapital) as personcapital from( select pr.noofstocks * pr.priceofshare as personcapital, p.pname, pr.compname from psxperson as p inner join psxrecord as pr on p.psxaccno = pr.psxaccno ) as a group by a.pname) as b order by b.personcapital desc";
            SqlConnection con = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand(queryString, con);
            try
            {
                con.Open();
                reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    double personcap = Convert.ToDouble(reader["personcapital"]);
                    string personname = (string)reader["pname"];
                    personcapitals k = new personcapitals();
                    k.amountofshareinmarket = personcap;
                    k.pname = personname;
                    mm.Add(k);
                }
            }
            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
                return null;
            }
            finally
            {
                con.Close();
            }
            return mm;
        }

        public static List<marketcapitals> marketcapital()
        {
            List<marketcapitals> mm = new List<marketcapitals>();
            SqlDataReader reader = null;
            String queryString = "select top 10 pc.totalshares* pm.msvom as marketcapital, pc.compgenre, pc.compname from psxcompany as pc inner join psxmarket as pm on pc.regno = pm.regno order by marketcapital desc";
            SqlConnection con = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand(queryString, con);
            try
            {
                con.Open();
                reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    string companygenre = (string)reader["compgenre"];
                    string companyname = (string)reader["compname"];
                    double marketcap = Convert.ToDouble(reader["marketcapital"]);
                    marketcapitals k = new marketcapitals();
                    k.amountofshareinmarket = marketcap;
                    k.compgenre = companygenre;
                    k.compname = companyname;
                    mm.Add(k);
                }
            }
            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
                return null;
            }
            finally
            {
                con.Close();
            }
            return mm;
        }


        public static List<marketcapitals> psxmarket()
        {
            List<marketcapitals> mm = new List<marketcapitals>();
            SqlDataReader reader = null;
            String queryString = "select pc.compname, pc.compgenre, pr.msvom from psxcompany as pc inner join psxmarket as pr on pc.regno = pr.regno order by pr.msvom desc";
            SqlConnection con = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand(queryString, con);
            try
            {
                con.Open();
                reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    string companygenre = (string)reader["compgenre"];
                    string companyname = (string)reader["compname"];
                    double price = Convert.ToDouble(reader["msvom"]);
                    marketcapitals k = new marketcapitals();
                    k.amountofshareinmarket = price;
                    k.compgenre = companygenre;
                    k.compname = companyname;
                    mm.Add(k);
                }
            }
            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
                return null;
            }
            finally
            {
                con.Close();
            }
            return mm;
        }

        public static kse30 calculatekse30()
        {
            kse30 k = new kse30();
            k.today = 0; k.previousday = 0; k.currentmonth = 0; k.comparison = "NIL";

            SqlConnection con = new SqlConnection(connectionString);
            con.Open();
            SqlCommand cmd;
            try
            {
                cmd = new SqlCommand("kse30today", con);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.Add("@out", SqlDbType.Int).Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();
                k.today = Convert.ToDouble(cmd.Parameters["@out"].Value);
            }
            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
            }
            // -----
            try
            {
                cmd = new SqlCommand("kse30prevday", con);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.Add("@out", SqlDbType.Int).Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();
                k.previousday = Convert.ToDouble(cmd.Parameters["@out"].Value);
            }
            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
            }
            // ----
            try
            {
                cmd = new SqlCommand("kse30month", con);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.Add("@out", SqlDbType.Int).Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();
                k.currentmonth = Convert.ToDouble(cmd.Parameters["@out"].Value);
            }
            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
            }
            // ----
            // ----
            try
            {
                cmd = new SqlCommand("comparekse30", con);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.Add("@out", SqlDbType.Int).Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();
                double result = Convert.ToDouble(cmd.Parameters["@out"].Value);
                if(result<0)
                {
                    k.comparison = "Market Falling";
                }
                else if(result>0)
                {
                    k.comparison = "Market Rising";
                }
                else { k.comparison = "Market Stable"; }
            }
            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
            }

            finally
            {
                con.Close();
            }
            return k;
        }
        public static int addbankaccount(String cnic, String bankname, Double balance)
        {

            SqlConnection con = new SqlConnection(connectionString);
            con.Open();
            SqlCommand cmd;

            int result = 0;

            try

            {

                cmd = new SqlCommand("addbankaccount", con);

                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.Add("@cnic", SqlDbType.NVarChar, 15).Value = cnic;

                cmd.Parameters.Add("@bankname", SqlDbType.NVarChar, 50).Value = bankname;

                cmd.Parameters.Add("@balance", SqlDbType.Real).Value = balance;





                cmd.Parameters.Add("@output", SqlDbType.Int).Direction = ParameterDirection.Output;



                cmd.ExecuteNonQuery();

                result = Convert.ToInt32(cmd.Parameters["@output"].Value);

            }



            catch (SqlException ex)

            {

                Console.WriteLine("SQL Error" + ex.Message.ToString());

                result = 0; //0 will be interpreted as "error while connecting with the database."

            }

            finally

            {

                con.Close();

            }

            return result;

        }

        public static int addbank(String bankname)

        {

            SqlConnection con = new SqlConnection(connectionString);
            con.Open();
            SqlCommand cmd;
            int result = 0;
            try
            {
                cmd = new SqlCommand("addbank", con);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.Add("@bankname", SqlDbType.NVarChar, 50).Value = bankname;
                cmd.Parameters.Add("@output", SqlDbType.Int).Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();
                result = Convert.ToInt32(cmd.Parameters["@output"].Value);
            }
            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
                result = 0; //0 will be interpreted as "error while connecting with the database."
            }
            finally
            {
                con.Close();
            }
            return result;
        }
        public static int addpsxrecord(String psxaccno, String noofstocks,String compname,String priceofshare)
        {
            SqlConnection con = new SqlConnection(connectionString);
            con.Open();
            SqlCommand cmd;
            int result = 0;
            try
            {
                cmd = new SqlCommand("checkpsxrecord", con);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.Add("@psxaccno", SqlDbType.Int).Value = psxaccno;
                cmd.Parameters.Add("@noofstocks", SqlDbType.Int).Value = noofstocks;
                cmd.Parameters.Add("@compname", SqlDbType.NVarChar, 100).Value = compname;
                cmd.Parameters.Add("@priceofshare", SqlDbType.Real).Value = priceofshare;
                cmd.Parameters.Add("@output", SqlDbType.Int).Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();
                result = Convert.ToInt32(cmd.Parameters["@output"].Value);

            }
            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
                result = 0; //-1 will be interpreted as "error while connecting with the database."
            }
            finally
            {
                con.Close();
            }
            return result;
        }

        public static int addpsxperson(String pcnic, String pername)
        {
            SqlConnection con = new SqlConnection(connectionString);
            con.Open();
            SqlCommand cmd;
            int result = 0;
            try
            {
                cmd = new SqlCommand("checkpsxperson", con);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.Add("@pcnic", SqlDbType.NVarChar, 15).Value = pcnic;
                cmd.Parameters.Add("@pername", SqlDbType.NVarChar, 50).Value = pername;


                cmd.Parameters.Add("@outputpp", SqlDbType.Int).Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();
                result = Convert.ToInt32(cmd.Parameters["@outputpp"].Value);

            }
            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
                result = 0; //-1 will be interpreted as "error while connecting with the database."
            }
            finally
            {
                con.Close();
            }
            return result;
        }

        public static int addpsxbroker(String brokname, String cnicbroker)
        {
            SqlConnection con = new SqlConnection(connectionString);
            con.Open();
            SqlCommand cmd;
            int result = 0;
            try
            {
                cmd = new SqlCommand("checkpsxbroker", con);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.Add("@brokname", SqlDbType.NVarChar, 50).Value = brokname;
                cmd.Parameters.Add("@cnicbroker", SqlDbType.NVarChar, 15).Value = cnicbroker;


                cmd.Parameters.Add("@output", SqlDbType.Int).Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();
                result = Convert.ToInt32(cmd.Parameters["@output"].Value);

            }
            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
                result = 0; //-1 will be interpreted as "error while connecting with the database."
            }
            finally
            {
                con.Close();
            }
            return result;
        }

        public static int addpsxcompany(String compname, String compgenre, Double faceval, Double dividend, String totalshares)
        {
            SqlConnection con = new SqlConnection(connectionString);
            con.Open();
            SqlCommand cmd;
            int result = 0;
            try
            {
                cmd = new SqlCommand("checkpsxcompany", con);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.Add("@compname", SqlDbType.NVarChar, 100).Value = compname;
                cmd.Parameters.Add("@compgenre", SqlDbType.NVarChar, 20).Value = compgenre;
                cmd.Parameters.Add("@faceval", SqlDbType.Real).Value = faceval;
                cmd.Parameters.Add("@dividend", SqlDbType.Real).Value = dividend;
                cmd.Parameters.Add("@totalshares", SqlDbType.Int).Value  = totalshares;


                cmd.Parameters.Add("@output", SqlDbType.Int).Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();
                result = Convert.ToInt32(cmd.Parameters["@output"].Value);

            }
            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
                result = 0; //-1 will be interpreted as "error while connecting with the database."
            }
            finally
            {
                con.Close();
            }
            return result;
        }

        public static int updatepsxmarket(String regno, String msvom)
        {
            SqlConnection con = new SqlConnection(connectionString);
            con.Open();
            SqlCommand cmd;
            int result = 0;
            try
            {
                cmd = new SqlCommand("checkpsxmarket", con);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.Add("@regno", SqlDbType.Int).Value = regno;
                cmd.Parameters.Add("@msvom", SqlDbType.Real).Value = msvom;


                cmd.Parameters.Add("@output", SqlDbType.Int).Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();
                result = Convert.ToInt32(cmd.Parameters["@output"].Value);

            }
            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
                result = 0; //0 will be interpreted as "error while connecting with the database."
            }
            finally
            {
                con.Close();
            }
            return result;
        }

        public static int companysignin(String companyname, String bankaccno)
        {
            SqlConnection con = new SqlConnection(connectionString);
            con.Open();
            SqlCommand cmd;
            int result = 0;
            try
            {
                cmd = new SqlCommand("SignInCompany", con);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.Add("@compname", SqlDbType.NVarChar, 100).Value = companyname;
                cmd.Parameters.Add("@bankaccno", SqlDbType.Int).Value = bankaccno;


                cmd.Parameters.Add("@output", SqlDbType.Int).Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();
                result = Convert.ToInt32(cmd.Parameters["@output"].Value);

            }
            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
                result = 0; //-1 will be interpreted as "error while connecting with the database."
            }
            finally
            {
                con.Close();
            }
            return result;
        }
        public static int dealcompany(String regnobroker, String compregno, String compname, String cnicbank, String bankname, String nipostosell)
        {

            SqlConnection con = new SqlConnection(connectionString);

            con.Open();

            SqlCommand cmd;

            int result = 0;
            try
            {
                cmd = new SqlCommand("Adminbrokercompany", con);

                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.Add("@regnobroker", SqlDbType.Int).Value = Convert.ToInt32(regnobroker);

                cmd.Parameters.Add("@compregno", SqlDbType.Int).Value = compregno;

                cmd.Parameters.Add("@compname", SqlDbType.NVarChar, 100).Value = compname;

                cmd.Parameters.Add("@cnicbank", SqlDbType.NVarChar, 15).Value = cnicbank;

                cmd.Parameters.Add("@bankname", SqlDbType.NVarChar, 50).Value = bankname;

                cmd.Parameters.Add("@nipostosell", SqlDbType.Int).Value = Convert.ToInt32(nipostosell);

                cmd.Parameters.Add("@output", SqlDbType.Int).Direction = ParameterDirection.Output;



                cmd.ExecuteNonQuery();

                result = Convert.ToInt32(cmd.Parameters["@output"].Value);

            }
            catch (SqlException ex)
            {

                Console.WriteLine("SQL Error" + ex.Message.ToString());

                result = 0; //-1 will be interpreted as "error while connecting with the database."
            }
            finally
            {

                con.Close();

            }
            return result;
        }
        public static int dealperson(String regnobroker, String cnicp, String bankname, String compname, String sharevalue, String noofshares)
        {
            SqlConnection con = new SqlConnection(connectionString);

            con.Open();

            SqlCommand cmd;

            int result = 0;
            try
            {
                cmd = new SqlCommand("Adminbrokerperson", con);

                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.Add("@regnobroker", SqlDbType.Int).Value = Convert.ToInt32(regnobroker);

                cmd.Parameters.Add("@cnicp", SqlDbType.NVarChar, 15).Value = cnicp;

                cmd.Parameters.Add("@bankname", SqlDbType.NVarChar, 50).Value = bankname;

                cmd.Parameters.Add("@compname", SqlDbType.NVarChar, 100).Value = compname;

                cmd.Parameters.Add("@sharevalue", SqlDbType.Real).Value = sharevalue;

                cmd.Parameters.Add("@noofshares", SqlDbType.Int).Value = Convert.ToInt32(noofshares);

                cmd.Parameters.Add("@output", SqlDbType.Int).Direction = ParameterDirection.Output;



                cmd.ExecuteNonQuery();

                result = Convert.ToInt32(cmd.Parameters["@output"].Value);

            }
            catch (SqlException ex)
            {

                Console.WriteLine("SQL Error" + ex.Message.ToString());

                result = -1; //-1 will be interpreted as "error while connecting with the database."
            }
            finally
            {

                con.Close();

            }
            return result;
        }
        public static int personsignin(String emailperson, String pass)
        {
            SqlConnection con = new SqlConnection(connectionString);
            con.Open();
            SqlCommand cmd;
            int result = 0;
            try
            {

                cmd = new SqlCommand("SignIn", con);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.Add("@lemail", SqlDbType.NVarChar, 75).Value = emailperson;
                cmd.Parameters.Add("@lpass", SqlDbType.NVarChar, 30).Value = pass;


                cmd.Parameters.Add("@output", SqlDbType.Int).Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();
                result = Convert.ToInt32(cmd.Parameters["@output"].Value);

            }

            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
                result = -1; //-1 will be interpreted as "error while connecting with the database."
            }
            finally
            {
                con.Close();
            }
            return result;
        }

        public static int addingcompany(String compname, String compgenre, String psxregno, String iposleft, String cnicbank, String bankaccno, String bankname)
        {
            SqlConnection con = new SqlConnection(connectionString);
            con.Open();
            SqlCommand cmd;
            int result = 0;
            try
            {

                cmd = new SqlCommand("SignUpcompany", con);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.Add("@compname", SqlDbType.NVarChar, 100).Value = compname;
                cmd.Parameters.Add("@compgenre", SqlDbType.NVarChar, 20).Value = compgenre;
                cmd.Parameters.Add("@psxregno", SqlDbType.Int).Value = psxregno;
                cmd.Parameters.Add("@iposrem", SqlDbType.Int).Value = Convert.ToInt32(iposleft);
                cmd.Parameters.Add("@cnicbank", SqlDbType.NVarChar, 15).Value = cnicbank;
                cmd.Parameters.Add("@bankaccno", SqlDbType.Int).Value = Convert.ToInt32(bankaccno);
                cmd.Parameters.Add("@bankname", SqlDbType.NVarChar, 50).Value =bankname;
                // output
                cmd.Parameters.Add("@output", SqlDbType.Int).Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();
                result = Convert.ToInt32(cmd.Parameters["@output"].Value);

            }

            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
                result = -1; //-1 will be interpreted as "error while connecting with the database."
            }
            finally
            {
                con.Close();
            }
            return result;
        }
        public static int addingperson(String nameperson, String bdate, String cnic, String country, String email, String pass, String bankaccno, String bankname, String psxaccno)
        {
            SqlConnection con = new SqlConnection(connectionString);
            con.Open();
            SqlCommand cmd;
            int result = 0;
            try
            {

                cmd = new SqlCommand("SignUp", con);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.Add("@lpname", SqlDbType.NVarChar, 50).Value = nameperson;
                cmd.Parameters.Add("@lbdate", SqlDbType.Date).Value = Convert.ToDateTime(bdate);
                cmd.Parameters.Add("@lcnic", SqlDbType.NVarChar,15).Value =cnic;
                cmd.Parameters.Add("@lcountry", SqlDbType.NVarChar, 25).Value = country;
                cmd.Parameters.Add("@lemail", SqlDbType.NVarChar, 75).Value = email;
                cmd.Parameters.Add("@lpass", SqlDbType.NVarChar, 8).Value = pass;
                cmd.Parameters.Add("@lbankaccno", SqlDbType.Int).Value = Convert.ToInt32(bankaccno);
                cmd.Parameters.Add("@lbankname", SqlDbType.NVarChar, 50).Value = bankname;
                cmd.Parameters.Add("@lpsxaccno", SqlDbType.Int).Value = Convert.ToInt32(psxaccno);


                cmd.Parameters.Add("@output", SqlDbType.Int).Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();
                result = Convert.ToInt32(cmd.Parameters["@output"].Value);



            }

            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
                result = -1; //-1 will be interpreted as "error while connecting with the database."
            }
            finally
            {
                con.Close();
            }
            return result;
        }
        public static int adminverify(String pass)
        {
            SqlConnection con = new SqlConnection(connectionString);
            con.Open();
            SqlCommand cmd;
            int result = 0;
            try
            {

                cmd = new SqlCommand("adminverify", con);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.Add("@passing", SqlDbType.NVarChar, 8).Value = pass;

                cmd.Parameters.Add("@output", SqlDbType.Int).Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();
                result = Convert.ToInt32(cmd.Parameters["@output"].Value);
            }

            catch (SqlException ex)
            {
                Console.WriteLine("SQL Error" + ex.Message.ToString());
                result = -1; //-1 will be interpreted as "error while connecting with the database."
            }
            finally
            {
                con.Close();
            }
            return result;
        }
    }
}
/* 
public  static string connectionString = @"Data Source=DESKTOP-NJ6QH8N;Initial Catalog=DbName;Integrated Security=True";

public static List<String> getUsers(string id)
{

    List<String> ll = new List<string>();
    SqlDataReader reader=null;
    String queryString = "select * from DbTable where id="+ Convert.ToInt32(id);

    SqlConnection con = new SqlConnection(connectionString);

    SqlCommand cmd = new SqlCommand(queryString, con);

    try
    {

        con.Open();
        reader = cmd.ExecuteReader();
        while (reader.Read())
        {
            ll.Add(reader[1].ToString());
        }
    }

    catch (SqlException ex)
    {
        Console.WriteLine("SQL Error" + ex.Message.ToString());
        return null; 
    }
    finally
    {
        con.Close();
    }
    return ll;

}


public static int Login(String userId, String password)
{

    SqlConnection con = new SqlConnection(connectionString);
    con.Open();
    SqlCommand cmd;
    int result = 0;

    try
    {

        cmd = new SqlCommand("UserLoginProc", con);
        cmd.CommandType = System.Data.CommandType.StoredProcedure;

        cmd.Parameters.Add("@userId", SqlDbType.Int).Value = Convert.ToInt32(userId);
        cmd.Parameters.Add("@password", SqlDbType.VarChar, 15).Value = password;


        cmd.Parameters.Add("@output", SqlDbType.Int).Direction = ParameterDirection.Output;

        cmd.ExecuteNonQuery();
        result = Convert.ToInt32(cmd.Parameters["@output"].Value);



    }

    catch (SqlException ex)
    {
        Console.WriteLine("SQL Error" + ex.Message.ToString());
        result = -1; //-1 will be interpreted as "error while connecting with the database."
    }
    finally
    {
        con.Close();
    }
    return result;

}*/
