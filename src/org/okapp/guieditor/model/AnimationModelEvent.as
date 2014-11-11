package org.okapp.guieditor.model
{
    import flash.events.Event;

    public class AnimationModelEvent extends Event
    {
        public static const CHANGE_STATE:String = "changeAnimationSate";
        public static const CHANGED_STATE:String = "changedAnimationState";

        public var newState:XML = null;

        public function AnimationModelEvent(type:String, newState:XML)
        {
            super(type, false, false);
            this.newState = newState;
        }
    }
}
