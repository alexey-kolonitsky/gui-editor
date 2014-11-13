package org.okapp.guieditor.model
{
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;

    import org.kolonitsky.alexey.utils.StringUtils;

    public class DataFile
    {
        public static const WARNING_WRONG_FILE:String = "Wrong file";
        public static const WARNING_WRONG_EXTENSION:String = "Wrong file extension '{extension}'. Should be '{pattern}'";
        public static const WARNING_WRONG_NS:String = "File must contain '{pattern}' namespace";


        /**
         *
         * @param fileNameTemplate with "#" to insert number
         * @param emptyFileContent
         */
        public static function createEmptyFile(nativePath:String, fileNameTemplate:String, emptyFileContent:String):File
        {
            var file:File = new File(nativePath);
            var parentPath:String;

            if (file.isDirectory)
                parentPath = file.nativePath + "\\";
            else
                parentPath = file.parent.nativePath + "\\";

            var i:int = 1;
            var fileName:String = parentPath + fileNameTemplate.replace("#", i);
            var newFile:File = new File(fileName);
            while (newFile.exists)
            {
                i++;
                fileName = parentPath + fileNameTemplate.replace("#", i);
                newFile = new File(fileName);
            }

            return createFile(newFile, emptyFileContent);
        }

        public static function createFile(newFile:File, content:String):File
        {
            var barr:ByteArray = new ByteArray();
            barr.writeUTF(content);

            var stream:FileStream = new FileStream();
            stream.open(newFile, FileMode.WRITE);
            stream.writeBytes(barr, 2, barr.length - 2);
            stream.close();

            return newFile;
        }


        //-----------------------------
        // path
        //-----------------------------

        private var _path:Array;

        public function get path():Array
        {
            return _path;
        }


        //-----------------------------
        // file
        //-----------------------------

        protected var _file:File;

        public function get file():File
        {
            return _file;
        }

        //-----------------------------
        // strBuffer
        //-----------------------------

        public function get strBuffer():String
        {
            return _buffer.toXMLString();
        }


        //-----------------------------
        // buffer
        //-----------------------------

        private var _buffer:XML = null;

        public function get buffer():XML
        {
            return _buffer;
        }


        //-----------------------------
        // Log
        //-----------------------------

        private var _log:String;

        public function get log():String
        {
            return _log
        }


        //-----------------------------
        // is Valid
        //-----------------------------

        private var _isValid:Boolean = false;

        /**
         * This property return true if passed to constructor file has correct
         * extension and
         */
        public function get isValid():Boolean
        {
            return _isValid;
        }


        //-----------------------------
        // constructor
        //-----------------------------

        public function DataFile (file:File, extension:String = null, ns:String = null)
        {
            if (file == null || file.isDirectory || !file.exists)
            {
                _log = WARNING_WRONG_FILE;
                return;
            }

            if (file.extension != extension)
            {
                _log = StringUtils.replacePlaceHolders(WARNING_WRONG_EXTENSION, {extension: file.extension, pattern: extension});
                return;
            }

            _file = file;
            _path = [];

            // pars path
            var parent:File = _file;
            while( (parent = parent.parent) != null)
                _path.unshift(parent.nativePath);

            // path file content
            parseFile(ns);
        }

        /**
         * Replace content on HD by passed in content parameter.
         *
         * @param content
         * @param force
         */
        public function update(content:XML, force:Boolean = false):void
        {
            var strContent:String = content.toXMLString();

            if (strContent == strBuffer && !force)
                return;

            _buffer = content;
            flush();
        }

        public function flush():void
        {
            var stream:FileStream = new FileStream();
            stream.open(_file, FileMode.WRITE);
            stream.writeUTFBytes(strBuffer);
            stream.close();
        }

        protected function parseFile(strNamespace:String):void
        {
            var stream:FileStream = new FileStream();
            stream.open(_file, FileMode.UPDATE);

            var strContent:String = stream.readUTFBytes(stream.bytesAvailable);
            try
            {
                _buffer = XML(strContent);
            }
            catch (error:Error)
            {
                _log = WARNING_WRONG_FILE + "\n" + error.message;
                return;
            }

            _isValid = false;
            var nsArray:Array = _buffer.namespaceDeclarations();
            for each (var ns:Namespace in nsArray)
            {
                if (ns.uri == strNamespace)
                {
                    _isValid = true;
                    break;
                }
            }

            stream.close();

            if ( !_isValid )
                _log = StringUtils.replacePlaceHolders(WARNING_WRONG_NS, {pattern: strNamespace});
        }
    }
}
