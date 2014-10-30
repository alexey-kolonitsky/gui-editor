package org.okapp.guieditor.view.controls
{
    import mx.core.UIComponent;

    public class TimelinePlayHead extends UIComponent
    {
        public static const COLOR:uint = 0xFF0000;

        public function TimelinePlayHead()
        {

        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);

            drawPlayhead(COLOR, Timeline.FRAME_WIDTH, Timeline.FRAME_HEIGHT, unscaledHeight);
        }

        private function drawPlayhead(color:uint, frameWidth:Number, frameHeight:Number, height:Number):void
        {
            graphics.clear();
            graphics.beginFill(color);
            graphics.drawRect(0, 0, frameWidth - 1, TimelineRule.DEFAULT_HEIGHT);
            graphics.drawRect(frameWidth >> 1, TimelineRule.DEFAULT_HEIGHT, 1, height);
            graphics.endFill();
        }
    }
}
