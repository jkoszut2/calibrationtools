%% Use to look at data for one fuel map point
%Example: findvalues(Data_Table,8000,0.8)
function values = findvalues(data,rpm,map)
    Fuelx = [0,500,1000,1250,1500,1630,1750,1880,2000,2250,2500,2750,3000,3500,4000,4500,5000,5500,6000,6500,6750,7000,7250,7500,7750,8000,8500,9000,9500,10000,10500,11000,11500,12000,12500,13000,13500,14000,14500,15000];
    Fuely = [0,0.100000000000000,0.200000000000000,0.300000000000000,0.400000000000000,0.500000000000000,0.550000000000000,0.600000000000000,0.650000000000000,0.700000000000000,0.750000000000000,0.800000000000000,0.850000000000000,0.870000000000000,0.900000000000000,0.920000000000000,0.930000000000000,0.940000000000000,0.950000000000000,0.970000000000000,0.980000000000000,0.990000000000000,1];
    rpm_coordinate = find(Fuelx==rpm) + 1;
    map_coordinate = find(Fuely==map);
    coordinates = [rpm_coordinate map_coordinate]
    values = data{coordinates(2), coordinates(1), 2};
    header = {'New IJPU','New Fuel Table','New Fuel Table2','k','Lambda','Target','IJPU','FBPW','FEPW','RPM','MAP','Time'};
    values = [header; num2cell(values)];
end