-- Description: Silly questions not answered in 60m --


-- Problem 1
--
-- Write three functions that compute the sum of the numbers in a given list 
-- using a for-loop, a while-loop, and recursion.
local function p1_sum_table_for(t)
    local sum = 0
    for i=1, #t do
        sum = sum + t[i]
    end
    return sum
end

local function p1_sum_table_while(t)
    local sum = 0
    local i = 1
    while i <= #t do
        sum = sum + t[i]
        i = i + 1
    end
    return sum        
end

local function p1_sum_table_recursive(t)
    if not v then v = 0 end   
    if t[1] == nil then return 0 end
    
    local temp = t[#t]
    t[#t] = nil -- trim (because we don't have slice)
    return temp + p1_sum_table_recursive(t)    
end

print(p1_sum_table_for({}))
print(p1_sum_table_for({1,2,3,4}))

print(p1_sum_table_while({}))
print(p1_sum_table_while({1,2,3,4}))

print(p1_sum_table_recursive({}))
print(p1_sum_table_recursive({1,2,3,4}))


-- Problem 2
--
-- Write a function that combines two lists by alternatingly taking elements. 
-- For example: given the two lists [a, b, c] and [1, 2, 3], the function 
-- should return [a, 1, b, 2, c, 3].

local function p2_interleave(t1, t2)
    if #t1 ~= #t2 then
        error('Both tables must be same length')
    end
    
    local t3 = {}
    
    for i=1, #t1 do
        table.insert(t3, t1[i])
        table.insert(t3, t2[i])
    end
    
    return t3
end


print(table.concat(p2_interleave({}, {})))
print(table.concat(p2_interleave({'a', 'b', 'c'}, {1, 2, 3})))


-- Problem 3
--
-- Write a function that computes the list of the first 100 Fibonacci numbers. 
-- By definition, the first two numbers in the Fibonacci sequence are 0 and 1, 
-- and each subsequent number is the sum of the previous two. As an example, 
-- here are the first 10 Fibonnaci numbers: 0, 1, 1, 2, 3, 5, 8, 13, 21, and 
-- 34.

local function p3_fib(n)
    if n == 1 then 
        return 0
    elseif n == 2 then 
        return 1
    else 
        return p3_fib(n-2) + p3_fib(n-1) 
    end
end

-- Oh yes, this is wrong hey.  
-- Just parroting the standard fib(n) = fib(n-2) + fib(n-1) function
local function p3_fib_table(n)
    local fibs = {}
    for i=1, n do
        table.insert(fibs, p3_fib(i))
    end
    return fibs
end

-- print(table.concat(p3_fib_table(100), ', '))

local function p3_fib_table_real_ex(n)
    local fibs = {0, 1, 1}
    for i=4, n do
        fibs[i] = fibs[i-1] + fibs[i-2]
    end
    return fibs
end

-- let's ignore how lua numbers work and just pretend I'm running arbitary prec?
-- 
-- def p3(n):
--     fibs = [0, 1, 1]
--     for i in range(4, 100): # off by one I'm sure (or 4 maybe)
--         fibs.append(fibs[i-2] + fibs[i-1])
--     return fibs
--
-- Python auto big-num promotion is cheating?
print(table.concat(p3_fib_table_real_ex(100), ', '))




-- Problem 4
--
-- Write a function that given a list of non negative integers, arranges them 
-- such that they form the largest possible number. For example, 
-- given [50, 2, 1, 9], the largest formed number is 95021.

local function p4_sort_nums(t)
    -- I want to just cast to string() and get the first character 
    -- but that's awful... But I'm too dumb
    
    table.sort(t, function(a, b)
        local s1 = tostring(a):sub(1, 1)
        local s2 = tostring(b):sub(1, 1)
        return tonumber(s1) > tonumber(s2)
    end)
    
    -- Well I just fail this...
    return tonumber(table.concat(t, ''))    
end


print(p4_sort_nums({50, 2, 1, 9}))

-- wrong, we need to check all places
print(p4_sort_nums({56, 50, 57, 0}))
print(p4_sort_nums({150, 161, 151, 160}))


-- For  N <= 5 just do permutations I guess...



-- Problem 5
--
-- Write a program that outputs all possibilities to put + or - or nothing 
-- between the numbers 1, 2, ..., 9 (in this order) such that the result is 
-- always 100. For example: 1 + 2 + 34 – 5 + 67 – 8 + 9 = 100.
--
-- Checking all the permutations of [1,9] and [-,+,] doesn't sound interesting.
-- Guess you just do it via recursion?
-- 
--
-- Whelp,
-- 30 minutes in and it's stopped being fun (and I've real work to do)
--
--
-- Followup:
--
-- "I never said that you'll be hired if you know how to answer these 
--  problems, but I won't consider you if you can't."  -- Author
--
-- So I would never be hired by the author of the blog post
--
-- But the author then posted an incorrect answer to question 4 (with no
-- time limit imposed).  So I guess that he's going to update his resume
-- and find a new job?
-- 
-- https://blog.svpino.com/2015/05/08/solution-to-problem-4
--
-- "...you need to stop calling yourself a "Software Engineer" (or 
--  Programmer, or Computer Science specialist, or even maybe "Developer".) 
--  Stop lying to yourself, and take some time to re-focus your priorities."



local function take(t)
    local top = t[1]
    local rest = {}
    for i=2, #t do
        table.insert(rest, t[i])
    end
    return top, rest
end

local function copyt(t)
    local new_t = {}
    for k,v in pairs(t) do
        new_t[k] = v
    end
    return new_t
end

local function q5_create_permutations(values)
    local permutations = {}

    local function q5(t, path)
        local top, rest = take(t)
        table.insert(path, top)

        if #rest == 0 then
            table.insert(permutations, path)
            return 
        end
        
        for _,op in ipairs({'+', '-', '.'}) do
            local new_path = copyt(path)
            table.insert(new_path, op)
            q5(rest, new_path)
        end
    end
    
    q5(values, {})
    return permutations
end

local function q5_doesnt_work()
    local permutations = q5_create_permutations({1, 2, 3, 4, 5, 6, 7, 8, 9})

    for i,path in ipairs(permutations) do

        local value = 1
        
        for i=2, #path, 2 do
            local op = path[i]
            local operand = path[i+1]
            
            if op == '+' then
                value = value + operand
            elseif op == '-' then
                value = value - operand
            elseif op == '.' then
                value = value .. operand
            end
        end
        
        if value == 100 then
            print('Path', i, table.concat(path), value)
        end
    end

    -- I know this is wrong too
    -- The concatantion doesn't work correctly
    -- e.g.  1.2 - 3.4  is doing something stupid like ((1.2) - 3) . 4
    --       Rather than (1.2) - (3.4)
    --
    -- Fine, I'm an idiot
end

