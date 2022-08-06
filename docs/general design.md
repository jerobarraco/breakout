# General Design #

The game is a simple Break-out game.

### The basic description is :
The user controls a paddle that move sideways at the bottom of the screen.
There's a ball that will be moving, bouncing off of objects in the screen, 
including the walls. 
The bottom part of the screen is open, if the ball "falls" through there,
the game is lost.
The user must use the paddle to avoid the ball to go offscreen.

There are also blocks that breaks when the ball bounces on them. 
The second objective is for the user to try to break all the blocks.

### Basic Game Elements:

	Paddle:
		* Controlled by the player
	
	Ball: 
		* Moves accordingly to its vector
		* When it collides with an element, it will bounce, changing
		its vector
		* When it gets offscreen the game is over
		
	Blocks:
		* Gets broken by the ball
		* When all the blocks are broken the game is over

### System Elements:
Might be added only if the time is available

	Gui:
		Buttons:
			* Restart game
			* Pause
			* Mute (includes implementing music)
		Dialogs:
			* Win/Lose. Game over
			* Pauses
	Media:
		Music:
		Sound FX:
		
    Particle system:

### Extra Game Elements
Will be added in case i have the time to.
	
	Details:
	    * Angle of reflection dependant on the position of the paddle
	    
	Power ups/downs:
		* System for common power ups /downs. 
		The ball and the paddle must be able to receive influence of other objects.
		
	Competitive Objective:
		* As the game can either be won or lost, there could be added another way
		to differentiatie skills. Those might be:
		Score: Same blocks the same stage makes it useless.
		Time: Might be a good diferentiating point.
		Lives: A multi-live system might be implemented.
	
	Levels:
		* A way to load levels from a definition source (json or xml).
		* A system to go trough levels
		
		
