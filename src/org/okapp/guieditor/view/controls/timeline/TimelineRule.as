package org.okapp.guieditor.view.controls.timeline
{
    import mx.controls.Label;
    import mx.core.UIComponent;

    public class TimelineRule extends UIComponent
    {
        public static const TICK_COLOR:uint = 0x666666;

        public static const DEFAULT_FPS:Number = 30;
        public static const TIME_TICK_DURATION:Number = 1000; /* milliseconds */
        public static const FRAME_WIDTH:Number = 8; /* pixels */
        public static const DEFAULT_HEIGHT:Number = 16; /* pixels */

        public function TimelineRule()
        {
            super();
        }

        private var labels:Array = [];

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            var w:Number = unscaledWidth || explicitWidth;
            var h:Number = DEFAULT_HEIGHT;

            // Draw background
            graphics.clear();
            graphics.beginFill(Constants.COLOR_INTERFACE_INACTIVE);
            graphics.drawRect(0, 0, w, h);

            // Draw tick
            graphics.beginFill(TICK_COLOR);
            var n:int = w / FRAME_WIDTH;
            for (var i:int = 0; i < n; i++)
            {
                var tickHeight:int = 2;
                if ((i % DEFAULT_FPS) == 0)
                    tickHeight = h;

                graphics.drawRect(i * FRAME_WIDTH, 0, 1, tickHeight);
            }

            // Add labels
            var labelCount:int = w / (FRAME_WIDTH * DEFAULT_FPS);
            while (labels.length < labelCount)
                labels.push(new Label());

            n = labels.length;
            for (i = 0; i < n; i++)
            {
                var sec:int = i + 1;
                var label:Label = labels[i];
                label.text = sec + " сек";
                label.x = sec * (FRAME_WIDTH * DEFAULT_FPS);
                label.y = 0;
                label.width = 200;
                label.height = 30;
                label.setStyle("paddingTop", 0);
                label.visible = i < labelCount;

                if (label.parent == null)
                    addChild(label);
            }

            graphics.endFill();
        }
    }
}

