# adlib _base libraries for a simple/adhoc/dynamic approach_

The following libraries represent a particular approach to small projects. The spine of the app is built up using a hierachy of objects subclassing SimpleNode, such as App, Scene and other larger components.

SimpleNode provides a consistent approach to managing resource lifetime and propagating events from the stage through the hierachy. These components are heavyweight and might not be used to represent all game objects.

Instead each SimpleNode object should use the tweening, frame based dispatch and other conveniences available to wrangle dynamic objects, functions and arrays to quickly build up functionality in an adhoc manner.

Functionality that would often be provided by various singletons is instead tied to the objects in the SimpleNode hierachy. The structure provided by the hierachy, particularly around lifetime and cleanup means dynamic functionality can be built up at runtime without things instantly becoming a total mess. This is at odds with both an entity/component system and a deeply subclassed OO approach. In adlib the hierachy of objects is more important than the hierachy of types, and class names should mostly be relevant only as constructors. An entity system would be a worthwhile addition, if associated with the lifecycle of a specific SimpleNode instance in exactly the same way as the TweenManager.

Other utility code represents opinionated ways to handle touch areas, buttons, sound and Starling resources. 

## the display list

SimpleNode objects do not subclass DisplayObject, instead a convenience property supports associating an empty sprite with each SimpleNode if required.

The intention is that this sprite is manually added to the stage display list as and where required. Visual assets are then added to the sprite at runtime (often as a MovieClip pulled out of the libary) and then wired up with behaviours.

In this manner a SimpleNode object can just as naturally manage objects in the Starling display list or non-visual objects.

## conventions

### Timing

All timing, eg. in the tween and event dispatch libraries is based on whole numbers of frames, rather than seconds, requiring a fixed timestep approach throughout.

### Events

The App class subscribes to flash events on the stage.

ENTER_FRAME is propagated through the hierachy as onFrame()

Other events are subscribed and dispatched through a shared EventDispatch object. Input events are deferred and handled during the next onFrame.

### Screen Size

A ScreenFit object is used to define a nominal point size for the application, that is then best fit to the actual screen size and available assets.

Code still needs to manually allow for alignment with screen space, but does so using a single nominal point size, so most behaviour is coded to fixed frame rate and dimensions.

### Resource cleanup

Objects with a dispose method should have their dispose method called when they are finished with, in addition they should dispose any resources they own.

The SimpleNode class allows you to add objects to a disposable list, if these objects have a disposable method it will be used. If the object is a function it will be called, if it is a sound it will be stopped.