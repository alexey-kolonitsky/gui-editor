package org.okapp.guieditor.view.controls
{
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import mx.containers.Canvas;

    import spark.components.Image;

    public class AnimationCanvas extends Canvas
    {
        public var updateTimer:Timer = null;

        public var layers:Layers;

        public function AnimationCanvas()
        {
            updateTimer = new Timer(33);
            updateTimer.addEventListener(TimerEvent.TIMER, updateTimer_timerHandler);
            updateTimer.start();
        }

        public function renderFrame():void
        {
            removeAllChildren();

            var n:int = layers.layers.length;
            for (var i:int = 0; i < n; i++)
            {
                var index:int = layers.currentIndex;
                var timeline:Timeline = layers.layers[i];
                var frames:Vector.<Image> = timeline.frames;
                if (index in frames && frames[index])
                    addChild(frames[index]);
            }

            lastRendererdFrame = layers.currentIndex;
        }

        private var lastRendererdFrame:int = -1;

        private function updateTimer_timerHandler(event:TimerEvent):void
        {
            if (layers && lastRendererdFrame != layers.currentIndex)
                renderFrame();
        }
    }
}
