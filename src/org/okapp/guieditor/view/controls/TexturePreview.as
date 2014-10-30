package org.okapp.guieditor.view.controls
{
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import mx.collections.ArrayCollection;

    import mx.graphics.SolidColor;

    import org.okapp.guieditor.model.AnimationTexture;

    import spark.components.Button;

    import spark.components.Group;

    import spark.components.Image;
    import spark.components.List;
    import spark.events.IndexChangeEvent;
    import spark.layouts.HorizontalLayout;
    import spark.primitives.Rect;

    public class TexturePreview extends Group
    {
        private var _texture:AnimationTexture;
        private var _textureChanged:Boolean = false;

        public function get texture():AnimationTexture
        {
            return _texture;
        }

        public function set texture(value:AnimationTexture):void
        {
            _index = 0;
            _texture = value;
            _textureChanged = true;
            invalidateProperties();
        }


        private var _image:Image;
        private var _rect:Rect;
        private var _btnPlay:Button;

        private var updateTimer:Timer;
        private var _index:int;

        public function TexturePreview()
        {
            _index = 0;
        }


        override protected function createChildren():void
        {
            super.createChildren();

            if (_rect == null)
            {
                _rect = new Rect();
                _rect.x = 0;
                _rect.y = 0;
                _rect.percentWidth = 100;
                _rect.percentHeight = 100;
                _rect.radiusX = 6;
                _rect.radiusY = 6;
                _rect.fill = new SolidColor(0xAAAAAA);
                addElement(_rect);
            }


            if (_image == null)
            {
                _image = new Image();
                _image.x = 0;
                _image.y = 0;
                _image.percentWidth = 100;
                _image.percentHeight = 100;
                addElement(_image);
            }
        }

        override protected function commitProperties():void
        {
            super.commitProperties();

            if (_textureChanged)
            {
                _image.source = _texture.image;
                _textureChanged = false;
            }
        }


    }
}
