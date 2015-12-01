//
//  Stack.swift
//  Atlas
//
//  Created by Dusty Artifact on 11/16/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation

class StackNode<T>
{
    var value:T
    var previous:StackNode<T>?
    
    init(value:T, previous:StackNode<T>?)
    {
        self.value = value
        self.previous = previous
    }
}

class Stack<T>
{
    var head:StackNode<T>?
    
    init()
    {
        
    }
    
    func push(value:T)
    {
        let newNode = StackNode(value:value, previous:head)
        head = newNode
    }
    
    func pop() -> T?
    {
        let value = head?.value
        head = head?.previous
        
        return value
    }
}