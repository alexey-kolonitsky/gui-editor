package org.okapp.guieditor.model
{
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;

    /**
     * File to pass animation texture to Texture Viewer and canvas.
     */
    public class AnimationTexture
    {
        public static const TEXTURE_FILENAME_PATTERN:RegExp = /^(?P<name>[a-z0-9_]*)\.png$/i;

        //-----------------------------
        // isValid
        //-----------------------------

        private var _isValid:Boolean;

        /**
         *  flag to indicate that file texture created successfully
         */
        public function get isValid():Boolean
        {
            return _isValid;
        }

        //-----------------------------
        // files
        //-----------------------------

        private var _file:File;

        /**
         * Reference to File object opened as base for texture.
         */
        public function get file():File
        {
            return _file;
        }


        //-----------------------------
        // Name
        //-----------------------------

        private var _name:String = "";

        /**
         * Texture name. Generally it is filename without extension and frame
         * index.
         */
        public function get name():String
        {
            return _name;
        }


        //-----------------------------
        //  Images
        //-----------------------------

        private var _image:Loader;

        /**
         * Loader object with image loaded to application.
         */
        public function get image():Loader
        {
            return _image;
        }


        //-----------------------------
        // Native Path
        //-----------------------------

        private var _nativePath:String = null;

        public function get nativePath():String
        {
            return _nativePath;
        }

        //-----------------------------
        // Constructor
        //-----------------------------

        public function AnimationTexture(file:File)
        {
            if (file == null)
            {
                trace("WARNING: AnimationTexture. file parameter must be not NULL");
                return;
            }

            if (!file.exists || file.isHidden || file.isDirectory || file.isPackage || file.isSymbolicLink)
            {
                return;
            }

            _file = file;
            _nativePath = _file.nativePath;

            var result:Array = TEXTURE_FILENAME_PATTERN.exec(_file.name);
            if (result == null)
            {
                trace("WARNING: AnimationTexture. Wrong file name");
                return;
            }

            _name = result.name;

            // load local file in memory
            var barrContent:ByteArray = new ByteArray();

            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.READ);
            stream.readBytes(barrContent, 0, stream.bytesAvailable);
            stream.close();

            _image = new Loader();
            _image.loadBytes(barrContent);

            _isValid = true;
        }


    }
}
