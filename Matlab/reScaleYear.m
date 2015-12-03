% =========================================================================
% This function converts the value between 0 to 1 to the year ranging from
% 1937 to 2014
% =========================================================================
% @param year: the year value that would be scaled
% =========================================================================
% @retval scaled_year: year value in the range from 0 to 1

function scaled_year = reScaleYear(years)

original_max = max(years);
original_min = min(years);
new_max = 2014;
new_min = 1937;
scaled_year = ((( years - original_min) * (new_max - new_min)) / (original_max - original_min)) + new_min;

end