clc
clear

% 데이터셋 불러오기
data = load('pedestrianDataset.mat');
pedestrianDataset = data.newTable;

% 상대경로를 절대경로로 변환
pedestrianDataset.imageFilename = fullfile(pwd, pedestrianDataset.imageFilename);

% 라벨 규칙 변경
% 기존 데이터셋은 [Xmin Ymin Xmax Ymax] 형식
% 매트랩 형식은 [Xmin, Ymin, width. height] 형식
for jj = 1:height(pedestrianDataset.vehicle)
    a = pedestrianDataset.vehicle{jj};
    buff = zeros(1,4);
    
    for ii = 1:height(a)
        tmp = [a(ii,1), a(ii,2), a(ii,3)-a(ii,1), a(ii,4)-a(ii,2)];
        buff = [buff; tmp;];
    end
    
    buff(1,:) = [];
    pedestrianDataset.vehicle{jj} = buff;
end

% 이미지 스토어, 라벨 스토어 자료형 선언
imdsTrain = imageDatastore(pedestrianDataset{:,'imageFilename'});
bldsTrain = boxLabelDatastore(pedestrianDataset(:,'vehicle'));

% 이미지 데이터, 라벨 데이터 합치기
trainingData = combine(imdsTrain, bldsTrain);

% trainingData 에 있는 데이터 1개 읽어오고 figure 창에 라벨과 함께 띄우기
data = read(trainingData);

I = data{1};
bbox = data{2};
annotatedImage = insertShape(I, 'Rectangle',bbox);
annotatedImage = imresize(annotatedImage, 2);
figure
imshow(annotatedImage);


