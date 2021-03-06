package org.okapp.guieditor.view.controls.timeline
{
    import org.okapp.guieditor.view.controls.*;
    import mx.core.UIComponent;

    public class TimelinePlayHead extends UIComponent
    {
        public static const COLOR:uint = 0xFF0000;

        //-----------------------------
        // Playhead height
        //-----------------------------

        private var _playHeadHeight:int = 1;

        /**
         * This property used to optimize component height measurement
         */
        public function get playHeadHeight():int
        {
            return _playHeadHeight;
        }

        public function set playHeadHeight(value:int):void
        {
            _playHeadHeight = value;
            invalidateDisplayList();
        }


        //-----------------------------
        // Constructor
        //-----------------------------

        public function TimelinePlayHead()
        {

        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);

            drawPlayhead(COLOR, Timeline.FRAME_WIDTH, Timeline.FRAME_HEIGHT);
        }

        private function drawPlayhead(color:uint, frameWidth:Number, frameHeight:Number):void
        {
            graphics.clear();
            graphics.beginFill(color);
            graphics.drawRect(0, 0, frameWidth - 1, TimelineRule.DEFAULT_HEIGHT);
            graphics.drawRect(frameWidth >> 1, TimelineRule.DEFAULT_HEIGHT, 1, frameHeight * _playHeadHeight);
            graphics.endFill();
        }
    }
}
