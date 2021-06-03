function new_array = remove_outliers(array)
    if length(array)>2
        array_iupper = find(array<mean(array)+std(array));
        array_ilower = find(array>mean(array)-std(array));
        array_i = intersect(array_iupper,array_ilower);
        new_array = array(array_i);
    elseif length(array) == 2 %outliers undefined for 2 values
        new_array = [mean(array), std(array)];
    elseif and(array ~= 0,~isnan(array)) % single value case
        new_array = [array,0];
    else % catch case for NaNs
        new_array = [0,0];
    end
end