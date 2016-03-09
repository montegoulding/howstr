script "displayerang2"
function writeInstructionsHTML @pMain,@pShort,pTopo,pNoVisit
   -- writes instructions directly in html
   -- ! assumes only one doc (doc 1) and only one scope level as of 14FEB2016
   put empty into tInstructions
   -- ! pTopo has case node listed first and last, which is redundant as long as we're only allowing one scope level 15FEB2016
   -- pTopo controls in what order the steps appear
   -- tDetailOrder controls in what order each piece of information (tag) appears in each step
   --   put "stepString anchor cr memo cr figure cr prev cr next" into tDetailOrder
   put "cr weight stepString anchor cr memo cr figure" into tDetailOrder -- don't need next/prev for action table
   put pMain[1][0]["filepath"] into tPath -- absolute path to *.how file
   set the itemdelimiter to slash
   put "resources.html" into item -1 of tPath -- now absolute path to resources file adjacent to *.how file
   put "<html>" & cr after tInstructions
   -- header kind of thing ----------------------------------------
   set the itemdelimiter to comma
   put item 1 of pTopo[1] into tCase
   put pShort[1][tCase]["title"] into tCaseTitle
   put "<head>" & cr & "<title>" after tInstructions
   if tCaseTitle is not empy then 
      --      put "<p><b>" & tCaseTitle & "</b></p>" & cr after tInstructions
      put tCaseTitle after tInstructions
   else
      --      put "<p><b>Untitled</b></p>" & cr after tInstructions
      put "Untitled" into tCaseTitle
      put tCasteTitle after tInstructions
   end if
   put "</title>" & cr & "</head>" & cr & "<body>" & cr after tInstructions
   put "<p><b>" & tCaseTitle & "</b></p>" & cr after tInstructions
   set the wholematches to true
   delete item (itemoffset(tCase,pTopo[1])) of pTopo[1]
   delete item (itemoffset(tCase,pTopo[1])) of pTopo[1] -- get rid of case node at start and end of list, at least for now 15FEB2016
   put "<p><b>Sorted steps (Instructions) as of" && the system date && the system time & "</b></p>" & cr after tInstructions
   put "<p><a href=" & quote & tPath & quote & ">Resources</a></p>" & cr after tInstructions
   -- list of only the change steps (define action groups)
   put empty into pTopoChanges
   repeat for each item tBlerg in pTopo[1]
      if pShort[1][tBlerg]["type"] is "change" then put tBlerg into item (the number of items of pTopoChanges)+1 of pTopoChanges
   end repeat
   -- start action table
   -- column header list
   -- column input states
   -- column change
   -- column output states
   -- end action table
   put 0 into tCount
   put empty into tTopoVisited
   repeat for each item tRec in pTopoChanges
      put tCount + 1 into tCount
      put empty into tStuff
      put "<p><b>Action" && tCount & ") </b>" & cr after tInstructions -- once to start the step
      put "<table border=" & quote & "1" & quote & ">" & cr after tInstructions
      put "<tr><th>In State(s)</th><th>Change</th><th>Out State(s)</th></tr>" & cr after tInstructions
      -- build a string to expand on
      put empty into tTable
      set itemdelimiter to comma
      put "rStart" into item 1 of tTable
      -- prev
      put "cStart" into item (the number of items of tTable)+1 of tTable
      repeat for each line tLine in pShort[1][tRec]["prev"]
         --         put pShort[1][tLine]["prev"] into item (the number of items of tTable)+1 of tTable
         put pShort[1][tLine]["prev"] into tNode
         put pShort[1][tLine]["weight"] into tWeight
         if tWeight is empty then put 1 into tWeight
         put tNode & "/" & tWeight into item (the number of items of tTable)+1 of tTable
      end repeat
      put "cEnd" into item (the number of items of tTable)+1 of tTable
      -- change
      put "cStart" into item (the number of items of tTable)+1 of tTable
      put tRec into item (the number of items of tTable)+1 of tTable
      put "cEnd" into item (the number of items of tTable)+1 of tTable
      -- next
      put "cStart" into item (the number of items of tTable)+1 of tTable
      repeat for each line tLine in pShort[1][tRec]["next"]
         --         put pShort[1][tLine]["next"] into item (the number of items of tTable)+1 of tTable
         put pShort[1][tLine]["next"] into tNode
         put pShort[1][tLine]["weight"] into tWeight
         if tWeight is empty then put 1 into tWeight
         put tNode & "/" & tWeight into item (the number of items of tTable)+1 of tTable
      end repeat
      put "cEnd" into item (the number of items of tTable)+1 of tTable
      put "rEnd" into item (the number of items of tTable)+1 of tTable
      
      -- step kind of things -------------------------------------------------
      repeat for each item tPiece in tTable
         switch 
            case tPiece is "rStart" -- start row
               put "<tr>" after tInstructions
               break
            case tPiece is "rEnd" -- end row
               put "</tr>" & cr after tInstructions
               break
            case tPiece is "cStart" -- start column
               put "<td valign=" & quote & "top" & quote & ">" after tInstructions
               break
            case tPiece is "cEnd" -- end column
               put "</td>" & cr after tInstructions
               break
            default 
               set the itemdelimiter to "/"
               put item 1 of tPiece into tNode
               put item 2 of tPiece into tWeight
               set the itemdelimiter to comma
               
               if tNode is among the items of tTopoVisited then -- only state recs end up in visited list, but it's okay cuz changes only appear once
                  -- just reference the previous step details
                  put pShort[1][tPrev]["prev"] into tPrev
                  put 1 into tStuff["doc"]
                  put tNode into tStuff["rec"]
                  put stepString(pMain,tStuff) into field "testHtml" stack "HowstrBeta"
                  put the htmltext of field "testHtml" stack "HowstrBeta" into tUgly
                  replace "<p>" with "" in tUgly
                  replace "</p>" with "" in tUgly
                  if tNode is tRec then -- this one is a change, so weight isn't applicable
                     put "<a href=" & quote & "#" & tNode & quote & ">" & tUgly & "</a>" after tInstructions
                  else
                     put "<a href=" & quote & "#" & tNode & quote & ">" & "(" & tWeight & "x) " & tUgly & "</a>" after tInstructions
                  end if
               else
                  put tNode into item (the number of items of tTopoVisited)+1 of tTopoVisited
                  -- since tNode hasn't been visited yet, write out all the details
                  repeat for each word tAdetail in tDetailOrder
                     switch tAdetail
                        case "weight"
                           if tNode is not tRec then put "(" & tWeight & "x) " after tInstructions
                           break
                        case "stepString"
                           put 1 into tStuff["doc"]
                           put tNode into tStuff["rec"]
                           put stepString(pMain,tStuff) into field "testHtml" stack "HowstrBeta"
                           put the htmltext of field "testHtml" stack "HowstrBeta" into tUgly
                           replace "<p>" with "<b>" in tUgly
                           replace "</p>" with "</b>" in tUgly
                           put tUgly after tInstructions
                           break
                        case "anchor"
                           put "<a name=" & quote & tNode & quote & "></a>" after tInstructions
                           break
                        case "cr"
                           put "<p></p>" & cr after tInstructions
                           break
                        case "memo"
                           put pShort[1][tNode]["memo"] into tMemo
                           if tMemo is not empty then put tMemo after tInstructions
                           break
                        case "figure"
                           put pShort[1][tNode]["figure"] into tFigure
                           if tFigure is not empty then 
                              set the itemdelimiter to slash
                              put item -1 of tFigure into tFigure
                              put "<a href=" & quote & tFigure & quote && "target=" & quote & "_blank" & quote & ">" after tInstructions
                              put "<img src=" & quote & tFigure & quote && "width=" & quote & "200" & quote & ">" after tInstructions
                              put "</a>" after tInstructions
                              set the itemdelimiter to comma
                           end if
                           break
                        case "prev"
                           put pShort[1][tNode]["prev"] into tList
                           if tList is not empty then
                              put "Previous step(s): " after tInstructions
                              repeat for each line tPrev in tList
                                 put pShort[1][tPrev]["prev"] into tPrev
                                 put 1 into tStuff["doc"]
                                 put tPrev into tStuff["rec"]
                                 put stepString(pMain,tStuff) into field "testHtml" stack "HowstrBeta"
                                 put the htmltext of field "testHtml" stack "HowstrBeta" into tUgly
                                 replace "<p>" with "" in tUgly
                                 replace "</p>" with "" in tUgly
                                 put "<a href=" & quote & "#" & tPrev & quote & ">" & tUgly & "</a>" after tInstructions
                              end repeat
                           end if
                           break
                        case "next"
                           put pShort[1][tNode]["next"] into tList
                           if tList is not empty then
                              put "Next step(s): " after tInstructions
                              repeat for each line tNext in tList
                                 put pShort[1][tNext]["next"] into tNext
                                 put 1 into tStuff["doc"]
                                 put tNext into tStuff["rec"]
                                 put stepString(pMain,tStuff) into field "testHtml" stack "HowstrBeta"
                                 put the htmltext of field "testHtml" stack "HowstrBeta" into tUgly
                                 replace "<p>" with "" in tUgly
                                 replace "</p>" with "" in tUgly
                                 put "<a href=" & quote & "#" & tNext & quote & ">" & tUgly && "</a>" after tInstructions
                              end repeat
                           end if
                           break
                     end switch -- what to do given tAdetail
                  end repeat -- word in tDetailOrder
               end if -- tNode is among tTopoVisited
         end switch -- what to do given tPiece
      end repeat -- item tPiece in tTable
      put "</table>" & cr after tInstructions
   end repeat -- item tRec in tTopoChanges
   put "</body>" & cr & "</html>" & cr after tInstructions
   return tInstructions
end writeInstructionsHTML

function summarizeResourcesHTML @pMain,@pShort,@pSketch,@pResources,pDoc
   -- ! assumes one doc (doc[1]) and one scope level as of 15FEB2016
   put "in thru out" into tPutOrder
   put "amount stepString anchor cr memo cr figure cr prev cr next" into tDetailOrder
   put empty into tResources
   put pMain[1][0]["filepath"] into tPath
   set the itemdelimiter to slash
   put "instructions.html" into item -1 of tPath
   -- header kind of thing ----------------------------------------
   set the itemdelimiter to comma
   put item 1 of pSketch[1][0]["top"] into tCase
   put "<head>" & cr & "<title>" after tResources
   put pShort[1][tCase]["title"] into tCaseTitle
   if tCaseTitle is not empy then 
      --      put "<p><b>" & tCaseTitle & "</b></p>" & cr after tResources
      put tCaseTitle after tResources
   else
      --      put "<p><b>Untitled</b></p>" & cr after tResources
      put "Untitled" into tCaseTitle
      put tCasteTitle after tResources
   end if
   put "</title>" & cr & "</head>" & cr & "<body>" & cr after tResources
   put "<p><b>" & tCaseTitle & "</b></p>" & cr after tResources
   put "<p><b>Supply and demand (bill of materials) as of" && the system date && the system time & "</b></p>" & cr after tResources
   put "<p><a href=" & quote & tPath & quote & ">Instructions</a></p>" & cr after tResources
   -- table of contents kind of thing ---------------------------------
   put "<p><a href=" & quote & "#in" & quote & ">Input</a></p>" & cr after tResources
   put "<p><a href=" & quote & "#thru" & quote & ">Thruput</a></p>" & cr after tResources
   put "<p><a href=" & quote & "#out" & quote & ">Output</a></p>" & cr after tResources
   -- in/thru/out-put kind of things ------------------------------------
   repeat for each word tPut in tPutOrder
      switch tPut
         case "in"
            put "<p><b>Required at start:</b><a name=" & quote & "in" & quote & "></a></p>" & cr after tResources
            break
         case "thru"
            put "<p><b>Excess during:</b><a name=" & quote & "thru" & quote & "></a></p>" & cr after tResources
            break
         case "out"
            put "<p><b>Result at end:</b><a name=" & quote & "out" & quote & "></a></p>" & cr after tResources
            break
      end switch
      set the itemdelimiter to comma
      repeat for each item tRec in pSketch[1][2][tPut]
         if tPut is "thru" and (pResources[1][tRec]["excess"] is empty) then next repeat
         repeat for each word tAdetail in tDetailOrder
            switch tAdetail
               case "amount"
                  if tPut is "in" then put "<p><b>" & pResources[1][tRec]["totDemand"] && "x</b>  " after tResources
                  if tPut is "thru" then put "<p><b>" & pResources[1][tRec]["excess"] && "x</b>  " after tResources
                  if tPut is "out" then put "<p><b>" & pResources[1][tRec]["totSupply"] && "x</b>  " after tResources
                  break
               case "stepString"
                  put 1 into tStuff["doc"]
                  put tRec into tStuff["rec"]
                  put stepString(pMain,tStuff) into field "testHtml" stack "HowstrBeta"
                  put the htmltext of field "testHtml" stack "HowstrBeta" into tUgly
                  replace "<p>" with "<b>" in tUgly
                  replace "</p>" with "</b>" in tUgly
                  put tUgly after tResources
                  break
               case "anchor"
                  put "<a name=" & quote & tRec & quote & "></a>" after tResources
                  break
               case "cr"
                  put "<p></p>" & cr after tResources
                  break
               case "memo"
                  put pShort[1][tRec]["memo"] into tMemo
                  if tMemo is not empty then put tMemo after tResources
                  break
               case "figure"
                  put pShort[1][tRec]["figure"] into tFigure
                  if tFigure is not empty then 
                     set the itemdelimiter to slash
                     put item -1 of tFigure into tFigure
                     --                     put "<img src=" & quote & tFigure & quote & ">" after tResources
                     put "<a href=" & quote & tFigure & quote && "target=" & quote & "_blank" & quote & ">" after tResources
                     put "<img src=" & quote & tFigure & quote && "width=" & quote & "200" & quote & ">" after tResources
                     put "</a>" after tResources
                     set the itemdelimiter to comma
                  end if
                  break
            end switch
         end repeat -- word in tDetailOrder
      end repeat -- tRec in tPut
   end repeat -- tPut in tPutOrder
   return tResources
end summarizeResourcesHTML

on resizeMainStack pNewWidth, pNewHeight, pOldWidth, pOldHeight
   put "on resizeStack" into xX["write"];    devLog xX
   if the rect of this stack is the screenRect then
      set the visible of widget "iconMaximize" stack "HowstrBeta" to false
      set the visible of widget "iconMediumsize" stack "HowstrBeta" to true
   else
      set the visible of widget "iconMaximize" stack "HowstrBeta" to true
      set the visible of widget "iconMediumsize" stack "HowstrBeta" to false
   end if
   -- all of the layer information for all of the graph data in memory is calculated by middleOut
   -- so when the window resizes, displayManager updates the graphics based on what fits now
   refreshDisplay
end resizeMainStack
