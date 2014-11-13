package org.okapp.guieditor.view
{
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.filesystem.File;
    import flash.net.FileFilter;
    import flash.utils.Timer;

    import mx.collections.ArrayCollection;
    import mx.containers.HBox;
    import mx.containers.TabNavigator;
    import mx.controls.FileSystemEnumerationMode;
    import mx.controls.FileSystemTree;
    import mx.core.ClassFactory;
    import mx.events.ListEvent;

    import org.kolonitsky.alexey.StoredFieldManager;
    import org.okapp.guieditor.model.AnimationModelEvent;
    import org.okapp.guieditor.model.AnimationModelVO;
    import org.okapp.guieditor.model.AnimationTexture;
    import org.okapp.guieditor.model.DataFile;
    import org.okapp.guieditor.renderers.TextureFileRenderer;
    import org.okapp.guieditor.view.controls.AnimationCanvas;
    import org.okapp.guieditor.view.controls.AnimationStatePanel;
    import org.okapp.guieditor.view.controls.Layers;
    import org.okapp.guieditor.view.controls.RawFileEditor;
    import org.okapp.guieditor.view.controls.TexturePreview;
    import org.okapp.guieditor.view.controls.timeline.Timeline;
    import org.okapp.guieditor.view.controls.timeline.TimelineRule;

    import spark.components.Button;
    import spark.components.Image;
    import spark.components.Label;
    import spark.components.List;

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


        //-----------------------------
        // selected file
        //-----------------------------

        private var _selectedFile:AnimationModelVO = null;
        private var _selectedFileChanged:Boolean = false;

        [Bindable]
        public function get selectedFile():AnimationModelVO
        {
            return _selectedFile;
        }

        public function set selectedFile(value:AnimationModelVO):void
        {
            _selectedFile = value;
            _selectedFileChanged = true;
            invalidateProperties();
        }


        //-----------------------------
        // Constructor
        //-----------------------------

        public function AnimationScreen()
        {
            super();

            _autoSaveTimer = new Timer(Constants.AUTOSAVE_DELAY);
            _autoSaveTimer.addEventListener(TimerEvent.TIMER, autoSaveTimer_timerHandler);
            _autoSaveTimer.start();
        }

        private function autoSaveTimer_timerHandler(event:TimerEvent):void
        {
            if (_selectedFile && _selectedFile.isValid)
            {
                _editor.update();
                _selectedFile.flush();
            }
        }


        //-------------------------------------------------------------------
        // Implement BaseScreen API
        //-------------------------------------------------------------------

        override protected function createPreview():void
        {
            trace("INFO: Animation preview created");
        }

        override protected function removePreview():void
        {
            trace("INFO: Animation preview removed");
        }


        //-------------------------------------------------------------------
        // Implement UIComponent API
        //-------------------------------------------------------------------

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
                lblXMLDirecotry.setStyle("paddingTop", 5);
                lblXMLDirecotry.setStyle("paddingLeft", 5);
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

            if (_layers == null)
            {
                _layers = new Layers();
                _layers.left = COL3_LEFT;
                _layers.right = COL_GAP;
                _layers.top = 0;
                _layers.height = TimelineRule.DEFAULT_HEIGHT;
            }

            if (_canvas == null)
            {
                _canvas = new AnimationCanvas(_layers);
                _canvas.left = COL3_LEFT;
                _canvas.top = (Timeline.FRAME_HEIGHT + 1) * 3;
                _canvas.right = COL_GAP;
                _canvas.height = 400;

                addElement(_canvas);
                addElement(_layers)
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
                listTextures.addEventListener(ListEvent.CHANGE, listTextures_changeHandler);
                listTextures.addEventListener(MouseEvent.MOUSE_DOWN, listTextures_changeHandler);
                listTextures.addEventListener(MouseEvent.DOUBLE_CLICK, listTextures_doubleClickhandler);
                addElement(listTextures);
            }

            if (_panels == null)
            {
                _panels = new TabNavigator();
                _panels.top = 600;
                _panels.left = COL3_LEFT;
                _panels.right = COL_GAP;
                _panels.bottom = 0;
                addElement(_panels);

                if (_editor == null)
                {
                    _editor = new RawFileEditor();
                    _editor.label = "Editor";
                    _editor.y = 0;
                    _editor.x = 0;
                    _editor.percentWidth = 100;
                    _editor.percentHeight = 100;
                    _panels.addChild(_editor);
                }

                if (_animationStatePanel == null)
                {
                    _animationStatePanel = new AnimationStatePanel();
                    _animationStatePanel.label = "States";
                    _animationStatePanel.y = 0;
                    _animationStatePanel.x = 0;
                    _animationStatePanel.percentWidth = 100;
                    _animationStatePanel.percentHeight = 100;
                    _animationStatePanel.addEventListener(AnimationModelEvent.CHANGE_STATE, animationStatePanel_changeHandler);
                    _panels.addChild(_animationStatePanel);
                }
            }

            if (btnOpenFile == null)
            {
                btnOpenFile = new Button();
                btnOpenFile.top = 0;
                btnOpenFile.left = COL2_WIDTH - 60 - COL_GAP - 60;
                btnOpenFile.width = 60;
                btnOpenFile.label = "Open";
                btnOpenFile.addEventListener(MouseEvent.CLICK, btnOpen_clickHandler);
                addElement(btnOpenFile);
            }
            if (btnCreateFile == null)
            {
                btnCreateFile = new Button();
                btnCreateFile.top = 0;
                btnCreateFile.left = COL2_WIDTH - 60;
                btnCreateFile.width = 60;
                btnCreateFile.label = "Create";
                btnCreateFile.addEventListener(MouseEvent.CLICK, btnCreate_clickHandler);
                addElement(btnCreateFile);
            }



            if (btnSaveFile == null)
            {
                btnSaveFile = new Button();
                btnSaveFile.top = 0;
                btnSaveFile.left =  COL2_WIDTH - 60 - COL_GAP - 60 - COL_GAP - 60;
                btnSaveFile.width = 60;
                btnSaveFile.label = "Save";
                btnSaveFile.addEventListener(MouseEvent.CLICK, btnSave_clickHandler);
                addElement(btnSaveFile);
            }

            if (fsTexturesDirectory == null)
            {
                fsTexturesDirectory = new FileSystemTree();
                fsTexturesDirectory.left = 0;
                fsTexturesDirectory.top = 30;
                fsTexturesDirectory.width = COL1_WIDTH;
                fsTexturesDirectory.bottom = 0;
                fsTexturesDirectory.enumerationMode = FileSystemEnumerationMode.DIRECTORIES_ONLY;
                fsTexturesDirectory.selectedPath = StoredFieldManager.instance.getString(Constants.SO_ANIMATION_DIRECTORY);
                fsTexturesDirectory.addEventListener(ListEvent.CHANGE, fsTexturesDirectory_changeHandler);

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
                fsTexturesDirectory_changeHandler(null);
            }
        }

        override protected function initializationComplete():void
        {
            super.initializationComplete();

            var fn:String = StoredFieldManager.instance.getString(Constants.SO_ANIMATION_PATH);
            var lastEditedFile:AnimationModelVO = new AnimationModelVO(new File(fn));
            if (lastEditedFile && lastEditedFile.isValid)
            {
                selectedFile = lastEditedFile;
            }
            else
            {
                var path:String = File.documentsDirectory.nativePath;
                var file:File = DataFile.createEmptyFile(path, AnimationModelVO.FILE_NAME_PATTERN, AnimationModelVO.EMPTY_FILE);

                selectedFile = new AnimationModelVO(file)
            }
        }

        override protected function commitProperties():void
        {
            if (_selectedFileChanged)
            {
                _editor.dataFile = selectedFile;
                _animationStatePanel.selectedFile = selectedFile;

                if (selectedFile.isValid)
                {
                    default xml namespace = Constants.OKAPP_ANIMATION_MODEL_NS;
                    var xml:XMLList = _selectedFile.buffer.state;
                    if (xml.length())
                        loadLayersFromXML(xml[0]);
                }

                _selectedFileChanged = false;
            }
        }




        //-------------------------------------------------------------------
        //
        //  Private
        //
        //-------------------------------------------------------------------

        private var lblPreview:Label;
        private var lblXMLDirecotry:Label;
        private var _layers:Layers;
        private var fsTexturesDirectory:FileSystemTree;
        private var imgPreview:TexturePreview;
        private var listTextures:List;


        private var btnOpenFile:Button;
        private var btnCreateFile:Button;
        private var btnSaveFile:Button;

        private var _canvas:AnimationCanvas;

        private var _panels:TabNavigator = null;
        private var _editor:RawFileEditor;
        private var _animationStatePanel:AnimationStatePanel;

        private var _autoSaveTimer = null;


        private function openFile(path:String):void
        {
            if (path == null || path == "")
                return;

            StoredFieldManager.instance.setString(Constants.SO_ANIMATION_PATH, path);
            selectedFile = new AnimationModelVO(new File(path));
        }

        private function saveFile():void
        {
            var state:XML = _animationStatePanel.selectedState;

            for each (var timelineNode:XML in state.timeline)
            {
                var parent:XML = timelineNode.parent();
                var chiltren:XMLList = parent.children();
                delete chiltren[ timelineNode.childIndex() ];
            }

            var timelines:Vector.<XML> = _layers.toXMLList();
            for each (var node:XML in timelines)
                state.appendChild(node);

            selectedFile.flush();
        }


        //-------------------------------------------------------------------
        // Event handlers
        //-------------------------------------------------------------------

        private function animationStatePanel_changeHandler(event:AnimationModelEvent):void
        {
            default xml namespace = Constants.OKAPP_ANIMATION_MODEL_NS;

            // Remove all existed timelines in last selected state and add
            // new timelines from _layers
            var state:XML = _animationStatePanel.selectedState;

            for each (var timelineNode:XML in state.timeline)
            {
                var parent:XML = timelineNode.parent();
                var chiltren:XMLList = parent.children();
                delete chiltren[ timelineNode.childIndex() ];
            }

            var timelines:Vector.<XML> = _layers.toXMLList();
            for each (var node:XML in timelines)
                state.appendChild(node);

            loadLayersFromXML(event.newState);
        }

        private function loadLayersFromXML(newState:XML):void
        {
            default xml namespace = Constants.OKAPP_ANIMATION_MODEL_NS;
            _layers.clear();

            if (newState && newState.timeline.length() > 0)
                _layers.loadFromXML(newState);
            else
                _layers.createEmptyLayer();

            _editor.update();
            _canvas.renderFrame();
        }

        private function btnCreate_clickHandler(event:MouseEvent):void
        {
            trace("AnimationScreen.btnCreate_clickHandler();");
            var file:File = new File();
            file.browseForSave("Choose new file location");
            file.addEventListener(Event.SELECT, fileSave_selectHandler);
        }


        private function btnOpen_clickHandler(event:MouseEvent):void
        {
            trace("AnimationScreen.btnOpen_clickHandler();");
            var file:File = new File();
            file.browseForOpen("Open animation model file", [ new FileFilter("Animation model file", "*.xml") ]);
            file.addEventListener(Event.SELECT, file_selectHandler);
        }

        private function btnSave_clickHandler(event:MouseEvent):void
        {
            trace("AnimationScreen.btnSave_clickHandler();");
            saveFile();
        }

        private function listTextures_doubleClickhandler(event:MouseEvent):void
        {
            var texture:AnimationTexture = listTextures.selectedItem as AnimationTexture;

            _layers.addTexture(texture);
            _canvas.renderFrame();
            _editor.update();
        }

        private function fsTexturesDirectory_changeHandler(event:ListEvent):void
        {
            if (fsTexturesDirectory.selectedPath == null)
                return;

            var file:File = new File(fsTexturesDirectory.selectedPath);
            if (file == null || !file.exists || !file.isDirectory )
                return;

            var files:Array = file.getDirectoryListing();
            var textures:Array = [];
            for each (var item:File in files)
            {
                var texture:AnimationTexture = new AnimationTexture(item);
                if (texture.isValid)
                    textures.push(texture);
            }

            listTextures.dataProvider = new ArrayCollection(textures);
            listTextures.selectedIndex = 0;

            if (textures.length)
                imgPreview.texture = textures[0];
            else
                imgPreview.texture = null;

            StoredFieldManager.instance.setString(Constants.SO_ANIMATION_DIRECTORY, file.nativePath);
        }

        private function listTextures_changeHandler(event:Event):void
        {
            var texture:AnimationTexture = listTextures.selectedItem as AnimationTexture;
            imgPreview.texture = texture;
        }

        private function file_selectHandler(event:Event):void
        {
            var file:File = event.currentTarget as File;
            openFile(file.nativePath);
        }

        private function fileSave_selectHandler(event:Event):void
        {
            var sf:File = event.currentTarget as File;
            var newFile:File = DataFile.createFile(sf, AnimationModelVO.EMPTY_FILE);

            selectedFile = new AnimationModelVO(newFile);
        }
    }
}
