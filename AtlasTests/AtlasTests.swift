//
//  AtlasTests.swift
//  AtlasTests
//
//  Created by Dusty Artifact on 9/30/15.
//  Copyright (c) 2015 Runemark Studios. All rights reserved.
//

import XCTest
@testable import Atlas

class AtlasTests: XCTestCase
{
    let tileMapView = ACTileMapView(viewSize:CGSize(width:250.0, height:120.0), tileWidth:32, tileHeight:32)
    
    override func setUp()
    {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDTS1by1()
    {
        tileMapView.loadMap((x:1, y:1))
        let st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:0, y:0, z:0))
        XCTAssert(st.x == 0 && st.y == 0)
    }
    
    func testDTS2by1()
    {
        tileMapView.loadMap((x:2, y:1))
        var st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:0, y:0, z:0))
        XCTAssert(st.x == 0 && st.y == 1)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:1, y:0, z:0))
        XCTAssert(st.x == 1 && st.y == 0)
    }
    
    func testDTS1by2()
    {
        tileMapView.loadMap((x:1, y:2))
        var st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:0, y:0, z:0))
        XCTAssert(st.x == 0 && st.y == 0)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:0, y:1, z:0))
        XCTAssert(st.x == 1 && st.y == 1)
    }
    
    func testDTS2by2()
    {
        tileMapView.loadMap((x:2, y:2))
        var st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:0, y:0, z:0))
        XCTAssert(st.x == 0 && st.y == 1)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:1, y:0, z:0))
        XCTAssert(st.x == 1 && st.y == 0)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:0, y:1, z:0))
        XCTAssert(st.x == 1 && st.y == 2)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:1, y:1, z:0))
        XCTAssert(st.x == 2 && st.y == 1)
    }
    
    func testDTS3by1()
    {
        tileMapView.loadMap((x:3, y:1))
        var st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:0, y:0, z:0))
        XCTAssert(st.x == 0 && st.y == 2)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:1, y:0, z:0))
        XCTAssert(st.x == 1 && st.y == 1)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:2, y:0, z:0))
        XCTAssert(st.x == 2 && st.y == 0)
        
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:1, y:1, z:0))
        XCTAssert(st.x == 2 && st.y == 2)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:1, y:-1, z:0))
        XCTAssert(st.x == 0 && st.y == 0)
    }
    
    func testDTS3by2()
    {
        tileMapView.loadMap((x:3, y:2))
        var st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:0, y:0, z:0))
        XCTAssert(st.x == 0 && st.y == 2)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:1, y:0, z:0))
        XCTAssert(st.x == 1 && st.y == 1)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:2, y:0, z:0))
        XCTAssert(st.x == 2 && st.y == 0)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:0, y:1, z:0))
        XCTAssert(st.x == 1 && st.y == 3)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:1, y:1, z:0))
        XCTAssert(st.x == 2 && st.y == 2)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:2, y:1, z:0))
        XCTAssert(st.x == 3 && st.y == 1)
        
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:1, y:2, z:0))
        XCTAssert(st.x == 3 && st.y == 3)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:1, y:-1, z:0))
        XCTAssert(st.x == 0 && st.y == 0)
    }
    
    func testDTS3by3()
    {
        tileMapView.loadMap((x:3, y:3))
        var st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:0, y:0, z:0))
        XCTAssert(st.x == 0 && st.y == 2)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:1, y:0, z:0))
        XCTAssert(st.x == 1 && st.y == 1)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:2, y:0, z:0))
        XCTAssert(st.x == 2 && st.y == 0)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:0, y:1, z:0))
        XCTAssert(st.x == 1 && st.y == 3)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:1, y:1, z:0))
        XCTAssert(st.x == 2 && st.y == 2)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:2, y:1, z:0))
        XCTAssert(st.x == 3 && st.y == 1)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:0, y:2, z:0))
        XCTAssert(st.x == 2 && st.y == 4)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:1, y:2, z:0))
        XCTAssert(st.x == 3 && st.y == 3)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:2, y:2, z:0))
        XCTAssert(st.x == 4 && st.y == 2)
        
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:-1, y:1, z:0))
        XCTAssert(st.x == 0 && st.y == 4)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:1, y:-1, z:0))
        XCTAssert(st.x == 0 && st.y == 0)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:1, y:3, z:0))
        XCTAssert(st.x == 4 && st.y == 4)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:3, y:1, z:0))
        XCTAssert(st.x == 4 && st.y == 0)
    }
    
    func testSTD1by1()
    {
        tileMapView.loadMap((x:1, y:1))
        let dm = tileMapView.staggeredToDiamond(StaggeredCoord(x:0, y:0, z:0))
        XCTAssert(dm.x == 0 && dm.y == 0)
    }
    
    func testSTD2by1()
    {
        tileMapView.loadMap((x:2, y:1))
        var dm = tileMapView.staggeredToDiamond(StaggeredCoord(x:0, y:1, z:0))
        XCTAssert(dm.x == 0 && dm.y == 0)
        dm = tileMapView.staggeredToDiamond(StaggeredCoord(x:1, y:0, z:0))
        XCTAssert(dm.x == 1 && dm.y == 0)
    }
    
    func testSTD1by2()
    {
        tileMapView.loadMap((x:1, y:2))
        var dm = tileMapView.staggeredToDiamond(StaggeredCoord(x:0, y:0, z:0))
        XCTAssert(dm.x == 0 && dm.y == 0)
        dm = tileMapView.staggeredToDiamond(StaggeredCoord(x:1, y:1, z:0))
        XCTAssert(dm.x == 0 && dm.y == 1)
    }
    
    func testSTD2by2()
    {
        tileMapView.loadMap((x:2, y:2))
        var dm = tileMapView.staggeredToDiamond(StaggeredCoord(x:0, y:1, z:0))
        XCTAssert(dm.x == 0 && dm.y == 0)
        dm = tileMapView.staggeredToDiamond(StaggeredCoord(x:1, y:0, z:0))
        XCTAssert(dm.x == 1 && dm.y == 0)
        dm = tileMapView.staggeredToDiamond(StaggeredCoord(x:1, y:2, z:0))
        XCTAssert(dm.x == 0 && dm.y == 1)
        dm = tileMapView.staggeredToDiamond(StaggeredCoord(x:2, y:1, z:0))
        XCTAssert(dm.x == 1 && dm.y == 1)
    }
    
    func testDTS5by5()
    {
        tileMapView.loadMap((x:5, y:5))
        var st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:0, y:0, z:0))
        XCTAssert(st.x == 0 && st.y == 4)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:1, y:0, z:0))
        XCTAssert(st.x == 1 && st.y == 3)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:2, y:0, z:0))
        XCTAssert(st.x == 2 && st.y == 2)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:3, y:0, z:0))
        XCTAssert(st.x == 3 && st.y == 1)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:4, y:0, z:0))
        XCTAssert(st.x == 4 && st.y == 0)
        
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:0, y:1, z:0))
        XCTAssert(st.x == 1 && st.y == 5)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:1, y:1, z:0))
        XCTAssert(st.x == 2 && st.y == 4)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:2, y:1, z:0))
        XCTAssert(st.x == 3 && st.y == 3)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:3, y:1, z:0))
        XCTAssert(st.x == 4 && st.y == 2)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:4, y:1, z:0))
        XCTAssert(st.x == 5 && st.y == 1)
        
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:0, y:2, z:0))
        XCTAssert(st.x == 2 && st.y == 6)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:1, y:2, z:0))
        XCTAssert(st.x == 3 && st.y == 5)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:2, y:2, z:0))
        XCTAssert(st.x == 4 && st.y == 4)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:3, y:2, z:0))
        XCTAssert(st.x == 5 && st.y == 3)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:4, y:2, z:0))
        XCTAssert(st.x == 6 && st.y == 2)
        
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:0, y:3, z:0))
        XCTAssert(st.x == 3 && st.y == 7)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:1, y:3, z:0))
        XCTAssert(st.x == 4 && st.y == 6)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:2, y:3, z:0))
        XCTAssert(st.x == 5 && st.y == 5)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:3, y:3, z:0))
        XCTAssert(st.x == 6 && st.y == 4)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:4, y:3, z:0))
        XCTAssert(st.x == 7 && st.y == 3)
        
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:0, y:4, z:0))
        XCTAssert(st.x == 4 && st.y == 8)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:1, y:4, z:0))
        XCTAssert(st.x == 5 && st.y == 7)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:2, y:4, z:0))
        XCTAssert(st.x == 6 && st.y == 6)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:3, y:4, z:0))
        XCTAssert(st.x == 7 && st.y == 5)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:4, y:4, z:0))
        XCTAssert(st.x == 8 && st.y == 4)
        
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:-2, y:2, z:0))
        XCTAssert(st.x == 0 && st.y == 8)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:-1, y:1, z:0))
        XCTAssert(st.x == 0 && st.y == 6)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:-1, y:2, z:0))
        XCTAssert(st.x == 1 && st.y == 7)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:-1, y:3, z:0))
        XCTAssert(st.x == 2 && st.y == 8)
        
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:2, y:6, z:0))
        XCTAssert(st.x == 8 && st.y == 8)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:1, y:5, z:0))
        XCTAssert(st.x == 6 && st.y == 8)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:2, y:5, z:0))
        XCTAssert(st.x == 7 && st.y == 7)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:3, y:5, z:0))
        XCTAssert(st.x == 8 && st.y == 6)
        
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:6, y:2, z:0))
        XCTAssert(st.x == 8 && st.y == 0)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:5, y:3, z:0))
        XCTAssert(st.x == 8 && st.y == 2)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:5, y:2, z:0))
        XCTAssert(st.x == 7 && st.y == 1)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:5, y:1, z:0))
        XCTAssert(st.x == 6 && st.y == 0)
        
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:2, y:-2, z:0))
        XCTAssert(st.x == 0 && st.y == 0)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:1, y:-1, z:0))
        XCTAssert(st.x == 0 && st.y == 2)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:2, y:-1, z:0))
        XCTAssert(st.x == 1 && st.y == 1)
        st = tileMapView.diamondToStaggered(DiscreteDiamondCoord(x:3, y:-1, z:0))
        XCTAssert(st.x == 2 && st.y == 0)
    }
    
    func testSTD5by5()
    {
        tileMapView.loadMap((x:5, y:5))
        var st = tileMapView.staggeredToDiamond(StaggeredCoord(x:0, y:0, z:0))
        XCTAssert(st.x == 2 && st.y == -2)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:2, y:0, z:0))
        XCTAssert(st.x == 3 && st.y == -1)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:4, y:0, z:0))
        XCTAssert(st.x == 4 && st.y == 0)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:6, y:0, z:0))
        XCTAssert(st.x == 5 && st.y == 1)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:8, y:0, z:0))
        XCTAssert(st.x == 6 && st.y == 2)
        
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:1, y:1, z:0))
        XCTAssert(st.x == 2 && st.y == -1)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:3, y:1, z:0))
        XCTAssert(st.x == 3 && st.y == 0)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:5, y:1, z:0))
        XCTAssert(st.x == 4 && st.y == 1)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:7, y:1, z:0))
        XCTAssert(st.x == 5 && st.y == 2)
        
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:0, y:2, z:0))
        XCTAssert(st.x == 1 && st.y == -1)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:2, y:2, z:0))
        XCTAssert(st.x == 2 && st.y == 0)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:4, y:2, z:0))
        XCTAssert(st.x == 3 && st.y == 1)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:6, y:2, z:0))
        XCTAssert(st.x == 4 && st.y == 2)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:8, y:2, z:0))
        XCTAssert(st.x == 5 && st.y == 3)
        
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:1, y:3, z:0))
        XCTAssert(st.x == 1 && st.y == 0)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:3, y:3, z:0))
        XCTAssert(st.x == 2 && st.y == 1)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:5, y:3, z:0))
        XCTAssert(st.x == 3 && st.y == 2)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:7, y:3, z:0))
        XCTAssert(st.x == 4 && st.y == 3)
        
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:0, y:4, z:0))
        XCTAssert(st.x == 0 && st.y == 0)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:2, y:4, z:0))
        XCTAssert(st.x == 1 && st.y == 1)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:4, y:4, z:0))
        XCTAssert(st.x == 2 && st.y == 2)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:6, y:4, z:0))
        XCTAssert(st.x == 3 && st.y == 3)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:8, y:4, z:0))
        XCTAssert(st.x == 4 && st.y == 4)
        
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:1, y:5, z:0))
        XCTAssert(st.x == 0 && st.y == 1)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:3, y:5, z:0))
        XCTAssert(st.x == 1 && st.y == 2)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:5, y:5, z:0))
        XCTAssert(st.x == 2 && st.y == 3)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:7, y:5, z:0))
        XCTAssert(st.x == 3 && st.y == 4)
        
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:0, y:6, z:0))
        XCTAssert(st.x == -1 && st.y == 1)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:2, y:6, z:0))
        XCTAssert(st.x == 0 && st.y == 2)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:4, y:6, z:0))
        XCTAssert(st.x == 1 && st.y == 3)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:6, y:6, z:0))
        XCTAssert(st.x == 2 && st.y == 4)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:8, y:6, z:0))
        XCTAssert(st.x == 3 && st.y == 5)
        
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:1, y:7, z:0))
        XCTAssert(st.x == -1 && st.y == 2)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:3, y:7, z:0))
        XCTAssert(st.x == 0 && st.y == 3)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:5, y:7, z:0))
        XCTAssert(st.x == 1 && st.y == 4)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:7, y:7, z:0))
        XCTAssert(st.x == 2 && st.y == 5)
        
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:0, y:8, z:0))
        XCTAssert(st.x == -2 && st.y == 2)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:2, y:8, z:0))
        XCTAssert(st.x == -1 && st.y == 3)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:4, y:8, z:0))
        XCTAssert(st.x == 0 && st.y == 4)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:6, y:8, z:0))
        XCTAssert(st.x == 1 && st.y == 5)
        st = tileMapView.staggeredToDiamond(StaggeredCoord(x:8, y:8, z:0))
        XCTAssert(st.x == 2 && st.y == 6)
    }
}