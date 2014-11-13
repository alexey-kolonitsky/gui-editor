package org.okapp.guieditor.view.controls.editor
{
    import mx.core.UIComponent;

    public interface ITool
    {
        function activate(container:UIComponent):void;
        function deactivate():void;
        function reset():void;
    }
}
