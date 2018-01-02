using System;
using System.Collections.Generic;
using System.Web;
using System.Text;
using System.Text.RegularExpressions;
using System.Security.Cryptography;
using System.IO;

namespace Acs.TripPakEnterprise.Common
{
    public static class StringHelper
    {
        public static string ComputeHashMD5(this string text)
        {
            // The resulting hash is 32 characters long.
            // It is the hex representation of 128 bits (16 bytes).
            // Here's an example of the output for text = "":
            // D41D8CD98F00B204E9800998ECF8427E

            byte[] bytes = Encoding.UTF8.GetBytes(text);
            byte[] hash = MD5.Create().ComputeHash(bytes);
            return ToHex(hash);
        }

        public static string ComputeHashSHA1(this string text)
        {
            // The resulting hash is 40 characters long.
            // It is the hex representation of 160 bits (20 bytes).
            // Here's an example of the output for password = "":
            // DA39A3EE5E6B4B0D3255BFEF95601890AFD80709

            byte[] bytes = Encoding.UTF8.GetBytes(text);
            byte[] hash = SHA1.Create().ComputeHash(bytes);
            return ToHex(hash);
        }

        public static string Decrypt(this string cipherText)
        {
            if (cipherText == null) throw new ArgumentNullException("cipherText");
            if (cipherText.Length == 0) throw new ArgumentException("cipherText");

            return Decrypt(cipherText, null, DataProtectionScope.LocalMachine);
        }

        public static string Decrypt(this string cipherText, byte[] optionalEntropy, DataProtectionScope scope)
        {
            if (cipherText == null) throw new ArgumentNullException("cipherText");
            if (cipherText.Length == 0) throw new ArgumentException("cipherText");

            byte[] cipherBytes = Convert.FromBase64String(cipherText);

            // Decrypt the data in memory.
            byte[] clearbytes = ProtectedData.Unprotect(cipherBytes, optionalEntropy, scope);
            return System.Text.Encoding.ASCII.GetString(clearbytes).Trim(new char[1] { '\0' });
        }

        /// <summary>
        /// Builds qualified cache key in order to avoid cache key naming conflicts
        /// </summary>
        /// <param name="type">Class where cache key is created and used (NOT the type of the cached object).</param>
        /// <param name="name">The the name of the method where the caching occurs (preferred) or the name of the object being cached.</param>
        /// <param name="args">Method arguments (preferred) or object properties that identify the cached instance.</param>
        public static string GetCacheKey(Type type, string name, params string[] args)
        {
            if (type == null) throw new ArgumentNullException("type");
            if (name == null) throw new ArgumentNullException("name");

            // Guard against backslashes in name and args since other special character escaping (below) depends on it.

            // Guard against semicolons in name and args.
            // Otherwise GetCacheKey(type, "a;b", "c") and GetCacheKey(type, "a", "b;c") yield the same cache key.

            // Guard against curly brackets in name and args.
            // Otherwise GetCacheKey(type, null) and GetCacheKey(type, "{Null}") yield the same cache key.

            name = name.Replace(@"\", @"\\").Replace(";", @"\;").Replace("{", @"\{").Replace("}", @"\}");
            for (int i = 0; i < args.Length; i++)
            {
                args[i] = args[i] == null ? "{Null}" : args[i].Replace(@"\", @"\\").Replace(";", @"\;").Replace("{", @"\{").Replace("}", @"\}");
            }

            string cacheKey;
            if (args.Length > 0)
            {
                cacheKey = string.Format("{0};{1};{2}", type, name, string.Join(";", args));
            }
            else
            {
                cacheKey = string.Format("{0};{1}", type, name);
            }

            return cacheKey;
        }

        /// <summary>
        /// Html encodes text and then replaces \r\n, \r, and \n with html BRs.
        /// </summary>
        public static string HtmlBreak(this string text)
        {
            return HttpUtility.HtmlEncode(text)
                .Replace("\r\n", "<br />")
                .Replace("\n", "<br />")
                .Replace("\r", "<br />");
        }

        /// <summary>
        /// Generic Overload to ease passing casting when using Eval/Bind
        /// </summary> 
        public static string HtmlBreak(object text)
        {
            if (text is string)
            {
                return HtmlBreak((string) text);
            }
            else
            {
                return HtmlBreak(text.ToString());
            }
        }

        public static bool IsDateTime(this string s)
        {
            DateTime result;
            return DateTime.TryParse(s, out result);
        }

        static public bool IsInt32(string s)
        {
            int result;
            return Int32.TryParse(s, out result);
        }

        public static string JavaScriptEncode(this string text)
        {
            if (text == null) return null;
            return text
                .Replace("\\", "\\\\")
                .Replace("\"", "\\\"")
                .Replace("\'", "\\\'")
                .Replace("\r", "\\r")
                .Replace("\n", "\\n");
        }

        public static IEnumerable<string> ReadLines(Stream stream, bool closeStream)
        {
            try
            {
                return ReadLines(stream);
            }
            finally
            {
                if (closeStream) stream.Close();
            }
        }

        public static IEnumerable<string> ReadLines(Stream stream)
        {
            if (stream == null) throw new ArgumentNullException("stream");

            string line;
            var reader = new StreamReader(stream);
            while ((line = reader.ReadLine()) != null)
            {
                yield return line;
            }
        }

        public static string ToHex(this byte[] buff)
        {
            StringBuilder hex = new StringBuilder();
            for (int i = 0; i < buff.Length; i++)
            {
                hex.AppendFormat("{0:X2}", buff[i]);
            }
            return hex.ToString();
        }

        /// <summary>
        /// Reverse of HtmlBreak().
        /// </summary>
        public static string UnHtmlBreak(this string html)
        {
            // Replace <BR/> with \r\n
            return HttpUtility.HtmlDecode(Regex.Replace(html, @"<br\s*/?\s*>", "\r\n", RegexOptions.IgnoreCase));
        }
    }
}
