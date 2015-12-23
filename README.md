# ShootingStars
Some fun Shooting Star animations built with both SpriteKit and CAEmitterLayer. Run the example project to see both in action.

There are 2 ways to achieve a shooting star animation, which travels along a defined path while emitting particles. There are both some advantages, and disadvantages for each method.

##Sprite Kit Example
![sprite-kit-star](http://i.imgur.com/AKS3AuT.gif)
###Advantages
- Particle emitters are much more flexible. You can attach a `targetNode` to your sprite's emitter, which allows your particles to become independent of the sprite, thus not moving along the same path as the sprite. This is not as easily achievable using `CAEmitterLayer`
- Sprite Particles (`.sks` files in Xcode) come with a very nice preview playground, where you can tweak values of the particles and see the changes real-time, and not have to keep restarting your app to see the changes.
- End result seems much smoother

###Disadvantages
- You must add a `SKView` and associated `SKScene` on top of your view. `SKScene`'s have very different coordinate systems than regular `UIView`s. Read more from Apple here. This means you may carefully translate coordinates from a `UIView` to a `SKScene`
- Performance wise, using Sprite Kit seems to lag much easier (at least with this example). For example, in the sample, try to shoot off 5 SpriteKit stars, and then shoot off 5 Core Animation stars. You'll notice a lot of lag on the SpriteKit star, but not much on the CoreAnimation star

##Core Animation Example
###Advantages
- You don't need to worry about thinking about converting coordinates to a points in a `SKScene`, or worry about adding a `SKView` on top of your current `UIView`
- Performance (at least for this example) seems much better. You can shoot off many CA stars with little to no lag

###Disadvantages
- Emitters do not have a nice playground where you can easily tweak settings and see the result real time. You must either keep restarting your app, or purchase an app that allows you to tweak settings and see the result real time.
- Emitter particles, when attached to a `UIView`, follow the same path the `UIView` does, resulting in some ugly animations of your `UIView` does lots of turns with particles.


![sprite-kit-star](http://i.imgur.com/FIXKVqG.gif)
