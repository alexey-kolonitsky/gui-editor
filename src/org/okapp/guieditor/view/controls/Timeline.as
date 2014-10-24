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

        public static const FILL_FRAME_COLOR:uint = 0x666666;
        public static const EMPTY_FRAME_COLOR:uint = 0xFFFFFF;
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

        /**
         * Set new keyframe at frameIndex position on timeline
         */
        public function addKeyframe(frameIndex:int):TimelineFrame
        {
            var currentFrame:TimelineFrame;
            var newFrame:TimelineFrame = new TimelineFrame(frameIndex);

            if (frameIndex < size)
            {
                // detect current frame duration
                currentFrame = getKeyframe(frameIndex);
                currentFrame.size = newFrame.startIndex - currentFrame.startIndex;

                // detect new frame duration
                newFrame.size = size - frameIndex;
                for each (var kf:TimelineFrame in _keyframes)
                {
                    if (kf.startIndex > frameIndex)
                    {
                        newFrame.size = kf.startIndex - frameIndex;
                        break;
                    }
                }
            }
            else
            {
                newFrame.size = 1;
                currentFrame = _keyframes[_keyframes.length - 1];
                if (currentFrame)
                    currentFrame.size = frameIndex - currentFrame.startIndex;
            }

            var i:int = _keyframes.indexOf(currentFrame);
            _keyframes.splice(i + 1, 0, newFrame);

            invalidateDisplayList();

            return newFrame;
        }

        /**
         * Add size to current keyframe.
         */
        public function addFrame(num:int = 1):void
        {
            var currentFrame:TimelineFrame = getKeyframe(frameIndex);
            currentFrame.size += num;

            invalidateDisplayList();
        }

        public function cloneFrameContent(source:TimelineFrame, distenation:TimelineFrame):void
        {

        }


        //-----------------------------
        // frames
        //-----------------------------

        private var _keyframes:Vector.<TimelineFrame>;

        public function get keyframes():Vector.<TimelineFrame>
        {
            return _keyframes;
        }


        //-----------------------------
        // size
        //-----------------------------

        public function get size():int
        {
            if (_keyframes.length)
            {
                var lastFrame:TimelineFrame = _keyframes[_keyframes.length - 1];
                return lastFrame.startIndex + lastFrame.size;
            }

            return 0;
        }


        //-----------------------------
        // Constructor
        //-----------------------------

        public function Timeline()
        {
            super();

            var firstFrame:TimelineFrame = new TimelineFrame(0, null);

            _keyframes = new <TimelineFrame>[ firstFrame ];

            invalidateDisplayList();
        }

        public function getFrameType(frameIndex:int):String
        {
            if (frameIndex > size)
                return TimelineFrame.TYPE_NOT_EXISTS;

            var frame:TimelineFrame = getKeyframe(frameIndex);
            if (frame == null)
            {
                trace("WARNING: Unexpected frame index: " + frameIndex);
                return TimelineFrame.TYPE_NOT_EXISTS;
            }

            if (frame.startIndex == frameIndex)
                return TimelineFrame.TYPE_KEYFRAME;

            return TimelineFrame.TYPE_FRAME;
        }

        public function getKeyframe(frameIndex:int):TimelineFrame
        {
            var result:TimelineFrame = null;

            for each (var frame:TimelineFrame in _keyframes)
                if (frame.startIndex <= frameIndex)
                    result = frame;

            return result;
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);

            graphics.clear();

            var n:int = _keyframes.length;
            for (var i:int = 0; i < n; i++)
            {
                var frame:TimelineFrame = _keyframes[i];
                var frameX:Number = frame.startIndex * FRAME_WIDTH;

                graphics.lineStyle(1, 0x000000);

                graphics.beginFill(frame.isEmpty ? EMPTY_FRAME_COLOR : FILL_FRAME_COLOR);
                graphics.drawRect(frameX, 0, FRAME_WIDTH * frame.size, FRAME_HEIGHT);

                graphics.beginFill(frame.isEmpty ? EMPTY_FRAME_COLOR : 0x000000);
                graphics.drawCircle(frameX + FRAME_WIDTH / 2, FRAME_HEIGHT / 2, FRAME_WIDTH / 4);
            }

            graphics.endFill();
        }
    }
}
