package org.okapp.guieditor.view.controls
{
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.filters.GlowFilter;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Timer;

    import mx.containers.Canvas;
    import mx.controls.Button;
    import mx.core.UIComponent;

    import org.okapp.guieditor.view.controls.editor.CanvasPivot;
    import org.okapp.guieditor.view.controls.editor.ITool;
    import org.okapp.guieditor.view.controls.editor.MoveTool;

    import org.okapp.guieditor.view.controls.timeline.Timeline;

    import org.okapp.guieditor.view.controls.timeline.TimelineFrame;

    import spark.components.Image;

    public class AnimationCanvas extends Canvas
    {
        //-----------------------------
        // Constructor
        //-----------------------------

        public function AnimationCanvas(layers:Layers)
        {
            super();

            mouseEnabled = false;
            mouseChildren = true;

            if (layers == null)
                throw new Error("layers parameter must be NOT NULL!");

            this.layers = layers;
            this.layers.btnPlayPause.addEventListener(MouseEvent.CLICK, btnPlayPause_clickHandler);

            this.btnPlayPause = this.layers.btnPlayPause;

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
            addChild(img);

            currentTool = new MoveTool();
        }

        /**
         * Remove all exists elements on canvas and display graphocs from
         * current frame
         */
        public function renderFrame():void
        {
            while (container.numChildren)
                container.removeChildAt(0);

            var n:int = layers.layers.length;
            var index:int = layers.currentIndex;

            drawGrid();

            for (var i:int = 0; i < n; i++)
            {
                var timeline:Timeline = layers.layers[i];
                if (index >= timeline.size)
                    continue;

                var frame:TimelineFrame = timeline.getKeyframe(index);
                if (frame && frame.content)
                    container.addChild(frame.content);
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

            if (container == null)
            {
                container = new UIComponent();
                container.mouseEnabled = true;
                container.mouseChildren = true;
                container.useHandCursor = true;
                addChild(container);
            }
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);

            var w2:int = unscaledWidth >> 1;
            var h2:int = unscaledHeight >> 1;

            if (pivot)
            {
                pivot.x = w2;
                pivot.y = h2;
            }

            if (container)
            {
                container.x = w2;
                container.y = h2;
            }

            drawGrid();
        }




        //-------------------------------------------------------------------
        //
        //  Private
        //
        //-------------------------------------------------------------------


        public var layers:Layers;
        public var btnPlayPause:Button;

        private var updateTimer:Timer;
        private var lastRenderedFrame:int;
        private var pivot:UIComponent;
        private var container:UIComponent;
        private var currentTool:ITool;

        private var bmdCell:BitmapData;

        private var running:Boolean = false;

        private function btnPlayPause_clickHandler(event:MouseEvent):void
        {
            running = !running;

            if (running)
            {
                btnPlayPause.label = "■";
                btnPlayPause.toolTip = "stop";
            }
            else
            {
                btnPlayPause.label = "►";
                btnPlayPause.toolTip = "play";
            }
        }

        private function drawGrid():void
        {
            graphics.clear();
            graphics.beginBitmapFill(bmdCell, new Matrix(1, 0, 0, 1, -x, -y + 15), true, true);
            graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
            graphics.endFill();
        }

        private function updateTimer_timerHandler(event:TimerEvent):void
        {
            if (layers == null)
                return;

            if (running)
            {
                layers.nextFrame();
                renderFrame();
                return;
            }

            if (lastRenderedFrame != layers.currentIndex || layers.frameContentChanged)
            {
                renderFrame();
                layers.frameContentRendered()
            }
        }
    }
}
