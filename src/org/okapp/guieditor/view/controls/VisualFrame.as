package org.okapp.guieditor.view.controls
{
    import mx.core.UIComponent;

    public class VisualFrame extends UIComponent
    {
        public function VisualFrame(color:uint)
        {
            graphics.clear();
            graphics.beginFill(color, 0.3);
            graphics.drawRect(1, 0, Timeline.FRAME_WIDTH -1, Timeline.FRAME_HEIGHT);
            graphics.endFill();
        }
    }
}
