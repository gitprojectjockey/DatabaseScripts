using System;
using System.Collections.Generic;
using System.Text;

namespace Acs.TripPakEnterprise.Common
{
    public static class DataHelper
    {
        /// <summary>
        /// Returns the first argument that is neither null nor DBNull.
        /// If no non-null arguments are found null is returned.
        /// This is similar as MSSQL's COALESCE function.
        /// </summary>
        public static object Coalesce(this object value, params object[] replacements)
        {
            if (value != null && !Convert.IsDBNull(value)) return value;
            if (replacements == null) return null;

            foreach (object replacement in replacements)
            {
                if (replacement != null && !Convert.IsDBNull(replacement))
                {
                    return replacement;
                }
            }

            return null;
        }

        /// <summary>
        /// Returns the first argument that is neither null nor DBNull.
        /// If no non-null arguments are found null is returned.
        /// This is similar as MSSQL's COALESCE function.
        /// </summary>
        public static T Coalesce<T>(this object value, T replacement)
        {
            return
                value != null && !Convert.IsDBNull(value)
                ? (T) value
                : replacement;
        }

        /// <summary>
        /// Returns the first argument that is neither null nor DBNull.
        /// If no non-null arguments are found null is returned.
        /// This is similar as MSSQL's COALESCE function.
        /// </summary>
        public static T Coalesce<T>(this object value, object replacement1, T replacement2)
        {
            return
                value != null && !Convert.IsDBNull(value) ? (T) value
                : replacement1 != null && !Convert.IsDBNull(replacement1) ? (T) replacement1
                : replacement2;
        }

        /// <summary>
        /// Returns the first argument that is neither null nor DBNull.
        /// If no non-null arguments are found null is returned.
        /// This is similar as MSSQL's COALESCE function.
        /// </summary>
        public static T Coalesce<T>(this object value, object replacement1, object replacement2, T replacement3)
        {
            return
                value != null && !Convert.IsDBNull(value) ? (T) value
                : replacement1 != null && !Convert.IsDBNull(replacement1) ? (T) replacement1
                : replacement2 != null && !Convert.IsDBNull(replacement2) ? (T) replacement2
                : replacement3;
        }

        static public string EscapeWildcards(string value)
        {
            return value.Replace("[", "[[]")
                .Replace("%", "[%]")
                .Replace("%", "[_]");
        }

        public static string FormatForSqlInClause(string[] strings)
        {
            strings = Array.FindAll<string>(
                strings,
                delegate(string s) { return s != null; });

            strings = Array.ConvertAll<string, string>(
                strings,
                delegate(string s) { return string.Format("'{0}'", s.Replace("'", "''")); });

            return string.Join(",", strings);
        }

        public static string FormatForSqlInClause(int[] numbers)
        {
            string[] strings = Array.ConvertAll<int, string>(
                numbers,
                delegate(int i) { return i.ToString(); });

            return string.Join(",", strings);
        }

        /// <summary>
        /// Returns null if the two specified arguments are equivalent,
        /// otherwise returns original value.
        /// </summary>
        static public Nullable<T> NullIf<T>(this object value, T compare) where T : struct
        {
            return
                value == null || Convert.IsDBNull(value) ? null
                : value.Equals(compare) ? null
                : (Nullable<T>) value;
        }

        /// <summary>
        /// Returns null if the two specified arguments are equivalent,
        /// otherwise returns original value.
        /// </summary>
        static public string NullIf(this object value, string compare)
        {
            return
                value == null || Convert.IsDBNull(value) ? null
                : (string) value == compare ? null
                : (string) value;
        }

        public static string ReverseSqlOrderByClause(string sort)
        {
            if (sort == null || sort.Trim().Length == 0) return sort;

            var sortItems = sort.Split(',');

            sortItems = Array.ConvertAll<string, string>(
                sortItems,
                delegate(string s)
                {
                    s = s.Trim();
                    if (s.Length == 0) return s;
                    return s.ToUpper().EndsWith(" ASC") ? s.Substring(0, s.Length - 4) + " DESC"
                        : s.ToUpper().EndsWith(" DESC") ? s.Substring(0, s.Length - 5)
                        : s + " DESC";
                });

            return string.Join(", ", sortItems);
        }
    }
}
