package org.okapp.guieditor.view.controls.timeline
{
    import flash.filesystem.File;
    import flash.geom.Matrix;

    import mx.controls.Label;

    import mx.core.UIComponent;

    import org.okapp.guieditor.model.AnimationTexture;

    public class Timeline extends UIComponent
    {
        /**
         * Left margin used to display layer name
         */
        public static const LEFT_MARGIN:Number = 80;

        public static const FRAME_WIDTH:Number = 8;
        public static const FRAME_HEIGHT:Number = 16;

        public static const FILL_FRAME_COLOR:uint = 0x666666;
        public static const EMPTY_FRAME_COLOR:uint = 0xFFFFFF;
        public static const TICK_COLOR:uint = 0x999999;


        //-----------------------------
        // color
        //-----------------------------

        private var _color:uint = 0x000000;
        private var _colorChanged:Boolean = false;

        public function get color():uint
        {
            return _color;
        }

        public function set color(value:uint):void
        {
            _color = value;
            _colorChanged = true;
            invalidateDisplayList();
        }


        //-----------------------------
        // isVisible
        //-----------------------------

        private var _isVisible:Boolean = true;
        private var _isVisibleChanged:Boolean = false;

        public function get isVisible():Boolean
        {
            return _isVisible;
        }

        public function set isVisible(value:Boolean):void
        {
            _isVisible = value;
            _isVisibleChanged = true;
            invalidateDisplayList();
        }


        //-----------------------------
        // layerName
        //-----------------------------

        private var _layerName:String = "noname";
        private var _layerNameChanged:Boolean = true;

        public function get layerName():String
        {
            return _layerName;
        }

        public function set layerName(value:String):void
        {
            _layerName = value;
            _layerNameChanged = true;
            invalidateProperties();
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
        public function addFrame(frameIndex:int, num:int = 1):void
        {
            var currentFrame:TimelineFrame;
            if (frameIndex > size)
            {
                currentFrame = _keyframes[keyframes.length - 1];
                num = frameIndex - size + 1;
            }
            else
            {
                currentFrame = getKeyframe(frameIndex);
            }

            currentFrame.size += num;
            updateStartIndex();

            invalidateDisplayList();
        }


        //-----------------------------
        // frames
        //-----------------------------

        private var _keyframes:Vector.<TimelineFrame>;

        /**
         * List of keyframes
         */
        public function get keyframes():Vector.<TimelineFrame>
        {
            return _keyframes;
        }


        //-----------------------------
        // size
        //-----------------------------

        /**
         * count of keyframes in timeline
         */
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

        /**
         *
         * @param frameIndex
         * @return
         */
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
            if (frameIndex > size)
                return null;

            var result:TimelineFrame = null;
            for each (var frame:TimelineFrame in _keyframes)
                if (frame.startIndex <= frameIndex)
                    result = frame;

            return result;
        }

        public function toXML():XML
        {
            var result:XML = <timeline color={_color} visible={_isVisible} name={_layerName} />;

            var n:int = _keyframes.length;
            for (var i:int = 0; i < n; i++)
            {
                var keyframe:TimelineFrame  = _keyframes[i];
                if ( keyframe.isEmpty )
                    continue;

                var img:UIComponent = keyframe.content;
                var m:Matrix = img.transform.matrix;
                var strTransform:String = m.a + ", " + m.b + ", " + m.c + ", " + m.d + ", " + m.tx + ", " + m.ty;

                var keyframeNode:XML = <keyframe startIndex="" size="" content="" />;
                keyframeNode.@startIndex = keyframe.startIndex;
                keyframeNode.@size = keyframe.size;
                keyframeNode.@content = keyframe.url;
                keyframeNode.@matrix = strTransform;

                result.appendChild(keyframeNode);
            }

            return result;
        }

        /**
         *
         * @param value
         */
        public function fromXML(value:XML):void
        {
            default xml namespace = Constants.OKAPP_ANIMATION_MODEL_NS;

            if (value.keyframe.length() == 0)
                return;

            _isVisible = true;
            if ("@visible" in value)
                _isVisible = String(value.@visible) == "true";

            _color = 0x000000;
            if ("@color" in value)
                _color = parseInt(String(value.@color), 16);

            _layerName = "noname";
            if ("@name" in value)
                _layerName = String(value.@name);

            _keyframes.length = 0;

            for each (var keyframeNode:XML in value.keyframe)
            {
                var fn:String = String(keyframeNode.@content);
                var texture:AnimationTexture = new AnimationTexture(new File(fn));


                if ( !texture.isValid )
                {
                    trace("Invalid loaded file: " + fn);
                    return;
                }

                var keyframe:TimelineFrame = new TimelineFrame();
                keyframe.startIndex = keyframeNode.@startIndex;
                keyframe.size = keyframeNode.@size;
                keyframe.url = texture.nativePath;
                keyframe.texture = texture;
                _keyframes.push(keyframe);
            }

            invalidateProperties();
            invalidateDisplayList();
        }




        //-------------------------------------------------------------------
        // UIComponent implementation
        //-------------------------------------------------------------------

        override protected function createChildren():void
        {
            super.createChildren();

            if (lblName == null)
            {
                lblName = new Label();
                lblName.y = 0;
                lblName.x = FRAME_HEIGHT;
                lblName.width = LEFT_MARGIN;
                lblName.height = FRAME_HEIGHT;
                addChild(lblName);
            }
        }

        override protected function commitProperties():void
        {
            super.commitProperties();

            if (lblName && _layerNameChanged)
            {
                lblName.text = _layerName;
                _layerNameChanged = false;
            }
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);

            var frameH2:int = FRAME_HEIGHT >> 1;
            var frameW2:int = FRAME_WIDTH >> 1;

            graphics.clear();
            graphics.beginFill(Constants.COLOR_INTERFACE_INACTIVE);
            graphics.drawRect(0, 0, LEFT_MARGIN, FRAME_HEIGHT);
            graphics.endFill();

            if (_isVisible)
                graphics.beginFill(_color);
            else
                graphics.lineStyle(1, _color);

            // draw visible marker
            graphics.drawCircle(frameH2, frameH2, frameH2 >> 1);
            graphics.lineStyle();
            graphics.endFill();

            // draw keyframes
            var n:int = _keyframes.length;
            for (var i:int = 0; i < n; i++)
            {
                var frame:TimelineFrame = _keyframes[i];
                var frameX:Number = LEFT_MARGIN + frame.startIndex * FRAME_WIDTH;

                graphics.lineStyle(1, 0x000000);

                graphics.beginFill(frame.isEmpty ? EMPTY_FRAME_COLOR : FILL_FRAME_COLOR);
                graphics.drawRect(frameX, 0, FRAME_WIDTH * frame.size, FRAME_HEIGHT);

                graphics.beginFill(frame.isEmpty ? EMPTY_FRAME_COLOR : 0x000000);
                graphics.drawCircle(frameX + frameW2, frameH2, frameW2 >> 1);
            }

            graphics.lineStyle(1, 0x000000);
            graphics.endFill();
        }


        //-------------------------------------------------------------------
        //
        // Private
        //
        //-------------------------------------------------------------------

        private var lblName:Label = null;



        /**
         *
         */
        private function updateStartIndex():void
        {
            var startIndex:int = 0;
            for each (var keyframe:TimelineFrame in _keyframes)
            {
                keyframe.startIndex = startIndex;
                startIndex += keyframe.size;
            }
        }
    }
}
