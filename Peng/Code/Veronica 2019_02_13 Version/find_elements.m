%% Find Valid Elements
function locs = find_elements(array);
    nonzero_locs = find(array ~= 0);
    num_locs = find(~isnan(array));
    locs = intersect(nonzero_locs,num_locs);  
end
