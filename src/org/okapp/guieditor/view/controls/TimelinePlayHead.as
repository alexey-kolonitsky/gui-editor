package org.okapp.guieditor.view.controls
{
    import mx.core.UIComponent;

    public class TimelinePlayHead extends UIComponent
    {
        public function TimelinePlayHead()
        {
            graphics.clear();
            graphics.beginFill(0xFF0000);
            graphics.drawRect(0, 0, Timeline.FRAME_WIDTH - 1, Timeline.FRAME_HEIGHT);
            graphics.drawRect(Timeline.FRAME_WIDTH / 2, Timeline.FRAME_HEIGHT, 1, Timeline.FRAME_HEIGHT * 2);
            graphics.endFill();
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);



        }
    }
}
