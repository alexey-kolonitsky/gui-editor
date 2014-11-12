package org.okapp.guieditor.view.controls
{
    import com.okapp.pirates.ui.core.IUIElement;

    import flash.events.Event;

    import mx.core.UIComponent;

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
        }

        private var currentPreview:UIComponent = null;

        override protected function commitProperties():void
        {
            super.commitProperties();

            if (_textureChanged)
            {
                if (currentPreview)
                    removeElement(currentPreview);

                if (_texture)
                {
                    if (_texture.frame)
                    {
                        currentPreview = _texture.frame;
                        addElement(currentPreview);
                    }
                }


                _textureChanged = false;
            }
        }


    }
}
