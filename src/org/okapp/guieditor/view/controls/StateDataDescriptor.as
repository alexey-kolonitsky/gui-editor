package org.okapp.guieditor.view.controls
{
    import mx.collections.ICollectionView;
    import mx.collections.XMLListCollection;
    import mx.controls.treeClasses.ITreeDataDescriptor;

    public class StateDataDescriptor implements ITreeDataDescriptor
    {
        public static const NS:Namespace = new Namespace(Constants.OKAPP_ANIMATION_MODEL_NAMESPACE);
        public function StateDataDescriptor()
        {
            super();
        }


        public function getChildren(node:Object, model:Object = null):ICollectionView
        {
            default xml namespace = NS;
            var list:XMLList = node.state;
            return new XMLListCollection(list);
        }

        public function hasChildren(node:Object, model:Object = null):Boolean
        {
            default xml namespace = NS;
            var collection:XMLListCollection = model as XMLListCollection;
            for each (var source:XML in collection)
            {
                if (source == node)
                    return true;

                for each (var item:XML in source..state)
                    if (node == item)
                        return true;
            }

            return false;
        }

        public function isBranch(node:Object, model:Object = null):Boolean
        {
            default xml namespace = NS;
            var list:XMLList = node.state;
            return list.length() > 0;
        }

        public function getData(node:Object, model:Object = null):Object
        {
            return node;
        }

        public function addChildAt(parent:Object, newChild:Object, index:int, model:Object = null):Boolean
        {
            return false;
        }

        public function removeChildAt(parent:Object, child:Object, index:int, model:Object = null):Boolean
        {
            return false;
        }
    }
}
