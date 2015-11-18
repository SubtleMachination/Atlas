//
//  Atlas.swift
//  Atlas
//
//  Created by Dusty Artifact on 11/16/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation

protocol MapDelegate
{
    //////////////////////////////////////////////////////////////////////////////////////////
    // Map Inspection
    //////////////////////////////////////////////////////////////////////////////////////////
    func mapDimensions() -> (width:Int, height:Int)
    func tileInfo() -> (min:Int, max:Int, tiles:Set<Int>)
    func valueAt(x:Int, y:Int) -> Int?
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Map Manipulation
    //////////////////////////////////////////////////////////////////////////////////////////
    func setTileAt(x:Int, y:Int, val:Int)
}

enum RunningState
{
    // RUNNING indicates that Atlas is initialized and operational
    case RUNNING, HALTED
}

enum OperatingState
{
    // READY indicates that Atlas has done thinking and is ready to decide on future steps
    // BUSY indicates that Atlas is still deciding what to do next
    case READY, BUSY
}

enum ResourceState
{
    case UNPREPARED, PREPARED
}

struct Action
{
    var x:Int
    var y:Int
    var val:Int
    var relatedTask:Task
}

enum TaskType
{
    case RANDOMNESS, BUNCHOFROOMS, ROOM, CONNECTROOMS
}

class Task
{
    let type:TaskType
    var subtasks:[Task]
    var completed:Bool
    var supertask:Task?
    
    init(type:TaskType)
    {
        self.type = type
        self.subtasks = [Task]()
        self.completed = false
    }
}

struct Region
{
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Atlas is used as follows:
// 1. Initialize Atlas
// 2. Give it access to a map (setDelegate)
// 3. Initialize its canvas (setupCanvas)
// 4. Give it a task
// 5. Let it go! (run)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class Atlas
{
    var mapDelegate:MapDelegate?
    var bounds:(width:Int, height:Int)
    var tileInfo:(min:Int, max:Int, tiles:Set<Int>)
    
    var centralLogicTimer:NSTimer
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Deliberate slowdown to a human-observable pace. 1 = 60fps, 2 = 30fps, 3 = 20fps...
    var tick:Int = 0
    var actionRateLimit:Int = 5
    var thoughRateLimit:Int = 2
    //////////////////////////////////////////////////////////////////////////////////////////
    
    var runningState:RunningState = RunningState.HALTED
    var operatingState:OperatingState = OperatingState.READY
    var canvasState:ResourceState = ResourceState.UNPREPARED
    
    var tasks:Queue<Task>
    var actions:Queue<Action>
    
    var actionThreshold:Int
    var currentTask:Task?
    
    init()
    {
        bounds = (width:0, height:0)
        tileInfo = (min:0, max:0, tiles:Set<Int>())
        
        tasks = Queue<Task>()
        actions = Queue<Action>()
        
        actionThreshold = 10

        centralLogicTimer = NSTimer()
        initializeCentralLogicTimer()
    }
    
    func initializeCentralLogicTimer()
    {
        centralLogicTimer = NSTimer.scheduledTimerWithTimeInterval(0.016, target:self, selector:"logicalCore:", userInfo:nil, repeats:true)
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Logic
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    @objc func logicalCore(timer: NSTimer)
    {
        incrementTick()
        
        if (runningState == .RUNNING)
        {
            // Perform a single action (rate-limited)
            if (tick % actionRateLimit == 0)
            {
                if (!actions.isEmpty())
                {
                    performAction(actions.dequeue()!)
                }
            }
            
            if (operatingState == .READY)
            {
                if (tick % thoughRateLimit == 0)
                {
                    // Decide what to do next
                    if (tasks.count > 0)
                    {
                        if (actions.count < actionThreshold)
                        {
                            getNextTask()
                            
                            if (currentTask != nil)
                            {
                                proceedWithTask()
                            }
                            else
                            {
                                // All tasks completed. Wait for further instructions
                                print("JOB DONE!")
                                pause()
                            }
                        }
                        else
                        {
                            // Hold your horses -- you've got too many actions queued up.
                            // Give them a chance to clear out before you decide what to do next.
                        }
                    }
                    else
                    {
                        
                    }
                }
            }
        }
    }
    
    func incrementTick()
    {
        tick++
        tick = (tick > 10000) ? 0 : tick
    }
    
    // Assumes that Atlas CAN and SHOULD act
    func proceedWithTask()
    {
        operatingState = .BUSY
        
        // Let's take a look at the next task on our list
        if (currentTask!.type == .BUNCHOFROOMS)
        {
            // Break the task down into subtasks
            let roomCount = randIntBetween(3, stop:5)
            for _ in 0..<roomCount
            {
                let roomTask = Task(type:TaskType.ROOM)
                roomTask.supertask = currentTask
                
                currentTask!.subtasks.append(roomTask)
            }
        }
        
        if (currentTask!.type == .ROOM)
        {
            createRandomRectangle()
            currentTask!.completed = true
        }
        
        operatingState = .READY
    }
    
    
    func createRandomSquare()
    {
        // Right now, not very sensitive to what is already on the board
        let randomRadius = randIntBetween(1, stop:3)
        let randomCenterX = randIntBetween(0+randomRadius, stop:bounds.width-1-randomRadius)
        let randomCenterY = randIntBetween(0+randomRadius, stop:bounds.height-1-randomRadius)
        
        for x in randomCenterX-randomRadius...randomCenterX+randomRadius
        {
            for y in randomCenterY-randomRadius...randomCenterY+randomRadius
            {
                let action = Action(x:x, y:y, val:1, relatedTask:currentTask!)
                actions.enqueue(action)
            }
        }
    }
    
    func createRandomRectangle()
    {
        // Right now, not very sensitive to what is already on the board
        let randomXRadius = randIntBetween(1, stop:3)
        let randomYRadius = randIntBetween(1, stop:3)
        let randomCenterX = randIntBetween(0+randomXRadius, stop:bounds.width-1-randomXRadius)
        let randomCenterY = randIntBetween(0+randomYRadius, stop:bounds.height-1-randomYRadius)
        
        for x in randomCenterX-randomXRadius...randomCenterX+randomXRadius
        {
            for y in randomCenterY-randomYRadius...randomCenterY+randomYRadius
            {
                let action = Action(x:x, y:y, val:1, relatedTask:currentTask!)
                actions.enqueue(action)
            }
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Tasks
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func getNextTask()
    {
        // Get the next task
        if let nextTask = tasks.peek()
        {
            currentTask = smallestIncompleteSubtask(nextTask)
        }
    }
    
    func smallestIncompleteSubtask(root:Task) -> Task?
    {
        if (root.completed)
        {
            return nil
        }
        else
        {
            // No children, return self
            if (root.subtasks.count == 0)
            {
                return root
            }
            else
            {
                // Get the FIRST INCOMPLETE CHILD
                for subtask in root.subtasks
                {
                    if (!subtask.completed)
                    {
                        return smallestIncompleteSubtask(subtask)
                    }
                }
            }
        }
        
        // Because we make the assumption that an incomplete parent MUST have at least one incomplete child,
        // This return statement should never fire
        return nil
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Actions
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Assumes that Atlas CAN and SHOULD act
    func randomAction()
    {
        let randomX = randIntBetween(0, stop:bounds.width-1)
        let randomY = randIntBetween(0, stop:bounds.height-1)
        let randomValue = randIntBetween(tileInfo.min, stop:tileInfo.max)
        
        let action = Action(x:randomX, y:randomY, val:randomValue, relatedTask:currentTask!)
        actions.enqueue(action)
    }
    
    // Assumes that Atlas CAN and SHOULD act
    func performAction(action:Action)
    {
        mapDelegate?.setTileAt(action.x, y:action.y, val:action.val)
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Setup and State Control
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func setDelegate(delegate:MapDelegate)
    {
        self.mapDelegate = delegate
    }
    
    func setupCanvas()
    {
        if let _ = mapDelegate
        {
            self.bounds = mapDelegate!.mapDimensions()
            self.tileInfo = mapDelegate!.tileInfo()
            
            canvasState = .PREPARED
        }
        else
        {
            print("I don't have access to the map, and so cannot prepare the canvas")
            canvasState = .UNPREPARED
        }
    }
    
    // Atlas is currently in a running (not halted) state
    func shouldAct() -> Bool
    {
        return (runningState == .RUNNING)
    }
    
    // Atlas has access to the map
    func canAct() -> Bool
    {
        return (canvasState == .PREPARED)
    }
    
    func pause()
    {
        runningState = .HALTED
    }
    
    func resume()
    {
        runningState = .RUNNING
    }
    
    func requestAction()
    {
        if (canAct() && shouldAct())
        {
            proceedWithTask()
        }
    }
    
    func assignTask()
    {
        tasks.enqueue(Task(type:TaskType.BUNCHOFROOMS))
    }
}