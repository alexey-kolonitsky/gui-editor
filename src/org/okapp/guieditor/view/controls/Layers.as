package org.okapp.guieditor.view.controls
{
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.ui.Keyboard;

    import mx.core.UIComponent;

    import spark.components.Image;
    import spark.filters.DropShadowFilter;

    public class Layers extends UIComponent
    {
        public static const HOVER_FRAME_COLOR:uint = 0x9DC1F5;
        public static const SELECTED_FRAME_COLOR:uint = 0x4C8CE6;

        //-----------------------------
        // current index
        //-----------------------------

        private var _currentIndex:int = 0;
        private var _currentIndexChanged:Boolean = true;

        public function get currentIndex():int
        {
            return _currentIndex;
        }

        public function set currentIndex(value:int):void
        {
            _currentIndex = value;
            _currentIndexChanged = true;
            invalidateProperties();
            invalidateDisplayList();
        }


        //-----------------------------
        // layers
        //-----------------------------

        private var _layers:Vector.<Timeline>;

        public  function get layers():Vector.<Timeline>
        {
            return _layers;
        }


        //-----------------------------
        // size
        //-----------------------------

        private var _size:int = 0;

        public function get size():int
        {
            return _size;
        }


        //-----------------------------
        // selectedLayer
        //-----------------------------

        public function get selectedLayer():Timeline
        {
            if (selectedLayerIndex != -1)
                return _layers[selectedLayerIndex];

            return null
        }


        //-----------------------------
        // selectedLayer
        //-----------------------------

        private var _frameContentChanged:Boolean = false;

        public function get frameContentChanged():Boolean
        {
            return _frameContentChanged;
        }

        public function frameContentRendered():void
        {
            _frameContentChanged = false;
        }


        //-----------------------------
        // Constructor
        //-----------------------------

        public function Layers()
        {
            selectedLayerIndex = 0;
            selectedFrameIndex = 0;

            var timeline:Timeline = new Timeline();
            _layers = new <Timeline>[ timeline ];
            addChild(timeline);

            filters = [ new DropShadowFilter(4, 90, 0x666666, 0.5) ];

            addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        }

        public function toXML():XML
        {
            var result:XML = <animation />;

            for each (var timeline:Timeline in _layers)
                result.appendChild(timeline.toXML());

            return result;
        }

        public function fromXML(value:XML):void
        {
            for each (var timelineNode:XML in value.timeline)
            {
                var timeline:Timeline = new Timeline();
                timeline.fromXML(timelineNode);
            }
        }


        public function addImage(image:Image, nativePath:String):void
        {
            var timeline:Timeline, frame:TimelineFrame;
            if (selectedLayer == null)
            {
                trace("No one layer is selected. Please choose frame to place.");
                return;
            }

            var type:String = selectedLayer.getFrameType(_currentIndex);
            switch ( type )
            {
                case TimelineFrame.TYPE_FRAME:
                    frame = addKeyframe();
                    frame.content = image;
                    frame.url = nativePath;
                    break;

                case TimelineFrame.TYPE_KEYFRAME:
                    frame = selectedLayer.getKeyframe(_currentIndex);
                    if ( frame.isEmpty )
                    {
                        frame.content = image;
                        frame.url = nativePath;
                    }
                    else
                    {
                        timeline = new Timeline();
                        timeline.frameIndex = _currentIndex;

                        frame = timeline.getKeyframe(0);
                        frame.content = image;
                        frame.url = nativePath;

                        selectedLayerIndex++;

                        _layers.splice(selectedLayerIndex, 0, timeline);
                        addChildAt(timeline, selectedLayerIndex);

                        invalidateSize();
                    }
                    break;

                case TimelineFrame.TYPE_NOT_EXISTS:
                    frame = addKeyframe();
                    frame.content = image;
                    frame.url = nativePath;
                    break;

                default:
                    trace("UNEXPECTED_FRAME_TYPE");
                    break;
            }

            _frameContentChanged = true;

            selectedLayer.invalidateDisplayList();

            invalidateDisplayList();
            invalidateSize();
        }


        private var hoverFrameIndex:int = -1;
        private var hoverLayerIndex:int = -1;

        private var selectedFrameIndex:int;
        private var selectedLayerIndex:int;

        private var rule:TimelineRule;
        private var playHead:TimelinePlayHead;

        private var hoverFrame:VisualFrame;
        private var selectedFrame:VisualFrame;


        //-------------------------------------------------------------------
        // Override Component API
        //-------------------------------------------------------------------

        override protected function createChildren():void
        {
            super.createChildren();

            if (rule == null)
            {
                rule = new TimelineRule();
                rule.left = 0;
                rule.right = 0;
                rule.top = 0;
                rule.height = TimelineRule.DEFAULT_HEIGHT;

                addChild(rule);
            }

            if (playHead == null)
            {
                playHead = new TimelinePlayHead();
                playHead.top = 0;
                playHead.left = 0;
                playHead.bottom = 0;
                addChild(playHead);
            }

            if (hoverFrame == null)
            {
                hoverFrame = new VisualFrame(HOVER_FRAME_COLOR);
                hoverFrame.visible = false;
                addChild(hoverFrame);
            }

            if (selectedFrame == null)
            {
                selectedFrame = new VisualFrame(SELECTED_FRAME_COLOR);
                selectedFrame.visible = false;
                addChild(selectedFrame);
            }
        }


        override protected function commitProperties():void
        {
            super.commitProperties();

            if (_currentIndexChanged)
            {
                for each (var timeline:Timeline in _layers)
                    timeline.frameIndex = _currentIndex;

                playHead.x = Timeline.FRAME_WIDTH * _currentIndex + 1;

                _currentIndexChanged = false;
            }
        }

        override protected function measure():void
        {
            super.measure();

            var maxLenght:int = 0;
            var n:int = _layers.length;
            for (var i:int = 0; i < n; i++)
                if (maxLenght < _layers[i].keyframes.length)
                    maxLenght = _layers[i].keyframes.length;

            measuredWidth = maxLenght * Timeline.FRAME_WIDTH;
            measuredHeight = _layers.length * Timeline.FRAME_HEIGHT;
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);

            if (hoverLayerIndex == -1 || hoverFrameIndex == -1)
            {
                hoverFrame.visible = false;
            }
            else
            {
                hoverFrame.x = hoverFrameIndex * Timeline.FRAME_WIDTH;
                hoverFrame.y = hoverLayerIndex * Timeline.FRAME_HEIGHT + TimelineRule.DEFAULT_HEIGHT;
                hoverFrame.visible = true;
            }

            if (selectedFrameIndex == -1 || selectedFrameIndex == -1)
            {
                selectedFrame.visible = false;
            }
            else
            {
                selectedFrame.x = selectedFrameIndex * Timeline.FRAME_WIDTH;
                selectedFrame.y = selectedLayerIndex * Timeline.FRAME_HEIGHT + TimelineRule.DEFAULT_HEIGHT;
                selectedFrame.visible = true;
            }

            graphics.clear();
            graphics.beginFill(0xCCCCCC);
            graphics.drawRect(0, TimelineRule.DEFAULT_HEIGHT, unscaledWidth, layers.length * Timeline.FRAME_HEIGHT);

            graphics.beginFill(Timeline.TICK_COLOR);
            var n:int = unscaledWidth / Timeline.FRAME_WIDTH;
            for (var i:int = 0; i < n; i++)
            {
                var tickWidth:int = (i % 5) == 0 ? Timeline.FRAME_WIDTH : 1;
                var tickHeight:int = Timeline.FRAME_HEIGHT * _layers.length;
                var tickX:int = i * Timeline.FRAME_WIDTH;
                graphics.drawRect(tickX, TimelineRule.DEFAULT_HEIGHT, tickWidth, tickHeight);
            }

            graphics.endFill();

            var n:int = _layers.length;
            for (var i:int = 0; i < n; i++)
            {
                var timeline:Timeline = _layers[i];
                timeline.x = 0;
                timeline.y = i * (Timeline.FRAME_HEIGHT + 1) + TimelineRule.DEFAULT_HEIGHT;
            }

            if (rule)
            {
                rule.explicitWidth = unscaledWidth;
                rule.explicitHeight = unscaledHeight;
                rule.invalidateDisplayList();
            }
        }


        //-------------------------------------------------------------------
        // Event handlers
        //-------------------------------------------------------------------

        private function addedToStageHandler(event:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);

            addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);

        }

        private function mouseUpHandler(event:MouseEvent):void
        {
            selectedFrameIndex = hoverFrameIndex;
            selectedLayerIndex = hoverLayerIndex;
            currentIndex = selectedFrameIndex;
        }

        private function stage_mouseMoveHandler(event:MouseEvent):void
        {
            hoverFrameIndex = -1;
            hoverLayerIndex = -1;

            var b:Rectangle = this.getBounds(stage);
            var left:Number = b.left;
            var right:Number = b.right;
            var top:Number = b.top + TimelineRule.DEFAULT_HEIGHT;
            var bottom:Number = top + _layers.length * (Timeline.FRAME_HEIGHT + 1);

            if (event.stageX < left)
                return;

            if (event.stageX > right)
                return;

            if (event.stageY < top)
                return;

            if (event.stageY > bottom)
                return;

            hoverFrameIndex = Math.floor((event.stageX - left) / Timeline.FRAME_WIDTH);
            hoverLayerIndex = Math.floor((event.stageY - top) / Timeline.FRAME_HEIGHT);
            invalidateDisplayList();
        }

        /**
         * Add empty keyframe to current layer
         */
        private function addKeyframe():TimelineFrame
        {
            if ( !(selectedLayerIndex in _layers) )
            {
                trace("WARNING: Incorrect selected layer index: " + selectedLayerIndex + ", layers number " + _layers.length);
                return null;
            }

            if ( (selectedFrameIndex == -1) )
            {
                trace("WARNING: Incorrect selected frame index: " + selectedFrameIndex);
                return null;
            }

            var frame:TimelineFrame = selectedLayer.addKeyframe(selectedFrameIndex);

            if (selectedLayer.size > _size)
                _size = selectedLayer.size;

            return frame;
        }

        /**
         * Add empty frame to curren keyframe
         */
        private function addFrame():void
        {
            if ( !(selectedLayerIndex in _layers) )
            {
                trace("WARNING: Incorrect selected layer index: " + selectedLayerIndex + ", layers number " + _layers.length);
                return;
            }

            if ( (selectedFrameIndex == -1) )
            {
                trace("WARNING: Incorrect selected frame index: " + selectedFrameIndex);
                return;
            }

            var timeline:Timeline = _layers[selectedLayerIndex];
            timeline.addFrame();

            if (timeline.size > _size)
                _size = timeline.size;
        }

        private function stage_keyDownHandler(event:KeyboardEvent):void
        {
            switch (event.keyCode)
            {
                case Keyboard.LEFT:
                    movePlayheadBy(-1);
                    break;

                case Keyboard.RIGHT:
                    movePlayheadBy(+1);
                    break;

                case Keyboard.F7: // move forward and add keyframe
                    currentIndex++;
                    selectedFrameIndex = currentIndex;
                    addKeyframe();
                    break;

                case Keyboard.F5: // add frame
                    addFrame();
                    break;

                case Keyboard.F6: // add keyframe
                    addKeyframe();
                    break;
            }
        }

        private function movePlayheadBy(delta:int):void
        {
            var newIndex:int = currentIndex + delta;

            if (newIndex < 0)
            {
                currentIndex = 0;
            }
            else if (newIndex >= size)
            {
                currentIndex = size -1;
            }
            else
            {
                currentIndex = newIndex;
            }
        }
    }
}
