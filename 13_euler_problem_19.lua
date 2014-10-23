-- Description: Project Euler problem 19 - Dates, loop, and leapyears --

--[[

You are given the following information, but you may prefer to do some research for yourself.

1 Jan 1900 was a Monday.
Thirty days has September,
April, June and November.
All the rest have thirty-one,
Saving February alone,
Which has twenty-eight, rain or shine.
And on leap years, twenty-nine.
A leap year occurs on any year evenly divisible by 4, but not on a century unless it is divisible by 400.
How many Sundays fell on the first of the month during the twentieth century (1 Jan 1901 to 31 Dec 2000)?

--------------------------------

The mistakes I made were related to reading the text incorrectly:
  * 1900-01-01 was monday, but start counting from 1901-01-01
  * Sundays on the first of any month (not sundays in the first month)

I'm not sure if I'm really learning anything doing these puzzles.  The stdlib
is often isn't not helpful for Project Euler puzzles and they test problem 
solving skills more than programming.

Might have to try rewritting some of my old programs in lua for something
more realistic.

]]


local isleapyear = function(year)
    if year % 4 ~= 0 then return false end
    if year % 400 == 0 then return true end
    if year % 100 == 0 then return false end
    return true
end


local daysinmonth = function(month, year)
    local days = {
        31, -- jan
        28, -- feb
        31, -- mar
        30, -- april
        31, -- may
        30, -- june
        31, -- july
        31, -- agust
        30, -- sept
        31, -- oct
        30, -- nov
        31, -- dec
    }
    
    if isleapyear(year) then
        days[2] = 29
    end
    
    return days[month]
end
    
    
local problem19 = function()
    local day = 1
    local month = 1
    local year = 1900
    local dayofweek = 1
    local sundaysonfirstofmonth = 0
    
    while true do
        
        -- Last day of a month?
        if day+1 > daysinmonth(month, year) then
            day = 1
            
            -- end of the year too?
            if month+1 > 12 then
                year = year + 1
                month = 1
            else
                month = month + 1
            end
        else
            day = day + 1
        end
        
        dayofweek = dayofweek + 1
        
        -- wrap the days around
        if dayofweek == 8 then dayofweek = 1 end
        
        if year == 2001 then break end
        
        -- print(string.format('%d-%d-%d is %d', year, month, day, dayofweek))
        if year > 1900 and day == 1 and dayofweek == 7 then 
            sundaysonfirstofmonth = sundaysonfirstofmonth + 1 
        end
    end
    
    return sundaysonfirstofmonth
end


print('Number of sundays on the first of then month from 1900-01-01 to 2001-12-31', problem19())