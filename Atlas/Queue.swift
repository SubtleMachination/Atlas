//
//  Queue.swift
//  Atlas
//
//  Created by Dusty Artifact on 11/17/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation

class QueueNode<T>
{
    var value:T
    var previous:QueueNode<T>?
    
    init(value:T, previous:QueueNode<T>?)
    {
        self.value = value
        self.previous = previous
    }
}

class Queue<T>
{
    var next:QueueNode<T>?
    var last:QueueNode<T>?
    var count:Int
    
    init()
    {
        count = 0
    }
    
    func enqueue(val:T)
    {
        let newNode = QueueNode(value:val, previous:nil)
        
        if (count == 0)
        {
            next = newNode
        }
        else
        {
            last!.previous = newNode
        }
        
        last = newNode
        
        count++
    }
    
    func dequeue() -> T?
    {
        let nextValue = next?.value
        
        next = next?.previous
        
        count--
        
        return nextValue
    }
    
    func peek() -> T?
    {
        let nextValue = next?.value
        return nextValue
    }
}