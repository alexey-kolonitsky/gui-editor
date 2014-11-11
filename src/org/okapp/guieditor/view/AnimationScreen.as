package org.okapp.guieditor.view
{
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.net.FileFilter;
    import flash.ui.Keyboard;

    import mx.collections.ArrayCollection;
    import mx.collections.HierarchicalData;
    import mx.containers.Box;
    import mx.containers.HBox;
    import mx.containers.TabNavigator;
    import mx.controls.FileSystemEnumerationMode;
    import mx.controls.FileSystemTree;
    import mx.controls.Tree;
    import mx.core.ClassFactory;
    import mx.events.ListEvent;
    import mx.managers.PopUpManager;

    import org.kolonitsky.alexey.StoredFieldManager;
    import org.okapp.guieditor.model.AnimationModelVO;
    import org.okapp.guieditor.model.AnimationTexture;
    import org.okapp.guieditor.model.DataFile;
    import org.okapp.guieditor.renderers.TextureFileRenderer;
    import org.okapp.guieditor.view.controls.AnimationCanvas;
    import org.okapp.guieditor.view.controls.Layers;
    import org.okapp.guieditor.view.controls.TexturePreview;
    import org.okapp.guieditor.view.controls.Timeline;
    import org.okapp.guieditor.view.controls.TimelineRule;

    import spark.components.Button;
    import spark.components.Group;
    import spark.components.Image;
    import spark.components.Label;
    import spark.components.List;
    import spark.components.TextArea;
    import spark.events.TextOperationEvent;

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


        //------------------commitP-----------
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
            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
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

            if (layers == null)
            {
                layers = new Layers();
                layers.left = COL3_LEFT;
                layers.right = COL_GAP;
                layers.top = 0;
                layers.height = TimelineRule.DEFAULT_HEIGHT;
            }

            if (canvas == null)
            {
                canvas = new AnimationCanvas(layers);
                canvas.left = COL3_LEFT;
                canvas.top = (Timeline.FRAME_HEIGHT + 1) * 3;
                canvas.right = COL_GAP;
                canvas.height = 400;

                addElement(canvas);
                addElement(layers)
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

            if (panels == null)
            {
                panels = new TabNavigator();
                panels.top = 600;
                panels.left = COL3_LEFT;
                panels.right = COL_GAP;
                panels.bottom = 0;
                addElement(panels);


                if (taEditor == null)
                {
                    var g:Box = new Box();
                    g.label = "Editor";
                    g.y = 0;
                    g.x = 0;
                    g.percentWidth = 0;
                    g.percentHeight= 0;
                    panels.addChild(g);

                    taEditor = new TextArea();
                    taEditor.y = 0;
                    taEditor.x = 0;
                    taEditor.percentWidth = 100;
                    taEditor.percentHeight = 100;
                    taEditor.setStyle("fontFamily", "_typewriter");
                    taEditor.setStyle("fontSize", 12);
                    taEditor.addEventListener(TextOperationEvent.CHANGE, editor_changeHandler);
                    g.addChild(taEditor);
                }

                if (treeStates == null)
                {
                    var hg:HBox = new HBox();
                    hg.label = "States";
                    hg.y = 0;
                    hg.x = 0;
                    hg.percentWidth = 100;
                    hg.percentHeight = 100;
                    panels.addChild(hg);

                    var btnAddState:Button = new Button();
                    btnAddState.label = "Add";
                    btnAddState.width = 60;
                    btnAddState.addEventListener(MouseEvent.CLICK, btnAddState_clickHandler);
                    hg.addChild(btnAddState);

                    var btnDeleteState:Button = new Button();
                    btnDeleteState.label = "Delete";
                    btnDeleteState.width = 60;
                    btnDeleteState.addEventListener(MouseEvent.CLICK, btnDeleteState_clickHandler);
                    hg.addChild(btnDeleteState);

                    treeStates = new Tree();
                    treeStates.y = 30;
                    treeStates.x = 0;
                    treeStates.percentWidth = 100;
                    treeStates.percentHeight = 100;
                    treeStates.showRoot = false;
                    treeStates.labelField = "@name";
                    treeStates.addEventListener(Event.CHANGE, treeStates_changeHandler);
                    hg.addChild(treeStates);
                }
            }

            if (btnOpen == null)
            {
                btnOpen = new Button();
                btnOpen.top = 0;
                btnOpen.left = COL2_WIDTH - 60 - COL_GAP - 60;
                btnOpen.width = 60;
                btnOpen.label = "Open";
                btnOpen.addEventListener(MouseEvent.CLICK, btnOpen_clickHandler);
                addElement(btnOpen);
            }
            if (btnCreate == null)
            {
                btnCreate = new Button();
                btnCreate.top = 0;
                btnCreate.left = COL2_WIDTH - 60;
                btnCreate.width = 60;
                btnCreate.label = "Save";
                btnCreate.addEventListener(MouseEvent.CLICK, btnCreate_clickHandler);
                addElement(btnCreate);
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

        private var _currentState:XML = null;

        private function treeStates_changeHandler(event:Event):void
        {
            var selectedState:XML = treeStates.selectedItem as XML;
            if (selectedState)
            {
                default xml namespace = new Namespace(Constants.OKAPP_ANIMATION_MODEL_NAMESPACE);
                var children:XMLList = selectedState.timeline;
                if (children.length() == 0)
                {
                    var timelines:XMLList = layers.toXML();
                    selectedState.appendChild(timelines);
                    layers.reset();
                }
                else
                {
                    layers.fromXML(selectedState);
                }
            }

            _currentState = selectedState;
        }

        private function btnDeleteState_clickHandler(event:MouseEvent):void
        {
            var selectedState:XML = treeStates.selectedItem as XML;
            if (selectedState)
            {
                default xml namespace = new Namespace(Constants.OKAPP_ANIMATION_MODEL_NAMESPACE);
                var parent:XML = selectedState.parent();
                var chiltren:XMLList = parent.children();
                delete chiltren[ selectedState.childIndex() ];
            }
        }

        private function btnAddState_clickHandler(event:MouseEvent):void
        {
            trace("addState");
            var popup:CreateStateDialog = PopUpManager.createPopUp(this, CreateStateDialog, true) as CreateStateDialog;
            PopUpManager.centerPopUp(popup);

            popup.addEventListener("NewState", addState_newStateHandler);
        }

        private function addState_newStateHandler(event:Event):void
        {
            var popup:CreateStateDialog = event.currentTarget as CreateStateDialog;
            var stateName:String = popup.tiStateName.text;

            if (stateName == null || stateName == "")
                return;

            var selectedState:* = treeStates.selectedItem;
            if (selectedState)
            {
                selectedState.appendChild(<state name={stateName} />);
            }
            else
            {
                selectedFile.buffer.appendChild(<state name={stateName} />);
            }
        }

        override protected function initializationComplete():void
        {
            super.initializationComplete();

            if (_selectedFile == null)
            {
                var path:String = File.documentsDirectory.nativePath + "\\" + "tmp.xml";
                var file:File = DataFile.createEmptyFile(path, AnimationModelVO.FILE_NAME_PATTERN, AnimationModelVO.EMPTY_FILE);

                selectedFile = new AnimationModelVO(file)
            }
        }

        override protected function commitProperties():void
        {
            if (_selectedFileChanged)
            {
                if (selectedFile.isValid)
                {
                    default xml namespace = new Namespace(Constants.OKAPP_ANIMATION_MODEL_NAMESPACE);
                    treeStates.dataProvider = selectedFile.buffer;
                }
                _selectedFileChanged = false;

            }
        }

        private function btnCreate_clickHandler(event:MouseEvent):void
        {
            trace("AnimationScreen.btnSave_clickHandler();");
        }

        private function btnOpen_clickHandler(event:MouseEvent):void
        {
            trace("AnimationScreen.btnOpen_clickHandler();");
        }

        private function listTextures_doubleClickhandler(event:MouseEvent):void
        {
            var texture:AnimationTexture = listTextures.selectedItem as AnimationTexture;

            var file:File = texture.file;

            var img:Image = new Image();
            img.source = texture.image;

            layers.addImage(img, file.nativePath);
            canvas.renderFrame();
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

        private var btnOpen:Button;
        private var btnCreate:Button;

        private var canvas:AnimationCanvas;

        private var textures:Array /* of AnimationTexture */ = [];

        private var panels:TabNavigator = null;
        private var treeStates:Tree;

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
                var texture:AnimationTexture = new AnimationTexture(item);
                if (texture.isValid)
                    textures.push(texture);
            }

            listTextures.dataProvider = new ArrayCollection(textures);
            listTextures.selectedIndex = 0;

            imgPreview.texture = textures[0];

            StoredFieldManager.instance.setString(Constants.SO_ANIMATION_PATH, file.nativePath);
        }

        private function editor_changeHandler(event:TextOperationEvent):void
        {

        }

        private function listTextures_changeHandler(event:MouseEvent):void
        {
            imgPreview.texture = listTextures.selectedItem as AnimationTexture;
        }

        private function addedToStage(event:Event):void
        {
            addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
        }

        private function stage_keyDownHandler(event:KeyboardEvent):void
        {
            var file:File;

            switch (event.keyCode)
            {
                case Keyboard.I:
                    file = new File();
                    file.browseForOpen("Open animation model file", [ new FileFilter("Animation model file", "*.xml") ]);
                    file.addEventListener(Event.SELECT, file_selectHandler);
                    break;

                case Keyboard.E:
                    var _buffer:XMLList = layers.toXML();
                    taEditor.text = _buffer.toXMLString();
                    file = new File(File.documentsDirectory.nativePath + "\\" + "tmp.xml");
                    var stream:FileStream = new FileStream();
                    stream.open(file, FileMode.WRITE);
                    stream.writeUTFBytes(_buffer.toString());
                    stream.close();
                    break;
            }
        }

        private function file_selectHandler(event:Event):void
        {
            var file:File = event.currentTarget as File;

            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.READ);
            var strBuffer:String = stream.readUTFBytes(stream.bytesAvailable);
            stream.close();

            var xml:XML = new XML(strBuffer);

            taEditor.text = strBuffer;

            layers.fromXML(xml);

        }
    }
}
