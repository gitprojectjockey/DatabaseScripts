using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace Acs.TripPakEnterprise.Common
{
    /// <summary>
    /// Creates a stream that exposes multiple streams as a single stream.
    /// This is useful for streaming chunked BLOB data from a database, for example.
    /// </summary>
    public class AggregateStream : Stream
    {
        Stream _stream = Stream.Null;
        IEnumerator<Stream> _streamEnumerator;

        public AggregateStream(IEnumerable<Stream> streams)
        {
            if (streams == null) throw new ArgumentNullException("streams");
            _streamEnumerator = streams.GetEnumerator();
        }

        public AggregateStream(Func<Stream> getNextStreamCallback)
        {
            if (getNextStreamCallback == null) throw new ArgumentNullException("getNextStreamCallback");
            _streamEnumerator = GetNextStream(getNextStreamCallback).GetEnumerator();
        }

        public override bool CanRead
        {
            get { return true; }
        }

        public override bool CanSeek
        {
            get { return false; }
        }

        public override bool CanWrite
        {
            get { return false; }
        }

        protected override void Dispose(bool disposing)
        {
            try { if (disposing && _stream != null) _stream.Dispose(); }
            finally { base.Dispose(disposing); }
        }

        public override void Flush()
        { }

        bool GetNextStream()
        {
            // Enumerate to new stream...
            if (!_streamEnumerator.MoveNext()) return false;
            if (_streamEnumerator.Current == null) throw new NullReferenceException("The Stream enumerator returned null.");

            // Close the old stream and switch to the new stream.
            if (_stream != null) _stream.Close();
            _stream = _streamEnumerator.Current;

            return true;
        }

        static IEnumerable<Stream> GetNextStream(Func<Stream> getNextStreamCallback)
        {
            Stream stream;
            while ((stream = getNextStreamCallback()) != null)
            {
                yield return stream;
            }
        }

        public override long Length
        {
            get { throw new NotSupportedException(); }
        }

        public override long Position
        {
            get { throw new NotSupportedException(); }
            set { throw new NotSupportedException(); }
        }

        public override int Read(byte[] buffer, int offset, int count)
        {
            if (buffer == null) throw new ArgumentNullException("buffer");
            if (offset < 0) throw new ArgumentOutOfRangeException("offset");
            if (count < 0 || buffer.Length - offset < count) throw new ArgumentOutOfRangeException("count");

            int totalBytesRead = 0;
            while (count > 0)
            {
                int bytesRead = _stream.Read(buffer, offset, count);
                totalBytesRead += bytesRead;
                if (bytesRead < count && !GetNextStream()) break;
                offset += bytesRead;
                count -= bytesRead;
            }

            return totalBytesRead;
        }

        public override int ReadByte()
        {
            int b = -1;
            while ((b = _stream.ReadByte()) == -1 && GetNextStream()) ;
            return b;
        }

        public override long Seek(long offset, SeekOrigin origin)
        {
            throw new NotSupportedException();
        }

        public override void SetLength(long value)
        {
            throw new NotSupportedException();
        }

        public override void Write(byte[] buffer, int offset, int count)
        {
            throw new NotSupportedException();
        }
    }
}
