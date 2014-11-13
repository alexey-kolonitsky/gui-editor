package org.okapp.guieditor.view.controls.editor
{
    import flash.display.DisplayObject;
    import flash.display.Stage;
    import flash.events.MouseEvent;
    import flash.filters.GlowFilter;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    import mx.core.UIComponent;

    import org.okapp.guieditor.view.controls.AnimationCanvas;

    public class MoveTool implements ITool
    {
        public static const SELECTION_FILTER:GlowFilter = new GlowFilter(0xFF0000);


        //-----------------------------
        // selected object
        //-----------------------------

        private var _selectedObject:UIComponent = null;

        public function get selectedObject():UIComponent
        {
            return _selectedObject;
        }


        //-----------------------------
        // Constructor
        //-----------------------------

        public function MoveTool()
        {
        }


        //-------------------------------------------------------------------
        // ITool implementation
        //-------------------------------------------------------------------

        public function activate(container:UIComponent):void
        {
            if (container == null)
            {
                throw new Error("Canvas must be not NULL");
                return;
            }

            if (container.stage == null)
            {
                throw new Error("Canvas must have reference on stage");
                return;
            }

            _container = container;
            _container.addEventListener(MouseEvent.MOUSE_MOVE, element_mouseMoveHandler);

            _stage = _container.stage;
            _stage.addEventListener(MouseEvent.MOUSE_DOWN, element_mouseDownHandler);

        }

        public function deactivate():void
        {
            _stage.removeEventListener(MouseEvent.MOUSE_DOWN, element_mouseDownHandler);
            _stage = null;

            _container.removeEventListener(MouseEvent.MOUSE_MOVE, element_mouseMoveHandler);
            _container = null;
        }


        public function reset():void
        {

        }

        //-------------------------------------------------------------------
        // Private
        //-------------------------------------------------------------------

        private var _stage:Stage;
        private var _container:UIComponent;

        private var _overObject:DisplayObject = null;
        private var _dragObject:UIComponent = null;

        private var _dragObjectOriginalPosition:Point = new Point();
        private var _dragOffset:Point = new Point();

        private function element_mouseDownHandler(event:MouseEvent):void
        {
            if (_overObject == null)
            {
                _selectedObject = null;
            }

            _dragOffset.x = event.stageX;
            _dragOffset.y = event.stageY;

            if (_overObject)
            {
                _overObject.filters = [ SELECTION_FILTER ];
                _dragObject = _overObject as UIComponent;

                _dragObjectOriginalPosition.x = _dragObject.x;
                _dragObjectOriginalPosition.y = _dragObject.y;

                _stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
                _stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
            }
        }


        private function stage_mouseUpHandler(event:MouseEvent):void
        {
            _selectedObject = _dragObject;
            _dragObject = null;

            _stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
            _stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
        }

        private function element_mouseMoveHandler(event:MouseEvent):void
        {
            var n:int = _container.numChildren;

            _overObject = null;

            for (var i:int = 0; i < n; i++)
            {
                var element:DisplayObject = _container.getChildAt(i);
                element.filters = [];

                var b:Rectangle = element.getBounds(_container);
                if (b.contains(event.localX, event.localY))
                {
                    _overObject = element;
                }
            }

            if (_overObject)
                _overObject.filters = [ new GlowFilter(0xFF0000) ];
        }

        private function stage_mouseMoveHandler(event:MouseEvent):void
        {
            if (_dragObject)
            {
                var dx:Number = event.stageX - _dragOffset.x;
                var dy:Number = event.stageY - _dragOffset.y;
                _dragObject.x = _dragObjectOriginalPosition.x + dx;
                _dragObject.y = _dragObjectOriginalPosition.y + dy;
            }
        }
    }
}
