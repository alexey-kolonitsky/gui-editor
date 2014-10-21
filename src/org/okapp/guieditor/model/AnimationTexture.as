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
        public static const TEXTURE_FILENAME_PATTERN:RegExp = /^(?P<name>[a-z_]*)(?P<state>_[a-z0-9_]*)\.png$/i;

        //-----------------------------
        // files
        //-----------------------------

        private var _files:Vector.<File>;

        private function get files():Vector.<File>
        {
            return _files;
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

        private var _images:Vector.<Loader>;

        public function get images():Vector.<Loader>
        {
            return _images;
        }



        //-----------------------------
        // states
        //-----------------------------

        private var _states:Array;

        public function get states():Array
        {
            return _states;
        }

        //-----------------------------
        // Constructor
        //-----------------------------

        public function AnimationTexture()
        {
            _files = new <File>[];
            _images = new <Loader>[];
            _states = [];
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

            if (_files.length == 0)
                _name = result.name;

            _files.push(file);
            _states.push(result.state);

            var barrContent:ByteArray = new ByteArray();

            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.READ);
            stream.readBytes(barrContent, 0, stream.bytesAvailable);
            stream.close();

            var loader:Loader = new Loader();
            loader.loadBytes(barrContent);

            _images.push(loader);

            return Boolean(result);
        }


    }
}
