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
    case READY, BUSY, DONE
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
    case RANDOMNESS, BUNCHOFROOMS, ROOM, CONNECTROOMS, PLACEWALLS
}

class Task
{
    let type:TaskType
    var subtasks:[Task]
    var completed:Bool
    var supertask:Task?
    var conceptualRef:Region?
    
    init(type:TaskType)
    {
        self.type = type
        self.subtasks = [Task]()
        self.completed = false
    }
}

struct Region
{
    var center:(x:Int, y:Int)
    var size:(xRad:Int, yRad:Int)
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
    var actionRateLimit:Int = 4
    var thoughRateLimit:Int = 2
    //////////////////////////////////////////////////////////////////////////////////////////
    
    var runningState:RunningState = RunningState.HALTED
    var operatingState:OperatingState = OperatingState.READY
    var canvasState:ResourceState = ResourceState.UNPREPARED
    
    var tasks:Queue<Task>
    var actions:Queue<Action>
    
    var actionThreshold:Int
    var currentTask:Task?
    
    var conceptualBlobs:[Region]
    
    init()
    {
        bounds = (width:0, height:0)
        tileInfo = (min:0, max:0, tiles:Set<Int>())
        
        tasks = Queue<Task>()
        actions = Queue<Action>()
        
        conceptualBlobs = [Region]()
        
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
//                                print("JOB DONE! CURRENT TASK IS NULL")
//                                operatingState == .DONE
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
                        // No more tasks
                        print("JOB DONE! NO MORE TASK")
                        operatingState == .DONE
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
            let roomTask = Task(type:TaskType.ROOM)
            roomTask.supertask = currentTask
            
            createRandomRectRefs()
            
            for conceptRegion in conceptualBlobs
            {
                let roomTask = Task(type:TaskType.ROOM)
                roomTask.supertask = currentTask
                roomTask.conceptualRef = conceptRegion

                currentTask!.subtasks.append(roomTask)
            }
            
            let connectionTask = Task(type:TaskType.CONNECTROOMS)
            connectionTask.supertask = currentTask
            currentTask!.subtasks.append(connectionTask)
            
            let wallsTask = Task(type:TaskType.PLACEWALLS)
            wallsTask.supertask = currentTask
            currentTask!.subtasks.append(wallsTask)
        }
        else if (currentTask!.type == .ROOM)
        {
            createRoom()
            currentTask!.completed = true
        }
        else if (currentTask!.type == .CONNECTROOMS)
        {
            connectAllRooms()
            currentTask!.completed = true
        }
        else if (currentTask!.type == .PLACEWALLS)
        {
            placeWalls()
            currentTask!.completed = true
        }
        
        operatingState = .READY
    }
    
    func placeWalls()
    {
        print("PLACING WALLS")
        
//        let region1 = conceptualBlobs[0]
//        var corner1 = (x:region1.center.x - region1.size.xRad, y:region1.center.y + region1.size.yRad)
        
        for _ in 0..<10
        {
//            if let value mapDelegate!.valueAt(corner1.x, y:corner1.y+1)
//            {
//                
//            }
        }
    }
    
    func connectAllRooms()
    {
        print("CONNECTING ROOMS")
        // Connect the first two regions
        let region1 = conceptualBlobs[0]
        let region2 = conceptualBlobs[1]
        let region3 = conceptualBlobs[2]
        
        connectRooms(region1, b:region2)
        connectRooms(region2, b:region3)
        connectRooms(region3, b:region1)
    }
    
    func connectRooms(a:Region, b:Region)
    {
        if (a.center.y != b.center.y)
        {
            if (a.center.y < b.center.y)
            {
                for y in a.center.y...b.center.y
                {
                    let action = Action(x:a.center.x, y:y, val:1, relatedTask:currentTask!)
                    actions.enqueue(action)
                }
            }
            else
            {
                for y in b.center.y...a.center.y
                {
                    let action = Action(x:a.center.x, y:y, val:1, relatedTask:currentTask!)
                    actions.enqueue(action)
                }
            }
        }
        
        if (a.center.x != b.center.x)
        {
            if (a.center.x < b.center.x)
            {
                for x in a.center.x...b.center.x
                {
                    let action = Action(x:x, y:b.center.y, val:1, relatedTask:currentTask!)
                    actions.enqueue(action)
                }
            }
            else
            {
                for x in b.center.x...a.center.x
                {
                    let action = Action(x:x, y:b.center.y, val:1, relatedTask:currentTask!)
                    actions.enqueue(action)
                }
            }
            
        }
    }
    
    func createRoom()
    {
        let region = currentTask!.conceptualRef!
        print("createRoom:\(region), vol:\((region.size.xRad)*2+1)*\(region.size.yRad*2+1)")
        
        for x in region.center.x-region.size.xRad...region.center.x+region.size.xRad
        {
            for y in region.center.y-region.size.yRad...region.center.y+region.size.yRad
            {
                let action = Action(x:x, y:y, val:1, relatedTask:currentTask!)
                actions.enqueue(action)
            }
        }
    }
    
    func createRandomRectRefs()
    {
//        let roomCount = randIntBetween(3, stop:4)
//        print(roomCount)
        let roomCount = 3
        
        for _ in 0..<roomCount
        {
            let conceptualRegion = Region(center:(x:0, y:0), size:(xRad:0, yRad:0))
            conceptualBlobs.append(conceptualRegion)
        }
        
        var goodCriteriaFound = false
        while (!goodCriteriaFound)
        {
            for blobIndex in 0..<roomCount
            {
                let randomXRadius = randIntBetween(1, stop:3)
                let randomYRadius = randIntBetween(1, stop:3)
                let randomCenterX = randIntBetween(2+randomXRadius, stop:bounds.width-1-randomXRadius)
                let randomCenterY = randIntBetween(2+randomYRadius, stop:bounds.height-1-randomYRadius)
                
                conceptualBlobs[blobIndex].center = (x:randomCenterX, y:randomCenterY)
                conceptualBlobs[blobIndex].size = (xRad:randomXRadius, yRad:randomYRadius)
            }
            
            var goodCriteria = true
            // Evaluate our blobs for goodness
            for blobIndex in 0..<conceptualBlobs.count
            {
                for comparableBlobIndex in 0..<conceptualBlobs.count
                {
                    if (blobIndex != comparableBlobIndex)
                    {
                        let blobA = conceptualBlobs[blobIndex]
                        let blobB = conceptualBlobs[comparableBlobIndex]
                        
                        let blobAModified = Region(center:blobA.center, size:(xRad:blobA.size.xRad+1, yRad:blobA.size.yRad+1))
                        let blobBModified = Region(center:blobB.center, size:(xRad:blobB.size.xRad+1, yRad:blobB.size.yRad+1))
                        
                        if (regionsIntersect(blobAModified, regionB:blobBModified))
                        {
                            goodCriteria = false
                            break
                        }
                    }
                }
                
                if (!goodCriteria)
                {
                    break
                }
            }
            
            if (goodCriteria)
            {
                goodCriteriaFound = true
            }
        }
    }
    
    func regionsIntersect(regionA:Region, regionB:Region) -> Bool
    {
        let rightA = regionA.center.x + regionA.size.xRad
        let leftA = regionA.center.x - regionA.size.xRad
        let topA = regionA.center.y + regionA.size.yRad
        let bottomA = regionA.center.y - regionA.size.yRad
        
        let rightB = regionB.center.x + regionB.size.xRad
        let leftB = regionB.center.x - regionB.size.xRad
        let topB = regionB.center.y + regionB.size.yRad
        let bottomB = regionB.center.y - regionB.size.yRad
        
        let a_h = atLeastOneOverlap(leftA, a2:rightA, b1:leftB, b2:rightB)
        let a_v = atLeastOneOverlap(bottomA, a2:topA, b1:bottomB, b2:topB)
        let b_h = atLeastOneOverlap(leftB, a2:rightB, b1:leftA, b2:rightA)
        let b_v = atLeastOneOverlap(bottomB, a2:topB, b1:bottomA, b2:topA)
        
        return (a_h && a_v) || (b_h && b_v) || (a_h && b_v) || (a_v && b_h)
    }
    
    func atLeastOneOverlap(a1:Int, a2:Int, b1:Int, b2:Int) -> Bool
    {
        return (a1 >= b1 && a1 <= b2) || (a2 >= b1 && a2 <= b2)
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