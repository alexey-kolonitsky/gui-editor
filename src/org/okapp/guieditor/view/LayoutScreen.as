package org.okapp.guieditor.view
{
    import com.okapp.pirates.commands.StarlingContextCommand;
    import com.okapp.pirates.ui.controls.Canvas;
    import com.okapp.pirates.ui.core.GUIElementDefinition;
    import com.okapp.pirates.ui.core.GUIXMLConverter;

    import flash.display3D.Context3D;
    import flash.events.MouseEvent;
    import flash.filesystem.File;

    import mx.controls.FileSystemTree;
    import mx.events.ListEvent;

    import org.kolonitsky.alexey.StoredFieldManager;
    import org.okapp.guieditor.model.DataFile;
    import org.okapp.guieditor.model.GUIVO;

    import spark.components.Button;
    import spark.components.Label;
    import spark.components.TextArea;
    import spark.events.TextOperationEvent;

    import starling.core.Starling;

    public class LayoutScreen extends BaseScreen
    {
        public var COL1_WIDTH:Number = 300;
        public var COL2_WIDTH:Number = 600;
        public var COL_GAP:Number = 4;


        //-----------------------------
        // selected file
        //-----------------------------

        private var _selectedFile:GUIVO = null;
        private var _selectedFileChanged:Boolean = false;

        [Bindable]
        public function get selectedFile():GUIVO
        {
            return _selectedFile;
        }

        public function set selectedFile(value:GUIVO):void
        {
            _selectedFile = value;
            _selectedFileChanged = true;
            invalidateProperties();
        }


        //-----------------------------
        // constructor
        //-----------------------------

        public function LayoutScreen()
        {
            super();
        }


        //-------------------------------------------------------------------
        // UIComponenet API implementation
        //-------------------------------------------------------------------


        override protected function createChildren():void
        {
            super.createChildren();

            if (lblXMLDirecotry == null)
            {
                lblXMLDirecotry = new Label();
                lblXMLDirecotry.text = "Layout-file Location";
                lblXMLDirecotry.left = 0;
                lblXMLDirecotry.top = 0;
                lblXMLDirecotry.width = COL1_WIDTH;
                lblXMLDirecotry.bottom = 0;
                lblXMLDirecotry.setStyle("backgroundColor", 0xFFFFFF);
                lblXMLDirecotry.setStyle("paddingTop", 5);
                lblXMLDirecotry.setStyle("paddingLeft", 5);
                addElement(lblXMLDirecotry);
            }

            if (btnCreate == null)
            {
                btnCreate = new Button();
                btnCreate.top = 0;
                btnCreate.left = COL1_WIDTH - 60;
                btnCreate.width = 60;
                btnCreate.label = "Create";
                btnCreate.addEventListener(MouseEvent.CLICK, btnCreate_clickHandler);
                addElement(btnCreate);
            }

            if (taEditor == null)
            {
                taEditor = new TextArea();
                taEditor.top = 600;
                taEditor.left = COL1_WIDTH + COL_GAP;
                taEditor.right = 0;
                taEditor.bottom = 0;
                taEditor.setStyle("fontFamily", "_typewriter");
                taEditor.setStyle("fontSize", 12);
                taEditor.addEventListener(TextOperationEvent.CHANGE, editor_changeHandler);
                addElement(taEditor);
            }

            if (fsTreeXML == null)
            {
                fsTreeXML = new FileSystemTree();
                fsTreeXML.left = 0;
                fsTreeXML.top = 30;
                fsTreeXML.width = COL1_WIDTH;
                fsTreeXML.bottom = 0;
                fsTreeXML.addEventListener(ListEvent.CHANGE, fsTreeXML_changeHandler);
                fsTreeXML.selectedPath = StoredFieldManager.instance.getString(Constants.SO_LAYOUT_PATH);
                addElement(fsTreeXML);

                fsTreeXML_changeHandler(null);
            }

            if (lblPreview == null)
            {
                lblPreview = new Label();
                lblPreview.y = 0;
                lblPreview.left = COL1_WIDTH + COL_GAP;
                lblPreview.right = 0;
                lblPreview.text = "Preview";
                lblPreview.setStyle("paddingTop", 5);
                addElement(lblPreview);
            }

            createPreview();
        }

        override protected function initializationComplete():void
        {
            super.initializationComplete();

            openFile(fsTreeXML.selectedPath);

            if (_selectedFile == null)
            {
                var documentsPath:String = File.documentsDirectory.nativePath;
                var newFile:File = DataFile.createEmptyFile(
                    documentsPath,
                    GUIVO.GUI_FILE_NAME_TEMPLATE,
                    GUIVO.GUI_EMPTY_FILE_CONTENT);

                _selectedFile = new GUIVO(newFile);
            }

            fsTreeXML.refresh();
            fsTreeXML.selectedPath = _selectedFile.file.nativePath;
            fsTreeXML_changeHandler(null);
        }

        override protected function commitProperties():void
        {
            super.commitProperties();

            if (_selectedFileChanged && selectedFile && selectedFile.file)
            {
                fsTreeXML.openPaths = selectedFile.path;
                _selectedFileChanged = false;
            }
        }


        //-------------------------------------------------------------------
        // Base Screen API Implementation
        //-------------------------------------------------------------------

        override protected function createPreview():void
        {
            if (_preview == null)
            {
                _preview = new Canvas();
                _preview.x = COL1_WIDTH + COL_GAP;
                _preview.y = 30;
            }

            var context:Context3D = Starling.context;
            if (starling && context)
            {
                starling.stage.addChild(_preview);
                var cmd:StarlingContextCommand = new StarlingContextCommand();
                cmd.execute();
            }
        }


        override protected function removePreview():void
        {
            if (starling && _preview)
            {
                starling.stage.removeChild(_preview);
            }
        }


        //-------------------------------------------------------------------
        //
        //  Private
        //
        //-------------------------------------------------------------------

        private var _preview:Canvas;
        private var lblPreview:Label;
        private var lblXMLDirecotry:Label;
        private var btnCreate:Button;
        private var fsTreeXML:FileSystemTree;
        private var taEditor:TextArea;


        private function openFile(path:String):void
        {
            if (path == null || path == "")
                return;

            var newFile:GUIVO = new GUIVO(new File(path));
            if (newFile.isValid)
            {
                selectedFile = newFile;

                StoredFieldManager.instance.setString(Constants.SO_LAYOUT_PATH, fsTreeXML.selectedPath);

                taEditor.text = selectedFile.buffer.toXMLString();

                if (_preview && selectedFile && starling)
                {
                    var definitions:Vector.<GUIElementDefinition> = GUIXMLConverter.convertGUINode(selectedFile.buffer);
                    _preview.createAllElements(definitions);
                }

            }
            else
            {
                taEditor.text = newFile.log;
            }
        }


        //-------------------------------------------------------------------
        // Event handlers
        //-------------------------------------------------------------------

        private function fsTreeXML_changeHandler(event:ListEvent):void
        {
            if (_preview)
                _preview.clearAllElements();

            openFile(fsTreeXML.selectedPath);
        }

        private function editor_changeHandler(event:TextOperationEvent):void
        {
            try
            {
                var xml:XML = new XML(taEditor.text);
                taEditor.errorString = "";
            }
            catch (error:Error)
            {
                taEditor.errorString = error.message;
                return;
            }

            selectedFile.update(xml);

            if (_preview && selectedFile)
            {
                _preview.clearAllElements();

                var definitions:Vector.<GUIElementDefinition> = GUIXMLConverter.convertGUINode(selectedFile.buffer);
                _preview.createAllElements(definitions);
            }
        }

        private function tiName_changeHandler(event:TextOperationEvent):void
        {
            //TODO: Add rename ability
        }

        private function btnCreate_clickHandler(event:MouseEvent):void
        {
            var newFile:File = DataFile.createEmptyFile(
                fsTreeXML.selectedPath,
                GUIVO.GUI_FILE_NAME_TEMPLATE,
                GUIVO.GUI_EMPTY_FILE_CONTENT);

            fsTreeXML.refresh();
            fsTreeXML.selectedPath = newFile.nativePath;
            fsTreeXML_changeHandler(null);
        }

    }
}
