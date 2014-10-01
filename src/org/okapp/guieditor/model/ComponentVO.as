package org.okapp.guieditor.model
{
    import flash.events.Event;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;

    public class ComponentVO
    {
        public static const COMPONENT_PATTERN:RegExp = /public\sclass\s\w*\s(extends\s\w*\s)?implements\sIUIElement/im;

        public var name:String;

        public var file:File;

        public function ComponentVO(file:File)
        {
            this.file = file;
            name = file.name;

            if ( !file.isDirectory )
                parsClassFile();
        }

        private var _isComponentFile:Boolean = false;

        public function isComponentFile():Boolean
        {
            return _isComponentFile;
        }

        public function parsClassFile():void
        {
            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.READ);

            var content:String = stream.readUTFBytes(stream.bytesAvailable);
            stream.close();

            trace("ComponentVO> " + file.extension);
            if (content.length == 0)
                _isComponentFile = false;

            var result:Array = COMPONENT_PATTERN.exec(content);
            _isComponentFile = Boolean(result);


        }

        public function getXMLString():String
        {
            return "";
        }

        public function toString():String
        {
            return name;
        }
    }
}
