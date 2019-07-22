//
//  inWalkDijkstra.m
//  dijkstra
//
//  Created by Dmitri Kozlov on 19/02/13.
//  Copyright (c) 2013 Dmitri Kozlov. All rights reserved.
//
//  This is a port of Dijkstra algorithm implemented in Python.
//  The Python implementation was suggested by David Eppstein.
//  http://code.activestate.com/recipes/119466-dijkstras-algorithm-for-shortest-paths/?in=user-218935
//

#import "InWalkDijkstra.h"
#import "InWalkPriorityDictionary.h"

@implementation InWalkDijkstraSolution : NSObject

@end

//
// Find shortest paths from the start vertex to all
// vertices nearer than or equal to the end.
//
InWalkDijkstraSolution *inWalkDijkstra(NSDictionary *graph, id start, id end)
{
    
    NSMutableDictionary *dist = [NSMutableDictionary dictionary];	// dictionary of final distances
    NSMutableDictionary *pred = [NSMutableDictionary dictionary];	// dictionary of predecessors
    InWalkPriorityDictionary *prio = [InWalkPriorityDictionary dictionaryAscending:NO];// estimated dist. of non-final vert.
    InWalkDijkstraSolution *res = [InWalkDijkstraSolution new];
    
    prio[start] = @0;
    
    for (id vtx1 = [prio top]; vtx1; vtx1 = [prio top])
    {
        dist[vtx1] = prio[vtx1];
        [prio pop];
        
        if ([vtx1 isEqual:end])
            break;
        
        NSDictionary *neighbours = graph[vtx1];
        for (id vtx2 in neighbours)
        {
            NSInteger vwLength = [dist[vtx1] integerValue] + [neighbours[vtx2] integerValue];
            
            if (dist[vtx2] != nil)
            {
                if (vwLength < [dist[vtx2] integerValue])
                {
                    //NSLog(@"Dijkstra: found better path to already-final vertex");
                    return res;
                }
            }
            else if (prio[vtx2] == nil || vwLength < [prio[vtx2] integerValue])
            {
                prio[vtx2] = [NSNumber numberWithInteger:vwLength];
                pred[vtx2] = vtx1;
            }
        }
    }
    
    res.distances = dist;
    res.predecessors = pred;
    return res;
}

// Find a single shortest path from the given start vertex
// to the given end vertex.
// The input has the same conventions as Dijkstra().
// The output is a list of the vertices in order along
// the shortest path.
NSArray *InWalkShortestPath(NSDictionary *graph, id start, id end)
{
    NSMutableArray *path = [NSMutableArray array];
    InWalkDijkstraSolution *solution = inWalkDijkstra(graph, start, end);
    id e = end;
    while (e) {
        [path addObject:e];
        if ([e isEqual:start])
            break;
        e = solution.predecessors[e];
    }
    
    NSUInteger l = [path count] - 1;
    for (int i = 0; i < l-i; ++i)
        [path exchangeObjectAtIndex:i withObjectAtIndex:l-i];

    return path.count > 0 ? path : nil;
}

