package org.okapp.guieditor.view.controls
{
    import flash.events.Event;
    import flash.events.MouseEvent;

    import mx.containers.Canvas;
    import mx.controls.Tree;
    import mx.managers.PopUpManager;
    import mx.managers.PopUpManagerChildList;

    import org.okapp.guieditor.model.AnimationModelEvent;

    import org.okapp.guieditor.model.AnimationModelVO;
    import org.okapp.guieditor.view.controls.StateDataDescriptor;
    import org.okapp.guieditor.view.popups.CreateStatePopup;

    import spark.components.Button;

    public class AnimationStatePanel extends Canvas
    {
        //-----------------------------
        // current state
        //-----------------------------

        private var _selectedState:XML = null;

        public function get selectedState():XML
        {
            return _selectedState;
        }

        //-----------------------------
        // selected File
        //-----------------------------

        private var _selectedFile:AnimationModelVO;
        private var _selectedFileChanged:Boolean = false;

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

        public function AnimationStatePanel()
        {

        }


        override protected function createChildren():void
        {
            super.createChildren();

            if (btnAddState == null)
            {
                btnAddState = new Button();
                btnAddState.label = "Add";
                btnAddState.left = 0;
                btnAddState.top = 0;
                btnAddState.width = 60;
                btnAddState.addEventListener(MouseEvent.CLICK, btnAddState_clickHandler);
                addChild(btnAddState);
            }

            if (btnDeleteState == null)
            {
                btnDeleteState = new Button();
                btnDeleteState.label = "Delete";
                btnDeleteState.left = 0;
                btnDeleteState.top = 30;
                btnDeleteState.width = 60;
                btnDeleteState.addEventListener(MouseEvent.CLICK, btnDeleteState_clickHandler);
                addChild(btnDeleteState);
            }

            if (btnCopyState == null)
            {
                btnCopyState = new Button();
                btnCopyState.label = "Copy";
                btnCopyState.width = 60;
                btnCopyState.left = 0;
                btnCopyState.top = 60;
                btnCopyState.enabled = false;
                btnCopyState.toolTip = "Not implemented yet";
                btnCopyState.addEventListener(MouseEvent.CLICK, btnCopyState_clickHandler);
                addChild(btnCopyState);
            }

            if (btnPasteState == null)
            {
                btnPasteState = new Button();
                btnPasteState.label = "Paste";
                btnPasteState.left = 0;
                btnPasteState.top = 90;
                btnPasteState.enabled = false;
                btnPasteState.toolTip = "Not implemented yet";
                btnPasteState.width = 60;
                btnPasteState.addEventListener(MouseEvent.CLICK, btnPasteState_clickHandler);
                addChild(btnPasteState);
            }

            if (treeStates == null)
            {
                treeStates = new Tree();
                treeStates.top = 0;
                treeStates.left = 64;
                treeStates.right = 0;
                treeStates.bottom = 0;
                treeStates.showRoot = false;
                treeStates.labelField = "@name";
                treeStates.dataDescriptor = new StateDataDescriptor();
                treeStates.addEventListener(Event.CHANGE, treeStates_changeHandler);
                addChild(treeStates);
            }
        }


        override protected function commitProperties():void
        {
            super.commitProperties();

            if (_selectedFileChanged)
            {
                if (_selectedFile)
                {
                    default xml namespace = Constants.OKAPP_ANIMATION_MODEL_NS;
                    var xml:XMLList = _selectedFile.buffer.state;
                    treeStates.dataProvider = xml;
                    if (xml.length())
                    {
                        _selectedState = xml[0];
                        treeStates.selectedItem = _selectedState;
                    }
                }
                else
                {
                    treeStates.dataProvider = null;
                    _selectedState = null;
                }
                _selectedFileChanged = false;
            }
        }




        //-------------------------------------------------------------------
        //
        // Private
        //
        //-------------------------------------------------------------------

        private var treeStates:Tree = null;
        private var btnAddState:Button = null;
        private var btnDeleteState:Button = null;
        private var btnCopyState:Button = null;
        private var btnPasteState:Button = null;


        private function btnDeleteState_clickHandler(event:MouseEvent):void
        {
            var selectedState:XML = treeStates.selectedItem as XML;

            if (selectedState)
            {
                default xml namespace = new Namespace(Constants.OKAPP_ANIMATION_MODEL_NAMESPACE);
                var parent:XML = selectedState.parent();
                var chiltren:XMLList = parent.children();
                delete chiltren[ selectedState.childIndex() ];

                trace("INFO: AnimationStatePanel. Delete state " + selectedState.toXMLString());
            }
            else
            {
                trace("INFO: AnimationStatePanel. Unsuccessful deletion. No one state selected.");
            }
        }

        private function btnAddState_clickHandler(event:MouseEvent):void
        {
            trace("INFO: AnimationStatePanel. Show CreateStateDialog");

            var popup:CreateStatePopup = PopUpManager.createPopUp(this, CreateStatePopup, true, PopUpManagerChildList.PARENT) as CreateStatePopup;
            PopUpManager.centerPopUp(popup);

            popup.addEventListener("NewState", addState_newStateHandler);
        }

        private function btnPasteState_clickHandler(event:MouseEvent):void
        {
            trace("Paste state. Not implemented yet");
        }

        private function btnCopyState_clickHandler(event:MouseEvent):void
        {
            trace("Copy state. Not implemented yet");
        }

        private function treeStates_changeHandler(event:Event):void
        {
            if (_selectedState == treeStates.selectedItem)
                return;

            var newState:XML = treeStates.selectedItem as XML;
            var type:String = AnimationModelEvent.CHANGE_STATE;
            dispatchEvent(new AnimationModelEvent(type, newState));

            _selectedState = newState;

            type = AnimationModelEvent.CHANGED_STATE;
            dispatchEvent(new AnimationModelEvent(type, _selectedState));
        }

        private function addState_newStateHandler(event:Event):void
        {
            var popup:CreateStatePopup = event.currentTarget as CreateStatePopup;
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
                _selectedFile.buffer.appendChild(<state name={stateName} />);
            }
        }
    }
}
