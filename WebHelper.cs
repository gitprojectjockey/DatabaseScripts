using System;
using System.Configuration;
using System.Web;
using System.Web.Configuration;
using System.Web.UI.WebControls;

namespace Acs.TripPakEnterprise.Common
{
    public static class WebHelper
    {
        static public string GetQueryString(this HttpRequest request, string name)
        {
            string text = request.QueryString[name];

            if (text == null)
            {
                string message = string.Format("Missing {0} in query string.", name);
                throw new ArgumentException(message, name);
            }

            return text;
        }

        static public string GetQueryStringOrDefault(this HttpRequest request, string name)
        {
            if ((request.QueryString[name] ?? "") == "") return "";
            return GetQueryString(request, name);
        }

        static public bool GetQueryStringBoolean(this HttpRequest request, string name)
        {
            int value = GetQueryStringInt32(request, name);
            if (value == 0) return false;
            if (value == 1) return true;

            string message = string.Format("Invalid {0} in query string.", name);
            throw new ArgumentException(message, name);
        }

        static public bool GetQueryStringBooleanOrDefault(this HttpRequest request, string name)
        {
            if ((request.QueryString[name] ?? "") == "") return false;
            return GetQueryStringBoolean(request, name);
        }

        static public DateTime GetQueryStringDateTime(this HttpRequest request, string name)
        {
            string text = request.QueryString[name] ?? "";

            if (text.Length == 0)
            {
                string message = string.Format("Missing {0} in query string.", name);
                throw new ArgumentException(message, name);
            }

            DateTime value;
            if (!DateTime.TryParse(text, out value))
            {
                string message = string.Format("Invalid {0} in query string.", name);
                throw new ArgumentException(message, name);
            }

            return value;
        }

        static public DateTime GetQueryStringDateTimeOrDefault(this HttpRequest request, string name)
        {
            if ((request.QueryString[name] ?? "") == "") return default(DateTime);
            return GetQueryStringDateTime(request, name);
        }

        static public Guid GetQueryStringGuid(this HttpRequest request, string name)
        {
            string text = request.QueryString[name] ?? "";

            if (text.Length == 0)
            {
                string message = string.Format("Missing {0} in query string.", name);
                throw new ArgumentException(message, name);
            }

            try
            {
                return new Guid(text);
            }
            catch (Exception err)
            {
                string message = string.Format("Invalid {0} in query string.", name);
                throw new ArgumentException(message, name, err);
            }
        }

        static public Guid GetQueryStringGuidOrDefault(this HttpRequest request, string name)
        {
            if ((request.QueryString[name] ?? "") == "") return default(Guid);
            return GetQueryStringGuid(request, name);
        }

        static public int GetQueryStringInt32(this HttpRequest request, string name)
        {
            string text = request.QueryString[name] ?? "";

            if (text.Length == 0)
            {
                string message = string.Format("Missing {0} in query string.", name);
                throw new ArgumentException(message, name);
            }

            int value;
            if (!int.TryParse(text, out value))
            {
                string message = string.Format("Invalid {0} in query string.", name);
                throw new ArgumentException(message, name);
            }

            return value;
        }

        static public int GetQueryStringInt32OrDefault(this HttpRequest request, string name)
        {
            if ((request.QueryString[name] ?? "") == "") return 0;
            return GetQueryStringInt32(request, name);
        }

        static public decimal GetQueryStringDecimal(this HttpRequest request, string name)
        {
            string text = request.QueryString[name] ?? "";

            if (text.Length == 0)
            {
                string message = string.Format("Missing {0} in query string.", name);
                throw new ArgumentException(message, name);
            }

            decimal value;
            if (!decimal.TryParse(text, out value))
            {
                string message = string.Format("Invalid {0} in query string.", name);
                throw new ArgumentException(message, name);
            }

            return value;
        }

        static public decimal GetQueryStringDecimalOrDefault(this HttpRequest request, string name)
        {
            if ((request.QueryString[name] ?? "") == "") return 0;
            return GetQueryStringDecimal(request, name);
        }

        static public double GetQueryStringDouble(this HttpRequest request, string name)
        {
            string text = request.QueryString[name] ?? "";

            if (text.Length == 0)
            {
                string message = string.Format("Missing {0} in query string.", name);
                throw new ArgumentException(message, name);
            }

            double value;
            if (!double.TryParse(text, out value))
            {
                string message = string.Format("Invalid {0} in query string.", name);
                throw new ArgumentException(message, name);
            }

            return value;
        }

        static public double GetQueryStringDoubleOrDefault(this HttpRequest request, string name)
        {
            if ((request.QueryString[name] ?? "") == "") return 0;
            return GetQueryStringDouble(request, name);
        }

        static public float GetQueryStringSingle(this HttpRequest request, string name)
        {
            string text = request.QueryString[name] ?? "";

            if (text.Length == 0)
            {
                string message = string.Format("Missing {0} in query string.", name);
                throw new ArgumentException(message, name);
            }

            float value;
            if (!float.TryParse(text, out value))
            {
                string message = string.Format("Invalid {0} in query string.", name);
                throw new ArgumentException(message, name);
            }

            return value;
        }

        static public float GetQueryStringSingleOrDefault(this HttpRequest request, string name)
        {
            if ((request.QueryString[name] ?? "") == "") return 0;
            return GetQueryStringSingle(request, name);
        }

        public static bool IsDebug()
        {
            if (_debug == null)
            {
                Configuration config = WebConfigurationManager.OpenWebConfiguration("~/web.config");
                CompilationSection compilationSection = (CompilationSection) config.GetSection("system.web/compilation");
                _debug = compilationSection.Debug;
            }

            return (bool) _debug;
        }
        static bool? _debug;

        static public void ReorderListControl(ListControl listControl, string[] values)
        {
            for (int i = values.Length - 1; i >= 0; i--)
            {
                string value = values[i];
                ListItem listItem = listControl.Items.FindByValue(value);
                if (listItem == null) continue;
                listControl.Items.Remove(listItem);
                listControl.Items.Insert(0, listItem);
            }
        }
    }
}
