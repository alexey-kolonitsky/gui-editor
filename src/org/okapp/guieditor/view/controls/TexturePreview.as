package org.okapp.guieditor.view.controls
{
    import mx.graphics.SolidColor;

    import org.okapp.guieditor.model.AnimationTexture;

    import spark.components.Group;
    import spark.components.Image;
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
            _texture = value;
            _textureChanged = true;
            invalidateProperties();
        }


        private var _image:Image;
        private var _rect:Rect;

        public function TexturePreview()
        {
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

            if (_textureChanged && _image)
            {
                if (_texture)
                    _image.source = _texture.image;
                else
                    _image.source = null;

                _textureChanged = false;
            }
        }


    }
}
