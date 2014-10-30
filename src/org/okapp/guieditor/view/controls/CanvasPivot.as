package org.okapp.guieditor.view.controls
{
    import mx.core.UIComponent;

    public class CanvasPivot extends UIComponent
    {
        public function CanvasPivot()
        {
            graphics.beginFill(0xFF0000);
            graphics.drawRect(0, -5, 1, 10);
            graphics.drawRect(-5, 0, 10, 1);
            graphics.drawCircle(0, 0, 2);
            graphics.endFill();
        }
    }
}
