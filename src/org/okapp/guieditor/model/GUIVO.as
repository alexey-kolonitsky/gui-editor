package org.okapp.guieditor.model
{
    import flash.events.Event;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;

    public class GUIVO
    {
        //-----------------------------
        // Log messages
        //-----------------------------

        public static const WARNING_WRONG_EXTENSION:String = "Wrong GUI-file extension";
        public static const WARNING_WRONG_FILE:String = "Wrong file";
        public static const WARNING_WRONG_NS:String = "GUI-file must contain " + Constants.OKAPP_GUI_NAMESPACE + " namespace";

        public var file:File;


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
        // is GUI-file
        //-----------------------------

        private var _isGUIFile:Boolean = false;

        /**
         * This property return true if passed to constructor file has correct
         * extension and
         */
        public function get isGUIFile():Boolean
        {
            return _isGUIFile;
        }

        //-----------------------------
        // Constructor
        //-----------------------------

        public function GUIVO(file:File):void
        {
            if (file == null || file.isDirectory)
            {
                _log = WARNING_WRONG_FILE;
                return;
            }

            if (file.extension != Constants.OKAPP_GUI_FILE_EXTENSION)
            {
                _log = WARNING_WRONG_EXTENSION;
                return;
            }

            this.file = file;
            parseFile();
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
            var strBuffet:String = _buffer.toString();

            if (strContent == strBuffet)
                return;

            _buffer = content;

            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.WRITE);
            stream.writeUTFBytes(strBuffet);
            stream.close();
        }



        //-------------------------------------------------------------------
        //
        //  Private
        //
        //-------------------------------------------------------------------

        private function parseFile():void
        {
            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.UPDATE);

            var strContent:String = stream.readUTFBytes(stream.bytesAvailable);
            try
            {
                _buffer = XML(strContent);
            }
            catch (error:Error)
            {
                _log = WARNING_WRONG_FILE + error.message;
                return;
            }

            _isGUIFile = false;
            var nsArray:Array = _buffer.namespaceDeclarations();
            for each (var ns:Namespace in nsArray)
            {
                if (ns.uri == Constants.OKAPP_GUI_NAMESPACE)
                {
                    _isGUIFile = true;
                    break;
                }
            }

            stream.close();

            if ( !_isGUIFile )
                _log = WARNING_WRONG_NS;
        }
    }
}
