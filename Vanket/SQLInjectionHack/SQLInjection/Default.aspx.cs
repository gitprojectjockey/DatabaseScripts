using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace SQLInjection
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string connString = ConfigurationManager.ConnectionStrings["Db"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand("Select * from tblEmployee", conn);
                GridView1.DataSource = cmd.ExecuteReader();
                GridView1.DataBind();
            }
        }

        protected void btnGetAll_Click(object sender, EventArgs e)
        {
            string connString = ConfigurationManager.ConnectionStrings["Db"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand("Select * from tblEmployee", conn);
                GridView1.DataSource = cmd.ExecuteReader();
                GridView1.DataBind();
            }
        }

        protected void btnGetEmployee_Click(object sender, EventArgs e)
        {
            string connString = ConfigurationManager.ConnectionStrings["Db"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connString))
            {

                /// Sara'; Delete from tblEmployee --
                /// This is a typical SQL injection. If you enter this into the name txtbox for a search you will find the name Sara
                /// but you will also delete * in tblEmployee
                conn.Open();
                //SqlCommand cmd = new SqlCommand(string.Format("Select * from tblEmployee where Name = '{0}'",txtName.Text.Trim()), conn);
                /// Change adhoc query to use a named parameter
                /// Or just use a Stored Procedure to avoid Sql injection.
                SqlCommand cmd = new SqlCommand("Select * from tblEmployee where Name = @Name" , conn);
                cmd.Parameters.Add(new SqlParameter("Name", txtName.Text.Trim()));
                GridView1.DataSource = cmd.ExecuteReader();
                GridView1.DataBind();
            }
        }
    }
}