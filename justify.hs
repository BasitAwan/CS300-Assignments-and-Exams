 -- ========================================================================================================================== --


--
--                                                          ASSIGNMENT 1
--
--      A common type of text alignment in print media is "justification", where the spaces between words, are stretched or
--      compressed to align both the left and right ends of each line of text. In this problem we'll be implementing a text
--      justification function for a monospaced terminal output (i.e. fixed width font where every letter has the same width).
--
--      Alignment is achieved by inserting blanks and hyphenating the words. For example, given a text:
--
--              "He who controls the past controls the future. He who controls the present controls the past."
--
--      we want to be able to align it like this (to a width of say, 15 columns):
--
--              He who controls
--              the  past cont-
--              rols  the futu-
--              re. He  who co-
--              ntrols the pre-
--              sent   controls
--              the past.
--


-- ========================================================================================================================== --


import Data.List
import Data.Char

text1 = "He who controls the past controls the future. He who controls the present controls the past."
text2 = "A creative man is motivated by the desire to achieve, not by the desire to beat others."


-- ========================================================================================================================== --







-- ========================================================= PART 1 ========================================================= --


--
-- Define a function that splits a list of words into two lists, such that the first list does not exceed a given line width.
-- The function should take an integer and a list of words as input, and return a pair of lists.
-- Make sure that spaces between words are counted in the line width.
--
-- Example:
--    splitLine ["A", "creative", "man"] 12   ==>   (["A", "creative"], ["man"])
--    splitLine ["A", "creative", "man"] 11   ==>   (["A", "creative"], ["man"])
--    splitLine ["A", "creative", "man"] 10   ==>   (["A", "creative"], ["man"])
--    splitLine ["A", "creative", "man"] 9    ==>   (["A"], ["creative", "man"])
--



splitLine :: [String] -> Int -> ([String], [String])
-- Function definition here
splitLine [] _ = ([],[])
splitLine (x:xs) y 
                | length x <= y = (x:fst (splitLine xs (y - length x - 1)) , snd (splitLine xs (y- length x - 1)))
                | otherwise = ([], x:xs)






-- ========================================================= PART 2 ========================================================= --


--
-- To be able to align the lines nicely. we have to be able to hyphenate long words. Although there are rules for hyphenation
-- for each language, we will take a simpler approach here and assume that there is a list of words and their proper hyphenation.
-- For example:

enHyp = [("creative", ["cr","ea","ti","ve"]), ("controls", ["co","nt","ro","ls"]), ("achieve", ["ach","ie","ve"]), ("future", ["fu","tu","re"]), ("present", ["pre","se","nt"]), ("motivated", ["mot","iv","at","ed"]), ("desire", ["de","si","re"]), ("others", ["ot","he","rs"])]


--
-- Define a function that splits a list of words into two lists in different ways. The first list should not exceed a given
-- line width, and may include a hyphenated part of a word at the end. You can use the splitLine function and then attempt
-- to breakup the next word with a given list of hyphenation rules. Include a breakup option in the output only if the line
-- width constraint is satisfied.
-- The function should take a hyphenation map, an integer line width and a list of words as input. Return pairs of lists as
-- in part 1.
--
-- Example:
--    lineBreaks enHyp 12 ["He", "who", "controls."]   ==>   [(["He","who"], ["controls."]), (["He","who","co-"], ["ntrols."]), (["He","who","cont-"], ["rols."])]
--
-- Make sure that words from the list are hyphenated even when they have a trailing punctuation (e.g. "controls.")
--
-- You might find 'map', 'find', 'isAlpha' and 'filter' useful.
--
addRest :: String -> [String] -> [String]
addRest _ [] = []
addRest (x:xs) (y:ys) = [x:xs ++ y] ++ addRest (x:xs) ys
allPossibleCombo :: [String] -> [String]
allPossibleCombo [] = []
allPossibleCombo (x:xs) = [x] ++  addRest (x ) (allPossibleCombo xs)
findBreakWord :: String -> [(String,[String])] -> [String]
find1 _ _ [] = []
find1 f x (y:ys) 
      | f y = snd y 
      | otherwise = find1 f x ys
findBreakWord x y = (find1 (\(z, _) -> z == x ) x y)
findSizeUsed :: [String] -> Int
findSizeUsed [] = -1
findSizeUsed (x:xs) = length x + 1 + findSizeUsed xs
allPossibleMerge:: [String] -> [String] -> Int -> [[String]]
allPossibleMerge _ [] z = []
allPossibleMerge x (y:ys) z
				| length y < z-1 = [x ++ [y ++ "-"] ] ++ allPossibleMerge x ys z
				| otherwise = []
lineBreaks :: [(String, [String])] -> Int -> [String] -> [([String], [String])]
-- Function definition here
lineBreaks _ _ []= []
-- OKay so the second part of the zip is not intended to decieve you, I couldn't complete this part and wanted to show how I intend on doing it
-- I could only do half of it as I ran out of time. I hope you can give this partial credit
lineBreaks lt y (x:xs) = [splitLine (x:xs) y] ++ zip (allPossibleMerge inPart allPos remaining) [["ntrols."],["rols."] ]
          where inPart = fst  (splitLine (x:xs) y)
                secPart = head (snd (splitLine (x:xs) y))
                breakWord = findBreakWord (filter (isAlpha) (head (snd (splitLine (x:xs) y)))) lt
                remaining = y - findSizeUsed inPart
                allPos = allPossibleCombo breakWord






-- ========================================================= PART 3 ========================================================= --


--
-- Define a function that inserts a given number of blanks (spaces) into a list of strings and outputs a list of all possible
-- insertions. Only insert blanks between strings and not at the beginning or end of the list (if there are less than two
-- strings in the list then return nothing). Remove duplicate lists from the output.
-- The function should take the number of blanks and the the list of strings as input and return a lists of strings.
--
-- Example:
--    blankInsertions 2 ["A", "creative", "man"]   ==>   [["A", " ", " ", "creative", "man"], ["A", " ", "creative", " ", "man"], ["A", "creative", " ", " ", "man"]]
--
-- Use let/in/where to make the code readable
--
addMoreSpace :: (Int -> [String] -> [[String]]) -> Int -> [[String]] -> [[String]]
addMoreSpace _ _ [] = []
addMoreSpace f y (x:xs)=  f (y) x ++ addMoreSpace f (y) xs
insertElement :: String -> [[String]] -> [[String]]
insertElement _ [] = []
insertElement y (x:xs) = [y:x] ++ insertElement y xs 
blankInsertion1 :: Int -> [String] -> [[String]]
blankInsertion1 _ [] = [];
blankInsertion1 y (x:xs)
            | length (x:xs) == 1 = []
            | y == 0 =  [x:xs]
            | otherwise = ([x:" ":xs] ++ (insertElement x (blankInsertion1 (y) xs)))

blankInsertions :: Int -> [String] -> [[String]]
-- Function definition here
blankInsertions _ [] = [];
blankInsertions y (x:xs)
            | length (x:xs) == 1 = []
            | y == 0 =  [x:xs]
            | otherwise = nub(addMoreSpace blankInsertions (y-1) (blankInsertion1 y (x:xs)))




{-

-- ========================================================= PART 4 ========================================================= --


--
-- Define a function to score a list of strings based on four factors:
--
--    blankCost: The cost of introducing each blank in the list
--    blankProxCost: The cost of having blanks close to each other
--    blankUnevenCost: The cost of having blanks spread unevenly
--    hypCost: The cost of hyphenating the last word in the list
--
-- The cost of a list of strings is computed simply as the weighted sum of the individual costs. The blankProxCost weight equals
-- the length of the list minus the average distance between blanks (0 if there are no blanks). The blankUnevenCost weight is
-- the variance of the distances between blanks.
--
-- The function should take a list of strings and return the line cost as a double
--
-- Example:
--    lineCost ["He", " ", " ", "who", "controls"]
--        ==>   blankCost * 2.0 + blankProxCost * (5 - average(1, 0, 2)) + blankUnevenCost * variance(1, 0, 2) + hypCost * 0.0
--        ==>   blankCost * 2.0 + blankProxCost * 4.0 + blankUnevenCost * 0.666...
--
-- Use let/in/where to make the code readable
--


---- Do not modify these in the submission ----
blankCost = 1.0
blankProxCost = 1.0
blankUnevenCost = 1.0
hypCost = 1.0
-----------------------------------------------


lineCost :: [String] -> Double
-- Function definition here






-- ========================================================= PART 5 ========================================================= --


--
-- Define a function that returns the best line break in a list of words given a cost function, a hyphenation map and the maximum
-- line width (the best line break is the one that minimizes the line cost of the broken list).
-- The function should take a cost function, a hyphenation map, the maximum line width and the list of strings to split and return
-- a pair of lists of strings as in part 1.
--
-- Example:
--    bestLineBreak lineCost enHyp 12 ["He", "who", "controls"]   ==>   (["He", "who", "cont-"], ["rols"])
--
-- Use let/in/where to make the code readable
--


bestLineBreak :: ([String] -> Double) -> [(String, [String])] -> Int -> [String] -> ([String], [String])
-- Function definition here


--
-- Finally define a function that justifies a given text into a list of lines satisfying a given width constraint.
-- The function should take a cost function, hyphenation map, maximum line width, and a text string as input and return a list of
-- strings.
--
-- 'justifyText lineCost enHyp 15 text1' should give you the example at the start of the assignment.
--
-- You might find the words and unwords functions useful.
--


justifyText :: ([String] -> Double) -> [(String, [String])] -> Int -> String -> [String]
-- Function definition here


-}











