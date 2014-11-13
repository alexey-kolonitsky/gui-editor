package org.okapp.guieditor.view.controls
{
    import flash.geom.Rectangle;

    import mx.core.UIComponent;

    import org.okapp.guieditor.model.AnimationTexture;
    import org.okapp.guieditor.view.AnimationScreen;

    public class TexturePreview extends UIComponent
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

        public function TexturePreview()
        {
            graphics.beginFill(Constants.COLOR_INTERFACE_INACTIVE);
            graphics.drawRoundRect(0, 0, AnimationScreen.COL2_WIDTH, AnimationScreen.COL2_WIDTH, 8, 8);
            graphics.endFill();
        }

        private var currentPreview:UIComponent = null;

        override protected function commitProperties():void
        {
            super.commitProperties();

            if (_textureChanged)
            {
                if (currentPreview && currentPreview.parent == this)
                {
                    currentPreview.scrollRect = null;
                    removeChild(currentPreview);
                }

                if (_texture)
                {
                    if (_texture.frame)
                    {
                        currentPreview = _texture.frame;
                        currentPreview.scrollRect = new Rectangle(0, 0, AnimationScreen.COL2_WIDTH, AnimationScreen.COL2_WIDTH);
                        addChild(currentPreview);
                    }
                }

                _textureChanged = false;
            }
        }


    }
}
