package org.okapp.guieditor.view.controls
{
    import flash.events.Event;

    import mx.core.UIComponent;

    import org.okapp.guieditor.model.AnimationTexture;

    import spark.components.Image;

    public class TimelineFrame
    {
        public static const TYPE_NOT_EXISTS:String = "notExists";
        public static const TYPE_FRAME:String = "frame";
        public static const TYPE_KEYFRAME:String = "keyframe";

        public var startIndex:int;
        public var size:int;
        public var content:UIComponent;
        public var url:String;


        //-----------------------------
        // is empty
        //-----------------------------

        public function get isEmpty():Boolean
        {
            return content == null;
        }


        //-----------------------------
        // texture
        //-----------------------------

        private var _texture:AnimationTexture;

        public function get texture():AnimationTexture
        {
            return _texture;
        }

        public function set texture(value:AnimationTexture):void
        {
            if (value == _texture)
                return;

            _texture = value;
            content = _texture.frame;
        }


        //-----------------------------
        // Constructor
        //-----------------------------

        public function TimelineFrame(index:int = 0, content:Image = null)
        {
            this.startIndex = index;
            this.content = content;
            this.size = 1;
        }

        public function clear():void
        {
            content = null;
        }
    }
}
