package org.okapp.guieditor.model
{
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;

    public class AnimationTexture
    {
        public static const TEXTURE_FILENAME_PATTERN:RegExp = /^(?P<name>[a-z0-9_]*)\.png$/i;

        //-----------------------------
        // files
        //-----------------------------

        private var _file:File;

        public function get file():File
        {
            return _file;
        }


        //-----------------------------
        // Name
        //-----------------------------

        private var _name:String = "";

        public function get name():String
        {
            return _name;
        }


        //-----------------------------
        //  Images
        //-----------------------------

        private var _image:Loader;

        public function get image():Loader
        {
            return _image;
        }

        //-----------------------------
        // Constructor
        //-----------------------------

        public function AnimationTexture()
        {

        }

        public function checkFile(file:File):Boolean
        {
            var fn:String = file.name;
            var result:Array = fn.match(TEXTURE_FILENAME_PATTERN);

            if (result == null)
                return false;

            return result.name == _name;
        }

        public function addFile(file:File):Boolean
        {
            var fn:String = file.name;
            var result:Array = TEXTURE_FILENAME_PATTERN.exec(fn);

            if (_file == null)
                _name = result.name;

            _file = file;

            var barrContent:ByteArray = new ByteArray();

            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.READ);
            stream.readBytes(barrContent, 0, stream.bytesAvailable);
            stream.close();

            var loader:Loader = new Loader();
            loader.loadBytes(barrContent);

            _image = loader;

            return Boolean(result);
        }


    }
}
