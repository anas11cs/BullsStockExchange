using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using dbconnectivity_C.Models;
using System.Data.SqlClient;

namespace dbconnectivity_C.Controllers
{
    public class DbTestController : Controller
    {
        // GET: DbTest
        public ActionResult Login()
        {

            return View();
        }

        public ActionResult authenticate(String userId, String password)
        {
        //  int result = CRUD.Login(userId, password);
            int  result = -1;
            if (result == -1)
            {
                String data = "Something went wrong while connecting with the database.";
                return View("Login", (object)data);
            }
            else if (result == 0)
            {

                String data = "Incorrect Credentials";
                return View("Login", (object)data);
            }


            Session["userId"] = userId;
            return RedirectToAction("homePage");

        }


        public ActionResult homePage()
        {
            if (Session["userId"] == null)
            {
                return RedirectToAction("Login");
            }

            string id = Session["userId"].ToString();

            //     List<string> users = CRUD.getUsers(id);
            List<string> users = null;
            if (users == null)
            {
                RedirectToAction("Login");
            }

            Console.Write(users);
            return View(users);
        }

    }
}