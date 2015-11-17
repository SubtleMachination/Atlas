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
}

enum TaskType
{
    case RANDOMNESS, SQUARE, RECTANGLE, CONNECTOBJECTS
}

struct Task
{
    let type:TaskType
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
    var tickSkip:Int = 1
    //////////////////////////////////////////////////////////////////////////////////////////
    
    var runningState:RunningState = RunningState.HALTED
    var operatingState:OperatingState = OperatingState.READY
    var canvasState:ResourceState = ResourceState.UNPREPARED
    
    var tasks:Queue<Task>
    var actions:Queue<Action>
    var currentTask:Task?
    
    init()
    {
        bounds = (width:0, height:0)
        tileInfo = (min:0, max:0, tiles:Set<Int>())
        
        tasks = Queue<Task>()
        actions = Queue<Action>()

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
        tick = (tick > 10000) ? 0 : tick
        
        if (runningState == .RUNNING)
        {
            // Perform a single action (rate-limited)
            if (tick % tickSkip == 0)
            {
                if let nextAction = actions.dequeue()
                {
                    performAction(nextAction)
                }
            }
            
            // Decide what to do next
            if (operatingState == .READY)
            {
                if (tasks.count == 0)
                {
                    // No more tasks, halt.
                    self.pause()
                }
                else
                {
                    getNextTask()
                    proceedWithTask()
                }
            }
        }
    }
    
    // Assumes that Atlas CAN and SHOULD act
    func proceedWithTask()
    {
        print("    Proceeding with Task")
        
        if (currentTask!.type == .RANDOMNESS)
        {
            operatingState = .BUSY
            
            randomAction()
            
            operatingState = .READY
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Tasks
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func getNextTask()
    {
        if (currentTask == nil)
        {
            // Get the next task
            if let nextTask = tasks.peek()
            {
                currentTask = nextTask
            }
        }
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
        
        let action = Action(x:randomX, y:randomY, val:randomValue)
        performAction(action)
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
        tasks.enqueue(Task(type:TaskType.RANDOMNESS))
    }
}