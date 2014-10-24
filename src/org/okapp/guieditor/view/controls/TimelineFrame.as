package org.okapp.guieditor.view.controls
{
    import spark.components.Image;

    public class TimelineFrame
    {
        public static const TYPE_NOT_EXISTS:String = "notExists";
        public static const TYPE_FRAME:String = "frame";
        public static const TYPE_KEYFRAME:String = "keyframe";

        public var startIndex:int;
        public var size:int;
        public var content:Image;

        public function get isEmpty():Boolean
        {
            return content == null;
        }

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
