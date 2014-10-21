package org.okapp.guieditor.view.controls
{
    import mx.core.UIComponent;

    public class TimelineRule extends UIComponent
    {
        public static const BG_COLOR:uint = 0xEEEEEE;
        public static const TICK_COLOR:uint = 0x999999;

        public static const RULE_TICK_WIDTH:Number = 8;
        public static const DEFAULT_HEIGHT:Number = 16;

        public function TimelineRule()
        {

        }

        override protected function measure():void
        {
            super.measure();
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);

            graphics.beginFill(BG_COLOR);
            graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);

            graphics.beginFill(TICK_COLOR);
            var n:int = unscaledWidth / RULE_TICK_WIDTH;
            for (var i:int = 0; i < n; i++)
                graphics.drawRect(i * RULE_TICK_WIDTH, 0, 1, DEFAULT_HEIGHT);

            graphics.endFill();
        }
    }
}

