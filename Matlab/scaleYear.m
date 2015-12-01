% =========================================================================
% This function scale the year value into the range from 0 to 1
% =========================================================================
% @param year: the year value that would be scaled
% =========================================================================
% @retval scaled_year: year value in the range from 0 to 1

function scaled_year = scaleYear(year)
years = cell2mat(year);
original_max = max(years);
original_min = min(years);
new_max = 1;
new_min = 0;
scaled_year = ((( years - original_min) * (new_max - new_min)) / (original_max - original_min)) + new_min;

end