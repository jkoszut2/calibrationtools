floor = 20;
count = 0;
for i = 2:length(Fuelx)
    for j = 1:length(Fuely)
        DataMatrix = Data_Table{j,i,2};
        Size_DataMatrix = size(DataMatrix);
        rows_DataMatrix = Size_DataMatrix(1);
        if rows_DataMatrix > floor
            count = count + 1;
        end
    end
end

n = sqrt(count);
n = n+0.5;
n = round(n,0);
subplotcounter = 1;
for i = 2:length(Fuelx)
    for j = 1:length(Fuely)
        DataMatrix = Data_Table{j,i,2};
        Size_DataMatrix = size(DataMatrix);
        rows_DataMatrix = Size_DataMatrix(1);
            if rows_DataMatrix > floor
                subplot(n,n,subplotcounter)
                plot(1:rows_DataMatrix,DataMatrix(:,1),1:rows_DataMatrix,DataMatrix(:,3));
                name_title = char(strcat(num2str(Fuelx(i-1)),{' '},{'rpm'},{' '},num2str(Fuely(j)),{' '},{'bar'}));
                title(name_title)
                subplotcounter = subplotcounter + 1;
                grid on
            end
    end
end

set(gcf, 'position', [1 42 1400 645]);
