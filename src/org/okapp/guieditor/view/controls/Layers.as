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

    public class Layers extends UIComponent
    {
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

        public function Layers()
        {
            _layers = new <Timeline>[];
            addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        }

        private function addedToStageHandler(event:Event):void
        {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
        }

        private function stage_mouseMoveHandler(event:MouseEvent):void
        {
            colIndex = -1;
            rowIndex = -1;
            var b:Rectangle = this.getBounds(stage);
            if (event.stageX < b.left)
                return;

            if (event.stageX > b.right)
                return;

            if (event.stageY < b.top)
                return;

            if (event.stageY > b.bottom)
                return;

            colIndex = Math.floor((event.stageX - b.left) / Timeline.FRAME_WIDTH);
            rowIndex = Math.floor((event.stageY - b.top) / Timeline.FRAME_HEIGHT);
            invalidateDisplayList();
        }

        private var colIndex:int = -1;
        private var rowIndex:int = -1;

        private function stage_keyDownHandler(event:KeyboardEvent):void
        {
            switch (event.keyCode)
            {
                case Keyboard.LEFT:
                    currentIndex--;
                    break;

                case Keyboard.RIGHT:
                    currentIndex++;
                    break;

                case Keyboard.F7:
                    currentIndex++;
                    break;

                case Keyboard.F6:
                    currentIndex++;
                    break;
            }
        }

        public function addImage(image:Image):void
        {
            var timeline:Timeline;
            var n:int = _layers.length;
            for (var i:int = 0; i < n; i++)
            {
                timeline = _layers[i];
                if (_currentIndex in timeline.frames && timeline.frames[_currentIndex])
                    continue;

                timeline.frames[_currentIndex] = image;
                timeline.invalidateDisplayList();
                return;
            }

            timeline = new Timeline();
            timeline.frames[_currentIndex] = image;
            timeline.frameIndex = _currentIndex;
            _layers.push(timeline);

            addChild(timeline);

            invalidateDisplayList();
            invalidateSize();
        }




        //-------------------------------------------------------------------
        // Override Component API
        //-------------------------------------------------------------------

        override protected function createChildren():void
        {
            super.createChildren();
        }


        override protected function commitProperties():void
        {
            super.commitProperties();

            if (_currentIndexChanged)
            {
                for each (var timeline:Timeline in _layers)
                    timeline.frameIndex = _currentIndex;

                _currentIndexChanged = false;
            }
        }

        override protected function measure():void
        {
            super.measure();

            var maxLenght:int = 0;
            var n:int = _layers.length;
            for (var i:int = 0; i < n; i++)
                if (maxLenght < _layers[i].frames.length)
                    maxLenght = _layers[i].frames.length;

            measuredWidth = maxLenght * Timeline.FRAME_WIDTH;
            measuredHeight = _layers.length * Timeline.FRAME_HEIGHT;
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            graphics.clear();

            if (rowIndex != -1 && colIndex != -1)
            {
                graphics.beginFill(0xFFFF00);
                graphics.drawRect(colIndex * Timeline.FRAME_WIDTH, rowIndex * Timeline.FRAME_HEIGHT, Timeline.FRAME_WIDTH, Timeline.FRAME_HEIGHT);
                graphics.endFill();
            }

            graphics.beginFill(Timeline.TICK_COLOR);
            var n:int = unscaledWidth / Timeline.FRAME_WIDTH;
            for (var i:int = 0; i < n; i++)
                graphics.drawRect(i * Timeline.FRAME_WIDTH, 0, 1, Timeline.FRAME_HEIGHT);




            var n:int = _layers.length;
            for (var i:int = 0; i < n; i++)
            {
                var timeline:Timeline = _layers[i];
                timeline.x = 0;
                timeline.y = i * (Timeline.FRAME_HEIGHT + 1);
            }
        }
    }
}
