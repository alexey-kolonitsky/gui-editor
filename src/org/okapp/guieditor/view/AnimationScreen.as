package org.okapp.guieditor.view
{
    import flash.events.MouseEvent;
    import flash.filesystem.File;
    import flash.geom.Point;

    import mx.collections.ArrayCollection;
    import mx.containers.Canvas;
    import mx.controls.FileSystemEnumerationMode;
    import mx.controls.FileSystemTree;
    import mx.core.ClassFactory;
    import mx.events.ListEvent;

    import org.kolonitsky.alexey.StoredFieldManager;
    import org.okapp.guieditor.model.AnimationTexture;
    import org.okapp.guieditor.renderers.TextureFileRenderer;
    import org.okapp.guieditor.view.controls.AnimationCanvas;
    import org.okapp.guieditor.view.controls.Layers;
    import org.okapp.guieditor.view.controls.TexturePreview;
    import org.okapp.guieditor.view.controls.Timeline;
    import org.okapp.guieditor.view.controls.TimelineRule;

    import spark.components.Image;
    import spark.components.Label;
    import spark.components.List;
    import spark.components.TextArea;
    import spark.events.TextOperationEvent;
    import spark.filters.GlowFilter;

    //TODO: Admin: special sign for invalid message
    public class AnimationScreen extends BaseScreen
    {
        public static const COL1_LEFT:Number = 0;
        public static const COL1_WIDTH:Number = 300;
        public static const COL2_LEFT:Number = COL1_LEFT + COL1_WIDTH + COL_GAP;
        public static const COL2_WIDTH:Number = 300;
        public static const COL3_LEFT:Number = COL2_LEFT + COL2_WIDTH + COL_GAP;
        public static const COL3_WIDTH:Number = 300;

        public static const COL_GAP:Number = 4;

        public function AnimationScreen()
        {
            super();

        }


        override protected function createChildren():void
        {
            super.createChildren();



            if (lblXMLDirecotry == null)
            {
                lblXMLDirecotry = new Label();
                lblXMLDirecotry.text = "Animation render directory";
                lblXMLDirecotry.left = 0;
                lblXMLDirecotry.top = 0;
                lblXMLDirecotry.width = COL1_WIDTH;
                lblXMLDirecotry.bottom = 0;
                lblXMLDirecotry.setStyle("backgroundColor", 0xFFFFFF);
                addElement(lblXMLDirecotry);
            }

            if(lblPreview == null)
            {
                lblPreview = new Label();
                lblPreview.top = 0;
                lblPreview.left = COL2_LEFT;
                lblPreview.width = COL2_WIDTH;
                lblPreview.text = "Textures";
                addElement(lblPreview);
            }

            if (imgPreview == null)
            {
                imgPreview = new TexturePreview();
                imgPreview.top = 0;
                imgPreview.left = COL2_LEFT;
                imgPreview.width = COL2_WIDTH;
                imgPreview.height = COL2_WIDTH;

                addElement(imgPreview);
            }

            if (layers == null)
            {
                layers = new Layers();
                layers.left = COL3_LEFT;
                layers.right = 0;
                layers.top = 0;
                layers.height = TimelineRule.DEFAULT_HEIGHT;

                addElement(layers)
            }

            if (canvas == null)
            {
                canvas = new AnimationCanvas(layers);
                canvas.setStyle("backgroundColor", 0xAAAAAA);
                canvas.left = COL3_LEFT;
                canvas.top = (Timeline.FRAME_HEIGHT + 1) * 3;
                canvas.right = 0;
                canvas.height = 400;

                addElement(canvas);
            }

            if (listTextures == null)
            {
                listTextures = new List();
                listTextures.top = COL2_WIDTH + COL_GAP;
                listTextures.bottom = 0;
                listTextures.left = COL2_LEFT;
                listTextures.width = COL2_WIDTH;
                listTextures.doubleClickEnabled = true;
                listTextures.itemRenderer = new ClassFactory(TextureFileRenderer);
                listTextures.dataProvider = new ArrayCollection([]);
                listTextures.addEventListener(MouseEvent.MOUSE_DOWN, listTextures_changeHandler);
                listTextures.addEventListener(MouseEvent.DOUBLE_CLICK, listTextures_doubleClickhandler);
                addElement(listTextures);
            }

            if (taEditor == null)
            {
                taEditor = new TextArea();
                taEditor.top = 600;
                taEditor.left = COL3_LEFT;
                taEditor.right = 0;
                taEditor.bottom = 0;
                taEditor.setStyle("fontFamily", "_typewriter");
                taEditor.setStyle("fontSize", 12);
                taEditor.addEventListener(TextOperationEvent.CHANGE, editor_changeHandler);
                addElement(taEditor);
            }

            if (fsTexturesDirectory == null)
            {
                fsTexturesDirectory = new FileSystemTree();
                fsTexturesDirectory.left = 0;
                fsTexturesDirectory.top = 30;
                fsTexturesDirectory.width = COL1_WIDTH;
                fsTexturesDirectory.bottom = 0;
                fsTexturesDirectory.enumerationMode = FileSystemEnumerationMode.DIRECTORIES_ONLY;
                fsTexturesDirectory.addEventListener(ListEvent.CHANGE, fsTexturesDirecotry_changeHandler);
                fsTexturesDirectory.selectedPath = StoredFieldManager.instance.getString(Constants.SO_ANIMATION_PATH);

                if (fsTexturesDirectory.selectedPath)
                {
                    var f:File = new File(fsTexturesDirectory.selectedPath);
                    var p:Array = [];

                    // pars path
                    var parent:File = f;
                    while ((parent = parent.parent) != null)
                        p.unshift(parent.nativePath);

                    fsTexturesDirectory.openPaths = p;
                }

                addElement(fsTexturesDirectory);
                fsTexturesDirecotry_changeHandler(null);
            }
        }

        private function listTextures_doubleClickhandler(event:MouseEvent):void
        {
            var texture:AnimationTexture = listTextures.selectedItem as AnimationTexture;

            var img:Image = new Image();
            img.source = texture.images[0];
            img.addEventListener(MouseEvent.ROLL_OVER, element_rollOverHandler);
            img.addEventListener(MouseEvent.ROLL_OUT, element_rollOutHandler);
            img.addEventListener(MouseEvent.MOUSE_DOWN, element_mouseDownHandler);

            layers.addImage(img);
            canvas.renderFrame();
        }

        private function element_rollOverHandler(event:MouseEvent):void
        {
            var target:Image = event.currentTarget as Image;
            if (target)
                target.filters = [ new GlowFilter(0xFF0000) ];
        }

        private function element_rollOutHandler(event:MouseEvent):void
        {
            var target:Image = event.currentTarget as Image;
            if (target)
                target.filters = [ ];
        }

        private var dragObject:Image = null;
        private var dragObjectOriginalPosition:Point = new Point();

        private var dragOffset:Point = new Point();

        private function element_mouseDownHandler(event:MouseEvent):void
        {
            dragOffset.x = event.stageX;
            dragOffset.y = event.stageY;

            var target:Image = event.currentTarget as Image;
            if (target)
            {
                target.filters = [ new GlowFilter(0xFF0000) ];
                dragObject = target;

                dragObjectOriginalPosition.x = dragObject.x;
                dragObjectOriginalPosition.y = dragObject.y;

                stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
                stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
            }
        }

        private function element_mouseUpHandler(event:MouseEvent):void
        {
            var target:Image = event.currentTarget as Image;
            if (target)
                target.filters = [ new GlowFilter(0xFF0000) ];
        }

        override protected function createPreview():void
        {
            trace("INFO: Animation preview created");
        }

        override protected function removePreview():void
        {
            trace("INFO: Animation preview removed");
        }

        //-------------------------------------------------------------------
        //
        //  Private
        //
        //-------------------------------------------------------------------

        private var lblPreview:Label;
        private var lblXMLDirecotry:Label;
        private var layers:Layers;
        private var fsTexturesDirectory:FileSystemTree;
        private var imgPreview:TexturePreview;
        private var listTextures:List;
        private var taEditor:TextArea;

        private var canvas:AnimationCanvas;

        private var textures:Array /* of AnimationTexture */ = [];

        private function fsTexturesDirecotry_changeHandler(event:ListEvent):void
        {
            if (fsTexturesDirectory.selectedPath == null)
                return;

            var file:File = new File(fsTexturesDirectory.selectedPath);
            if (file == null || !file.exists || !file.isDirectory )
                return;

            var files:Array = file.getDirectoryListing();

            textures = [];
            for each (var item:File in files)
            {
                if ( !item.exists || item.isHidden || item.isDirectory || item.isPackage || item.isSymbolicLink )
                    continue;
//
//                var matchResult:Array = item.name.match(AnimationTexture.TEXTURE_FILENAME_PATTERN);
//                var isTexuteFile:Boolean = matchResult && matchResult.length > 0;
//                if ( !isTexuteFile )
//                    continue;
//
//                var itemIsPartOfSequence:Boolean = false;
//                for each (var texture:AnimationTexture in textures)
//                {
//                    itemIsPartOfSequence = texture.checkFile(item);
//                    if ( itemIsPartOfSequence )
//                    {
//                        texture.addFile(item);
//                        break;
//                    }
//                }
//
//                if ( !itemIsPartOfSequence )
//                {
                    var texture:AnimationTexture = new AnimationTexture();
                    texture.addFile(item);
                    textures.push(texture);
//                }
            }

            listTextures.dataProvider = new ArrayCollection(textures);
            StoredFieldManager.instance.setString(Constants.SO_ANIMATION_PATH, file.nativePath);
        }

        private function editor_changeHandler(event:TextOperationEvent):void
        {

        }

        private function listTextures_changeHandler(event:MouseEvent):void
        {
            imgPreview.texture = listTextures.selectedItem as AnimationTexture;
        }

        private function stage_mouseUpHandler(event:MouseEvent):void
        {
            dragObject = null;

            stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
        }

        private function stage_mouseMoveHandler(event:MouseEvent):void
        {
            if (dragObject)
            {
                var dx:Number = event.stageX - dragOffset.x;
                var dy:Number = event.stageY - dragOffset.y;
                dragObject.x = dragObjectOriginalPosition.x + dx;
                dragObject.y = dragObjectOriginalPosition.y + dy;
            }
        }
    }
}
