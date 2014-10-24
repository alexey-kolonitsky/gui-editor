package org.okapp.guieditor.view.controls
{
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import mx.containers.Canvas;

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
        }

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

            lastRenderedFrame = index;
        }



        //-------------------------------------------------------------------
        //
        //  Private
        //
        //-------------------------------------------------------------------


        public var layers:Layers;
        private var updateTimer:Timer;
        private var lastRenderedFrame:int;

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
