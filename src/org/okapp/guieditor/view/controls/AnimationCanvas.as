package org.okapp.guieditor.view.controls
{
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.TimerEvent;
    import flash.geom.Matrix;
    import flash.utils.Timer;

    import mx.containers.Canvas;
    import mx.controls.Image;
    import mx.core.UIComponent;

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

            for (var i:int = 0; i < n; i++)
            {
                var timeline:Timeline = layers.layers[i];
                var frame:TimelineFrame = timeline.getKeyframe(index);
                if (frame && frame.content)
                    addChild(frame.content);
            }

            addChild(pivot);
            drawGrid();

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
