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
trainingDataTbl = pedestrianDataset(:,:);
imdsTrain = imageDatastore(trainingDataTbl{:,'imageFilename'});
bldsTrain = boxLabelDatastore(trainingDataTbl(:,'vehicle'));

% 이미지 데이터, 라벨 데이터 합치기
trainingData = combine(imdsTrain, bldsTrain);



inputSize = [224 224 3];
numClasses = width(pedestrianDataset)-1;
trainingDataForEstimation = transform(trainingData,@(data)preprocessData(data,inputSize));
numAnchors = 7;
[anchorBoxes, meanIoU] = estimateAnchorBoxes(trainingDataForEstimation, numAnchors);


featureExtractionNetwork = resnet50;
featureLayer = 'activation_40_relu';
lgraph = yolov2Layers(inputSize, numClasses, anchorBoxes,featureExtractionNetwork,featureLayer);


preprocessedTrainingData = transform(trainingData, @(data)preprocessData(data,inputSize));
data = read(preprocessedTrainingData)
I = data{1};
bbox = data{2};
annotatedImage = insertShape(I, 'Rectangle',bbox);
annotatedImage = imresize(annotatedImage, 2);
figure
imshow(annotatedImage);

options = trainingOptions('sgdm',...
          'InitialLearnRate',0.001,...
          'Verbose',true,...
          'MiniBatchSize',16,...
          'MaxEpochs',20,...
          'Shuffle','never',...
          'VerboseFrequency',30,...
          'CheckpointPath',tempdir);
 disp("Training Start")     
[detector, info] = trainYOLOv2ObjectDetector(preprocessedTrainingData, lgraph, options);
