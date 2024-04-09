
"""
1. Procedure Merge(s=t)
2. If s and t are constants a and b Then {
3. add a=b to Pending
4. Propagate() }
5. Else /* s=t is of the form f (a1, a2)=a */
6. If Lookup(a′1, a′2) is some f (b1, b2)=b Then {
7. add ( f (a1, a2)=a, f (b1, b2)=b ) to Pending
8. Propagate() }
9. Else {
10. set Lookup(a′1, a′2) to f (a1, a2)=a
11. add f (a1, a2)=a to UseList(a′1) and to UseList(a′2) }
"""

"""
12. Procedure Propagate()
13. While Pending is non-empty Do {
14. Remove E of the form a=b or (f (a1, a2)=a, f (b1, b2)=b) from Pending
15. If a′  = b′ and, wlog., |ClassList (a′)| ≤ |ClassList (b′)| Then {
16. old repr a := a′
17. Insert edge a → b labelled with E into the proof forest
18. For each c in ClassList (old repr a) Do {
19. set Representative(c) to b′
20. move c from ClassList (old repr a) to ClassList (b′) }
21. For each f (c1, c2)=c in UseList(old repr a) Do
22. If Lookup(c′1, c′2) is some f (d1, d2)=d Then {
23. add (f (c1, c2)=c, f (d1, d2)=d) to Pending
24. remove f (c1, c2)=c from UseList(old repr a) }
25. Else {
26. set Lookup(c′1, c′2) to f (c1, c2)=c
27. move f (c1, c2)=c from UseList(old repr a) to UseList(b′) }}}
"""

"""
8. Procedure ExplainAlongPath(a,c)
9. a := HighestNode(a)
10. While a /= c Do {
11. b := parent(a)
12. If edge a → b is labelled with a single input merge a=b
13. Output a=b
14. Else { /* edge labelled with f (a1, a2)=a and f (b1, b2)=b */
15. Output f (a1, a2)=a and f (b1, b2)=b
16. Add a1=b1 and a2=b2 to PendingProofs }
17. Union(a, b)
18. a := HighestNode(b) }
"""
function parents(a::Id)
    return g.getindex(current_node).parents
end

function ExplainAlongPath(a::Id,b::Id,g::EGraph, PendingProofs!::Vector{Tuple{Id, Id}}) 
    let c = find(g,a) # find(g,a) should get us to the top level of the UnionFind in g for id a
        while (a /= c)
            let d = parents(a) # ??? parent wrt e-graph? what does that mean...
                # If edge is labelled 
                #   "Output" (a,b)?? (return?)
                # Else return some label equality thing ??
                #   "Output" (f(a1,a2),a) (f(b1,b2),b)?? (return?)
                #   Add (a1,b1) (a2,b2) to pending proofs
                # Union(a,b)??
                # a := HighestNode(b)
                # end
            end
        end
    end
end


function NearestCommonAncestor(a::Id, b::Id, g::EGraph)::Union{Id,Nothing}#What should this return? Id? Yes
    function ancestors(node, visited)
        ancestor_set = Set{Id}()
        stack = [node]
        
        while !isempty(stack)
            current_node = pop!(stack)
            if current_node in visited # Handle cycles
                continue
            end
            push!(visited, current_node)
            push!(ancestor_set, current_node)
            parents = parents(current_node)
            for parent in parents
                push!(stack, parent)
            end
        end
        return ancestor_set
    end
    

    # Get ancestors of both nodes
    visited = Set{Id}()
    ancestors1 = ancestors(a, visited)
    visited = Set{Id}()
    ancestors2 = ancestors(b, visited)
    
    # Find nearest common ancestor
    common_ancestors = intersect(ancestors1, ancestors2)
    return isempty(common_ancestors) ? noting : first(common_ancestors)
end

"""
Procedure Explain(c1, c2)
2. Set PendingProofs to {c1=c2}
3. While PendingProofs is not empty Do {
4. Remove an equation a=b from PendingProofs
5. c := NearestCommonAncestor(a,b)
6. ExplainAlongPath(a,c)
7. ExplainAlongPath(b,c) }
"""

function Explain(c1::Id, c2::Id, g::EGraph)
    let PendingProofs = [(c1, c2)]
        while (~isempty(PendingProofs))
            let ab = pop!(PendingProofs)
                    let c = NearestCommonAncestor(ab[1],ab[2],g)
                        ExplainAlongPath(ab[1],c,g,PendingProofs) # Not sure where this is meant to go
                        ExplainAlongPath(ab[2],c,g,PendingProofs) # Same as above
                end
            end
        end
    end
end

