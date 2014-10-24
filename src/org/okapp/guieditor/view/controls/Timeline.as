package org.okapp.guieditor.view.controls
{
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    import mx.core.UIComponent;

    import spark.components.Image;

    public class Timeline extends UIComponent
    {
        public static const FRAME_WIDTH:Number = 8;
        public static const FRAME_HEIGHT:Number = 16;

        public static const FILL_FRAME_COLOR:uint = 0xFFFFFF;
        public static const EMPTY_FRAME_COLOR:uint = 0x999999;
        public static const SELECTED_FRAME_COLOR:uint = 0x990000;
        public static const TICK_COLOR:uint = 0x999999;


        //-----------------------------
        // frame index
        //-----------------------------

        private var _frameIndex:int = 0;
        private var _frameIndexChanged:Boolean = false;

        public function get frameIndex():int
        {
            return _frameIndex;
        }

        public function set frameIndex(value:int):void
        {
            _frameIndex = value;
            _frameIndexChanged = true;
            invalidateProperties();
            invalidateDisplayList();
        }


        //-----------------------------
        // frames
        //-----------------------------

        private var _frames:Vector.<Image>;

        public function get frames():Vector.<Image>
        {
            return _frames;
        }


        //-----------------------------
        // Constructor
        //-----------------------------

        public function Timeline()
        {
            super();
            _frames = new <Image>[];
            addEventListener(KeyboardEvent.KEY_DOWN, _keyDownHandler)
        }

        private function _keyDownHandler(event:KeyboardEvent):void
        {
            switch (event.keyCode)
            {
                case Keyboard.DELETE:
                    if (_frameIndex in _frames)
                        _frames[_frameIndex] = null;
                    break;
            }
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);

            super.updateDisplayList(unscaledWidth, unscaledHeight);

            graphics.beginFill(EMPTY_FRAME_COLOR);
            graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);

            graphics.beginFill(FILL_FRAME_COLOR);
            graphics.drawRect(0, 0, FRAME_WIDTH * _frames.length, FRAME_HEIGHT);

            graphics.beginFill(SELECTED_FRAME_COLOR);
            graphics.drawRect(_frameIndex * FRAME_WIDTH, 0, FRAME_WIDTH, FRAME_HEIGHT);

        }
    }
}
