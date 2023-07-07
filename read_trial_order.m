function blockType=read_trial_order(HomeDir,parNo,numBlocks);

RandomDir = fullfile(HomeDir, 'Random/'); %reading pseudo randomized trial order. 
file1 = dir([char(RandomDir),'P',num2str(parNo),'_randomList_run*.mat']);
file2 = dir([char(RandomDir),'P',num2str(parNo+21),'_randomList_run*.mat']);
file3 = dir([char(RandomDir),'P',num2str(parNo+42),'_randomList_run*.mat']);
TotalrandomList=[];
for i=1:numBlocks
    if i<7
        TotalrandomList{i}=load([file1(1).folder '/' file1(i).name]);
    elseif 6<i  &&  i <13
        TotalrandomList{i}=load([file2(1).folder '/' file2(i-6).name]);
    else
        TotalrandomList{i}=load([file3(1).folder '/' file3(i-12).name]);
    end
end
blockType=[]; blockType1=[];
for i=1:numBlocks
    findR=(TotalrandomList{1,i}.randomList(:,1)>3);
    blockType{i}=zeros(length(TotalrandomList{1,i}.randomList(:,1)),2);
    for k=1:length(findR)
        if findR(k)==1
            blockType1{i}(k,:) = [TotalrandomList{1,i}.randomList(k,1) TotalrandomList{1,i}.randomList(k,2)-13];
        else
            blockType1{i}(k,:) = [TotalrandomList{1,i}.randomList(k,1) TotalrandomList{1,i}.randomList(k,2)];
        end
        blockType{i} = [blockType1{i}];
    end
end
end