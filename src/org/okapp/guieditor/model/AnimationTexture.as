package org.okapp.guieditor.model
{

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;

    import mx.core.UIComponent;

    /**
     * File to pass animation texture to Texture Viewer and canvas.
     */
    public class AnimationTexture extends EventDispatcher
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
        //  Frame
        //-----------------------------

        private var _frame:UIComponent = null;

        public function get frame():UIComponent
        {
            return _frame;
        }



        //-----------------------------
        //  Images
        //-----------------------------

        private var _image:Bitmap = null;

        /**
         * Loader object with image loaded to application.
         */
        public function get image():Bitmap
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

            _frame = new UIComponent();
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

            var loader:Loader = new Loader();
            loader.loadBytes(barrContent);
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, image_completeHandler);

            _isValid = true;
        }

        private function image_completeHandler(event:Event):void
        {
            var loader:LoaderInfo = event.currentTarget as LoaderInfo;

            _image = loader.content as Bitmap;

            var bmd:BitmapData = _image.bitmapData;

            _frame.graphics.beginBitmapFill(bmd);
            _frame.graphics.drawRect(0, 0, bmd.width, bmd.height);
            _frame.graphics.endFill();
        }


    }
}
