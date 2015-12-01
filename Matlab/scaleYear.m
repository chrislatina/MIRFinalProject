function scaled_year = scaleYear(year, original_max, original_min, new_max, new_min)
scaled_year = ((( year - original_min) * (new_max - new_min)) / (original_max - original_min)) + new_min;

end