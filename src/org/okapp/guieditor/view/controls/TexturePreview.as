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
        private var _states:List;
        private var _rect:Rect;
        private var _btnPlay:Button;

        private var updateTimer:Timer;
        private var _index:int;

        public function TexturePreview()
        {
            _index = 0;

            updateTimer = new Timer(33);
            updateTimer.addEventListener(TimerEvent.TIMER, updateTimer_timerHandler);
            updateTimer.start();
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

            if (_states == null)
            {
                _states = new List();
                _states.left = 0;
                _states.right = 38;
                _states.bottom = 0;
                _states.height = 32;
                _states.layout = new HorizontalLayout();
                _states.addEventListener(IndexChangeEvent.CHANGE, states_changeHandler)
                addElement(_states);
            }

            if (_btnPlay == null)
            {
                _btnPlay = new Button();
                _btnPlay.label = "■";
                _btnPlay.width = 32;
                _btnPlay.height= 32;
                _btnPlay.right = 0;
                _btnPlay.bottom = 0;
                _btnPlay.addEventListener(MouseEvent.CLICK, btnPlay_clickHandler);
                addElement(_btnPlay);
            }
        }

        private function states_changeHandler(event:IndexChangeEvent):void
        {
            _index = _states.selectedIndex;
            _image.source = _texture.images[_index];
        }

        private function btnPlay_clickHandler(event:MouseEvent):void
        {
            if (updateTimer.running)
            {
                updateTimer.stop();
                _btnPlay.label = "►";
            }
            else
            {
                updateTimer.start();
                _btnPlay.label = "■";
            }
        }

        override protected function commitProperties():void
        {
            super.commitProperties();

            if (_textureChanged)
            {
                if (_texture)
                    _states.dataProvider = new ArrayCollection(_texture.states);
                _textureChanged = false;
            }
        }

        private function updateTimer_timerHandler(event:TimerEvent):void
        {
            if (_texture)
            {
                _index = (_index + 1) % _texture.images.length;
                _image.source = _texture.images[_index]
                _states.selectedIndex = _index;
            }
        }


    }
}
