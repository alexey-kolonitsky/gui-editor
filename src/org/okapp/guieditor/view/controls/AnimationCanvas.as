package org.okapp.guieditor.view.controls
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.filters.GlowFilter;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.ui.Keyboard;
    import flash.utils.Timer;

    import mx.containers.Canvas;
    import mx.core.UIComponent;

    import spark.components.Image;

    public class AnimationCanvas extends Canvas
    {


        //-----------------------------
        // Constructor
        //-----------------------------

        public function AnimationCanvas(layers:Layers)
        {
            super();

            if (layers == null)
                throw new Error("layers parameter must be NOT NULL!");

            addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
             addEventListener(MouseEvent.MOUSE_DOWN, element_mouseDownHandler);
             addEventListener(MouseEvent.ROLL_OVER, element_rollOverHandler);
             addEventListener(MouseEvent.ROLL_OUT, element_rollOutHandler);

            this.layers = layers;

            lastRenderedFrame = -1;

            updateTimer = new Timer(33);
            updateTimer.addEventListener(TimerEvent.TIMER, updateTimer_timerHandler);
            updateTimer.start();

            var s:Sprite = new Sprite();
           s.graphics.beginFill(0xCCCCCC);
           s.graphics.drawRect(0, 0, 60, 30);
           s.graphics.endFill();

           s.graphics.moveTo(30, 0);

           s.graphics.beginFill(0xEEEEEE);
           s.graphics.moveTo(30, 0);
           s.graphics.lineTo(60, 15);
           s.graphics.lineTo(30, 30);
           s.graphics.lineTo(0, 15);
           s.graphics.endFill();

           bmdCell = new BitmapData(60, 30, false);
           bmdCell.draw(s);

            var img:Image = new Image();
            img.source = bmdCell;
            addChild(img)
        }

        private function addedToStageHandler(event:Event):void
        {
            stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyDownHandler);
        }



        private function element_rollOverHandler(event:MouseEvent):void
        {
            var target:Image = event.target as Image;
            if (target)
                target.filters = [ new GlowFilter(0xFF0000) ];
        }

        private function element_rollOutHandler(event:MouseEvent):void
        {
            var target:Image = event.target as Image;
            if (target)
                target.filters = [ ];
        }

        private var dragObject:Image = null;
        private var dragObjectOriginalPosition:Point = new Point();

        private var dragOffset:Point = new Point();


        private var _selectedObject:Image = null;

        public function get selectedObject():Image
        {
            return _selectedObject;
        }

        private function element_mouseDownHandler(event:MouseEvent):void
        {
            var target:Image = event.currentTarget as Image;
            if (target == null)
            {
                _selectedObject = null;
            }

            dragOffset.x = event.stageX;
            dragOffset.y = event.stageY;


            if (target)
            {
                target.filters = [ new GlowFilter(0xFF0000) ];
                dragObject = target;

                dragObjectOriginalPosition.x = dragObject.x;
                dragObjectOriginalPosition.y = dragObject.y;

                stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
                stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
            }
        }


        private function stage_mouseUpHandler(event:MouseEvent):void
        {
            _selectedObject = dragObject;
            dragObject = null;

            stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
        }

        private function stage_mouseMoveHandler(event:MouseEvent):void
        {
            if (dragObject)
            {
                var dx:Number = event.stageX - dragOffset.x;
                var dy:Number = event.stageY - dragOffset.y;
                dragObject.x = dragObjectOriginalPosition.x + dx;
                dragObject.y = dragObjectOriginalPosition.y + dy;
            }
        }

        private function element_mouseUpHandler(event:MouseEvent):void
        {
            var target:Image = event.currentTarget as Image;
            if (target)
                target.filters = [ new GlowFilter(0xFF0000) ];
        }

        private function stage_keyDownHandler(event:KeyboardEvent):void
        {
            switch (event.keyCode)
            {
                case Keyboard.DELETE:
                    var n:int = layers.layers.length;
                    var index:int = layers.currentIndex;
                    for (var i:int = 0; i < n; i++)
                    {
                        var timeline:Timeline = layers.layers[i];
                        var frame:TimelineFrame = timeline.getKeyframe(index);
                        if (frame && frame.content == selectedObject)
                        {
                            frame.content = null;
                            break;
                        }
                    }
                    break;
            }
        }

        private var bmdCell:BitmapData;

        /**
         * Remove all exists elements on canvas and display graphocs from
         * current frame
         */
        public function renderFrame():void
        {
            removeAllChildren();

            var n:int = layers.layers.length;
            var index:int = layers.currentIndex;

            addChild(pivot);
            drawGrid();

            for (var i:int = 0; i < n; i++)
            {
                var timeline:Timeline = layers.layers[i];
                var frame:TimelineFrame = timeline.getKeyframe(index);
                if (frame && frame.content)
                {
                    var img:Image = frame.content;
                    var ldr:Loader = img.source as Loader;
                    var bm:Bitmap = ldr.content as Bitmap;
                    if (bm)
                    {
                        graphics.beginBitmapFill(bm.bitmapData, new Matrix());
                        graphics.drawRect(100, 100, bm.width, bm.height);
                        graphics.endFill();
                    }
                }
            }

            lastRenderedFrame = index;
        }


        override protected function createChildren():void
        {
            super.createChildren();

            if (pivot == null)
            {
                pivot = new CanvasPivot();
                addChild(pivot);
            }
        }


        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);

            if (pivot)
            {
                pivot.x = unscaledWidth >> 1;
                pivot.y = unscaledHeight >> 1;
            }

            drawGrid();
        }

        private function drawGrid():void
        {
            graphics.clear();
            graphics.beginBitmapFill(bmdCell, new Matrix(1, 0, 0, 1, pivot.x, pivot.y + 15), true, true);
            graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
            graphics.endFill();
        }

        //-------------------------------------------------------------------
        //
        //  Private
        //
        //-------------------------------------------------------------------


        public var layers:Layers;
        private var updateTimer:Timer;
        private var lastRenderedFrame:int;
        private var pivot:UIComponent;

        private function updateTimer_timerHandler(event:TimerEvent):void
        {
            if (layers == null)
                return;

            if (lastRenderedFrame != layers.currentIndex || layers.frameContentChanged)
            {
                renderFrame();
                layers.frameContentRendered()
            }
        }
    }
}
