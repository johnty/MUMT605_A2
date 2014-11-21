function [ out ] = getTimeStartEnd(in, t_start, t_end)
%GETTIMETOFROM Summary of this function goes here
%   Detailed explanation goes here

len = t_end-t_start+1;
out = zeros(1, len);

if t_start <= 0
    out(1:1-t_start) = 0;
    out(2-t_start:len) = in(1:len-(1-t_start));
else
    out = in(t_start:t_end);
end

