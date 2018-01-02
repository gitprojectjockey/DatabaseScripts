using System;
using System.Web;

namespace Acs.TripPakEnterprise.Common
{
    public static class CookieHelper
    {
        public static bool? GetBoolean(string name)
        {
            int? i = GetInt32(name);
            if (i == null) return null;
            return i != 0;
        }

        public static void SetBoolean(string name, bool? value)
        {
            SetInt32(name,
                value == null ? (int?) null
                : value.Value ? 1
                : 0);
        }

        public static int? GetInt32(string name)
        {
            string s = GetString(name);
            if (s.Length == 0) return null;
            return int.Parse(s);
        }

        public static void SetInt32(string name, int? value)
        {
            SetString(name, value == null ? "" : value.ToString());
        }

        public static DateTime? GetDateTime(string name)
        {
            string s = GetString(name);
            if (s.Length == 0) return null;
            return DateTime.Parse(s);
        }

        public static void SetDateTime(string name, DateTime? value)
        {
            SetString(name, value == null ? "" : value.Value.ToString("yyyy'-'MM'-'dd'T'HH':'mm':'ss.fffffff"));
        }

        public static string GetString(string name)
        {
            HttpCookie cookie = Request.Cookies[name];
            if (cookie == null) return "";
            return HttpUtility.UrlDecode(cookie.Value);
        }

        public static void SetString(string name, string value)
        {
            Response.Cookies[name].Value = HttpUtility.UrlEncode(value);
        }

        public static HttpRequest Request
        {
            get { return HttpContext.Current.Request; }
        }

        public static HttpResponse Response
        {
            get { return HttpContext.Current.Response; }
        }
    }
}
