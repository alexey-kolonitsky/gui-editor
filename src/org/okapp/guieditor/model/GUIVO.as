package org.okapp.guieditor.model
{
    import flash.events.Event;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;

    public class GUIVO
    {
        public static const OKAPP_GUI_NAMESPACE:String = "http://wwww.okapp.ru/gui/0.1";
        public static const EXTENSION:String = "xml";

        public var file:File;
        public var buffer:XML;

        public function GUIVO(file:File):void
        {
            if (file.extension != EXTENSION)
                return;

            this.file = file;

            parseFile();
        }

        private function parseFile():void
        {
            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.UPDATE);

            buffer = XML(stream.readUTFBytes(stream.bytesAvailable));

            _isGUIFile = false;
            var nsArray:Array = buffer.namespaceDeclarations();
            for each (var ns:Namespace in nsArray)
            {
                if (ns.uri == OKAPP_GUI_NAMESPACE)
                {
                    _isGUIFile = true;
                    break;
                }
            }

            stream.close();

        }

        public function flush():void
        {
            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.WRITE);
            stream.writeUTFBytes(buffer.toXMLString());
            stream.close();
        }

        private var _isGUIFile:Boolean = false;

        public function get isGUIFile():Boolean
        {
            return _isGUIFile;
        }
    }
}
