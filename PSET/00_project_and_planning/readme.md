# The Final Project!

> This is it--the final course project!

## Logistics

- All of your assets, source code, and deliverables will be in the [../Engine](../Engine) directory.
- We should be able to run your engine in a 'data-driven manner' by feeding in assets/scripts to run a game..

# Final Project - Description

The greater gaming industry is getting positive buzz talking about your game development skills. But dynamics change rapidly in the game industry--you have decided to form a new game studio of your own. From your previous projects, your team has developed a nice codebase with your own intellectual property, and has decided to form a 'game making' studio around this technology. Building an impressive piece of middleware (i.e. a tool or technology that is not a game) to showcase at the giant tradeshows ([PAX East](http://east.paxsite.com/), [GDC](https://www.gdconf.com/), and [the former E3](https://en.wikipedia.org/wiki/E3), etc.) is your next task!

# Final Project

## Game Maker

- For this project you are going to be building a Small 'Game Maker' engine for your final project! 
- You will use your engine to make a game with at least '3' scenes.
- With your engine **you will also** implement either a classic game that we have not previously implemented (e.g. pacman, super mario, etc.)) or an original game using your engine to demonstrate how to use your engine.
	- Thus you will again build a data-driven game engine for 2D games.. 
	- Your game maker will incorporate scripting (whether in D scripts, or perhaps 'pyd') to further enable anyone to use your engine 
		- (Note: you are allowed to explore other scripting languages and libraries like [lua](https://www.lua.org/) or [Angelscript](https://www.angelcode.com/angelscript/)).


## Project Requirements and Constraints

1. Your must build the majority of your technology from scratch.
  - Any 3rd party code (e.g. an image library, networking library, physics library, etc.), must be **first** instructor/ULA/TF approved, and then you should cite your source in the [../readme.md](../readme.md).
	- 3rd party libraries for a physics engine (e.g. Box2D) are okay if you want to incorporate it into the engine, but you otherwise should do the majority of the work.
2. It is expected/permissable that you reuse some code from previous problem sets.
3. You cannot build a tech demo with Unity3D, Unreal Engine -- that is not in the spirit of the course, we are building things from scratch (i.e. you cannot change the final project assignment to something else).

Note--if you have not taken computer graphics, you should not be attempting to learn 3D graphics during this duration -- I am expecting most engines will follow what we have done in this semester and be 2D or pseudo-2D (i.e. perhaps faking 3D perspective, but ultimately be using 2D graphics API). It is highly recommended (and to some extent expected) that most students will work on 2D projects leveraging their previous codebase.

## Project Requirements

The **key** components for your project are:

1. The Dlang based engine that does the heavy lifting and management of game objects and resources -- this is likely similar to your most recent game and editor PSETS.
2. An editor or supporting tools for building games
   - (e.g. A GUI editor that shows your scene and game objects, a GUI-based tile editor, a GUI-based world editor, a sprite animation tool, etc.)
   - i.e. You should have some 'tooling' that otherwise generates data for your engine. Someone should be able to build or layout scenes for your game using tooling (i.e. your engine should not just be D code, but some tooling supporting the engine).
4. A game built in your engine (i.e. a classic or original game) with 3 'scenes'.

## Technical Requirements

The following are the technical requirements of your game engine. There is significant freedom in how you achieve them, but I would like you to apply these techniques in your engine.

- [ ] Implement a resource manager
- [ ] Implement a GUI-based editor/environment for assisting building a game (e.g. A tilemap editor, 2D animation preview tool, etc.)
	- This tool need not be implemented in Dlang, but should otherwise generate data that your Dlang engine can use.
- [ ] Your engine must be data-driven
  - [ ] Scripts of some kind should be loaded for the gameplay logic (e.g. D Scripts, hot reloaded from DLang, using PyD, or perhaps something else)
  - [ ] Other configuration files (e.g. levels, scenes, etc.) should be loaded at run-time.
- [ ] Your engine should be component-based **or** use some other logical pattern for organizing game objects (At a minimum you should have a gameobject class).
- [ ] Something **extra** that gives your engine a 'wow' factor to show off to the TA's and instructors. Highlight this in your video (could be engineering, could be a gameplay mechanic that you designed your engine around, the goal is that it is something non-trivial)

### Some notes on building a game maker

1. Very likely you may need to integrate some GUI library into your engine to make it useable.
   - Think about this early--even draw a picture of what you think it should look like.
   - Think about if this GUI needs to be in a scripting language (e.g. Python) or in the D code.
      - At the end of the day, you just need a tool that generates data.
2. *Think* data-driven
   - This means your Dlang Code handles your engine, and your scripting language (e.g. A script component in D, or perhaps PyD or luaD) should handle the game logic.
3. You should be able to utilize many of the game programming patterns discussed in the course with this system.
4. The game you build, need not span hours, but should at least demonstrate that a game with objectives can be played and won, and new data can be loaded and handled in the engine.

## Inspiration!

It **would be wise** to spend some time looking at [past course projects](./past.md) to otherwise get an idea of what your project make look like.

Note; Project requirements have changed over time, but generally speaking the linked previous year projects are good examples of the spirit of what we are making this semester.

## Gameplan

Given the above requirements, you may use this space to write some notes in with your team. I suggest coming up with a timeline with your team members below.

For example:

1. Week 1 - Start brainstorming, gather resources, from previous assignments and start planning
3. Week 2 - Implementation of Editor and main components of engine
4. Week 3 - Continue iterating on engine, and build prototype of game.
5. Week 4 to finish - Put together website and polish off bugs

You may also want to discuss how you'd like to keep in touch (e.g. E-mail, discord, teams, Google Meet, etc.), and the frequency at which you will meet.

### Timeline

*edit if you like*

1. *week 1 goals, and who will work on what*
2. *week 2 goals, and who will work on what*
3. *week 3 goals, and who will work on what*
4. *week 4 goals, and who will work on what*
5. *week 5 goals, and who will work on what*
6. *week 6 goals, and who will work on what*
7. *week 7 goals, and who will work on what*
8. *week 8 goals, and who will work on what*

## Universal Resources

You will be using SDL to build this project and the same libraries that we have been using during the semester.

| D Programming Related Links                         | Description                       |
| --------------------------------------------------  | --------------------------------- |
| [My D Youtube Series](https://www.youtube.com/playlist?list=PLvv0ScY6vfd9Fso-3cB4CGnSlW0E4btJV) | My video series playlist for learning D Lang. |
| [DLang Phobos Standard Library Index](https://dlang.org/phobos/index.html)  | The Phobos Runtime Library (i.e. standard library of code.)
| [D Language Tour](https://tour.dlang.org/)           | Nice introduction to the D Language with samples you can run in the browser. |
| [Programming in D](https://ddili.org/ders/d.en/)     | Freely available D language programming book |
| [My SDL 3 D Playlist](https://www.youtube.com/playlist?list=PLvv0ScY6vfd-5hY-sFyttTjfuUxG5c7OA) | My SDL 3 Playlist in D | 
| [My SDL 3 C++ Playlist](https://www.youtube.com/playlist?list=PLvv0ScY6vfd-RZSmGbLkZvkgec6lJ0BfX) | My SDL 3 Playlist in C++ (Also relevant for this course) |
| [My SDL 2 C++ Playlist](https://www.youtube.com/playlist?list=PLvv0ScY6vfd-p1gSnbQhY7vMe2rng0IL0)     | My SDL 2 Playlist (Older but some different lessons) |
